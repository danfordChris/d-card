import { event, eventPlan, invitation, payment, plan, pledge } from "@dcard/db";
import { and, asc, desc, eq, sql } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole } from "../auth/roles.js";
import { issueInvitationInTx } from "../cards/cards.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { ConflictError, NotFoundError, ValidationError } from "../errors.js";
import { enqueueMessage } from "../messaging/outbox.js";
import { addGuestInTx, assertEventOpen, ConsentRequiredError, recordConsent, type CardType } from "../guests/guests.js";

// docs/design/features/contributions.md (Workflow: Contribution to Card, CON-1..12).
// Roles: host + committee add contributors; host + treasurers record payments and edit
// pledges; host, committee and treasurers see amounts (CON-12).

export type PaymentMethod = "mpesa" | "mixx_by_yas" | "airtel_money" | "halopesa" | "bank" | "cash" | "other";
export type PledgeStatus = "not_paid" | "part_paid" | "fully_paid";

const ADD = ["committee"] as const;
const PAY = ["treasurer"] as const;
const READ = ["committee", "treasurer"] as const;
const MAX_AMOUNT = 100_000_000;

export type PledgeView = {
  id: string;
  guestId: string;
  name: string;
  phone: string;
  partnerName: string | null;
  cardType: CardType;
  amountPledged: number;
  amountPaid: number;
  amountExtra: number;
  balance: number;
  status: PledgeStatus;
  upgradedAt: Date | null;
  invitationStatus: "pending" | "issued" | "cancelled";
  cardNumber: string | null;
};

export type PaymentView = {
  id: string;
  kind: "payment" | "refund";
  amount: number;
  method: PaymentMethod;
  reference: string | null;
  paidOn: string;
  recordedBy: string | null;
  recordedAt: Date;
};

type PledgeRow = typeof pledge.$inferSelect;
type InvitationRow = typeof invitation.$inferSelect;

function toView(p: PledgeRow, i: InvitationRow): PledgeView {
  return {
    id: p.id,
    guestId: i.id,
    name: i.guestName,
    phone: i.guestPhone,
    partnerName: i.partnerName,
    cardType: p.cardType,
    amountPledged: p.amountPledged,
    amountPaid: p.amountPaid,
    amountExtra: p.amountExtra,
    balance: Math.max(0, p.amountPledged - p.amountPaid),
    status: p.status,
    upgradedAt: p.upgradedAt,
    invitationStatus: i.status,
    cardNumber: i.cardNumber,
  };
}

function toPaymentView(r: typeof payment.$inferSelect): PaymentView {
  return {
    id: r.id,
    kind: r.kind,
    amount: r.amount,
    method: r.method,
    reference: r.reference,
    paidOn: r.paidOn,
    recordedBy: r.recordedBy,
    recordedAt: r.recordedAt,
  };
}

function checkAmount(value: number, path: string): number {
  if (!Number.isInteger(value) || value <= 0 || value > MAX_AMOUNT) {
    throw new ValidationError("Some fields are invalid.", [{ path, message: "Enter a whole amount in TZS above 0." }]);
  }
  return value;
}

function checkDate(value: string, path = "paidOn"): string {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value) || Number.isNaN(Date.parse(`${value}T00:00:00Z`))) {
    throw new ValidationError("Some fields are invalid.", [{ path, message: "Use YYYY-MM-DD." }]);
  }
  return value;
}

const statusFor = (paid: number, pledged: number): PledgeStatus => (paid <= 0 ? "not_paid" : paid < pledged ? "part_paid" : "fully_paid");

async function lockPledge(tx: DbExecutor, eventId: string, pledgeId: string) {
  const [row] = await tx
    .select()
    .from(pledge)
    .where(and(eq(pledge.id, pledgeId), eq(pledge.eventId, eventId)))
    .for("update");
  if (!row) throw new NotFoundError("Pledge not found.");
  const [inv] = await tx.select().from(invitation).where(eq(invitation.id, row.invitationId)).for("update");
  return { pledge: row, invitation: inv! };
}

async function autoUpgradeAllowed(tx: DbExecutor, eventId: string): Promise<{ allowed: boolean; doubleAmount: number | null }> {
  const [row] = await tx
    .select({ enabled: event.autoUpgradeEnabled, doubleAmount: event.doubleAmount, entitlements: plan.entitlements })
    .from(event)
    .innerJoin(eventPlan, eq(eventPlan.eventId, event.id))
    .innerJoin(plan, eq(plan.id, eventPlan.planId))
    .where(eq(event.id, eventId));
  return { allowed: Boolean(row?.enabled && row.entitlements.autoUpgrade), doubleAmount: row?.doubleAmount ?? null };
}

/**
 * Recomputes paid/extra/status from the payment records, then applies the design's rules
 * in order: (1) auto-upgrade Single → Double before issue, (2) auto-issue when paid ≥ pledge.
 * Manual pledge edits skip rule 1 so a host's Double → Single change is not undone.
 */
async function settle(tx: DbExecutor, actorId: string, eventId: string, pledgeId: string, opts: { allowUpgrade: boolean }) {
  const { pledge: p, invitation: inv } = await lockPledge(tx, eventId, pledgeId);
  const [{ paid }] = (await tx
    .select({ paid: sql<number>`coalesce(sum(${payment.amount}), 0)::int` })
    .from(payment)
    .where(eq(payment.pledgeId, pledgeId))) as [{ paid: number }];
  let amountPledged = p.amountPledged;
  let cardType = p.cardType;
  let upgradedAt = p.upgradedAt;
  if (opts.allowUpgrade && inv.status === "pending" && cardType === "single") {
    const rule = await autoUpgradeAllowed(tx, eventId);
    if (rule.allowed && rule.doubleAmount !== null && paid >= rule.doubleAmount) {
      const old = { cardType, amountPledged };
      cardType = "double";
      amountPledged = Math.max(amountPledged, rule.doubleAmount);
      upgradedAt = new Date();
      await tx.update(invitation).set({ cardType: "double", totalEntries: 2 }).where(eq(invitation.id, inv.id));
      await recordAudit(tx, {
        actorUserId: actorId,
        eventId,
        action: "pledge.auto_upgraded",
        targetType: "pledge",
        targetId: p.id,
        oldValue: old,
        newValue: { cardType, amountPledged },
      });
      // NTF-5: card upgraded to Double.
      await enqueueMessage(tx, { key: `card_upgraded:${p.id}`, eventId, invitationId: inv.id, messageType: "card_upgraded" });
    }
  }
  await tx
    .update(pledge)
    .set({
      amountPledged,
      cardType,
      upgradedAt,
      amountPaid: paid,
      amountExtra: Math.max(0, paid - amountPledged),
      status: statusFor(paid, amountPledged),
    })
    .where(eq(pledge.id, p.id));
  if (inv.status === "pending" && paid >= amountPledged) {
    await issueInvitationInTx(tx, { actorId, eventId, guestId: inv.id, reason: "fully_paid" });
  }
  return loadPledgeView(tx, eventId, p.id);
}

async function loadPledgeView(db: DbExecutor, eventId: string, pledgeId: string): Promise<PledgeView> {
  const [row] = await db
    .select({ p: pledge, i: invitation })
    .from(pledge)
    .innerJoin(invitation, eq(invitation.id, pledge.invitationId))
    .where(and(eq(pledge.id, pledgeId), eq(pledge.eventId, eventId)));
  if (!row) throw new NotFoundError("Pledge not found.");
  return toView(row.p, row.i);
}

/** CON-1: add a contributor (reuses the invitation for an existing phone, GST-2). */
export async function addContributor(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  input: { name: string; phone: string; cardType?: CardType; partnerName?: string | null; amount: number; consent: boolean },
): Promise<{ pledge: PledgeView; existingGuest: boolean }> {
  await requireEventRole(db, { userId: actorId, eventId, roles: ADD });
  if (!input.consent) throw new ConsentRequiredError();
  const amount = checkAmount(input.amount, "amount");
  await assertEventOpen(db, eventId);
  return inTransaction(db, async (tx) => {
    const { guest, existing } = await addGuestInTx(tx, actorId, eventId, input);
    if (!existing) await recordConsent(tx, { eventId, actorId, source: "form", guestCount: 1 });
    const [taken] = await tx.select({ id: pledge.id }).from(pledge).where(eq(pledge.invitationId, guest.id));
    if (taken) throw new ConflictError("This guest already has a pledge.");
    let cardType: CardType = guest.cardType;
    if (existing && guest.status === "pending" && input.cardType && input.cardType !== guest.cardType) {
      cardType = input.cardType;
      await tx
        .update(invitation)
        .set({ cardType, totalEntries: cardType === "double" ? 2 : 1 })
        .where(eq(invitation.id, guest.id));
    }
    const [created] = await tx.insert(pledge).values({ eventId, invitationId: guest.id, amountPledged: amount, cardType, createdBy: actorId }).returning();
    await recordAudit(tx, {
      actorUserId: actorId,
      eventId,
      action: "pledge.created",
      targetType: "pledge",
      targetId: created!.id,
      newValue: { guestId: guest.id, amountPledged: amount, cardType },
    });
    // NTF-1: contribution request with the committee's payment details.
    await enqueueMessage(tx, {
      key: `contribution_request:${created!.id}`,
      eventId,
      invitationId: guest.id,
      messageType: "contribution_request",
      payload: { pledge_amount: amount },
    });
    return { pledge: await loadPledgeView(tx, eventId, created!.id), existingGuest: existing };
  });
}

/** CON-2/CON-7: record a payment or a refund (entered as a positive amount). */
export async function recordPayment(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  pledgeId: string,
  input: { kind?: "payment" | "refund"; amount: number; method: PaymentMethod; reference?: string | null; paidOn: string },
): Promise<{ pledge: PledgeView; payment: PaymentView }> {
  await requireEventRole(db, { userId: actorId, eventId, roles: PAY });
  const kind = input.kind ?? "payment";
  const amount = checkAmount(input.amount, "amount");
  const paidOn = checkDate(input.paidOn);
  return inTransaction(db, async (tx) => {
    const { pledge: p } = await lockPledge(tx, eventId, pledgeId);
    if (kind === "refund" && amount > p.amountPaid) {
      throw new ValidationError("A refund cannot be more than the amount paid.", [{ path: "amount", message: "More than paid." }]);
    }
    const [created] = await tx
      .insert(payment)
      .values({
        eventId,
        pledgeId,
        kind,
        amount: kind === "refund" ? -amount : amount,
        method: input.method,
        reference: input.reference?.trim() || null,
        paidOn,
        recordedBy: actorId,
      })
      .returning();
    await recordAudit(tx, {
      actorUserId: actorId,
      eventId,
      action: kind === "refund" ? "refund.recorded" : "payment.recorded",
      targetType: "payment",
      targetId: created!.id,
      newValue: { pledgeId, amount: created!.amount, method: created!.method, reference: created!.reference, paidOn },
    });
    const view = await settle(tx, actorId, eventId, pledgeId, { allowUpgrade: kind === "payment" });
    if (kind === "payment") {
      // NTF-2: thank-you with the totals as they are after this payment.
      await enqueueMessage(tx, {
        key: `thank_you:${created!.id}`,
        eventId,
        invitationId: view.guestId,
        messageType: "thank_you",
        payload: { amount_paid: view.amountPaid, balance: view.balance },
      });
    }
    return { pledge: view, payment: toPaymentView(created!) };
  });
}

/** CON-11: correct a payment record (audited with old and new values). */
export async function updatePayment(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  paymentId: string,
  input: { amount?: number; method?: PaymentMethod; reference?: string | null; paidOn?: string },
): Promise<{ pledge: PledgeView; payment: PaymentView }> {
  await requireEventRole(db, { userId: actorId, eventId, roles: PAY });
  return inTransaction(db, async (tx) => {
    const [row] = await tx
      .select()
      .from(payment)
      .where(and(eq(payment.id, paymentId), eq(payment.eventId, eventId)))
      .for("update");
    if (!row) throw new NotFoundError("Payment not found.");
    const sign = row.kind === "refund" ? -1 : 1;
    const next = {
      amount: input.amount !== undefined ? sign * checkAmount(input.amount, "amount") : row.amount,
      method: input.method ?? row.method,
      reference: input.reference !== undefined ? input.reference?.trim() || null : row.reference,
      paidOn: input.paidOn !== undefined ? checkDate(input.paidOn) : row.paidOn,
    };
    const [updated] = await tx.update(payment).set(next).where(eq(payment.id, row.id)).returning();
    await recordAudit(tx, {
      actorUserId: actorId,
      eventId,
      action: "payment.updated",
      targetType: "payment",
      targetId: row.id,
      oldValue: { amount: row.amount, method: row.method, reference: row.reference, paidOn: row.paidOn },
      newValue: next,
    });
    const view = await settle(tx, actorId, eventId, row.pledgeId, { allowUpgrade: row.kind === "payment" });
    if (view.amountPaid < 0) throw new ValidationError("Refunds would be more than the amount paid.", [{ path: "amount", message: "Too large." }]);
    return { pledge: view, payment: toPaymentView(updated!) };
  });
}

/** CON-5a: host/treasurer change amount and card type before issue; issues if already covered. */
export async function updatePledge(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  pledgeId: string,
  input: { amount?: number; cardType?: CardType },
): Promise<PledgeView> {
  await requireEventRole(db, { userId: actorId, eventId, roles: PAY });
  return inTransaction(db, async (tx) => {
    const { pledge: p, invitation: inv } = await lockPledge(tx, eventId, pledgeId);
    if (inv.status !== "pending") throw new ConflictError("A pledge can only be changed before the card is issued.");
    const next = {
      amountPledged: input.amount !== undefined ? checkAmount(input.amount, "amount") : p.amountPledged,
      cardType: input.cardType ?? p.cardType,
    };
    await tx.update(pledge).set(next).where(eq(pledge.id, p.id));
    if (next.cardType !== inv.cardType) {
      await tx
        .update(invitation)
        .set({ cardType: next.cardType, totalEntries: next.cardType === "double" ? 2 : 1, partnerName: next.cardType === "single" ? null : inv.partnerName })
        .where(eq(invitation.id, inv.id));
    }
    const auditId = await recordAudit(tx, {
      actorUserId: actorId,
      eventId,
      action: "pledge.updated",
      targetType: "pledge",
      targetId: p.id,
      oldValue: { amountPledged: p.amountPledged, cardType: p.cardType },
      newValue: next,
    });
    const view = await settle(tx, actorId, eventId, p.id, { allowUpgrade: false });
    // Rule 9: the contributor gets the updated balance (the card message covers a fully paid pledge).
    if (view.balance > 0) {
      await enqueueMessage(tx, {
        key: `pledge_updated:${auditId}`,
        eventId,
        invitationId: view.guestId,
        messageType: "contribution_reminder",
        payload: { balance: view.balance },
      });
    }
    return view;
  });
}

export type ContributionSummary = {
  pledged: number;
  collected: number;
  outstanding: number;
  extras: number;
  refunds: number;
  budget: number | null;
  counts: Record<PledgeStatus | "cancelled", number>;
};

/** CON-9 dashboard data: totals and contributors, newest first. Cancelled cards' payments still count. */
export async function getContributions(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  params: { status?: PledgeStatus | "cancelled"; q?: string } = {},
): Promise<{ summary: ContributionSummary; contributors: PledgeView[] }> {
  await requireEventRole(db, { userId: actorId, eventId, roles: READ });
  const rows = await db
    .select({ p: pledge, i: invitation })
    .from(pledge)
    .innerJoin(invitation, eq(invitation.id, pledge.invitationId))
    .where(eq(pledge.eventId, eventId))
    .orderBy(desc(pledge.createdAt), desc(pledge.id));
  const [refundRow] = (await db
    .select({ refunds: sql<number>`coalesce(-sum(${payment.amount}), 0)::int` })
    .from(payment)
    .where(and(eq(payment.eventId, eventId), eq(payment.kind, "refund")))) as [{ refunds: number }];
  const [ev] = await db.select({ budget: event.budgetAmount }).from(event).where(eq(event.id, eventId));
  const views = rows.map((r) => toView(r.p, r.i));
  const active = views.filter((v) => v.invitationStatus !== "cancelled");
  const summary: ContributionSummary = {
    pledged: active.reduce((a, v) => a + v.amountPledged, 0),
    collected: views.reduce((a, v) => a + v.amountPaid, 0),
    outstanding: active.reduce((a, v) => a + v.balance, 0),
    extras: views.reduce((a, v) => a + v.amountExtra, 0),
    refunds: refundRow.refunds,
    budget: ev?.budget ?? null,
    counts: { not_paid: 0, part_paid: 0, fully_paid: 0, cancelled: 0 },
  };
  for (const v of views) summary.counts[v.invitationStatus === "cancelled" ? "cancelled" : v.status]++;
  const q = params.q?.trim().toLowerCase();
  const digits = q?.replace(/\D/g, "").replace(/^0/, "") ?? "";
  const contributors = views.filter((v) => {
    const st = v.invitationStatus === "cancelled" ? "cancelled" : v.status;
    if (params.status && st !== params.status) return false;
    if (q && !v.name.toLowerCase().includes(q) && !(digits.length >= 3 && v.phone.includes(digits))) return false;
    return true;
  });
  return { summary, contributors };
}

/** One contributor with payment history (oldest first). */
export async function getPledge(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  pledgeId: string,
): Promise<{ pledge: PledgeView; payments: PaymentView[] }> {
  await requireEventRole(db, { userId: actorId, eventId, roles: READ });
  const view = await loadPledgeView(db, eventId, pledgeId);
  const payments = await db.select().from(payment).where(eq(payment.pledgeId, pledgeId)).orderBy(asc(payment.paidOn), asc(payment.recordedAt));
  return { pledge: view, payments: payments.map(toPaymentView) };
}

import {
  billingSetting,
  event,
  eventPlan,
  hostPayment,
  invitation,
  paymentAttempt,
  plan,
  pledge,
  userAccount,
  webhookEvent,
} from "@dcard/db";
import { and, asc, desc, eq, gte, ne, sql } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole } from "../auth/roles.js";
import { issueInvitationInTx } from "../cards/cards.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { requireAdmin } from "../admin/event-types/event-types.js";
import { NotFoundError, ValidationError } from "../errors.js";
import { BillingError } from "./gate.js";
import { normalisePhone } from "../phone/phone.js";
import { PaymentProviderError, type PaymentGateway, type ProviderStatus } from "./gateway.js";

// Host payments for guest cards (docs/design/features/plans-and-billing.md):
// flat price per card; minimum Tsh 50,000 per event; extra guests in blocks of 10; upgrades pay
// the per-card difference for every paid card; launch offer on the host's first event; full
// payment before any card is issued or guest message is sent.

export const MINIMUM_CHARGE = 50_000;
export const BLOCK_SIZE = 10;
/** Snippe expires unpaid payments after 4 h; we stop polling a little later. */
const PENDING_LIFETIME_MS = 4 * 60 * 60 * 1000 + 15 * 60 * 1000;
/** A new checkout is refused while a recent one is still pending (the USSD prompt may be open). */
const IN_PROGRESS_MS = 10 * 60 * 1000;

export type QuoteLine = { code: "new_cards" | "extra_cards" | "upgrade"; quantity: number; unitPrice: number; amount: number };
export type BillingQuote = {
  planKey: string;
  planName: string;
  pricePerGuest: number;
  currentGuestCards: number;
  guestCards: number;
  blockSize: number;
  minimumCharge: number;
  lines: QuoteLine[];
  subtotal: number;
  discountPercent: number;
  discountAmount: number;
  total: number;
  payable: boolean;
};

type PlanRow = typeof plan.$inferSelect;

async function loadEventBilling(db: DbExecutor, eventId: string) {
  const [row] = await db
    .select({ ep: eventPlan, plan, ev: event })
    .from(eventPlan)
    .innerJoin(plan, eq(plan.id, eventPlan.planId))
    .innerJoin(event, eq(event.id, eventPlan.eventId))
    .where(eq(eventPlan.eventId, eventId));
  if (!row) throw new NotFoundError("Event not found.");
  return row;
}

export async function getBillingSettings(db: DbExecutor): Promise<{ launchOfferEnabled: boolean; launchOfferPercent: number }> {
  const [row] = await db.select().from(billingSetting).where(eq(billingSetting.id, 1));
  return { launchOfferEnabled: row?.launchOfferEnabled ?? true, launchOfferPercent: row?.launchOfferPercent ?? 20 };
}

/** Launch offer: the host's first event, i.e. no completed payment for any other event. */
async function launchOfferPercent(db: DbExecutor, hostUserId: string, eventId: string): Promise<number> {
  const settings = await getBillingSettings(db);
  if (!settings.launchOfferEnabled || settings.launchOfferPercent <= 0) return 0;
  const [other] = await db
    .select({ id: hostPayment.id })
    .from(hostPayment)
    .where(and(eq(hostPayment.hostUserId, hostUserId), ne(hostPayment.eventId, eventId)))
    .limit(1);
  return other ? 0 : settings.launchOfferPercent;
}

/** Pure pricing rules (unit-tested). */
export function priceQuote(params: {
  current: { pricePerGuest: number; guestLimit: number };
  target: { pricePerGuest: number };
  guestCards: number;
  discountPercent: number;
}): Omit<BillingQuote, "planKey" | "planName"> {
  const { current, target } = params;
  const paid = current.guestLimit;
  const lines: QuoteLine[] = [];
  let cards: number;
  if (paid === 0) {
    // First purchase: at least the minimum charge (e.g. 50 cards on Msingi).
    const minCards = Math.ceil(MINIMUM_CHARGE / target.pricePerGuest);
    cards = Math.max(params.guestCards, minCards);
    lines.push({ code: "new_cards", quantity: cards, unitPrice: target.pricePerGuest, amount: cards * target.pricePerGuest });
  } else {
    if (params.guestCards < paid) throw new ValidationError(`You have already paid for ${paid} cards.`, [{ path: "guestCards", message: `At least ${paid}.` }]);
    if (target.pricePerGuest < current.pricePerGuest) {
      throw new ValidationError("A paid plan cannot be downgraded.", [{ path: "planKey", message: "Choose the same or a higher plan." }]);
    }
    const extra = Math.ceil((params.guestCards - paid) / BLOCK_SIZE) * BLOCK_SIZE;
    cards = paid + extra;
    const diff = target.pricePerGuest - current.pricePerGuest;
    if (diff > 0) lines.push({ code: "upgrade", quantity: paid, unitPrice: diff, amount: paid * diff });
    if (extra > 0) lines.push({ code: "extra_cards", quantity: extra, unitPrice: target.pricePerGuest, amount: extra * target.pricePerGuest });
  }
  const subtotal = lines.reduce((n, l) => n + l.amount, 0);
  const discountAmount = Math.floor((subtotal * params.discountPercent) / 100);
  const total = subtotal - discountAmount;
  return {
    pricePerGuest: target.pricePerGuest,
    currentGuestCards: paid,
    guestCards: cards,
    blockSize: BLOCK_SIZE,
    minimumCharge: MINIMUM_CHARGE,
    lines,
    subtotal,
    discountPercent: subtotal > 0 ? params.discountPercent : 0,
    discountAmount,
    total,
    payable: total > 0,
  };
}

async function buildQuote(db: DbExecutor, eventId: string, hostUserId: string, input: { planKey?: string | null; guestCards: number }): Promise<{ quote: BillingQuote; target: PlanRow }> {
  const b = await loadEventBilling(db, eventId);
  let target: PlanRow = b.plan;
  if (input.planKey && input.planKey !== b.plan.key) {
    const [p] = await db.select().from(plan).where(and(eq(plan.key, input.planKey), eq(plan.active, true)));
    if (!p) throw new ValidationError("Unknown plan.", [{ path: "planKey", message: "Unknown plan." }]);
    target = p;
  }
  // Before the first payment the host may still switch plans freely (nothing paid yet).
  const current = b.ep.guestLimit > 0 ? { pricePerGuest: b.ep.pricePerGuest, guestLimit: b.ep.guestLimit } : { pricePerGuest: target.pricePerGuest, guestLimit: 0 };
  const targetPrice = target.id === b.plan.id && b.ep.guestLimit > 0 ? b.ep.pricePerGuest : target.pricePerGuest;
  const discountPercent = await launchOfferPercent(db, hostUserId, eventId);
  const priced = priceQuote({ current, target: { pricePerGuest: targetPrice }, guestCards: input.guestCards, discountPercent });
  return { quote: { planKey: target.key, planName: target.name, ...priced }, target };
}

export async function quoteBilling(db: DbExecutor, userId: string, eventId: string, input: { planKey?: string | null; guestCards: number }): Promise<BillingQuote> {
  await requireEventRole(db, { userId, eventId, roles: [] });
  return (await buildQuote(db, eventId, userId, input)).quote;
}

type AttemptRow = typeof paymentAttempt.$inferSelect;

export function attemptView(a: AttemptRow, planKey: string) {
  return {
    id: a.id,
    status: a.status,
    method: a.method,
    amount: a.amount,
    planKey,
    guestCards: a.guestCards,
    phone: a.phone,
    checkoutUrl: a.checkoutUrl,
    reference: a.providerReference,
    failureReason: a.failureReason,
    createdAt: a.createdAt,
    completedAt: a.completedAt,
  };
}

async function planKeyOf(db: DbExecutor, planId: string): Promise<string> {
  const [p] = await db.select({ key: plan.key }).from(plan).where(eq(plan.id, planId));
  return p?.key ?? "";
}

export async function getBilling(db: DbExecutor, userId: string, eventId: string) {
  await requireEventRole(db, { userId, eventId, roles: [] });
  const b = await loadEventBilling(db, eventId);
  const [counts] = await db
    .select({
      issued: sql<number>`count(*) filter (where ${invitation.status} = 'issued')::int`,
      guests: sql<number>`count(*) filter (where ${invitation.status} <> 'cancelled')::int`,
    })
    .from(invitation)
    .where(eq(invitation.eventId, eventId));
  const payments = await db
    .select({ p: hostPayment, key: plan.key })
    .from(hostPayment)
    .innerJoin(plan, eq(plan.id, hostPayment.planId))
    .where(eq(hostPayment.eventId, eventId))
    .orderBy(desc(hostPayment.paidAt));
  const [pending] = await db
    .select()
    .from(paymentAttempt)
    .where(and(eq(paymentAttempt.eventId, eventId), eq(paymentAttempt.status, "pending")))
    .orderBy(desc(paymentAttempt.createdAt))
    .limit(1);
  const percent = await launchOfferPercent(db, userId, eventId);
  return {
    planKey: b.plan.key,
    planName: b.plan.name,
    pricePerGuest: b.ep.guestLimit > 0 ? b.ep.pricePerGuest : b.plan.pricePerGuest,
    guestLimit: b.ep.guestLimit,
    amountPaid: b.ep.amountPaid,
    paid: b.ep.guestLimit > 0,
    issuedCards: counts?.issued ?? 0,
    guestCount: counts?.guests ?? 0,
    launchOfferPercent: percent,
    launchOfferEligible: percent > 0,
    pendingAttempt: pending ? attemptView(pending, await planKeyOf(db, pending.planId)) : null,
    payments: payments.map(({ p, key }) => ({
      id: p.id,
      planKey: key,
      guestCards: p.guestCards,
      amount: p.amount,
      discountAmount: p.discountAmount,
      method: p.method,
      reference: p.reference,
      paidAt: p.paidAt,
    })),
  };
}

/** Snippe Idempotency-Key must be ≤ 30 characters. */
const idempotencyKeyFor = (attemptId: string) => `dc${attemptId.replace(/-/g, "").slice(0, 28)}`;

export async function startCheckout(
  db: DbExecutor,
  gateway: PaymentGateway,
  userId: string,
  eventId: string,
  input: { planKey?: string | null; guestCards: number; method: "mobile" | "session"; phone?: string | null; expectedTotal: number },
  urls: { webhookUrl: string; redirectUrl: string },
) {
  await requireEventRole(db, { userId, eventId, roles: [] });
  const b = await loadEventBilling(db, eventId);
  if (b.ev.status !== "draft" && b.ev.status !== "published") throw new BillingError("event_closed", `A ${b.ev.status} event cannot be paid for.`);
  const [recent] = await db
    .select({ id: paymentAttempt.id })
    .from(paymentAttempt)
    .where(and(eq(paymentAttempt.eventId, eventId), eq(paymentAttempt.status, "pending"), gte(paymentAttempt.createdAt, new Date(Date.now() - IN_PROGRESS_MS))))
    .limit(1);
  if (recent) throw new BillingError("payment_in_progress", "A payment for this event is still waiting. Finish it or wait a few minutes.");
  const { quote, target } = await buildQuote(db, eventId, userId, input);
  if (!quote.payable) throw new BillingError("nothing_to_pay", "These cards are already paid for.");
  if (quote.total !== input.expectedTotal) throw new BillingError("quote_changed", "The price changed. Check the new total and confirm again.");
  const phone = input.method === "mobile" ? normalisePhone(input.phone ?? "") : null;
  const [host] = await db.select({ email: userAccount.email }).from(userAccount).where(eq(userAccount.id, userId));

  const [attempt] = await db
    .insert(paymentAttempt)
    .values({
      eventId,
      hostUserId: userId,
      planId: target.id,
      pricePerGuest: quote.pricePerGuest,
      guestCards: quote.guestCards,
      subtotal: quote.subtotal,
      discountAmount: quote.discountAmount,
      amount: quote.total,
      method: input.method,
      phone,
      provider: gateway.name,
      idempotencyKey: "pending",
    })
    .returning();
  const idempotencyKey = idempotencyKeyFor(attempt!.id);
  const req = {
    amount: quote.total,
    idempotencyKey,
    webhookUrl: urls.webhookUrl,
    description: `D-Card: ${quote.guestCards} kadi · ${b.ev.title}`.slice(0, 120),
    metadata: { attempt_id: attempt!.id, event_id: eventId },
    customer: { name: host?.email?.split("@")[0] ?? "D-Card host", email: host?.email ?? "host@dcard.co.tz", phone },
  };
  try {
    const created =
      input.method === "mobile" ? await gateway.createMobilePayment({ ...req, phone: phone! }) : await gateway.createSession({ ...req, redirectUrl: urls.redirectUrl });
    const [updated] = await db
      .update(paymentAttempt)
      .set({ idempotencyKey, providerReference: created.reference, checkoutUrl: created.checkoutUrl })
      .where(eq(paymentAttempt.id, attempt!.id))
      .returning();
    await recordAudit(db, {
      actorUserId: userId,
      eventId,
      action: "billing.checkout_started",
      targetType: "payment_attempt",
      targetId: attempt!.id,
      newValue: { amount: quote.total, guestCards: quote.guestCards, plan: target.key, method: input.method, provider: gateway.name },
    });
    return attemptView(updated!, target.key);
  } catch (err) {
    const message = err instanceof Error ? err.message : String(err);
    await db.update(paymentAttempt).set({ idempotencyKey, status: "failed", failureReason: message.slice(0, 300) }).where(eq(paymentAttempt.id, attempt!.id));
    if (err instanceof PaymentProviderError) throw new BillingError("provider_unavailable", "The payment service is not responding. Try again in a moment.");
    throw err;
  }
}

export async function getCheckout(db: DbExecutor, userId: string, eventId: string, attemptId: string) {
  await requireEventRole(db, { userId, eventId, roles: [] });
  const [a] = await db.select().from(paymentAttempt).where(and(eq(paymentAttempt.id, attemptId), eq(paymentAttempt.eventId, eventId)));
  if (!a) throw new NotFoundError("Payment not found.");
  return attemptView(a, await planKeyOf(db, a.planId));
}

/**
 * Applies a provider result to an attempt. Completion unlocks the cards exactly once (the
 * pending → completed update is conditional and `host_payment.attempt_id` is unique).
 */
export async function applyPaymentResult(
  db: DbExecutor,
  find: { attemptId?: string | null; reference?: string | null },
  status: ProviderStatus,
  reason?: string | null,
): Promise<"completed" | "failed" | "expired" | "ignored"> {
  if (status === "pending") return "ignored";
  const where = find.attemptId ? eq(paymentAttempt.id, find.attemptId) : find.reference ? eq(paymentAttempt.providerReference, find.reference) : null;
  if (!where) return "ignored";
  return inTransaction(db, async (tx) => {
    const [attempt] = await tx
      .update(paymentAttempt)
      .set({ status, completedAt: new Date(), ...(status !== "completed" ? { failureReason: (reason ?? status).slice(0, 300) } : {}) })
      .where(and(where, eq(paymentAttempt.status, "pending")))
      .returning();
    if (!attempt) return "ignored";
    if (status !== "completed") {
      await recordAudit(tx, { actorUserId: null, eventId: attempt.eventId, action: `billing.payment_${status}`, targetType: "payment_attempt", targetId: attempt.id, newValue: { reason: reason ?? null } });
      return status;
    }
    await tx.insert(hostPayment).values({
      attemptId: attempt.id,
      eventId: attempt.eventId,
      hostUserId: attempt.hostUserId,
      planId: attempt.planId,
      guestCards: attempt.guestCards,
      amount: attempt.amount,
      discountAmount: attempt.discountAmount,
      method: attempt.method,
      reference: attempt.providerReference ?? attempt.id,
      paidAt: attempt.completedAt ?? new Date(),
    });
    await tx
      .update(eventPlan)
      .set({
        planId: attempt.planId,
        pricePerGuest: attempt.pricePerGuest,
        guestLimit: sql`greatest(${eventPlan.guestLimit}, ${attempt.guestCards})`,
        amountPaid: sql`${eventPlan.amountPaid} + ${attempt.amount}`,
        purchasedAt: sql`coalesce(${eventPlan.purchasedAt}, now())`,
      })
      .where(eq(eventPlan.eventId, attempt.eventId));
    await recordAudit(tx, {
      actorUserId: attempt.hostUserId,
      eventId: attempt.eventId,
      action: "billing.paid",
      targetType: "payment_attempt",
      targetId: attempt.id,
      newValue: { amount: attempt.amount, guestCards: attempt.guestCards, discount: attempt.discountAmount, reference: attempt.providerReference },
    });
    await issueWaitingCards(tx, attempt.eventId, attempt.hostUserId);
    return "completed";
  });
}

/** After payment, contributors who already paid in full get the cards that were waiting. */
async function issueWaitingCards(tx: DbExecutor, eventId: string, actorId: string): Promise<void> {
  const waiting = await tx
    .select({ id: invitation.id })
    .from(invitation)
    .innerJoin(pledge, eq(pledge.invitationId, invitation.id))
    .where(and(eq(invitation.eventId, eventId), eq(invitation.status, "pending"), eq(pledge.status, "fully_paid")))
    .orderBy(asc(pledge.createdAt));
  for (const w of waiting) {
    try {
      await issueInvitationInTx(tx, { actorId, eventId, guestId: w.id, reason: "fully_paid" });
    } catch (err) {
      if (err instanceof BillingError && err.code === "guest_limit") break;
      throw err;
    }
  }
}

/** Snippe webhook (signature already verified by the route). Deduplicated by event id. */
export async function handleSnippeWebhook(db: DbExecutor, body: unknown): Promise<{ duplicate: boolean; result: string }> {
  const evt = body as { id?: string; type?: string; data?: { reference?: string; status?: string; metadata?: Record<string, unknown>; failure_reason?: string } };
  if (!evt?.id || !evt.type) return { duplicate: false, result: "ignored" };
  const inserted = await db.insert(webhookEvent).values({ id: evt.id, provider: "snippe", type: evt.type }).onConflictDoNothing().returning();
  if (!inserted.length) return { duplicate: true, result: "duplicate" };
  const kind = evt.type.split(".").pop() ?? "";
  const status: ProviderStatus | null =
    kind === "completed" ? "completed" : ["failed", "voided", "cancelled"].includes(kind) ? "failed" : kind === "expired" ? "expired" : null;
  if (!status) return { duplicate: false, result: "ignored" };
  const attemptId = typeof evt.data?.metadata?.attempt_id === "string" ? (evt.data.metadata.attempt_id as string) : null;
  const result = await applyPaymentResult(db, { attemptId, reference: attemptId ? null : evt.data?.reference }, status, evt.data?.failure_reason ?? null);
  return { duplicate: false, result };
}

/** Fallback when webhooks are late: poll pending attempts; expire those past Snippe's window. */
export async function pollPendingPayments(db: DbExecutor, gateway: PaymentGateway, now = new Date()): Promise<{ checked: number; changed: number }> {
  const pending = await db
    .select()
    .from(paymentAttempt)
    .where(and(eq(paymentAttempt.status, "pending"), eq(paymentAttempt.provider, gateway.name)))
    .orderBy(asc(paymentAttempt.createdAt))
    .limit(50);
  let changed = 0;
  for (const a of pending) {
    if (!a.providerReference) continue;
    let status: ProviderStatus;
    try {
      status = await gateway.getStatus(a.providerReference, a.method);
    } catch {
      continue;
    }
    if (status === "pending" && now.getTime() - a.createdAt.getTime() > PENDING_LIFETIME_MS) status = "expired";
    if ((await applyPaymentResult(db, { attemptId: a.id }, status)) !== "ignored") changed++;
  }
  return { checked: pending.length, changed };
}

export async function updateBillingSettings(db: DbExecutor, userId: string, input: { launchOfferEnabled: boolean; launchOfferPercent: number }) {
  await requireAdmin(db, userId);
  const before = await getBillingSettings(db);
  await db
    .insert(billingSetting)
    .values({ id: 1, ...input, updatedBy: userId })
    .onConflictDoUpdate({ target: billingSetting.id, set: { ...input, updatedBy: userId, updatedAt: new Date() } });
  await recordAudit(db, { actorUserId: userId, action: "billing.settings_updated", targetType: "billing_setting", targetId: "1", oldValue: before, newValue: input });
  return getBillingSettings(db);
}

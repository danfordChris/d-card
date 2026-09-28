import { checkInAttempt, doorDevice, entry, event, eventRole, invitation, userAccount } from "@dcard/db";
import { and, asc, eq, gt, inArray, isNull, or, sql } from "drizzle-orm";
import { createHash } from "node:crypto";
import { recordAudit } from "../audit/audit.js";
import { decryptSecret } from "../crypto/secrets.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { NotFoundError } from "../errors.js";
import type { PushNotifyJob } from "../queues/index.js";
import { requireDoorDevice, type CheckInMethod } from "./door.js";
import { hostUserId, mergeOfflineWalkIns, walkInApproverIds, walkInPush, walkInViews, type OfflineWalkIn } from "./walk-ins.js";

// Offline cache and sync (offline-sync.md 9.1–9.4). Entries form a grow-only set keyed by the
// device-generated id: inserting is idempotent and order-free, and entries used per card are
// derived from the set. Limits cannot be enforced across disconnected gates, so over-use is
// detected after the merge, flagged once, alerted and audited — never rejected (9.3).

const HOUR = 60 * 60 * 1000;
/** Deltas overlap by this much so rows committed while a query ran are not missed. */
const CURSOR_OVERLAP_MS = 30_000;

/** Unkeyed digest a device can compute from a scanned QR code. Tokens are 32 random bytes. */
export const qrTokenDigest = (token: string) => createHash("sha256").update(token).digest("hex");

export type DoorSyncCard = {
  invitationId: string;
  guestName: string;
  partnerName: string | null;
  cardNumber: string | null;
  qrTokenDigest: string | null;
  cardType: "single" | "double";
  status: "pending" | "issued" | "cancelled";
  totalEntries: number;
  entriesUsed: number;
  table: string | null;
  overUsed: boolean;
  updatedAt: Date;
};

function parseCursor(since: string | undefined): Date | null {
  if (!since) return null;
  const at = new Date(since);
  return Number.isNaN(at.getTime()) ? null : at;
}

export async function doorSyncDownload(db: DbExecutor, userId: string, params: { deviceId: string; since?: string; pending?: number }) {
  const device = await requireDoorDevice(db, userId, params.deviceId);
  const startedAt = new Date();
  const since = parseCursor(params.since);
  const [ev] = await db.select().from(event).where(eq(event.id, device.eventId));
  if (!ev) throw new NotFoundError("Event not found.");

  // A card changes when its row changes or when any entry for it arrives (from any device).
  const changed = since
    ? or(
        gt(invitation.updatedAt, since),
        sql`exists (select 1 from entry e where e.invitation_id = ${invitation.id} and e.received_at > ${since.toISOString()}::timestamptz)`,
      )
    : undefined;
  const rows = await db
    .select({
      i: invitation,
      // Explicit aliases: unqualified columns in a correlated subquery would bind to `entry`.
      used: sql<number>`coalesce((select sum(e.admitted_count) from entry e where e.invitation_id = "invitation"."id"), 0)::int`,
    })
    .from(invitation)
    .where(and(eq(invitation.eventId, device.eventId), changed));

  const approvers = await db
    .select({ userId: userAccount.id, name: userAccount.email })
    .from(eventRole)
    .innerJoin(userAccount, eq(userAccount.id, eventRole.userId))
    .where(and(eq(eventRole.eventId, device.eventId), eq(eventRole.role, "walkin_approver")));
  const [host] = await db.select({ userId: userAccount.id, name: userAccount.email }).from(userAccount).where(eq(userAccount.id, ev.hostUserId));

  await db
    .update(doorDevice)
    .set({ lastSyncAt: startedAt, ...(params.pending !== undefined ? { pendingCount: params.pending } : {}) })
    .where(eq(doorDevice.id, device.id));

  const endsAt = ev.endsAt ?? new Date(ev.startsAt.getTime() + 12 * HOUR);
  return {
    eventId: device.eventId,
    full: !since,
    cards: rows.map(({ i, used }): DoorSyncCard => ({
      invitationId: i.id,
      guestName: i.guestName,
      partnerName: i.partnerName,
      cardNumber: i.cardNumber,
      qrTokenDigest: i.qrTokenEnc && i.status === "issued" ? qrTokenDigest(decryptSecret(i.qrTokenEnc)) : null,
      cardType: i.cardType,
      status: i.status,
      totalEntries: i.totalEntries,
      entriesUsed: used,
      table: null,
      overUsed: used > i.totalEntries,
      updatedAt: i.updatedAt,
    })),
    approvers: [...(host ? [host] : []), ...approvers.filter((a) => a.userId !== host?.userId)].map((a) => ({ userId: a.userId, name: a.name ?? "" })),
    cursor: new Date(startedAt.getTime() - CURSOR_OVERLAP_MS).toISOString(),
    wipeAfter: new Date(endsAt.getTime() + 24 * HOUR),
  };
}

export type SyncUpload = {
  deviceId: string;
  entries: { id: string; invitationId: string; admittedCount: number; method: CheckInMethod; occurredAt: string }[];
  attempts: {
    id: string;
    invitationId?: string | null;
    method: CheckInMethod;
    query?: string | null;
    outcome: "fully_used" | "cancelled" | "not_issued" | "too_many" | "not_found" | "locked";
    occurredAt: string;
  }[];
  walkIns?: OfflineWalkIn[];
  pending: number;
};

export async function doorSyncUpload(db: DbExecutor, userId: string, upload: SyncUpload) {
  const device = await requireDoorDevice(db, userId, upload.deviceId);
  const eventId = device.eventId;
  const ids = [
    ...new Set([
      ...upload.entries.map((e) => e.invitationId),
      ...upload.attempts.flatMap((a) => (a.invitationId ? [a.invitationId] : [])),
      ...(upload.walkIns ?? []).flatMap((w) => (w.invitationId ? [w.invitationId] : [])),
    ]),
  ];
  const known = new Set(
    ids.length
      ? (await db.select({ id: invitation.id }).from(invitation).where(and(eq(invitation.eventId, eventId), inArray(invitation.id, ids)))).map((r) => r.id)
      : [],
  );

  const merged = await inTransaction(db, async (tx) => {
    const rejected = upload.entries.filter((e) => !known.has(e.invitationId)).map((e) => e.id);
    const valid = upload.entries.filter((e) => known.has(e.invitationId));
    // Two gates uploading entries for the same card at once must see each other's entries when
    // checking over-use: lock the cards first (sorted, so concurrent uploads cannot deadlock),
    // like online admits do. Found by the T07-02 load test.
    const lockIds = [...new Set(valid.map((e) => e.invitationId))].sort();
    if (lockIds.length) {
      await tx.select({ id: invitation.id }).from(invitation).where(inArray(invitation.id, lockIds)).orderBy(asc(invitation.id)).for("update");
    }
    let accepted = 0;
    const touched = new Set<string>();
    for (const e of valid) {
      const inserted = await tx
        .insert(entry)
        .values({
          id: e.id,
          eventId,
          invitationId: e.invitationId,
          admittedCount: e.admittedCount,
          method: e.method,
          staffUserId: userId,
          deviceId: device.id,
          source: "offline",
          occurredAt: new Date(e.occurredAt),
        })
        .onConflictDoNothing({ target: entry.id })
        .returning({ id: entry.id });
      if (inserted.length) {
        accepted++;
        touched.add(e.invitationId);
        await tx.insert(checkInAttempt).values({
          id: e.id,
          eventId,
          invitationId: e.invitationId,
          entryId: e.id,
          deviceId: device.id,
          staffUserId: userId,
          method: e.method,
          outcome: "admitted",
          source: "offline",
          occurredAt: new Date(e.occurredAt),
        }).onConflictDoNothing({ target: checkInAttempt.id });
      }
    }

    let attemptsAccepted = 0;
    let lockouts = 0;
    for (const a of upload.attempts) {
      const inserted = await tx
        .insert(checkInAttempt)
        .values({
          id: a.id,
          eventId,
          invitationId: a.invitationId && known.has(a.invitationId) ? a.invitationId : null,
          deviceId: device.id,
          staffUserId: userId,
          method: a.method,
          query: a.query ?? null,
          outcome: a.outcome,
          source: "offline",
          occurredAt: new Date(a.occurredAt),
        })
        .onConflictDoNothing({ target: checkInAttempt.id })
        .returning({ id: checkInAttempt.id });
      if (inserted.length) {
        attemptsAccepted++;
        if (a.outcome === "locked") lockouts++;
      }
    }
    if (lockouts) {
      // CHK-5 offline: the device enforced the lock; it is reported to the host here.
      await recordAudit(tx, { actorUserId: userId, eventId, action: "door.card_number_lockout", targetType: "door_device", targetId: device.id, newValue: { source: "offline", attempts: lockouts } });
    }

    const walkIns = await mergeOfflineWalkIns(tx, { eventId, deviceId: device.id, userId }, upload.walkIns ?? [], known);
    const { all: overUsed, newly } = await flagOverUse(tx, eventId, [...touched], userId);
    await tx.update(doorDevice).set({ lastSyncAt: new Date(), pendingCount: upload.pending }).where(eq(doorDevice.id, device.id));
    if (accepted || attemptsAccepted) {
      await recordAudit(tx, {
        actorUserId: userId,
        eventId,
        action: "door.synced",
        targetType: "door_device",
        targetId: device.id,
        newValue: { entries: accepted, attempts: attemptsAccepted, rejected: rejected.length },
      });
    }
    return { entriesAccepted: accepted, entriesDuplicate: valid.length - accepted, entriesRejected: rejected, attemptsAccepted, walkInsAccepted: walkIns.length, overUsed, newly, walkIns, lockouts };
  });

  // Host alerts (CHK-7, CHK-5 offline) and review requests (CHK-8a), sent after commit.
  const push: PushNotifyJob[] = [];
  const host = await hostUserId(db, eventId);
  if (host && merged.newly.length) {
    push.push({ userIds: [host], title: "Kadi imetumika zaidi ya kiwango", body: `${merged.newly.length} · angalia dashibodi ya tukio`, data: { type: "over_used", eventId } });
  }
  if (host && merged.lockouts) {
    push.push({ userIds: [host], title: "Namba za kadi zimefungwa mlangoni", body: "Namba 3 zisizo sahihi mfululizo (bila mtandao)", data: { type: "lockout", eventId } });
  }
  if (merged.walkIns.length) {
    const recipients = await walkInApproverIds(db, eventId);
    for (const w of await walkInViews(db, merged.walkIns)) push.push(walkInPush(w, recipients));
  }
  const { newly: _newly, walkIns: _walkIns, lockouts: _lockouts, ...result } = merged;
  return { ...result, push };
}

/** Flags cards whose entries now exceed their allowance (first time only) and audits them with the entries. */
async function flagOverUse(tx: DbExecutor, eventId: string, invitationIds: string[], actorUserId: string): Promise<{ all: string[]; newly: string[] }> {
  if (!invitationIds.length) return { all: [], newly: [] };
  const over = await tx
    .select({ id: invitation.id, total: invitation.totalEntries, flagged: invitation.overUsedAt, used: sql<number>`coalesce(sum(${entry.admittedCount}), 0)::int` })
    .from(invitation)
    .leftJoin(entry, eq(entry.invitationId, invitation.id))
    .where(inArray(invitation.id, invitationIds))
    .groupBy(invitation.id)
    .having(sql`coalesce(sum(${entry.admittedCount}), 0) > ${invitation.totalEntries}`);
  for (const card of over.filter((c) => !c.flagged)) {
    await tx.update(invitation).set({ overUsedAt: new Date() }).where(and(eq(invitation.id, card.id), isNull(invitation.overUsedAt)));
    const entries = await tx
      .select({ id: entry.id, admittedCount: entry.admittedCount, occurredAt: entry.occurredAt, deviceId: entry.deviceId, deviceName: doorDevice.name, staffUserId: entry.staffUserId, source: entry.source })
      .from(entry)
      .leftJoin(doorDevice, eq(doorDevice.id, entry.deviceId))
      .where(eq(entry.invitationId, card.id));
    // CHK-7 host alert: the dashboard lists `door.over_used`; the push alert is wired with T04-06.
    await recordAudit(tx, {
      actorUserId,
      eventId,
      action: "door.over_used",
      targetType: "invitation",
      targetId: card.id,
      newValue: { allowed: card.total, used: card.used, entries: entries.map((e) => ({ ...e, occurredAt: e.occurredAt.toISOString() })) },
    });
  }
  return { all: over.map((c) => c.id), newly: over.filter((c) => !c.flagged).map((c) => c.id) };
}

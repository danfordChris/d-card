import { auditLog, doorDevice, entry, event, invitation, userAccount, walkinRequest } from "@dcard/db";
import { and, asc, desc, eq, gte, isNotNull, sql } from "drizzle-orm";
import { createHash } from "node:crypto";
import { requireEventRole, type EventAccess } from "../auth/roles.js";
import { calculateConfirmationSummary, type ConfirmationSummary } from "../confirmations/confirmations.js";
import type { DbExecutor } from "../db-types.js";
import { NotFoundError } from "../errors.js";

// Event-day dashboard (events.md "Event Day Dashboard"; check-in.md CHK-7, CHK-10; offline-sync 9.3, 9.4)
// and the printable backup list (CHK-9). Host and committee only.

/** A device is "stale" when it still holds unsynced entries and has not synced for this long. */
export const DEVICE_STALE_MS = 10 * 60 * 1000;
/** Lockout alerts shown on the dashboard look back this far. */
export const LOCKOUT_WINDOW_MS = 24 * 60 * 60 * 1000;

export type DashboardDevice = {
  id: string;
  name: string | null;
  staffName: string | null;
  lastSeenAt: Date;
  lastSyncAt: Date | null;
  pendingCount: number;
  revoked: boolean;
  stale: boolean;
};

export type OverUsedAlert = {
  invitationId: string;
  guestName: string;
  cardNumber: string | null;
  totalEntries: number;
  entriesUsed: number;
  at: Date;
};

export type LockoutAlert = {
  id: string;
  deviceName: string | null;
  staffName: string | null;
  source: "online" | "offline";
  at: Date;
};

export type EventDashboard = {
  eventId: string;
  title: string;
  startsAt: Date;
  /** How the caller was granted access; the UI shows host-only actions (revoke) for "host". */
  access: EventAccess;
  admitted: { total: number; cards: number; walkIns: number; online: number; offline: number };
  confirmations: ConfirmationSummary;
  cards: { issued: number; checkedIn: number; notArrived: number };
  walkIns: { pending: number; needsReview: number };
  devices: DashboardDevice[];
  alerts: { overUsed: OverUsedAlert[]; lockouts: LockoutAlert[] };
  /** Changes whenever anything above changes, so live clients can skip unchanged payloads. */
  version: string;
};

export async function getEventDashboard(db: DbExecutor, userId: string, eventId: string, now = new Date()): Promise<EventDashboard> {
  const access = await requireEventRole(db, { userId, eventId, roles: ["committee"] });
  const [ev] = await db
    .select({ title: event.title, startsAt: event.startsAt, headcountPct: event.headcountPct })
    .from(event)
    .where(eq(event.id, eventId));
  if (!ev) throw new NotFoundError("Event not found.");

  const issuedCards = and(eq(invitation.eventId, eventId), eq(invitation.status, "issued"));
  const [entryTotals, used, cards, walkInCounts, deviceRows, overUsedRows, lockoutRows] = await Promise.all([
    db
      .select({
        cards: sql<number>`coalesce(sum(${entry.admittedCount}) filter (where ${entry.invitationId} is not null), 0)::int`,
        walkIns: sql<number>`coalesce(sum(${entry.admittedCount}) filter (where ${entry.invitationId} is null), 0)::int`,
        online: sql<number>`coalesce(sum(${entry.admittedCount}) filter (where ${entry.source} = 'online'), 0)::int`,
        offline: sql<number>`coalesce(sum(${entry.admittedCount}) filter (where ${entry.source} = 'offline'), 0)::int`,
      })
      .from(entry)
      .where(eq(entry.eventId, eventId)),
    entriesUsedByCard(db, eventId),
    db
      .select({
        confirmationStatus: invitation.confirmationStatus,
        totalEntries: invitation.totalEntries,
        id: invitation.id,
      })
      .from(invitation)
      .where(issuedCards),
    db
      .select({
        pending: sql<number>`count(*) filter (where ${walkinRequest.status} = 'pending')::int`,
        needsReview: sql<number>`count(*) filter (where ${walkinRequest.status} = 'admitted_offline')::int`,
      })
      .from(walkinRequest)
      .where(eq(walkinRequest.eventId, eventId)),
    db
      .select({ d: doorDevice, staffName: userAccount.email })
      .from(doorDevice)
      .leftJoin(userAccount, eq(userAccount.id, doorDevice.staffUserId))
      .where(eq(doorDevice.eventId, eventId))
      .orderBy(desc(doorDevice.lastSeenAt), asc(doorDevice.id)),
    db
      .select({
        invitationId: invitation.id,
        guestName: invitation.guestName,
        cardNumber: invitation.cardNumber,
        totalEntries: invitation.totalEntries,
        at: invitation.overUsedAt,
      })
      .from(invitation)
      .where(and(eq(invitation.eventId, eventId), isNotNull(invitation.overUsedAt)))
      .orderBy(desc(invitation.overUsedAt), asc(invitation.id)),
    db
      .select({ id: auditLog.id, at: auditLog.createdAt, newValue: auditLog.newValue, deviceName: doorDevice.name, staffName: userAccount.email })
      .from(auditLog)
      .leftJoin(doorDevice, sql`${doorDevice.id}::text = ${auditLog.targetId}`)
      .leftJoin(userAccount, eq(userAccount.id, auditLog.actorUserId))
      .where(
        and(
          eq(auditLog.eventId, eventId),
          eq(auditLog.action, "door.card_number_lockout"),
          gte(auditLog.createdAt, new Date(now.getTime() - LOCKOUT_WINDOW_MS)),
        ),
      )
      .orderBy(desc(auditLog.createdAt), asc(auditLog.id)),
  ]);

  const totals = entryTotals[0] ?? { cards: 0, walkIns: 0, online: 0, offline: 0 };
  const checkedIn = cards.filter((c) => used.has(c.id)).length;
  const body: Omit<EventDashboard, "version"> = {
    eventId,
    title: ev.title,
    startsAt: ev.startsAt,
    access,
    admitted: {
      total: totals.cards + totals.walkIns,
      cards: totals.cards,
      walkIns: totals.walkIns,
      online: totals.online,
      offline: totals.offline,
    },
    confirmations: calculateConfirmationSummary(cards, ev.headcountPct),
    cards: { issued: cards.length, checkedIn, notArrived: cards.length - checkedIn },
    walkIns: walkInCounts[0] ?? { pending: 0, needsReview: 0 },
    devices: deviceRows.map(({ d, staffName }) => ({
      id: d.id,
      name: d.name,
      staffName,
      lastSeenAt: d.lastSeenAt,
      lastSyncAt: d.lastSyncAt,
      pendingCount: d.pendingCount,
      revoked: d.revokedAt !== null,
      stale: isStale(d.pendingCount, d.lastSyncAt ?? d.createdAt, now),
    })),
    alerts: {
      overUsed: overUsedRows.map((r) => ({ ...r, entriesUsed: used.get(r.invitationId) ?? 0, at: r.at! })),
      lockouts: lockoutRows.map((r) => ({
        id: r.id,
        deviceName: r.deviceName,
        staffName: r.staffName,
        source: (r.newValue as { source?: string } | null)?.source === "offline" ? "offline" : "online",
        at: r.at,
      })),
    },
  };
  return { ...body, version: dashboardVersion(body) };
}

/** People admitted per card (walk-in entries have no card). */
async function entriesUsedByCard(db: DbExecutor, eventId: string): Promise<Map<string, number>> {
  const rows = await db
    .select({ invitationId: entry.invitationId, used: sql<number>`sum(${entry.admittedCount})::int` })
    .from(entry)
    .where(and(eq(entry.eventId, eventId), isNotNull(entry.invitationId)))
    .groupBy(entry.invitationId);
  return new Map(rows.map((r) => [r.invitationId!, r.used]));
}

function isStale(pendingCount: number, lastSyncAt: Date, now: Date): boolean {
  return pendingCount > 0 && now.getTime() - lastSyncAt.getTime() > DEVICE_STALE_MS;
}

/**
 * A digest of the payload: it changes exactly when the rendered numbers change (entries,
 * walk-ins, device sync, alerts, confirmations, a device turning stale), unlike a max-timestamp.
 */
function dashboardVersion(body: Omit<EventDashboard, "version">): string {
  return createHash("sha256").update(JSON.stringify(body)).digest("base64url").slice(0, 22);
}

export type BackupListRow = {
  invitationId: string;
  guestName: string;
  partnerName: string | null;
  cardNumber: string | null;
  cardType: "single" | "double";
  totalEntries: number;
  entriesUsed: number;
};

export type BackupList = {
  eventId: string;
  title: string;
  startsAt: Date;
  timeZone: string;
  venueName: string | null;
  rows: BackupListRow[];
};

/** CHK-9: every issued card, sorted by guest name, for the printed last-resort list. */
export async function getBackupList(db: DbExecutor, userId: string, eventId: string): Promise<BackupList> {
  await requireEventRole(db, { userId, eventId, roles: ["committee"] });
  const [ev] = await db
    .select({ title: event.title, startsAt: event.startsAt, timeZone: event.timeZone, venueName: event.venueName })
    .from(event)
    .where(eq(event.id, eventId));
  if (!ev) throw new NotFoundError("Event not found.");
  const [used, rows] = await Promise.all([
    entriesUsedByCard(db, eventId),
    db
      .select({
        invitationId: invitation.id,
        guestName: invitation.guestName,
        partnerName: invitation.partnerName,
        cardNumber: invitation.cardNumber,
        cardType: invitation.cardType,
        totalEntries: invitation.totalEntries,
      })
      .from(invitation)
      .where(and(eq(invitation.eventId, eventId), eq(invitation.status, "issued")))
      .orderBy(sql`lower(${invitation.guestName})`, asc(invitation.cardNumber), asc(invitation.id)),
  ]);
  return { eventId, ...ev, rows: rows.map((r) => ({ ...r, entriesUsed: used.get(r.invitationId) ?? 0 })) };
}

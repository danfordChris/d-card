import { auditLog, person, userAccount } from "@dcard/db";
import { and, desc, eq, like, lt, or, sql, type SQL } from "drizzle-orm";
import { requireEventRole } from "../auth/roles.js";
import type { DbExecutor } from "../db-types.js";
import { ValidationError } from "../errors.js";

// T06-04: the host's view of one event's audit trail (privacy-and-audit.md "Audited Actions").
// Host and treasurer only. Values are shown as stored, so fields masked by retention stay masked.

/** Roles besides the host that may read an event's audit trail. */
export const EVENT_AUDIT_ROLES = ["treasurer"] as const;

export type AuditChange = { field: string; from: string | null; to: string | null };

export type EventAuditEntry = {
  id: string;
  createdAt: Date;
  action: string;
  actorType: "user" | "system";
  /** Person name, else account email; null for system actions or deleted accounts. */
  actorName: string | null;
  targetType: string;
  targetId: string | null;
  /** Field-by-field summary of old → new values (top-level keys only). */
  changes: AuditChange[];
};

export type EventAuditPage = { entries: EventAuditEntry[]; nextCursor: string | null };

/** `action` is a dotted prefix: "payment" matches "payment.recorded"; "payment.recorded" matches itself. */
export type EventAuditQuery = { action?: string | null; limit?: number; cursor?: string | null };

const ACTION_FILTER = /^[a-z_]+(\.[a-z_]+)*\.?$/;
const MAX_VALUE_LENGTH = 200;

/** Newest first, keyset-paginated (createdAt, id). */
export async function listEventAudit(
  db: DbExecutor,
  userId: string,
  eventId: string,
  query: EventAuditQuery = {},
): Promise<EventAuditPage> {
  await requireEventRole(db, { userId, eventId, roles: EVENT_AUDIT_ROLES });
  const limit = Math.min(Math.max(Math.trunc(query.limit ?? 50), 1), 200);
  const filters: SQL[] = [eq(auditLog.eventId, eventId)];
  const action = query.action?.trim().toLowerCase();
  if (action) {
    if (action.length > 80 || !ACTION_FILTER.test(action)) {
      throw new ValidationError("Some fields are invalid.", [{ path: "action", message: "Invalid action filter." }]);
    }
    const prefix = action.replace(/\.$/, "");
    // "_" is a LIKE wildcard; escape it so "door.over_used" does not match "door.overXused".
    filters.push(or(eq(auditLog.action, prefix), like(auditLog.action, `${prefix.replace(/_/g, "\\_")}.%`))!);
  }
  if (query.cursor) {
    const c = decodeCursor(query.cursor);
    // Postgres keeps microseconds; compare at millisecond precision so a page boundary never repeats or skips a row.
    const at = sql`date_trunc('milliseconds', ${auditLog.createdAt})`;
    filters.push(or(sql`${at} < ${c.createdAt.toISOString()}::timestamptz`, and(sql`${at} = ${c.createdAt.toISOString()}::timestamptz`, lt(auditLog.id, c.id)))!);
  }
  const rows = await db
    .select({
      id: auditLog.id,
      createdAt: auditLog.createdAt,
      action: auditLog.action,
      actorType: auditLog.actorType,
      actorName: sql<string | null>`coalesce(${person.name}, ${userAccount.email})`,
      targetType: auditLog.targetType,
      targetId: auditLog.targetId,
      oldValue: auditLog.oldValue,
      newValue: auditLog.newValue,
    })
    .from(auditLog)
    .leftJoin(userAccount, eq(userAccount.id, auditLog.actorUserId))
    .leftJoin(person, eq(person.id, userAccount.personId))
    .where(and(...filters))
    .orderBy(sql`date_trunc('milliseconds', ${auditLog.createdAt}) desc`, desc(auditLog.id))
    .limit(limit + 1);
  const page = rows.slice(0, limit);
  const last = page[page.length - 1];
  return {
    entries: page.map(({ oldValue, newValue, ...r }) => ({ ...r, changes: summariseChanges(oldValue, newValue) })),
    nextCursor: rows.length > limit && last ? encodeCursor(last.createdAt, last.id) : null,
  };
}

/** Top-level differences between two stored values. Non-object values are reported as one "value" change. */
export function summariseChanges(oldValue: unknown, newValue: unknown): AuditChange[] {
  const isRecord = (v: unknown): v is Record<string, unknown> => typeof v === "object" && v !== null && !Array.isArray(v);
  if (oldValue == null && newValue == null) return [];
  if (!isRecord(oldValue ?? {}) || !isRecord(newValue ?? {})) {
    const from = display(oldValue);
    const to = display(newValue);
    return from === to ? [] : [{ field: "value", from, to }];
  }
  const before = (oldValue ?? {}) as Record<string, unknown>;
  const after = (newValue ?? {}) as Record<string, unknown>;
  const changes: AuditChange[] = [];
  for (const field of new Set([...Object.keys(before), ...Object.keys(after)])) {
    const from = display(before[field]);
    const to = display(after[field]);
    if (from !== to) changes.push({ field, from, to });
  }
  return changes;
}

function display(value: unknown): string | null {
  if (value === undefined || value === null) return null;
  const text = typeof value === "string" ? value : JSON.stringify(value);
  return text.length > MAX_VALUE_LENGTH ? `${text.slice(0, MAX_VALUE_LENGTH - 1)}…` : text;
}

function encodeCursor(createdAt: Date, id: string): string {
  return Buffer.from(`${createdAt.toISOString()}|${id}`).toString("base64url");
}

function decodeCursor(cursor: string): { createdAt: Date; id: string } {
  const [ts, id] = Buffer.from(cursor, "base64url").toString().split("|");
  const createdAt = new Date(ts ?? "");
  if (!id || !/^[0-9a-f-]{36}$/i.test(id) || Number.isNaN(createdAt.getTime())) {
    throw new ValidationError("Some fields are invalid.", [{ path: "cursor", message: "Invalid cursor." }]);
  }
  return { createdAt, id };
}

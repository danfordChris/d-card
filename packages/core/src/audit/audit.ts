import { auditLog } from "@dcard/db";
import type { DbExecutor } from "../db-types.js";

export type AuditEntry = {
  /** Acting user; omit for system actions. */
  actorUserId?: string | null;
  eventId?: string | null;
  /** Dotted verb, e.g. "account.created", "payment.recorded". */
  action: string;
  targetType: string;
  targetId?: string | null;
  oldValue?: unknown;
  newValue?: unknown;
  ip?: string | null;
  device?: string | null;
};

/** Appends one audit_log row (docs/design/features/privacy-and-audit.md). Pass a transaction to keep it atomic with the change. */
export async function recordAudit(db: DbExecutor, entry: AuditEntry): Promise<string> {
  const [row] = await db
    .insert(auditLog)
    .values({
      actorType: entry.actorUserId ? "user" : "system",
      actorUserId: entry.actorUserId ?? null,
      eventId: entry.eventId ?? null,
      action: entry.action,
      targetType: entry.targetType,
      targetId: entry.targetId ?? null,
      oldValue: entry.oldValue ?? null,
      newValue: entry.newValue ?? null,
      ip: entry.ip ?? null,
      device: entry.device ?? null,
    })
    .returning({ id: auditLog.id });
  return row!.id;
}

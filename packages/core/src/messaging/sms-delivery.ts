import { messageLog } from "@dcard/db";
import { and, eq, gt } from "drizzle-orm";
import type { DbExecutor } from "../db-types.js";

// NextSMS delivery status is polled by our reference (message_log id); see
// docs/design/integrations/messaging.md. Groups: PENDING, DELIVERED, UNDELIVERABLE, EXPIRED, REJECTED…

/** SMS we sent recently that have no final status yet. */
export async function smsAwaitingDelivery(db: DbExecutor, now = new Date(), limit = 200) {
  return db
    .select({ logId: messageLog.id })
    .from(messageLog)
    .where(
      and(
        eq(messageLog.channel, "sms"),
        eq(messageLog.direction, "outbound"),
        eq(messageLog.status, "sent"),
        gt(messageLog.sentAt, new Date(now.getTime() - 3 * 24 * 60 * 60 * 1000)),
      ),
    )
    .limit(limit);
}

const FAILED = new Set(["UNDELIVERABLE", "EXPIRED", "REJECTED", "DELETED"]);

/** Applies one provider report. Returns the new status, or null if nothing changed. */
export async function applySmsDelivery(
  db: DbExecutor,
  logId: string,
  report: { messageId: string | null; group: string; doneAt: string | null; description: string | null },
): Promise<"delivered" | "failed" | null> {
  const status = report.group === "DELIVERED" ? "delivered" : FAILED.has(report.group) ? "failed" : null;
  const [log] = await db.select().from(messageLog).where(eq(messageLog.id, logId));
  if (!log) return null;
  const idUpdate = report.messageId && log.providerMessageId !== report.messageId ? { providerMessageId: report.messageId } : {};
  if (!status || log.status !== "sent") {
    if (Object.keys(idUpdate).length) await db.update(messageLog).set(idUpdate).where(eq(messageLog.id, logId));
    return null;
  }
  const at = report.doneAt ? new Date(report.doneAt.replace(" ", "T") + "+03:00") : new Date();
  await db
    .update(messageLog)
    .set({
      ...idUpdate,
      status,
      ...(status === "delivered" ? { deliveredAt: Number.isNaN(at.getTime()) ? new Date() : at } : { error: `${report.group} ${report.description ?? ""}`.trim() }),
    })
    .where(eq(messageLog.id, logId));
  return status;
}

import { paymentAttempt, type Database } from "@dcard/db";
import type { Queue } from "bullmq";
import { and, count, eq, lt } from "drizzle-orm";
import type { Redis } from "ioredis";
import type { EmailSender } from "../email/sender.js";

// T06-06: every 5 minutes the worker checks queues and payments and emails ALERT_EMAIL, at most
// once per hour per condition (Redis SET NX EX). Without ALERT_EMAIL alerts are only logged.

export const ALERT_LIMITS = { waiting: 100, failedPerHour: 10, pendingPaymentMs: 60 * 60 * 1000 } as const;
const THROTTLE_SECONDS = 60 * 60;

export type Alert = { key: string; text: string };

export async function findAlerts(db: Database, queues: Queue[], now = new Date()): Promise<Alert[]> {
  const alerts: Alert[] = [];
  const hourAgo = now.getTime() - 60 * 60 * 1000;
  for (const q of queues) {
    const counts = await q.getJobCounts("waiting");
    if ((counts.waiting ?? 0) > ALERT_LIMITS.waiting) alerts.push({ key: `waiting:${q.name}`, text: `Queue ${q.name} has ${counts.waiting} waiting jobs (limit ${ALERT_LIMITS.waiting}). Is the worker keeping up?` });
    const failed = (await q.getJobs(["failed"], 0, 499)).filter((j) => (j.finishedOn ?? 0) >= hourAgo);
    if (failed.length > ALERT_LIMITS.failedPerHour) alerts.push({ key: `failed:${q.name}`, text: `Queue ${q.name}: ${failed.length} jobs failed in the last hour. Last error: ${failed[0]?.failedReason ?? "unknown"}` });
  }
  const [stuck] = await db
    .select({ n: count() })
    .from(paymentAttempt)
    .where(and(eq(paymentAttempt.status, "pending"), lt(paymentAttempt.createdAt, new Date(now.getTime() - ALERT_LIMITS.pendingPaymentMs))));
  if ((stuck?.n ?? 0) > 0) alerts.push({ key: "payments:pending", text: `${stuck!.n} host payment(s) are still pending after 1 hour. Check Snippe and the webhook.` });
  return alerts;
}

export async function sendAlerts(
  alerts: Alert[],
  deps: { redis: Redis; sender: EmailSender; to?: string; prefix?: string; log: (msg: string, fields?: Record<string, unknown>) => void },
): Promise<number> {
  let sent = 0;
  for (const a of alerts) {
    const fresh = await deps.redis.set(`${deps.prefix ?? "dcard"}:alert:${a.key}`, "1", "EX", THROTTLE_SECONDS, "NX");
    if (fresh !== "OK") continue;
    deps.log("alert", { alert: a.key, text: a.text });
    if (!deps.to) continue;
    await deps.sender.send({ to: deps.to, subject: `D-Card alert: ${a.key}`, text: a.text, html: `<p>${a.text.replace(/[<>&]/g, "")}</p>` });
    sent++;
  }
  return sent;
}

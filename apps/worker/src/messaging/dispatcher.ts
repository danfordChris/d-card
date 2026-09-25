import { dispatchOutbox, MESSAGE_JOBS, QUEUES, staleQueuedMessages, type DispatchedMessage } from "@dcard/core";
import type { Database } from "@dcard/db";
import type { JobsOptions, Queue } from "bullmq";
import { SEND_ATTEMPTS } from "./processor.js";

export type SendQueues = { sms: Queue; whatsapp: Queue };

export const sendJobOptions = (logId: string): JobsOptions => ({
  jobId: logId, // one job per message: re-queuing the same log is a no-op while the job exists
  attempts: SEND_ATTEMPTS,
  backoff: { type: "exponential" as const, delay: 30_000 },
  removeOnComplete: 1000,
  removeOnFail: 5000,
});

async function queueAll(queues: SendQueues, messages: DispatchedMessage[]): Promise<void> {
  await Promise.all(messages.map((m) => queues[m.channel].add(MESSAGE_JOBS.send, { logId: m.logId }, sendJobOptions(m.logId))));
}

/** Outbox → message_log → send jobs, plus re-queuing messages left queued by a crash. */
export async function runDispatch(db: Database, queues: SendQueues, now = new Date()): Promise<number> {
  const fresh = await dispatchOutbox(db, 100, now);
  await queueAll(queues, fresh);
  await queueAll(queues, await staleQueuedMessages(db));
  return fresh.length;
}

export const SEND_QUEUE_NAMES = [QUEUES.sms, QUEUES.whatsapp] as const;

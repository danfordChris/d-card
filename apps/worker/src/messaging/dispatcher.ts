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

const DISPATCH_BATCH = 100;
/** Per tick: a 1,000-guest fan-out leaves in one tick instead of ten (T07-02). */
const MAX_BATCHES_PER_TICK = 20;

/**
 * Outbox → message_log → send jobs, plus re-queuing messages left queued by a crash. Drains up to
 * 2,000 messages per tick in batches of 100 (short transactions); send rates are capped by the
 * queue limiters, not here.
 */
export async function runDispatch(db: Database, queues: SendQueues, now = new Date()): Promise<number> {
  let total = 0;
  for (let i = 0; i < MAX_BATCHES_PER_TICK; i++) {
    const fresh = await dispatchOutbox(db, DISPATCH_BATCH, now);
    await queueAll(queues, fresh);
    total += fresh.length;
    if (fresh.length < DISPATCH_BATCH) break;
  }
  await queueAll(queues, await staleQueuedMessages(db));
  return total;
}

export const SEND_QUEUE_NAMES = [QUEUES.sms, QUEUES.whatsapp] as const;

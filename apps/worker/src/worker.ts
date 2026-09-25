import { applySmsDelivery, QUEUES, scheduleDueMessages, smsAwaitingDelivery, SYSTEM_JOBS } from "@dcard/core";
import type { Database } from "@dcard/db";
import { Queue, Worker, type Job } from "bullmq";
import type { Redis } from "ioredis";
import { ResendEmailSender, type EmailSender } from "./email/sender.js";
import { runDispatch } from "./messaging/dispatcher.js";
import { createSendProcessor, type SendDeps } from "./messaging/processor.js";
import type { SmsDeliveryLookup, SmsSender, WhatsAppSender } from "./messaging/senders.js";
import { createEmailProcessor } from "./processors/email.js";
import { processSystemJob } from "./processors/system.js";

export type RunningWorkers = {
  workers: Worker[];
  close: () => Promise<void>;
};

export type MessagingDeps = Omit<SendDeps, "db" | "sms" | "whatsapp" | "log"> & {
  db: Database;
  sms: SmsSender & Partial<SmsDeliveryLookup>;
  whatsapp: WhatsAppSender;
  /** How often the outbox is dispatched (ms). 0 disables the repeating job (tests call it directly). */
  dispatchEveryMs?: number;
};

/** Starts all queue consumers on one Redis connection. Messaging runs when `messaging` is given. */
export async function startWorkers(
  connection: Redis,
  log: (msg: string) => void = console.log,
  deps: { emailSender?: EmailSender; prefix?: string; messaging?: MessagingDeps } = {},
): Promise<RunningWorkers> {
  const prefix = deps.prefix ?? process.env.QUEUE_PREFIX ?? "dcard";
  const queues: Queue[] = [];
  const workers: Worker[] = [];

  const m = deps.messaging;
  const sendQueues = m
    ? {
        sms: new Queue(QUEUES.sms, { connection, prefix }),
        whatsapp: new Queue(QUEUES.whatsapp, { connection, prefix }),
      }
    : null;
  if (sendQueues) queues.push(sendQueues.sms, sendQueues.whatsapp);

  const system = new Worker(
    QUEUES.system,
    async (job: Job) => {
      if (job.name === SYSTEM_JOBS.dispatchMessages) {
        if (!m || !sendQueues) throw new Error("messaging is not configured");
        return { dispatched: await runDispatch(m.db, sendQueues) };
      }
      if (job.name === SYSTEM_JOBS.pollSmsDelivery) {
        if (!m?.sms.lookup) return { checked: 0 };
        let updated = 0;
        const pending = await smsAwaitingDelivery(m.db);
        for (const { logId } of pending) {
          const report = await m.sms.lookup(logId);
          if (report && (await applySmsDelivery(m.db, logId, report))) updated++;
        }
        return { checked: pending.length, updated };
      }
      if (job.name === SYSTEM_JOBS.scheduleMessages) {
        if (!m) throw new Error("messaging is not configured");
        return scheduleDueMessages(m.db);
      }
      return processSystemJob(job);
    },
    { connection, concurrency: 5, prefix },
  );
  system.on("failed", (job, err) => log(`job:failed ${QUEUES.system}/${job?.name} ${err.message}`));
  workers.push(system);

  const email = new Worker(QUEUES.email, createEmailProcessor(deps.emailSender ?? new ResendEmailSender(), log), {
    connection,
    concurrency: 5,
    prefix,
  });
  email.on("failed", (job, err) => log(`job:failed ${QUEUES.email}/${job?.name} ${err.message}`));
  workers.push(email);

  if (m) {
    const processor = createSendProcessor({ ...m, log });
    for (const name of [QUEUES.sms, QUEUES.whatsapp]) {
      const w = new Worker(name, processor, { connection, concurrency: 10, prefix });
      w.on("failed", (job, err) => log(`job:failed ${name}/${job?.id} ${err.message}`));
      workers.push(w);
    }
    if ((m.dispatchEveryMs ?? 5000) > 0) {
      const systemQueue = new Queue(QUEUES.system, { connection, prefix });
      queues.push(systemQueue);
      await systemQueue.upsertJobScheduler("dispatch-messages", { every: m.dispatchEveryMs ?? 5000 }, { name: SYSTEM_JOBS.dispatchMessages });
      await systemQueue.upsertJobScheduler("schedule-messages", { every: 5 * 60_000 }, { name: SYSTEM_JOBS.scheduleMessages });
      await systemQueue.upsertJobScheduler("poll-sms-delivery", { every: 10 * 60_000 }, { name: SYSTEM_JOBS.pollSmsDelivery });
    }
  }

  await Promise.all(workers.map((w) => w.waitUntilReady()));
  log("worker:ready");
  return {
    workers,
    close: async () => {
      await Promise.all(workers.map((w) => w.close()));
      await Promise.all(queues.map((q) => q.close()));
    },
  };
}

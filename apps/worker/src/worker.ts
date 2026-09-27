import { applySmsDelivery, gatewayFromEnv, pollPendingPayments, QUEUES, runRetention, scheduleDueMessages, smsAwaitingDelivery, SYSTEM_JOBS, type PaymentGateway } from "@dcard/core";
import type { Database } from "@dcard/db";
import { Queue, Worker, type Job } from "bullmq";
import type { Redis } from "ioredis";
import { ResendEmailSender, type EmailSender } from "./email/sender.js";
import { runDispatch } from "./messaging/dispatcher.js";
import { createSendProcessor, createWhatsAppProcessor, type SendDeps } from "./messaging/processor.js";
import type { SmsDeliveryLookup, SmsSender, WhatsAppSender } from "./messaging/senders.js";
import { findAlerts, sendAlerts } from "./health/alerts.js";
import { createEmailProcessor } from "./processors/email.js";
import { processSystemJob } from "./processors/system.js";
import { createPushProcessor } from "./push/processor.js";
import type { PushSender } from "./push/push.js";

/**
 * Idle workers block on the queue marker, so a long drainDelay does not delay pickup (a new job
 * wakes them at once) but cuts idle Redis commands ~90 %. Stall checks every 5 min are enough for
 * our short jobs. Keeps Redis cheap (single small instance; docs/deployment.md).
 */
export const WORKER_REDIS_OPTIONS = { drainDelay: 60, stalledInterval: 300_000 } as const;

/** Outbox dispatch cadence in production (ms). Guests never need sub-15 s delivery. */
export const DEFAULT_DISPATCH_EVERY_MS = 15_000;

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
  deps: {
    emailSender?: EmailSender;
    prefix?: string;
    messaging?: MessagingDeps;
    push?: { db: Database; sender: PushSender };
    payments?: PaymentGateway;
    /** Error tracking hook (Sentry in production). */
    onJobFailed?: (err: Error, queue: string, job: string | undefined) => void;
    alertEmail?: string;
  } = {},
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
      if (job.name === SYSTEM_JOBS.pollPayments) {
        if (!m) return { checked: 0, changed: 0 };
        return pollPendingPayments(m.db, deps.payments ?? gatewayFromEnv());
      }
      if (job.name === SYSTEM_JOBS.checkHealth) {
        if (!m) return { alerts: 0 };
        const all = Object.values(QUEUES).map((name) => new Queue(name, { connection, prefix }));
        try {
          const alerts = await findAlerts(m.db, all);
          const sent = await sendAlerts(alerts, { redis: connection, sender: deps.emailSender ?? new ResendEmailSender(), to: deps.alertEmail, prefix, log: (msg, f) => log(`${msg} ${JSON.stringify(f ?? {})}`) });
          return { alerts: alerts.length, sent };
        } finally {
          await Promise.all(all.map((q) => q.close()));
        }
      }
      if (job.name === SYSTEM_JOBS.runRetention) {
        if (!m) return { events: 0 };
        const result = await runRetention(m.db);
        log(`retention ${JSON.stringify(result)}`);
        return result;
      }
      if (job.name === SYSTEM_JOBS.scheduleMessages) {
        if (!m) throw new Error("messaging is not configured");
        return scheduleDueMessages(m.db);
      }
      return processSystemJob(job);
    },
    { connection, concurrency: 5, prefix, ...WORKER_REDIS_OPTIONS },
  );
  system.on("failed", (job, err) => {
    log(`job:failed ${QUEUES.system}/${job?.name} ${err.message}`);
    deps.onJobFailed?.(err, QUEUES.system, job?.name);
  });
  workers.push(system);

  const email = new Worker(QUEUES.email, createEmailProcessor(deps.emailSender ?? new ResendEmailSender(), log), {
    ...WORKER_REDIS_OPTIONS,
    connection,
    concurrency: 5,
    prefix,
  });
  email.on("failed", (job, err) => {
    log(`job:failed ${QUEUES.email}/${job?.name} ${err.message}`);
    deps.onJobFailed?.(err, QUEUES.email, job?.name);
  });
  workers.push(email);

  if (deps.push) {
    const push = new Worker(QUEUES.push, createPushProcessor(deps.push.db, deps.push.sender, log), { connection, concurrency: 5, prefix, ...WORKER_REDIS_OPTIONS });
    push.on("failed", (job, err) => {
    log(`job:failed ${QUEUES.push}/${job?.name} ${err.message}`);
    deps.onJobFailed?.(err, QUEUES.push, job?.name);
  });
    workers.push(push);
  }

  if (m) {
    const processors = { [QUEUES.sms]: createSendProcessor({ ...m, log }), [QUEUES.whatsapp]: createWhatsAppProcessor({ ...m, log }) };
    for (const name of [QUEUES.sms, QUEUES.whatsapp] as const) {
      const w = new Worker(name, processors[name], { connection, concurrency: 10, prefix, ...WORKER_REDIS_OPTIONS });
      w.on("failed", (job, err) => {
    log(`job:failed ${name}/${job?.id} ${err.message}`);
    deps.onJobFailed?.(err, name, job?.name);
  });
      workers.push(w);
    }
    if ((m.dispatchEveryMs ?? DEFAULT_DISPATCH_EVERY_MS) > 0) {
      const systemQueue = new Queue(QUEUES.system, { connection, prefix });
      queues.push(systemQueue);
      await systemQueue.upsertJobScheduler("dispatch-messages", { every: m.dispatchEveryMs ?? DEFAULT_DISPATCH_EVERY_MS }, { name: SYSTEM_JOBS.dispatchMessages });
      await systemQueue.upsertJobScheduler("schedule-messages", { every: 5 * 60_000 }, { name: SYSTEM_JOBS.scheduleMessages });
      await systemQueue.upsertJobScheduler("poll-sms-delivery", { every: 10 * 60_000 }, { name: SYSTEM_JOBS.pollSmsDelivery });
      await systemQueue.upsertJobScheduler("poll-payments", { every: 2 * 60_000 }, { name: SYSTEM_JOBS.pollPayments });
      // 03:00 East Africa Time, when traffic is lowest.
      await systemQueue.upsertJobScheduler("check-health", { every: 5 * 60_000 }, { name: SYSTEM_JOBS.checkHealth });
      await systemQueue.upsertJobScheduler("run-retention", { pattern: "0 3 * * *", tz: "Africa/Dar_es_Salaam" }, { name: SYSTEM_JOBS.runRetention });
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

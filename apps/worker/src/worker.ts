import { QUEUES } from "@dcard/core";
import { Worker } from "bullmq";
import type { Redis } from "ioredis";
import { ResendEmailSender, type EmailSender } from "./email/sender.js";
import { createEmailProcessor } from "./processors/email.js";
import { processSystemJob } from "./processors/system.js";

export type RunningWorkers = {
  workers: Worker[];
  close: () => Promise<void>;
};

/** Starts all queue consumers on one Redis connection. */
export async function startWorkers(
  connection: Redis,
  log: (msg: string) => void = console.log,
  deps: { emailSender?: EmailSender; prefix?: string } = {},
): Promise<RunningWorkers> {
  const prefix = deps.prefix ?? process.env.QUEUE_PREFIX ?? "dcard";
  const system = new Worker(QUEUES.system, processSystemJob, { connection, concurrency: 5, prefix });
  system.on("failed", (job, err) => log(`job:failed ${QUEUES.system}/${job?.name} ${err.message}`));
  const email = new Worker(QUEUES.email, createEmailProcessor(deps.emailSender ?? new ResendEmailSender(), log), {
    connection,
    concurrency: 5,
    prefix,
  });
  email.on("failed", (job, err) => log(`job:failed ${QUEUES.email}/${job?.name} ${err.message}`));
  await Promise.all([system.waitUntilReady(), email.waitUntilReady()]);
  log("worker:ready");
  const workers = [system, email];
  return {
    workers,
    close: async () => {
      await Promise.all(workers.map((w) => w.close()));
    },
  };
}

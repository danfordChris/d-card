import { QUEUES } from "@dcard/core";
import { Worker } from "bullmq";
import type { Redis } from "ioredis";
import { processSystemJob } from "./processors/system.js";

export type RunningWorkers = {
  workers: Worker[];
  close: () => Promise<void>;
};

/** Starts all queue consumers on one Redis connection. */
export async function startWorkers(connection: Redis, log: (msg: string) => void = console.log): Promise<RunningWorkers> {
  const system = new Worker(QUEUES.system, processSystemJob, { connection, concurrency: 5 });
  system.on("failed", (job, err) => log(`job:failed ${QUEUES.system}/${job?.name} ${err.message}`));
  await system.waitUntilReady();
  log("worker:ready");
  const workers = [system];
  return {
    workers,
    close: async () => {
      await Promise.all(workers.map((w) => w.close()));
    },
  };
}

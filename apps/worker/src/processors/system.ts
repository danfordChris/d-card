import { SYSTEM_JOBS, type PingJobData, type PingJobResult } from "@dcard/core";
import type { Job } from "bullmq";

export async function processSystemJob(job: Job<PingJobData>): Promise<PingJobResult> {
  switch (job.name) {
    case SYSTEM_JOBS.ping:
      return { pong: true, sentAt: job.data.sentAt, processedAt: new Date().toISOString() };
    default:
      throw new Error(`Unknown system job: ${job.name}`);
  }
}

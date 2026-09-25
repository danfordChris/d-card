import { EMAIL_JOBS, QUEUES, type TeamInviteEmailJob } from "@dcard/core";
import { Queue } from "bullmq";
import { Redis } from "ioredis";

// Producer side of the Redis queues (docs/design/architecture/system.md). The worker consumes them.

const g = globalThis as unknown as { __dcardEmailQueue?: Queue; __dcardRedis?: Redis };

export function connection(): Redis {
  const url = process.env.REDIS_URL;
  if (!url) throw new Error("REDIS_URL is not set");
  g.__dcardRedis ??= new Redis(url, { maxRetriesPerRequest: null });
  return g.__dcardRedis;
}

export function emailQueue(): Queue {
  g.__dcardEmailQueue ??= new Queue(QUEUES.email, {
    connection: connection(),
    prefix: process.env.QUEUE_PREFIX ?? "dcard",
    defaultJobOptions: { attempts: 5, backoff: { type: "exponential", delay: 30_000 }, removeOnComplete: 1000, removeOnFail: 5000 },
  });
  return g.__dcardEmailQueue;
}

export async function enqueueTeamInviteEmail(job: TeamInviteEmailJob): Promise<void> {
  await emailQueue().add(EMAIL_JOBS.teamInvite, job, { jobId: `team-invite-${job.inviteId}` });
}

/** Test helper. */
export async function closeQueues(): Promise<void> {
  await g.__dcardEmailQueue?.close();
  await g.__dcardRedis?.quit();
  delete g.__dcardEmailQueue;
  delete g.__dcardRedis;
}

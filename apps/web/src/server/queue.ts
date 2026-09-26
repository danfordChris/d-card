import { EMAIL_JOBS, MESSAGE_JOBS, PUSH_JOBS, QUEUES, type PushNotifyJob, type TeamInviteEmailJob, type WhatsAppReply } from "@dcard/core";
import { Queue } from "bullmq";
import { Redis, type RedisOptions } from "ioredis";

// Producer side of the Redis queues (docs/design/architecture/system.md). The worker consumes them.

const g = globalThis as unknown as { __dcardEmailQueue?: Queue; __dcardPushQueue?: Queue; __dcardWhatsAppQueue?: Queue; __dcardRedis?: Redis };

/**
 * Production Redis runs on Railway behind a TCP proxy that does not encrypt, so the server
 * speaks TLS itself with a private certificate. `REDIS_TLS_CA_B64` pins that CA: only a
 * certificate it signed is accepted (the hostname check is skipped because the proxy host is
 * not in the certificate; chain verification still applies). docs/deployment.md
 */
export function redisOptions(env: Record<string, string | undefined> = process.env): RedisOptions {
  const caB64 = env.REDIS_TLS_CA_B64;
  const tls = caB64 ? { tls: { ca: Buffer.from(caB64, "base64").toString("utf8"), checkServerIdentity: () => undefined } } : {};
  return { maxRetriesPerRequest: null, ...tls };
}

export function connection(): Redis {
  const url = process.env.REDIS_URL;
  if (!url) throw new Error("REDIS_URL is not set");
  g.__dcardRedis ??= new Redis(url, redisOptions());
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

function pushQueue(): Queue {
  g.__dcardPushQueue ??= new Queue(QUEUES.push, {
    connection: connection(),
    prefix: process.env.QUEUE_PREFIX ?? "dcard",
    defaultJobOptions: { attempts: 3, backoff: { type: "exponential", delay: 10_000 }, removeOnComplete: 1000, removeOnFail: 5000 },
  });
  return g.__dcardPushQueue;
}

/**
 * Best-effort push (walk-ins, host alerts). The decision or entry is already committed, so a
 * Redis outage must not fail the door request: the host still sees it on the dashboard.
 */
export async function enqueuePush(jobs: PushNotifyJob | PushNotifyJob[] | null | undefined): Promise<void> {
  const list = (Array.isArray(jobs) ? jobs : jobs ? [jobs] : []).filter((j) => j.userIds.length);
  if (!list.length) return;
  try {
    await pushQueue().addBulk(list.map((data) => ({ name: PUSH_JOBS.notify, data })));
  } catch (err) {
    console.error("push enqueue failed", err);
  }
}

/** CNF-2 replies (acknowledgement / already recorded). Job id = inbound message id: Meta retries never reply twice. */
export async function enqueueWhatsAppReplies(replies: WhatsAppReply[]): Promise<void> {
  if (!replies.length) return;
  try {
    g.__dcardWhatsAppQueue ??= new Queue(QUEUES.whatsapp, {
      connection: connection(),
      prefix: process.env.QUEUE_PREFIX ?? "dcard",
      defaultJobOptions: { attempts: 5, backoff: { type: "exponential", delay: 15_000 }, removeOnComplete: 1000, removeOnFail: 5000 },
    });
    await g.__dcardWhatsAppQueue.addBulk(replies.map((data) => ({ name: MESSAGE_JOBS.reply, data, opts: { jobId: `reply-${data.inboundId}` } })));
  } catch (err) {
    console.error("whatsapp reply enqueue failed", err);
  }
}

/** Test helper. */
export async function closeQueues(): Promise<void> {
  await g.__dcardWhatsAppQueue?.close();
  delete g.__dcardWhatsAppQueue;
  await g.__dcardEmailQueue?.close();
  await g.__dcardPushQueue?.close();
  delete g.__dcardPushQueue;
  await g.__dcardRedis?.quit();
  delete g.__dcardEmailQueue;
  delete g.__dcardRedis;
}

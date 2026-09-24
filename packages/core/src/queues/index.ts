// Queue and job names shared by the web app (producers) and the worker (consumers).
// docs/design/architecture/system.md — Messaging and Background Processing.

export const QUEUES = {
  system: "system",
} as const;

export type QueueName = (typeof QUEUES)[keyof typeof QUEUES];

export const SYSTEM_JOBS = {
  ping: "ping",
} as const;

export type PingJobData = { sentAt: string };
export type PingJobResult = { pong: true; sentAt: string; processedAt: string };

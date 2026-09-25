// Queue and job names shared by the web app (producers) and the worker (consumers).
// docs/design/architecture/system.md — Messaging and Background Processing.

export const QUEUES = {
  system: "system",
  email: "email",
} as const;

export type QueueName = (typeof QUEUES)[keyof typeof QUEUES];

export const SYSTEM_JOBS = {
  ping: "ping",
} as const;

export type PingJobData = { sentAt: string };
export type PingJobResult = { pong: true; sentAt: string; processedAt: string };

export const EMAIL_JOBS = {
  teamInvite: "team-invite",
} as const;

/** docs/design/integrations/email.md — queue `email`, job `team-invite`. */
export type TeamInviteEmailJob = {
  inviteId: string;
  to: string;
  eventTitle: string;
  role: "treasurer" | "committee" | "door_staff" | "walkin_approver";
  link: string;
  language: "sw" | "en";
};

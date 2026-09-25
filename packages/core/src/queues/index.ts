// Queue and job names shared by the web app (producers) and the worker (consumers).
// docs/design/architecture/system.md — Messaging and Background Processing.

export const QUEUES = {
  system: "system",
  email: "email",
  sms: "sms",
  whatsapp: "whatsapp",
} as const;

export type QueueName = (typeof QUEUES)[keyof typeof QUEUES];

export const SYSTEM_JOBS = {
  ping: "ping",
  /** Every few seconds: outbox → message_log → send jobs (ADR 0003). */
  dispatchMessages: "dispatch-messages",
  /** Every 5 minutes: queue due scheduled messages (NTF-3, NTF-6, NTF-7, NTF-8). */
  scheduleMessages: "schedule-messages",
  /** Every 10 minutes: fetch NextSMS delivery status for recent SMS. */
  pollSmsDelivery: "poll-sms-delivery",
} as const;

/** Queues `sms` and `whatsapp`, job `send`; job id = message_log id. */
export const MESSAGE_JOBS = { send: "send" } as const;
export type SendMessageJob = { logId: string };

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

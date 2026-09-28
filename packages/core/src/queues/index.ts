// Queue and job names shared by the web app (producers) and the worker (consumers).
// docs/design/architecture/system.md — Messaging and Background Processing.

export const QUEUES = {
  system: "system",
  email: "email",
  sms: "sms",
  whatsapp: "whatsapp",
  push: "push",
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
  /** Every 2 minutes: check pending Snippe payments (fallback when a webhook is late). */
  pollPayments: "poll-payments",
  /** Daily: W13 retention (anonymise guests without an account 14 days after the event). */
  runRetention: "run-retention",
  /** Every 5 minutes: queue backlog, failing jobs and stuck payments → alert email (T06-06). */
  checkHealth: "check-health",
} as const;

/** Queues `sms` and `whatsapp`, job `send`; job id = message_log id. Queue `whatsapp`, job `reply`: free-form reply in the 24 h window, job id = `reply-<inbound wamid>`. */
export const MESSAGE_JOBS = { send: "send", reply: "reply" } as const;
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

/** Queue `push`, job `notify`: FCM push to every device of each user (T03-08 sender, T04-06). */
export const PUSH_JOBS = { notify: "notify" } as const;
export type PushNotifyJob = {
  userIds: string[];
  title: string;
  body: string;
  /** String values only (FCM data payload), e.g. { type: "walk_in", eventId, walkInId }. */
  data?: Record<string, string>;
};

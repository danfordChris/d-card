// Web-side shapes for manual send (MSG-13) and the host message log (MSG-9, MSG-14).
// They mirror ManualSendInput / MessageLogQuery in @dcard/api-contract. Costs are never sent to hosts.

export const MANUAL_MESSAGE_TYPES = ["invitation_card", "contribution_reminder", "attendance_confirmation", "event_reminder", "post_event_thanks"] as const;
export const MANUAL_GROUPS = ["all", "unpaid", "not_confirmed", "confirmed"] as const;
export const LOG_STATUSES = ["queued", "sent", "delivered", "read", "failed", "held"] as const;
export const LOG_CHANNELS = ["sms", "whatsapp"] as const;

export type ManualMessageType = (typeof MANUAL_MESSAGE_TYPES)[number];
export type ManualGroup = (typeof MANUAL_GROUPS)[number];
export type LogStatus = (typeof LOG_STATUSES)[number];
export type LogChannel = (typeof LOG_CHANNELS)[number];

export interface ManualSendBody {
  messageType: ManualMessageType;
  group: ManualGroup;
  preview?: true;
}

/** 200 reply to a preview request. */
export interface ManualSendPreview {
  recipients: number;
  sendsUsed: number;
  sendsAllowed: number;
}

/** 202 reply to a real send. */
export interface ManualSendResult {
  queued: number;
  sendsUsed: number;
  sendsAllowed: number;
}

export interface MessageLogItem {
  id: string;
  guestName: string | null;
  toPhone: string | null;
  messageType: string | null;
  channel: LogChannel;
  status: LogStatus;
  error: string | null;
  createdAt: string;
  sentAt: string | null;
  deliveredAt: string | null;
}

export interface OptOut {
  name: string;
  phone: string | null;
  createdAt: string;
}

export interface MessageLogPage {
  items: MessageLogItem[];
  nextBefore: string | null;
  optOuts: OptOut[];
  counts: Partial<Record<LogStatus, number>>;
}

export interface MessageLogFilters {
  status?: LogStatus;
  messageType?: string;
  channel?: LogChannel;
  q?: string;
}

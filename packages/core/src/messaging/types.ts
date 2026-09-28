// Guest message types and defaults (docs/design/features/notifications.md, NTF-1…NTF-8).

export const MESSAGE_TYPES = [
  "contribution_request",
  "thank_you",
  "contribution_reminder",
  "invitation_card",
  "card_upgraded",
  "attendance_confirmation",
  "event_reminder",
  "post_event_thanks",
] as const;

export type MessageType = (typeof MESSAGE_TYPES)[number];
export type Channel = "sms" | "whatsapp";
export type ChannelChoice = "both" | "sms" | "whatsapp";
export type Language = "sw" | "en";

export type MessageScheduleDefaults = { offsetDays?: number; timeOfDay?: string; frequencyDays?: number };

export const MESSAGE_DEFAULTS: Record<MessageType, { ntf: string; enabled: boolean; canDisable: boolean; schedule?: MessageScheduleDefaults }> = {
  contribution_request: { ntf: "NTF-1", enabled: true, canDisable: true },
  thank_you: { ntf: "NTF-2", enabled: true, canDisable: true },
  contribution_reminder: { ntf: "NTF-3", enabled: true, canDisable: true, schedule: { frequencyDays: 14, timeOfDay: "10:00" } },
  invitation_card: { ntf: "NTF-4", enabled: true, canDisable: false },
  card_upgraded: { ntf: "NTF-5", enabled: true, canDisable: true },
  attendance_confirmation: { ntf: "NTF-6", enabled: true, canDisable: true, schedule: { offsetDays: 2, timeOfDay: "10:00" } },
  event_reminder: { ntf: "NTF-7", enabled: true, canDisable: true, schedule: { offsetDays: 1, timeOfDay: "09:00" } },
  post_event_thanks: { ntf: "NTF-8", enabled: false, canDisable: true, schedule: { offsetDays: -1, timeOfDay: "10:00" } },
};

export const channelsOf = (choice: ChannelChoice): Channel[] => (choice === "both" ? ["whatsapp", "sms"] : [choice]);

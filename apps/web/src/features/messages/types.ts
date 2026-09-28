import type { MessageType } from "@dcard/core/sms";

export type ChannelChoice = "both" | "sms" | "whatsapp";
export type Schedule = { offsetDays?: number; timeOfDay?: string; frequencyDays?: number; maxCount?: number; stopOffsetDays?: number };

export type MessageSetting = {
  messageType: MessageType;
  enabled: boolean;
  channels: ChannelChoice;
  smsTextSw: string | null;
  smsTextEn: string | null;
  whatsappTemplateVariant: string | null;
  whatsappNote: string | null;
  schedule: Schedule | null;
};

export type Limits = {
  channelPerMessage: boolean;
  smsWordingEdit: boolean;
  maxSmsSegments: number;
  whatsappTemplateStyles: boolean;
  customTiming: boolean;
  maxContributionReminders: number;
  maxManualSends: number;
  marketingMessages: boolean;
};

export type SettingsView = {
  settings: MessageSetting[];
  limits: Limits;
  templates: { messageType: MessageType; variantName: string; language: "sw" | "en" }[];
};

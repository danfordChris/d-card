export type AdminWhatsappTemplate = {
  id: string;
  messageType:
    | "contribution_request"
    | "thank_you"
    | "contribution_reminder"
    | "invitation_card"
    | "card_upgraded"
    | "attendance_confirmation"
    | "event_reminder"
    | "post_event_thanks";
  variantName: string;
  language: "sw" | "en";
  metaTemplateName: string;
  category: "utility" | "marketing" | "authentication";
  bodyParams: string[];
  editableParams: string[];
  headerImage: boolean;
  confirmButtons: boolean;
  status: "pending" | "approved" | "rejected" | "paused";
  active: boolean;
  createdAt: Date | string;
  updatedAt: Date | string;
};

export type AdminProviderRate = {
  id: string;
  provider: "meta" | "nextsms";
  channel: "whatsapp" | "sms";
  category: string;
  market: string;
  priceTzs: string;
  effectiveFrom: Date | string;
  createdAt: Date | string;
};

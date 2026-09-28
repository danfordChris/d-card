import type { PlanEntitlements } from "./schema.js";

// Seed data from docs/design/domain/overview.md (event types) and
// docs/design/features/plans-and-billing.md (plans).

export const EVENT_TYPES = [
  { key: "wedding", nameSw: "Harusi", nameEn: "Wedding" },
  { key: "send_off", nameSw: "Send-off", nameEn: "Send-off" },
  { key: "kitchen_party", nameSw: "Kitchen Party", nameEn: "Kitchen party" },
  { key: "birthday", nameSw: "Siku ya Kuzaliwa", nameEn: "Birthday" },
  { key: "graduation", nameSw: "Mahafali", nameEn: "Graduation" },
  { key: "other", nameSw: "Nyingine", nameEn: "Other" },
] as const;

const noMedia: PlanEntitlements["media"] = {
  cardPhotos: 0,
  cardVideoSeconds: 0,
  animatedCard: false,
  storyPhotos: 0,
  storyVideos: 0,
  storyVideoSeconds: 0,
  gallery: false,
  galleryVideoSeconds: 0,
  galleryUploadDaysAfter: 0,
  galleryPageMonths: 0,
  galleryUploadsPerGuest: 0,
  slideshow: false,
};

export const PLANS: { key: string; name: string; pricePerGuest: number; entitlements: PlanEntitlements }[] = [
  {
    key: "msingi",
    name: "Msingi",
    pricePerGuest: 1000,
    entitlements: {
      doorStaffAccounts: 2,
      autoUpgrade: false,
      maxContributionReminders: 0,
      channelPerMessage: false,
      smsWordingEdit: false,
      maxSmsSegments: 1,
      whatsappTemplateStyles: false,
      customTiming: false,
      maxManualSends: 0,
      marketingMessages: false,
      media: noMedia,
    },
  },
  {
    key: "kawaida",
    name: "Kawaida",
    pricePerGuest: 1500,
    entitlements: {
      doorStaffAccounts: 5,
      autoUpgrade: true,
      maxContributionReminders: 3,
      channelPerMessage: true,
      smsWordingEdit: true,
      maxSmsSegments: 1,
      whatsappTemplateStyles: true,
      customTiming: true,
      maxManualSends: 2,
      marketingMessages: false,
      media: {
        cardPhotos: 5,
        cardVideoSeconds: 30,
        animatedCard: false,
        storyPhotos: 20,
        storyVideos: 1,
        storyVideoSeconds: 60,
        gallery: true,
        galleryVideoSeconds: 30,
        galleryUploadDaysAfter: 3,
        galleryPageMonths: 3,
        galleryUploadsPerGuest: 20,
        slideshow: false,
      },
    },
  },
  {
    key: "premium",
    name: "Premium",
    pricePerGuest: 2000,
    entitlements: {
      doorStaffAccounts: null,
      autoUpgrade: true,
      maxContributionReminders: 6,
      channelPerMessage: true,
      smsWordingEdit: true,
      maxSmsSegments: 2,
      whatsappTemplateStyles: true,
      customTiming: true,
      maxManualSends: 5,
      marketingMessages: true,
      media: {
        cardPhotos: 10,
        cardVideoSeconds: 60,
        animatedCard: true,
        storyPhotos: 50,
        storyVideos: 5,
        storyVideoSeconds: 120,
        gallery: true,
        galleryVideoSeconds: 60,
        galleryUploadDaysAfter: 7,
        galleryPageMonths: 12,
        galleryUploadsPerGuest: 50,
        slideshow: true,
      },
    },
  },
];

// Default WhatsApp template variants (docs/design/features/notifications.md MSG-5). Seeded as
// `pending`: an admin marks each one approved once Meta approves the template of that name.
type TemplateSeed = {
  messageType:
    | "contribution_request"
    | "thank_you"
    | "contribution_reminder"
    | "invitation_card"
    | "card_upgraded"
    | "attendance_confirmation"
    | "event_reminder"
    | "post_event_thanks";
  bodyParams: string[];
  category: "utility" | "marketing";
  headerImage?: boolean;
  confirmButtons?: boolean;
  editableParams?: string[];
};

const TEMPLATE_SEEDS: TemplateSeed[] = [
  { messageType: "contribution_request", bodyParams: ["guest_name", "pledge_amount", "event_title", "payment_details", "contact_name", "contact_phone"], category: "utility" },
  { messageType: "thank_you", bodyParams: ["guest_name", "amount_paid", "event_title", "balance", "contact_name", "contact_phone"], category: "utility" },
  { messageType: "contribution_reminder", bodyParams: ["guest_name", "event_title", "balance", "payment_details", "contact_name", "contact_phone"], category: "utility" },
  {
    messageType: "invitation_card",
    bodyParams: ["guest_name", "event_title", "date", "time", "venue", "card_number", "card_link", "note"],
    category: "utility",
    headerImage: true,
    editableParams: ["note"],
  },
  { messageType: "card_upgraded", bodyParams: ["guest_name", "event_title", "card_type", "card_number"], category: "utility" },
  { messageType: "attendance_confirmation", bodyParams: ["guest_name", "event_title", "date", "time", "venue"], category: "utility", confirmButtons: true },
  { messageType: "event_reminder", bodyParams: ["guest_name", "event_title", "date", "time", "venue", "card_number"], category: "utility" },
  { messageType: "post_event_thanks", bodyParams: ["guest_name", "event_title", "note"], category: "marketing", editableParams: ["note"] },
];

export const WHATSAPP_TEMPLATES = TEMPLATE_SEEDS.flatMap((t) =>
  (["sw", "en"] as const).map((language) => ({
    messageType: t.messageType,
    variantName: "standard",
    language,
    metaTemplateName: `dcard_${t.messageType}_standard`,
    category: t.category,
    bodyParams: t.bodyParams,
    editableParams: t.editableParams ?? [],
    headerImage: t.headerImage ?? false,
    confirmButtons: t.confirmButtons ?? false,
    status: "pending" as const,
  })),
);

// Internal cost tracking (docs/research/whatsapp-pricing.md). TZS per delivered WhatsApp
// message by category (US$ rate × 2,600 TZS/US$, admin-editable) and per NextSMS segment.
export const PROVIDER_RATES = [
  { provider: "meta", channel: "whatsapp" as const, category: "utility", priceTzs: "10.4000" },
  { provider: "meta", channel: "whatsapp" as const, category: "marketing", priceTzs: "58.5000" },
  { provider: "meta", channel: "whatsapp" as const, category: "service", priceTzs: "0.0000" },
  { provider: "nextsms", channel: "sms" as const, category: "sms_segment", priceTzs: "15.0000" },
].map((r) => ({ ...r, market: "TZ", effectiveFrom: new Date("2026-01-01T00:00:00Z") }));

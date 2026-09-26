import { sql } from "drizzle-orm";
import {
  bigint,
  boolean,
  check,
  index,
  integer,
  jsonb,
  pgEnum,
  pgTable,
  primaryKey,
  text,
  timestamp,
  numeric,
  date,
  unique,
  uuid,
} from "drizzle-orm/pg-core";

// Schema v1 (phase 00): foundation tables only.
// Source: docs/design/data-models/postgres.md

const id = () => uuid("id").primaryKey().defaultRandom();
const createdAt = () => timestamp("created_at", { withTimezone: true }).notNull().defaultNow();
const updatedAt = () =>
  timestamp("updated_at", { withTimezone: true })
    .notNull()
    .defaultNow()
    .$onUpdate(() => new Date());

export const languageEnum = pgEnum("language", ["sw", "en"]);
export const authProviderEnum = pgEnum("auth_provider", ["password", "google", "apple"]);
export const eventStatusEnum = pgEnum("event_status", ["draft", "published", "completed", "cancelled"]);
export const eventRoleEnum = pgEnum("event_role_type", [
  "treasurer",
  "committee",
  "door_staff",
  "walkin_approver",
]);
export const planBillingEnum = pgEnum("plan_billing", ["per_event", "subscription"]);
export const auditActorTypeEnum = pgEnum("audit_actor_type", ["user", "system"]);

/** A real human, identified platform-wide by phone (255 + 9 digits). */
export const person = pgTable(
  "person",
  {
    id: id(),
    phone: text("phone").notNull().unique(),
    name: text("name").notNull(),
    language: languageEnum("language").notNull().default("sw"),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (t) => [check("person_phone_format", sql`${t.phone} ~ '^255[0-9]{9}$'`)],
);

/** A login. Credentials live in Firebase Auth; this row links the Firebase UID to D-Card data. */
export const userAccount = pgTable("user_account", {
  id: id(),
  firebaseUid: text("firebase_uid").notNull().unique(),
  email: text("email"),
  authProvider: authProviderEnum("auth_provider").notNull(),
  personId: uuid("person_id").references(() => person.id, { onDelete: "set null" }),
  isAdmin: boolean("is_admin").notNull().default(false),
  emailVerifiedAt: timestamp("email_verified_at", { withTimezone: true }),
  createdAt: createdAt(),
});

/** Admin-managed event types (wedding, send-off, kitchen party, ...). */
export const eventType = pgTable("event_type", {
  id: id(),
  key: text("key").notNull().unique(),
  nameSw: text("name_sw").notNull(),
  nameEn: text("name_en").notNull(),
  active: boolean("active").notNull().default(true),
});

/** Plan entitlements and limits (docs/design/features/plans-and-billing.md). */
export type PlanEntitlements = {
  doorStaffAccounts: number | null; // null = unlimited
  autoUpgrade: boolean;
  maxContributionReminders: number;
  channelPerMessage: boolean;
  smsWordingEdit: boolean;
  maxSmsSegments: number;
  whatsappTemplateStyles: boolean;
  customTiming: boolean;
  maxManualSends: number;
  marketingMessages: boolean;
  media: {
    cardPhotos: number;
    cardVideoSeconds: number;
    animatedCard: boolean;
    storyPhotos: number;
    storyVideos: number;
    storyVideoSeconds: number;
    gallery: boolean;
    galleryVideoSeconds: number;
    galleryUploadDaysAfter: number;
    galleryPageMonths: number;
    galleryUploadsPerGuest: number;
    slideshow: boolean;
  };
};

export const plan = pgTable(
  "plan",
  {
    id: id(),
    key: text("key").notNull().unique(),
    name: text("name").notNull(),
    pricePerGuest: integer("price_per_guest").notNull(),
    billing: planBillingEnum("billing").notNull().default("per_event"),
    entitlements: jsonb("entitlements").$type<PlanEntitlements>().notNull(),
    active: boolean("active").notNull().default(true),
    createdAt: createdAt(),
  },
  (t) => [check("plan_price_positive", sql`${t.pricePerGuest} > 0`)],
);

export const event = pgTable(
  "event",
  {
    id: id(),
    hostUserId: uuid("host_user_id")
      .notNull()
      .references(() => userAccount.id),
    eventTypeId: uuid("event_type_id")
      .notNull()
      .references(() => eventType.id),
    title: text("title").notNull(),
    startsAt: timestamp("starts_at", { withTimezone: true }).notNull(),
    endsAt: timestamp("ends_at", { withTimezone: true }),
    timeZone: text("time_zone").notNull().default("Africa/Dar_es_Salaam"),
    venueName: text("venue_name"),
    venueAddress: text("venue_address"),
    venueMapUrl: text("venue_map_url"),
    contactName: text("contact_name").notNull(),
    contactPhone: text("contact_phone").notNull(),
    contact2Name: text("contact2_name"),
    contact2Phone: text("contact2_phone"),
    status: eventStatusEnum("status").notNull().default("draft"),
    confirmationEnabled: boolean("confirmation_enabled").notNull().default(true),
    confirmationOffsetDays: integer("confirmation_offset_days").notNull().default(2),
    headcountPct: integer("headcount_pct").notNull().default(70),
    autoUpgradeEnabled: boolean("auto_upgrade_enabled").notNull().default(true),
    /** Next card guest sequence (the NNN in NNN-PPPP), taken atomically at issue. */
    nextGuestSeq: integer("next_guest_seq").notNull().default(1),
    singleAmount: integer("single_amount"),
    doubleAmount: integer("double_amount"),
    /** Contribution budget target (TZS), for dashboard progress (CON-9). */
    budgetAmount: integer("budget_amount"),
    /** How contributors pay the committee (e.g. "M-Pesa 0754 123 456 (Asha)"); used in NTF-1/NTF-3. */
    paymentDetails: text("payment_details"),
    currency: text("currency").notNull().default("TZS"),
    photoAlbumUrl: text("photo_album_url"),
    reminderFrequencyDays: integer("reminder_frequency_days"),
    retentionProcessedAt: timestamp("retention_processed_at", { withTimezone: true }),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (t) => [
    check("event_contact_phone_format", sql`${t.contactPhone} ~ '^255[0-9]{9}$'`),
    check(
      "event_contact2_phone_format",
      sql`${t.contact2Phone} IS NULL OR ${t.contact2Phone} ~ '^255[0-9]{9}$'`,
    ),
    check("event_headcount_pct_range", sql`${t.headcountPct} BETWEEN 0 AND 100`),
    check("event_amounts_non_negative", sql`coalesce(${t.singleAmount}, 0) >= 0 AND coalesce(${t.doubleAmount}, 0) >= 0`),
  ],
);

export const eventRole = pgTable(
  "event_role",
  {
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    userId: uuid("user_id")
      .notNull()
      .references(() => userAccount.id, { onDelete: "cascade" }),
    role: eventRoleEnum("role").notNull(),
    createdAt: createdAt(),
  },
  (t) => [primaryKey({ columns: [t.eventId, t.userId, t.role] })],
);

/** Append-only audit trail (UPDATE/DELETE blocked by trigger; see migration 0001). */
export const auditLog = pgTable("audit_log", {
  id: id(),
  createdAt: createdAt(),
  actorType: auditActorTypeEnum("actor_type").notNull(),
  actorUserId: uuid("actor_user_id").references(() => userAccount.id),
  eventId: uuid("event_id").references(() => event.id),
  action: text("action").notNull(),
  targetType: text("target_type").notNull(),
  targetId: text("target_id"),
  oldValue: jsonb("old_value"),
  newValue: jsonb("new_value"),
  ip: text("ip"),
  device: text("device"),
});

/** The plan chosen for an event and what has been paid (docs/design/features/plans-and-billing.md). */
export const eventPlan = pgTable(
  "event_plan",
  {
    eventId: uuid("event_id")
      .primaryKey()
      .references(() => event.id, { onDelete: "cascade" }),
    planId: uuid("plan_id")
      .notNull()
      .references(() => plan.id),
    /** Price per guest card at the time the plan was chosen (TZS). */
    pricePerGuest: integer("price_per_guest").notNull(),
    /** Guest cards paid for; 0 until the host pays (phase 05). */
    guestLimit: integer("guest_limit").notNull().default(0),
    amountPaid: integer("amount_paid").notNull().default(0),
    purchasedAt: timestamp("purchased_at", { withTimezone: true }),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (t) => [
    check("event_plan_amounts_non_negative", sql`${t.guestLimit} >= 0 AND ${t.amountPaid} >= 0`),
  ],
);

export const cardTypeEnum = pgEnum("card_type", ["single", "double"]);
export const invitationStatusEnum = pgEnum("invitation_status", ["pending", "issued", "cancelled"]);
export const rsvpStatusEnum = pgEnum("rsvp_status", ["none", "yes", "no"]);
export const confirmationStatusEnum = pgEnum("confirmation_status", ["none", "yes", "no"]);
export const consentSourceEnum = pgEnum("consent_source", ["form", "import", "contacts", "copy"]);

/**
 * A Person invited to one event (docs/design/features/guests-and-cards.md).
 * guest_name / guest_phone are the host-owned snapshot; card fields arrive in phase 02.
 */
export const invitation = pgTable(
  "invitation",
  {
    id: id(),
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    personId: uuid("person_id").references(() => person.id, { onDelete: "set null" }),
    guestName: text("guest_name").notNull(),
    guestPhone: text("guest_phone").notNull(),
    partnerName: text("partner_name"),
    cardType: cardTypeEnum("card_type").notNull().default("single"),
    totalEntries: integer("total_entries").notNull().default(1),
    status: invitationStatusEnum("status").notNull().default("pending"),
    // Card (set once at issue; kept on cancel/reinstate). Tokens: HMAC hash for lookup,
    // AES-GCM copy so the card can be re-sent (docs/adr/0003-technical-stack.md).
    guestSeq: integer("guest_seq"),
    cardNumber: text("card_number"),
    qrTokenHash: text("qr_token_hash").unique(),
    linkTokenHash: text("link_token_hash").unique(),
    qrTokenEnc: text("qr_token_enc"),
    linkTokenEnc: text("link_token_enc"),
    issuedAt: timestamp("issued_at", { withTimezone: true }),
    cancelledAt: timestamp("cancelled_at", { withTimezone: true }),
    // GST-12: RSVP (Yes/No, ADR 0001 O19) and dietary needs through the card link.
    rsvpStatus: rsvpStatusEnum("rsvp_status").notNull().default("none"),
    rsvpAt: timestamp("rsvp_at", { withTimezone: true }),
    dietaryNotes: text("dietary_notes"),
    // NTF-6 attendance confirmation (WhatsApp buttons now; host-recorded answers in phase 04).
    confirmationStatus: confirmationStatusEnum("confirmation_status").notNull().default("none"),
    confirmationAt: timestamp("confirmation_at", { withTimezone: true }),
    confirmationSource: text("confirmation_source"),
    /** Set when synced offline entries exceed the card's allowance (CHK-7); alerts once. */
    overUsedAt: timestamp("over_used_at", { withTimezone: true }),
    createdBy: uuid("created_by").references(() => userAccount.id),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (t) => [
    unique("invitation_event_person_unique").on(t.eventId, t.personId),
    unique("invitation_event_card_number_unique").on(t.eventId, t.cardNumber),
    unique("invitation_event_guest_seq_unique").on(t.eventId, t.guestSeq),
    check("invitation_card_number_format", sql`${t.cardNumber} IS NULL OR ${t.cardNumber} ~ '^[0-9]{3,}-[0-9]{4}$'`),
    index("invitation_event_created_idx").on(t.eventId, t.createdAt),
    check("invitation_guest_phone_format", sql`${t.guestPhone} ~ '^255[0-9]{9}$'`),
    check(
      "invitation_entries_match_type",
      sql`(${t.cardType} = 'single' AND ${t.totalEntries} = 1) OR (${t.cardType} = 'double' AND ${t.totalEntries} = 2)`,
    ),
  ],
);

/** Host/committee confirmation that guests agreed to receive event messages (MSG-14). */
export const guestConsent = pgTable("guest_consent", {
  id: id(),
  eventId: uuid("event_id")
    .notNull()
    .references(() => event.id, { onDelete: "cascade" }),
  confirmedBy: uuid("confirmed_by")
    .notNull()
    .references(() => userAccount.id),
  source: consentSourceEnum("source").notNull(),
  guestCount: integer("guest_count").notNull(),
  confirmedAt: timestamp("confirmed_at", { withTimezone: true }).notNull().defaultNow(),
});

export const importSourceEnum = pgEnum("import_source", ["file", "past_event"]);
export const importStatusEnum = pgEnum("import_status", ["previewed", "completed"]);

export type ImportRow = { row: number; name: string; phone: string; cardType: "single" | "double"; partnerName: string | null };
export type ImportReport = {
  total: number;
  valid: number;
  invalid: { row: number; phone: string; reason: string }[];
  duplicatesInFile: { row: number; phone: string; firstRow: number }[];
  existing: { row: number; phone: string; name: string }[];
};

/** A guest import preview; nothing is written to invitations until it is confirmed (GST-5, GST-7). */
export const importJob = pgTable("import_job", {
  id: id(),
  eventId: uuid("event_id")
    .notNull()
    .references(() => event.id, { onDelete: "cascade" }),
  source: importSourceEnum("source").notNull(),
  status: importStatusEnum("status").notNull().default("previewed"),
  fileName: text("file_name"),
  sourceEventId: uuid("source_event_id").references(() => event.id, { onDelete: "set null" }),
  /** Rows that will be created on confirm (valid, not duplicates, not already invited). */
  rows: jsonb("rows").$type<ImportRow[]>().notNull(),
  report: jsonb("report").$type<ImportReport>().notNull(),
  total: integer("total").notNull(),
  imported: integer("imported").notNull().default(0),
  createdBy: uuid("created_by")
    .notNull()
    .references(() => userAccount.id),
  createdAt: createdAt(),
  completedAt: timestamp("completed_at", { withTimezone: true }),
});

/** Invitation for a team member (docs/design/features/auth.md › Team Invitation). Token stored hashed. */
export const teamInvite = pgTable("team_invite", {
  id: id(),
  eventId: uuid("event_id")
    .notNull()
    .references(() => event.id, { onDelete: "cascade" }),
  role: eventRoleEnum("role").notNull(),
  email: text("email"),
  tokenHash: text("token_hash").notNull().unique(),
  createdBy: uuid("created_by")
    .notNull()
    .references(() => userAccount.id),
  expiresAt: timestamp("expires_at", { withTimezone: true }).notNull(),
  acceptedBy: uuid("accepted_by").references(() => userAccount.id),
  acceptedAt: timestamp("accepted_at", { withTimezone: true }),
  revokedAt: timestamp("revoked_at", { withTimezone: true }),
  createdAt: createdAt(),
});

// ── Contributions (docs/design/features/contributions.md) ───────────────────
// D-Card never holds contribution money: payments are records of money paid outside.

export const pledgeStatusEnum = pgEnum("pledge_status", ["not_paid", "part_paid", "fully_paid"]);
export const paymentKindEnum = pgEnum("payment_kind", ["payment", "refund"]);
export const paymentMethodEnum = pgEnum("payment_method", ["mpesa", "mixx_by_yas", "airtel_money", "halopesa", "bank", "cash", "other"]);

export const pledge = pgTable(
  "pledge",
  {
    id: id(),
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    invitationId: uuid("invitation_id")
      .notNull()
      .unique()
      .references(() => invitation.id, { onDelete: "cascade" }),
    amountPledged: integer("amount_pledged").notNull(),
    cardType: cardTypeEnum("card_type").notNull(),
    /** Net of refunds. Maintained with every payment change. */
    amountPaid: integer("amount_paid").notNull().default(0),
    amountExtra: integer("amount_extra").notNull().default(0),
    status: pledgeStatusEnum("status").notNull().default("not_paid"),
    upgradedAt: timestamp("upgraded_at", { withTimezone: true }),
    createdBy: uuid("created_by").references(() => userAccount.id),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (t) => [check("pledge_amount_positive", sql`${t.amountPledged} > 0`), index("pledge_event_idx").on(t.eventId)],
);

export const payment = pgTable(
  "payment",
  {
    id: id(),
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    pledgeId: uuid("pledge_id")
      .notNull()
      .references(() => pledge.id, { onDelete: "cascade" }),
    kind: paymentKindEnum("kind").notNull(),
    /** Signed: positive for payments, negative for refunds. */
    amount: integer("amount").notNull(),
    method: paymentMethodEnum("method").notNull(),
    reference: text("reference"),
    paidOn: date("paid_on").notNull(),
    recordedBy: uuid("recorded_by").references(() => userAccount.id),
    recordedAt: timestamp("recorded_at", { withTimezone: true }).notNull().defaultNow(),
    updatedAt: updatedAt(),
  },
  (t) => [
    check("payment_sign_matches_kind", sql`(${t.kind} = 'payment' AND ${t.amount} > 0) OR (${t.kind} = 'refund' AND ${t.amount} < 0)`),
    index("payment_pledge_idx").on(t.pledgeId),
  ],
);

// ── Messaging (docs/design/features/notifications.md, docs/design/integrations/messaging.md) ──

export const messageTypeEnum = pgEnum("message_type", [
  "contribution_request", // NTF-1
  "thank_you", // NTF-2
  "contribution_reminder", // NTF-3
  "invitation_card", // NTF-4
  "card_upgraded", // NTF-5
  "attendance_confirmation", // NTF-6
  "event_reminder", // NTF-7
  "post_event_thanks", // NTF-8
]);
export const messageChannelEnum = pgEnum("message_channel", ["sms", "whatsapp"]);
export const messageStatusEnum = pgEnum("message_status", ["queued", "sent", "delivered", "read", "failed", "held"]);
export const messageDirectionEnum = pgEnum("message_direction", ["outbound", "inbound"]);
export const templateCategoryEnum = pgEnum("template_category", ["utility", "marketing", "authentication"]);
export const templateStatusEnum = pgEnum("template_status", ["pending", "approved", "rejected", "paused"]);
export const channelChoiceEnum = pgEnum("channel_choice", ["both", "sms", "whatsapp"]);

/** Transactional outbox: written with the business change, dispatched by the worker (ADR 0003). */
export const outbox = pgTable(
  "outbox",
  {
    id: id(),
    /** Idempotency key, e.g. `thank_you:payment:<paymentId>`. */
    key: text("key").notNull().unique(),
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    invitationId: uuid("invitation_id").references(() => invitation.id, { onDelete: "cascade" }),
    messageType: messageTypeEnum("message_type").notNull(),
    /** Extra values for placeholders (e.g. payment amount at the time). */
    payload: jsonb("payload").$type<Record<string, string | number | null>>().notNull().default({}),
    /** Only these channels (manual/test sends); null = use event settings. */
    channels: channelChoiceEnum("channels"),
    /** Test sends go to this phone instead of the guest. */
    toPhone: text("to_phone"),
    createdAt: createdAt(),
    dispatchedAt: timestamp("dispatched_at", { withTimezone: true }),
  },
  (t) => [index("outbox_pending_idx").on(t.dispatchedAt, t.createdAt)],
);

export const messageLog = pgTable(
  "message_log",
  {
    id: id(),
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    invitationId: uuid("invitation_id").references(() => invitation.id, { onDelete: "set null" }),
    outboxId: uuid("outbox_id").references(() => outbox.id, { onDelete: "set null" }),
    channel: messageChannelEnum("channel").notNull(),
    direction: messageDirectionEnum("direction").notNull().default("outbound"),
    messageType: messageTypeEnum("message_type"),
    toPhone: text("to_phone"),
    language: languageEnum("language").notNull().default("sw"),
    /** SMS text as sent (WhatsApp: template name + params live in `detail`). */
    body: text("body"),
    detail: jsonb("detail").$type<Record<string, unknown>>(),
    templateId: uuid("template_id"),
    providerMessageId: text("provider_message_id"),
    status: messageStatusEnum("status").notNull().default("queued"),
    error: text("error"),
    segments: integer("segments"),
    /** Estimated cost in TZS (internal; hosts never see it). */
    costTzs: numeric("cost_tzs", { precision: 12, scale: 2 }),
    attempts: integer("attempts").notNull().default(0),
    createdAt: createdAt(),
    sentAt: timestamp("sent_at", { withTimezone: true }),
    deliveredAt: timestamp("delivered_at", { withTimezone: true }),
    updatedAt: updatedAt(),
  },
  (t) => [
    unique("message_log_outbox_channel_unique").on(t.outboxId, t.channel),
    index("message_log_event_idx").on(t.eventId, t.createdAt),
    index("message_log_provider_idx").on(t.providerMessageId),
  ],
);

export type MessageSchedule = {
  offsetDays?: number; // days before (negative = after) the event start
  timeOfDay?: string; // "HH:MM" in the event time zone
  frequencyDays?: number;
  maxCount?: number;
  stopOffsetDays?: number;
  quietStart?: string;
  quietEnd?: string;
};

export const eventMessageSetting = pgTable(
  "event_message_setting",
  {
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    messageType: messageTypeEnum("message_type").notNull(),
    enabled: boolean("enabled").notNull(),
    channels: channelChoiceEnum("channels").notNull().default("both"),
    smsTextSw: text("sms_text_sw"),
    smsTextEn: text("sms_text_en"),
    whatsappTemplateVariant: text("whatsapp_template_variant"),
    whatsappNote: text("whatsapp_note"),
    schedule: jsonb("schedule").$type<MessageSchedule>(),
    updatedBy: uuid("updated_by").references(() => userAccount.id),
    updatedAt: updatedAt(),
  },
  (t) => [primaryKey({ columns: [t.eventId, t.messageType] })],
);

export const whatsappTemplate = pgTable(
  "whatsapp_template",
  {
    id: id(),
    messageType: messageTypeEnum("message_type").notNull(),
    variantName: text("variant_name").notNull(),
    language: languageEnum("language").notNull(),
    metaTemplateName: text("meta_template_name").notNull(),
    category: templateCategoryEnum("category").notNull(),
    /** Placeholder keys for the body parameters, in order ({{1}}, {{2}}, …). */
    bodyParams: jsonb("body_params").$type<string[]>().notNull(),
    /** Parameters the host may edit (e.g. ["note"]). */
    editableParams: jsonb("editable_params").$type<string[]>().notNull().default([]),
    headerImage: boolean("header_image").notNull().default(false),
    /** Quick-reply confirmation buttons (NTF-6). */
    confirmButtons: boolean("confirm_buttons").notNull().default(false),
    status: templateStatusEnum("status").notNull().default("pending"),
    active: boolean("active").notNull().default(true),
    createdAt: createdAt(),
    updatedAt: updatedAt(),
  },
  (t) => [unique("whatsapp_template_variant_unique").on(t.messageType, t.variantName, t.language)],
);

export const providerRate = pgTable("provider_rate", {
  id: id(),
  provider: text("provider").notNull(), // meta | nextsms
  channel: messageChannelEnum("channel").notNull(),
  /** Meta category or `sms_segment`. */
  category: text("category").notNull(),
  market: text("market").notNull().default("TZ"),
  priceTzs: numeric("price_tzs", { precision: 12, scale: 4 }).notNull(),
  effectiveFrom: timestamp("effective_from", { withTimezone: true }).notNull(),
  createdAt: createdAt(),
});

export const whatsappOptout = pgTable(
  "whatsapp_optout",
  {
    personId: uuid("person_id")
      .notNull()
      .references(() => person.id, { onDelete: "cascade" }),
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    createdAt: createdAt(),
  },
  (t) => [primaryKey({ columns: [t.personId, t.eventId] })],
);

// T03-08 push notification setup (docs/design/integrations/firebase.md › FCM/APNs)

export const devicePlatformEnum = pgEnum("device_platform", ["android", "ios"]);
export const deviceAppEnum = pgEnum("device_app", ["mobile", "door"]);

/** An FCM registration token for one app install, owned by the signed-in user. */
export const deviceToken = pgTable(
  "device_token",
  {
    id: id(),
    userId: uuid("user_id")
      .notNull()
      .references(() => userAccount.id, { onDelete: "cascade" }),
    token: text("token").notNull().unique(),
    platform: devicePlatformEnum("platform").notNull(),
    app: deviceAppEnum("app").notNull(),
    createdAt: createdAt(),
    lastSeenAt: timestamp("last_seen_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (t) => [index("device_token_user_idx").on(t.userId)],
);

// ── Door check-in (T04-01; docs/design/features/check-in.md, architecture/offline-sync.md) ──

export const checkInMethodEnum = pgEnum("check_in_method", ["qr", "card_number", "name"]);
export const checkInOutcomeEnum = pgEnum("check_in_outcome", [
  "admitted",
  "fully_used",
  "cancelled",
  "not_issued",
  "too_many",
  "not_found",
  "locked",
]);
export const entrySourceEnum = pgEnum("entry_source", ["online", "offline"]);

/** A D-Card Door install registered for one event (AUTH-9). The id is generated by the app. */
export const doorDevice = pgTable(
  "door_device",
  {
    id: uuid("id").primaryKey(),
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    staffUserId: uuid("staff_user_id")
      .notNull()
      .references(() => userAccount.id),
    name: text("name"),
    createdAt: createdAt(),
    lastSeenAt: timestamp("last_seen_at", { withTimezone: true }).notNull().defaultNow(),
    lastSyncAt: timestamp("last_sync_at", { withTimezone: true }),
    /** Entries the device reported as still waiting to upload (dashboard, offline-sync 9.4). */
    pendingCount: integer("pending_count").notNull().default(0),
    revokedAt: timestamp("revoked_at", { withTimezone: true }),
    revokedBy: uuid("revoked_by").references(() => userAccount.id),
  },
  (t) => [index("door_device_event_idx").on(t.eventId)],
);

/**
 * One admission (1 or 2 people). Immutable; the id is generated on the device, so the set of
 * entries is a grow-only set and entries used per card are derived from it (offline-sync 9.2).
 */
export const entry = pgTable(
  "entry",
  {
    id: uuid("id").primaryKey(),
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    /** Null for walk-in entries (T04-06), which set walkin_request_id instead. */
    invitationId: uuid("invitation_id").references(() => invitation.id, { onDelete: "cascade" }),
    walkinRequestId: uuid("walkin_request_id"),
    admittedCount: integer("admitted_count").notNull(),
    method: checkInMethodEnum("method").notNull(),
    staffUserId: uuid("staff_user_id").references(() => userAccount.id),
    deviceId: uuid("device_id").references(() => doorDevice.id),
    source: entrySourceEnum("source").notNull().default("online"),
    occurredAt: timestamp("occurred_at", { withTimezone: true }).notNull(),
    receivedAt: timestamp("received_at", { withTimezone: true }).notNull().defaultNow(),
  },
  (t) => [
    check("entry_admitted_count", sql`${t.admittedCount} between 1 and 2`),
    check("entry_target", sql`${t.invitationId} is not null or ${t.walkinRequestId} is not null`),
    index("entry_invitation_idx").on(t.invitationId),
    index("entry_event_idx").on(t.eventId, t.occurredAt),
  ],
);

/** Every door attempt, admitted or refused (CHK-4, CHK-5). Append-only; offline ones keep their time. */
export const checkInAttempt = pgTable(
  "check_in_attempt",
  {
    id: uuid("id").primaryKey().defaultRandom(),
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    invitationId: uuid("invitation_id").references(() => invitation.id, { onDelete: "set null" }),
    entryId: uuid("entry_id"),
    deviceId: uuid("device_id").references(() => doorDevice.id),
    staffUserId: uuid("staff_user_id").references(() => userAccount.id),
    method: checkInMethodEnum("method").notNull(),
    /** What was typed for card-number and name lookups (never a QR token). */
    query: text("query"),
    outcome: checkInOutcomeEnum("outcome").notNull(),
    source: entrySourceEnum("source").notNull().default("online"),
    occurredAt: timestamp("occurred_at", { withTimezone: true }).notNull().defaultNow(),
    createdAt: createdAt(),
  },
  (t) => [index("check_in_attempt_event_idx").on(t.eventId, t.occurredAt)],
);

// ── Walk-ins (T04-06; check-in.md CHK-8, CHK-8a) ──

export const walkinStatusEnum = pgEnum("walkin_status", ["pending", "approved", "refused", "admitted_offline", "accepted", "flagged"]);

/** A person admitted without a valid card, or beyond their card, with approval. Id from the device. */
export const walkinRequest = pgTable(
  "walkin_request",
  {
    id: uuid("id").primaryKey(),
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    staffUserId: uuid("staff_user_id").references(() => userAccount.id),
    deviceId: uuid("device_id").references(() => doorDevice.id),
    invitationId: uuid("invitation_id").references(() => invitation.id, { onDelete: "set null" }),
    description: text("description").notNull(),
    admittedCount: integer("admitted_count").notNull().default(1),
    source: entrySourceEnum("source").notNull().default("online"),
    /** Required for offline walk-ins (e.g. "host approved by phone call"). */
    offlineReason: text("offline_reason"),
    status: walkinStatusEnum("status").notNull(),
    decidedBy: uuid("decided_by").references(() => userAccount.id),
    decidedAt: timestamp("decided_at", { withTimezone: true }),
    occurredAt: timestamp("occurred_at", { withTimezone: true }).notNull(),
    createdAt: createdAt(),
  },
  (t) => [
    check("walkin_admitted_count", sql`${t.admittedCount} between 1 and 2`),
    check("walkin_offline_reason", sql`${t.source} = 'online' or ${t.offlineReason} is not null`),
    index("walkin_request_event_idx").on(t.eventId, t.status),
  ],
);

// ── Billing (T05-01; plans-and-billing.md, integrations/snippe.md) ──

export const paymentAttemptStatusEnum = pgEnum("payment_attempt_status", ["pending", "completed", "failed", "expired"]);
export const hostPaymentMethodEnum = pgEnum("host_payment_method", ["mobile", "session"]);

/** One try to pay through Snippe. Money is only recorded as `host_payment` when it completes. */
export const paymentAttempt = pgTable(
  "payment_attempt",
  {
    id: id(),
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    hostUserId: uuid("host_user_id")
      .notNull()
      .references(() => userAccount.id),
    planId: uuid("plan_id")
      .notNull()
      .references(() => plan.id),
    pricePerGuest: integer("price_per_guest").notNull(),
    /** Total guest cards after this payment. */
    guestCards: integer("guest_cards").notNull(),
    subtotal: integer("subtotal").notNull(),
    discountAmount: integer("discount_amount").notNull().default(0),
    amount: integer("amount").notNull(),
    method: hostPaymentMethodEnum("method").notNull(),
    phone: text("phone"),
    provider: text("provider").notNull().default("snippe"),
    /** Snippe payment/session reference. */
    providerReference: text("provider_reference").unique(),
    idempotencyKey: text("idempotency_key").notNull().unique(),
    checkoutUrl: text("checkout_url"),
    status: paymentAttemptStatusEnum("status").notNull().default("pending"),
    failureReason: text("failure_reason"),
    createdAt: createdAt(),
    completedAt: timestamp("completed_at", { withTimezone: true }),
  },
  (t) => [
    check("payment_attempt_amounts", sql`${t.amount} >= 0 AND ${t.guestCards} > 0`),
    check("payment_attempt_phone_format", sql`${t.phone} IS NULL OR ${t.phone} ~ '^255[0-9]{9}$'`),
    index("payment_attempt_event_idx").on(t.eventId, t.createdAt),
    index("payment_attempt_pending_idx").on(t.status, t.createdAt),
  ],
);

/** Confirmed payment for an event's guest cards (exactly one per completed attempt). */
export const hostPayment = pgTable(
  "host_payment",
  {
    id: id(),
    attemptId: uuid("attempt_id")
      .notNull()
      .unique()
      .references(() => paymentAttempt.id),
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    hostUserId: uuid("host_user_id")
      .notNull()
      .references(() => userAccount.id),
    planId: uuid("plan_id")
      .notNull()
      .references(() => plan.id),
    guestCards: integer("guest_cards").notNull(),
    amount: integer("amount").notNull(),
    discountAmount: integer("discount_amount").notNull().default(0),
    method: hostPaymentMethodEnum("method").notNull(),
    reference: text("reference").notNull(),
    paidAt: timestamp("paid_at", { withTimezone: true }).notNull(),
    createdAt: createdAt(),
  },
  (t) => [index("host_payment_host_idx").on(t.hostUserId)],
);

/** Provider webhook events already processed (deduplicated by the provider's event id). */
export const webhookEvent = pgTable("webhook_event", {
  id: text("id").primaryKey(),
  provider: text("provider").notNull(),
  type: text("type").notNull(),
  receivedAt: timestamp("received_at", { withTimezone: true }).notNull().defaultNow(),
});

/** Platform billing settings (single row, id = 1): the launch offer an admin can change or switch off. */
export const billingSetting = pgTable(
  "billing_setting",
  {
    id: integer("id").primaryKey().default(1),
    launchOfferEnabled: boolean("launch_offer_enabled").notNull().default(true),
    launchOfferPercent: integer("launch_offer_percent").notNull().default(20),
    updatedBy: uuid("updated_by").references(() => userAccount.id),
    updatedAt: updatedAt(),
  },
  (t) => [
    check("billing_setting_single_row", sql`${t.id} = 1`),
    check("billing_setting_percent", sql`${t.launchOfferPercent} BETWEEN 0 AND 90`),
  ],
);

// ── Media in the host's Google Drive (T05-04; features/media.md, integrations/google-drive.md) ──

export const sharingModeEnum = pgEnum("sharing_mode", ["private", "link"]);
export const mediaKindEnum = pgEnum("media_kind", ["card", "story", "gallery"]);
export const mediaTypeEnum = pgEnum("media_type", ["photo", "video"]);
export const mediaStatusEnum = pgEnum("media_status", ["uploading", "visible", "hidden", "reported", "deleted", "missing"]);

/** A host's Google account (scope drive.file). The refresh token is AES-GCM encrypted. */
export const googleConnection = pgTable(
  "google_connection",
  {
    id: id(),
    userId: uuid("user_id")
      .notNull()
      .references(() => userAccount.id, { onDelete: "cascade" }),
    googleEmail: text("google_email").notNull(),
    refreshTokenEnc: text("refresh_token_enc").notNull(),
    scopes: text("scopes").notNull(),
    connectedAt: timestamp("connected_at", { withTimezone: true }).notNull().defaultNow(),
    revokedAt: timestamp("revoked_at", { withTimezone: true }),
  },
  (t) => [index("google_connection_user_idx").on(t.userId)],
);

/** An event's Drive folder ("D-Card – {title}" with card/story/gallery) and sharing mode. */
export const eventMedia = pgTable("event_media", {
  eventId: uuid("event_id")
    .primaryKey()
    .references(() => event.id, { onDelete: "cascade" }),
  connectionId: uuid("connection_id").references(() => googleConnection.id, { onDelete: "set null" }),
  folderId: text("folder_id"),
  cardFolderId: text("card_folder_id"),
  storyFolderId: text("story_folder_id"),
  galleryFolderId: text("gallery_folder_id"),
  sharingMode: sharingModeEnum("sharing_mode").notNull().default("private"),
  /** Drive access failed (revoked, folder deleted): the host must reconnect (MED-13). */
  needsReconnect: boolean("needs_reconnect").notNull().default(false),
  /** Uploads paused because the host's Drive is full (MED-10). */
  driveFull: boolean("drive_full").notNull().default(false),
  updatedAt: updatedAt(),
});

/** One photo or video. The bytes live only in the host's Drive; D-Card keeps ids and metadata. */
export const mediaItem = pgTable(
  "media_item",
  {
    id: id(),
    eventId: uuid("event_id")
      .notNull()
      .references(() => event.id, { onDelete: "cascade" }),
    kind: mediaKindEnum("kind").notNull(),
    type: mediaTypeEnum("type").notNull(),
    /** Guest uploads (gallery) are tied to the invitation behind the card link. */
    invitationId: uuid("invitation_id").references(() => invitation.id, { onDelete: "set null" }),
    uploadedByUserId: uuid("uploaded_by_user_id").references(() => userAccount.id),
    driveFileId: text("drive_file_id"),
    fileName: text("file_name").notNull(),
    mimeType: text("mime_type").notNull(),
    sizeBytes: bigint("size_bytes", { mode: "number" }).notNull(),
    durationSeconds: integer("duration_seconds"),
    status: mediaStatusEnum("status").notNull().default("uploading"),
    reportedAt: timestamp("reported_at", { withTimezone: true }),
    createdAt: createdAt(),
    completedAt: timestamp("completed_at", { withTimezone: true }),
  },
  (t) => [
    index("media_item_event_idx").on(t.eventId, t.kind, t.status),
    index("media_item_invitation_idx").on(t.invitationId),
    unique("media_item_drive_file_unique").on(t.driveFileId),
  ],
);

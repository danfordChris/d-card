import { sql } from "drizzle-orm";
import {
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


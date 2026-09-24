import { sql } from "drizzle-orm";
import {
  boolean,
  check,
  integer,
  jsonb,
  pgEnum,
  pgTable,
  primaryKey,
  text,
  timestamp,
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
    singleAmount: integer("single_amount"),
    doubleAmount: integer("double_amount"),
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

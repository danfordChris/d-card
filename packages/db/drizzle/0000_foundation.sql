CREATE TYPE "public"."audit_actor_type" AS ENUM('user', 'system');--> statement-breakpoint
CREATE TYPE "public"."auth_provider" AS ENUM('password', 'google', 'apple');--> statement-breakpoint
CREATE TYPE "public"."event_role_type" AS ENUM('treasurer', 'committee', 'door_staff', 'walkin_approver');--> statement-breakpoint
CREATE TYPE "public"."event_status" AS ENUM('draft', 'published', 'completed', 'cancelled');--> statement-breakpoint
CREATE TYPE "public"."language" AS ENUM('sw', 'en');--> statement-breakpoint
CREATE TYPE "public"."plan_billing" AS ENUM('per_event', 'subscription');--> statement-breakpoint
CREATE TABLE "audit_log" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"actor_type" "audit_actor_type" NOT NULL,
	"actor_user_id" uuid,
	"event_id" uuid,
	"action" text NOT NULL,
	"target_type" text NOT NULL,
	"target_id" text,
	"old_value" jsonb,
	"new_value" jsonb,
	"ip" text,
	"device" text
);
--> statement-breakpoint
CREATE TABLE "event" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"host_user_id" uuid NOT NULL,
	"event_type_id" uuid NOT NULL,
	"title" text NOT NULL,
	"starts_at" timestamp with time zone NOT NULL,
	"ends_at" timestamp with time zone,
	"time_zone" text DEFAULT 'Africa/Dar_es_Salaam' NOT NULL,
	"venue_name" text,
	"venue_address" text,
	"venue_map_url" text,
	"contact_name" text NOT NULL,
	"contact_phone" text NOT NULL,
	"contact2_name" text,
	"contact2_phone" text,
	"status" "event_status" DEFAULT 'draft' NOT NULL,
	"confirmation_enabled" boolean DEFAULT true NOT NULL,
	"confirmation_offset_days" integer DEFAULT 2 NOT NULL,
	"headcount_pct" integer DEFAULT 70 NOT NULL,
	"auto_upgrade_enabled" boolean DEFAULT true NOT NULL,
	"single_amount" integer,
	"double_amount" integer,
	"currency" text DEFAULT 'TZS' NOT NULL,
	"photo_album_url" text,
	"reminder_frequency_days" integer,
	"retention_processed_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "event_contact_phone_format" CHECK ("event"."contact_phone" ~ '^255[0-9]{9}$'),
	CONSTRAINT "event_contact2_phone_format" CHECK ("event"."contact2_phone" IS NULL OR "event"."contact2_phone" ~ '^255[0-9]{9}$'),
	CONSTRAINT "event_headcount_pct_range" CHECK ("event"."headcount_pct" BETWEEN 0 AND 100),
	CONSTRAINT "event_amounts_non_negative" CHECK (coalesce("event"."single_amount", 0) >= 0 AND coalesce("event"."double_amount", 0) >= 0)
);
--> statement-breakpoint
CREATE TABLE "event_role" (
	"event_id" uuid NOT NULL,
	"user_id" uuid NOT NULL,
	"role" "event_role_type" NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "event_role_event_id_user_id_role_pk" PRIMARY KEY("event_id","user_id","role")
);
--> statement-breakpoint
CREATE TABLE "event_type" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"key" text NOT NULL,
	"name_sw" text NOT NULL,
	"name_en" text NOT NULL,
	"active" boolean DEFAULT true NOT NULL,
	CONSTRAINT "event_type_key_unique" UNIQUE("key")
);
--> statement-breakpoint
CREATE TABLE "person" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"phone" text NOT NULL,
	"name" text NOT NULL,
	"language" "language" DEFAULT 'sw' NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "person_phone_unique" UNIQUE("phone"),
	CONSTRAINT "person_phone_format" CHECK ("person"."phone" ~ '^255[0-9]{9}$')
);
--> statement-breakpoint
CREATE TABLE "plan" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"key" text NOT NULL,
	"name" text NOT NULL,
	"price_per_guest" integer NOT NULL,
	"billing" "plan_billing" DEFAULT 'per_event' NOT NULL,
	"entitlements" jsonb NOT NULL,
	"active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "plan_key_unique" UNIQUE("key"),
	CONSTRAINT "plan_price_positive" CHECK ("plan"."price_per_guest" > 0)
);
--> statement-breakpoint
CREATE TABLE "user_account" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"firebase_uid" text NOT NULL,
	"email" text,
	"auth_provider" "auth_provider" NOT NULL,
	"person_id" uuid,
	"is_admin" boolean DEFAULT false NOT NULL,
	"email_verified_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "user_account_firebase_uid_unique" UNIQUE("firebase_uid")
);
--> statement-breakpoint
ALTER TABLE "audit_log" ADD CONSTRAINT "audit_log_actor_user_id_user_account_id_fk" FOREIGN KEY ("actor_user_id") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "audit_log" ADD CONSTRAINT "audit_log_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event" ADD CONSTRAINT "event_host_user_id_user_account_id_fk" FOREIGN KEY ("host_user_id") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event" ADD CONSTRAINT "event_event_type_id_event_type_id_fk" FOREIGN KEY ("event_type_id") REFERENCES "public"."event_type"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event_role" ADD CONSTRAINT "event_role_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event_role" ADD CONSTRAINT "event_role_user_id_user_account_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user_account"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_account" ADD CONSTRAINT "user_account_person_id_person_id_fk" FOREIGN KEY ("person_id") REFERENCES "public"."person"("id") ON DELETE set null ON UPDATE no action;
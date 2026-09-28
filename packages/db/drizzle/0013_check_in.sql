CREATE TYPE "public"."check_in_method" AS ENUM('qr', 'card_number', 'name');--> statement-breakpoint
CREATE TYPE "public"."check_in_outcome" AS ENUM('admitted', 'fully_used', 'cancelled', 'not_issued', 'too_many', 'not_found', 'locked');--> statement-breakpoint
CREATE TYPE "public"."entry_source" AS ENUM('online', 'offline');--> statement-breakpoint
CREATE TYPE "public"."walkin_status" AS ENUM('pending', 'approved', 'refused', 'admitted_offline', 'accepted', 'flagged');--> statement-breakpoint
CREATE TABLE "check_in_attempt" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"event_id" uuid NOT NULL,
	"invitation_id" uuid,
	"entry_id" uuid,
	"device_id" uuid,
	"staff_user_id" uuid,
	"method" "check_in_method" NOT NULL,
	"query" text,
	"outcome" "check_in_outcome" NOT NULL,
	"source" "entry_source" DEFAULT 'online' NOT NULL,
	"occurred_at" timestamp with time zone DEFAULT now() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "door_device" (
	"id" uuid PRIMARY KEY NOT NULL,
	"event_id" uuid NOT NULL,
	"staff_user_id" uuid NOT NULL,
	"name" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"last_seen_at" timestamp with time zone DEFAULT now() NOT NULL,
	"last_sync_at" timestamp with time zone,
	"pending_count" integer DEFAULT 0 NOT NULL,
	"revoked_at" timestamp with time zone,
	"revoked_by" uuid
);
--> statement-breakpoint
CREATE TABLE "entry" (
	"id" uuid PRIMARY KEY NOT NULL,
	"event_id" uuid NOT NULL,
	"invitation_id" uuid,
	"walkin_request_id" uuid,
	"admitted_count" integer NOT NULL,
	"method" "check_in_method" NOT NULL,
	"staff_user_id" uuid,
	"device_id" uuid,
	"source" "entry_source" DEFAULT 'online' NOT NULL,
	"occurred_at" timestamp with time zone NOT NULL,
	"received_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "entry_admitted_count" CHECK ("entry"."admitted_count" between 1 and 2),
	CONSTRAINT "entry_target" CHECK ("entry"."invitation_id" is not null or "entry"."walkin_request_id" is not null)
);
--> statement-breakpoint
CREATE TABLE "walkin_request" (
	"id" uuid PRIMARY KEY NOT NULL,
	"event_id" uuid NOT NULL,
	"staff_user_id" uuid,
	"device_id" uuid,
	"invitation_id" uuid,
	"description" text NOT NULL,
	"admitted_count" integer DEFAULT 1 NOT NULL,
	"source" "entry_source" DEFAULT 'online' NOT NULL,
	"offline_reason" text,
	"status" "walkin_status" NOT NULL,
	"decided_by" uuid,
	"decided_at" timestamp with time zone,
	"occurred_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "walkin_admitted_count" CHECK ("walkin_request"."admitted_count" between 1 and 2),
	CONSTRAINT "walkin_offline_reason" CHECK ("walkin_request"."source" = 'online' or "walkin_request"."offline_reason" is not null)
);
--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "over_used_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "check_in_attempt" ADD CONSTRAINT "check_in_attempt_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "check_in_attempt" ADD CONSTRAINT "check_in_attempt_invitation_id_invitation_id_fk" FOREIGN KEY ("invitation_id") REFERENCES "public"."invitation"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "check_in_attempt" ADD CONSTRAINT "check_in_attempt_device_id_door_device_id_fk" FOREIGN KEY ("device_id") REFERENCES "public"."door_device"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "check_in_attempt" ADD CONSTRAINT "check_in_attempt_staff_user_id_user_account_id_fk" FOREIGN KEY ("staff_user_id") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "door_device" ADD CONSTRAINT "door_device_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "door_device" ADD CONSTRAINT "door_device_staff_user_id_user_account_id_fk" FOREIGN KEY ("staff_user_id") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "door_device" ADD CONSTRAINT "door_device_revoked_by_user_account_id_fk" FOREIGN KEY ("revoked_by") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "entry" ADD CONSTRAINT "entry_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "entry" ADD CONSTRAINT "entry_invitation_id_invitation_id_fk" FOREIGN KEY ("invitation_id") REFERENCES "public"."invitation"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "entry" ADD CONSTRAINT "entry_staff_user_id_user_account_id_fk" FOREIGN KEY ("staff_user_id") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "entry" ADD CONSTRAINT "entry_device_id_door_device_id_fk" FOREIGN KEY ("device_id") REFERENCES "public"."door_device"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "walkin_request" ADD CONSTRAINT "walkin_request_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "walkin_request" ADD CONSTRAINT "walkin_request_staff_user_id_user_account_id_fk" FOREIGN KEY ("staff_user_id") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "walkin_request" ADD CONSTRAINT "walkin_request_device_id_door_device_id_fk" FOREIGN KEY ("device_id") REFERENCES "public"."door_device"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "walkin_request" ADD CONSTRAINT "walkin_request_invitation_id_invitation_id_fk" FOREIGN KEY ("invitation_id") REFERENCES "public"."invitation"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "walkin_request" ADD CONSTRAINT "walkin_request_decided_by_user_account_id_fk" FOREIGN KEY ("decided_by") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "check_in_attempt_event_idx" ON "check_in_attempt" USING btree ("event_id","occurred_at");--> statement-breakpoint
CREATE INDEX "door_device_event_idx" ON "door_device" USING btree ("event_id");--> statement-breakpoint
CREATE INDEX "entry_invitation_idx" ON "entry" USING btree ("invitation_id");--> statement-breakpoint
CREATE INDEX "entry_event_idx" ON "entry" USING btree ("event_id","occurred_at");--> statement-breakpoint
CREATE INDEX "walkin_request_event_idx" ON "walkin_request" USING btree ("event_id","status");
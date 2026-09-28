CREATE TYPE "public"."channel_choice" AS ENUM('both', 'sms', 'whatsapp');--> statement-breakpoint
CREATE TYPE "public"."message_channel" AS ENUM('sms', 'whatsapp');--> statement-breakpoint
CREATE TYPE "public"."message_direction" AS ENUM('outbound', 'inbound');--> statement-breakpoint
CREATE TYPE "public"."message_status" AS ENUM('queued', 'sent', 'delivered', 'read', 'failed', 'held');--> statement-breakpoint
CREATE TYPE "public"."message_type" AS ENUM('contribution_request', 'thank_you', 'contribution_reminder', 'invitation_card', 'card_upgraded', 'attendance_confirmation', 'event_reminder', 'post_event_thanks');--> statement-breakpoint
CREATE TYPE "public"."template_category" AS ENUM('utility', 'marketing', 'authentication');--> statement-breakpoint
CREATE TYPE "public"."template_status" AS ENUM('pending', 'approved', 'rejected', 'paused');--> statement-breakpoint
CREATE TABLE "event_message_setting" (
	"event_id" uuid NOT NULL,
	"message_type" "message_type" NOT NULL,
	"enabled" boolean NOT NULL,
	"channels" "channel_choice" DEFAULT 'both' NOT NULL,
	"sms_text_sw" text,
	"sms_text_en" text,
	"whatsapp_template_variant" text,
	"whatsapp_note" text,
	"schedule" jsonb,
	"updated_by" uuid,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "event_message_setting_event_id_message_type_pk" PRIMARY KEY("event_id","message_type")
);
--> statement-breakpoint
CREATE TABLE "message_log" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"event_id" uuid NOT NULL,
	"invitation_id" uuid,
	"outbox_id" uuid,
	"channel" "message_channel" NOT NULL,
	"direction" "message_direction" DEFAULT 'outbound' NOT NULL,
	"message_type" "message_type",
	"to_phone" text,
	"language" "language" DEFAULT 'sw' NOT NULL,
	"body" text,
	"detail" jsonb,
	"template_id" uuid,
	"provider_message_id" text,
	"status" "message_status" DEFAULT 'queued' NOT NULL,
	"error" text,
	"segments" integer,
	"cost_tzs" numeric(12, 2),
	"attempts" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"sent_at" timestamp with time zone,
	"delivered_at" timestamp with time zone,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "message_log_outbox_channel_unique" UNIQUE("outbox_id","channel")
);
--> statement-breakpoint
CREATE TABLE "outbox" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"key" text NOT NULL,
	"event_id" uuid NOT NULL,
	"invitation_id" uuid,
	"message_type" "message_type" NOT NULL,
	"payload" jsonb DEFAULT '{}'::jsonb NOT NULL,
	"channels" "channel_choice",
	"to_phone" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"dispatched_at" timestamp with time zone,
	CONSTRAINT "outbox_key_unique" UNIQUE("key")
);
--> statement-breakpoint
CREATE TABLE "provider_rate" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"provider" text NOT NULL,
	"channel" "message_channel" NOT NULL,
	"category" text NOT NULL,
	"market" text DEFAULT 'TZ' NOT NULL,
	"price_tzs" numeric(12, 4) NOT NULL,
	"effective_from" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "whatsapp_optout" (
	"person_id" uuid NOT NULL,
	"event_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "whatsapp_optout_person_id_event_id_pk" PRIMARY KEY("person_id","event_id")
);
--> statement-breakpoint
CREATE TABLE "whatsapp_template" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"message_type" "message_type" NOT NULL,
	"variant_name" text NOT NULL,
	"language" "language" NOT NULL,
	"meta_template_name" text NOT NULL,
	"category" "template_category" NOT NULL,
	"body_params" jsonb NOT NULL,
	"editable_params" jsonb DEFAULT '[]'::jsonb NOT NULL,
	"header_image" boolean DEFAULT false NOT NULL,
	"confirm_buttons" boolean DEFAULT false NOT NULL,
	"status" "template_status" DEFAULT 'pending' NOT NULL,
	"active" boolean DEFAULT true NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "whatsapp_template_variant_unique" UNIQUE("message_type","variant_name","language")
);
--> statement-breakpoint
ALTER TABLE "event" ADD COLUMN "payment_details" text;--> statement-breakpoint
ALTER TABLE "event_message_setting" ADD CONSTRAINT "event_message_setting_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event_message_setting" ADD CONSTRAINT "event_message_setting_updated_by_user_account_id_fk" FOREIGN KEY ("updated_by") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "message_log" ADD CONSTRAINT "message_log_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "message_log" ADD CONSTRAINT "message_log_invitation_id_invitation_id_fk" FOREIGN KEY ("invitation_id") REFERENCES "public"."invitation"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "message_log" ADD CONSTRAINT "message_log_outbox_id_outbox_id_fk" FOREIGN KEY ("outbox_id") REFERENCES "public"."outbox"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "outbox" ADD CONSTRAINT "outbox_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "outbox" ADD CONSTRAINT "outbox_invitation_id_invitation_id_fk" FOREIGN KEY ("invitation_id") REFERENCES "public"."invitation"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "whatsapp_optout" ADD CONSTRAINT "whatsapp_optout_person_id_person_id_fk" FOREIGN KEY ("person_id") REFERENCES "public"."person"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "whatsapp_optout" ADD CONSTRAINT "whatsapp_optout_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "message_log_event_idx" ON "message_log" USING btree ("event_id","created_at");--> statement-breakpoint
CREATE INDEX "message_log_provider_idx" ON "message_log" USING btree ("provider_message_id");--> statement-breakpoint
CREATE INDEX "outbox_pending_idx" ON "outbox" USING btree ("dispatched_at","created_at");
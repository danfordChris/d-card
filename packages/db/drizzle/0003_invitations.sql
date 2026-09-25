CREATE TYPE "public"."card_type" AS ENUM('single', 'double');--> statement-breakpoint
CREATE TYPE "public"."consent_source" AS ENUM('form', 'import', 'contacts', 'copy');--> statement-breakpoint
CREATE TYPE "public"."invitation_status" AS ENUM('pending', 'issued', 'cancelled');--> statement-breakpoint
CREATE TABLE "guest_consent" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"event_id" uuid NOT NULL,
	"confirmed_by" uuid NOT NULL,
	"source" "consent_source" NOT NULL,
	"guest_count" integer NOT NULL,
	"confirmed_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "invitation" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"event_id" uuid NOT NULL,
	"person_id" uuid,
	"guest_name" text NOT NULL,
	"guest_phone" text NOT NULL,
	"partner_name" text,
	"card_type" "card_type" DEFAULT 'single' NOT NULL,
	"total_entries" integer DEFAULT 1 NOT NULL,
	"status" "invitation_status" DEFAULT 'pending' NOT NULL,
	"created_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "invitation_event_person_unique" UNIQUE("event_id","person_id"),
	CONSTRAINT "invitation_guest_phone_format" CHECK ("invitation"."guest_phone" ~ '^255[0-9]{9}$'),
	CONSTRAINT "invitation_entries_match_type" CHECK (("invitation"."card_type" = 'single' AND "invitation"."total_entries" = 1) OR ("invitation"."card_type" = 'double' AND "invitation"."total_entries" = 2))
);
--> statement-breakpoint
ALTER TABLE "guest_consent" ADD CONSTRAINT "guest_consent_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "guest_consent" ADD CONSTRAINT "guest_consent_confirmed_by_user_account_id_fk" FOREIGN KEY ("confirmed_by") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "invitation" ADD CONSTRAINT "invitation_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "invitation" ADD CONSTRAINT "invitation_person_id_person_id_fk" FOREIGN KEY ("person_id") REFERENCES "public"."person"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "invitation" ADD CONSTRAINT "invitation_created_by_user_account_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "invitation_event_created_idx" ON "invitation" USING btree ("event_id","created_at");
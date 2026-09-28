CREATE TYPE "public"."rsvp_status" AS ENUM('none', 'yes', 'no');--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "rsvp_status" "rsvp_status" DEFAULT 'none' NOT NULL;--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "rsvp_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "dietary_notes" text;
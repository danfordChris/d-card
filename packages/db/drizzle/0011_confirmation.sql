CREATE TYPE "public"."confirmation_status" AS ENUM('none', 'yes', 'no');--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "confirmation_status" "confirmation_status" DEFAULT 'none' NOT NULL;--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "confirmation_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "confirmation_source" text;
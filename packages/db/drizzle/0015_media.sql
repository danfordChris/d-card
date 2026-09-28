CREATE TYPE "public"."media_kind" AS ENUM('card', 'story', 'gallery');--> statement-breakpoint
CREATE TYPE "public"."media_status" AS ENUM('uploading', 'visible', 'hidden', 'reported', 'deleted', 'missing');--> statement-breakpoint
CREATE TYPE "public"."media_type" AS ENUM('photo', 'video');--> statement-breakpoint
CREATE TYPE "public"."sharing_mode" AS ENUM('private', 'link');--> statement-breakpoint
CREATE TABLE "event_media" (
	"event_id" uuid PRIMARY KEY NOT NULL,
	"connection_id" uuid,
	"folder_id" text,
	"card_folder_id" text,
	"story_folder_id" text,
	"gallery_folder_id" text,
	"sharing_mode" "sharing_mode" DEFAULT 'private' NOT NULL,
	"needs_reconnect" boolean DEFAULT false NOT NULL,
	"drive_full" boolean DEFAULT false NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE "google_connection" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"user_id" uuid NOT NULL,
	"google_email" text NOT NULL,
	"refresh_token_enc" text NOT NULL,
	"scopes" text NOT NULL,
	"connected_at" timestamp with time zone DEFAULT now() NOT NULL,
	"revoked_at" timestamp with time zone
);
--> statement-breakpoint
CREATE TABLE "media_item" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"event_id" uuid NOT NULL,
	"kind" "media_kind" NOT NULL,
	"type" "media_type" NOT NULL,
	"invitation_id" uuid,
	"uploaded_by_user_id" uuid,
	"drive_file_id" text,
	"file_name" text NOT NULL,
	"mime_type" text NOT NULL,
	"size_bytes" bigint NOT NULL,
	"duration_seconds" integer,
	"status" "media_status" DEFAULT 'uploading' NOT NULL,
	"reported_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"completed_at" timestamp with time zone,
	CONSTRAINT "media_item_drive_file_unique" UNIQUE("drive_file_id")
);
--> statement-breakpoint
ALTER TABLE "event_media" ADD CONSTRAINT "event_media_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event_media" ADD CONSTRAINT "event_media_connection_id_google_connection_id_fk" FOREIGN KEY ("connection_id") REFERENCES "public"."google_connection"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "google_connection" ADD CONSTRAINT "google_connection_user_id_user_account_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."user_account"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "media_item" ADD CONSTRAINT "media_item_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "media_item" ADD CONSTRAINT "media_item_invitation_id_invitation_id_fk" FOREIGN KEY ("invitation_id") REFERENCES "public"."invitation"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "media_item" ADD CONSTRAINT "media_item_uploaded_by_user_id_user_account_id_fk" FOREIGN KEY ("uploaded_by_user_id") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "google_connection_user_idx" ON "google_connection" USING btree ("user_id");--> statement-breakpoint
CREATE INDEX "media_item_event_idx" ON "media_item" USING btree ("event_id","kind","status");--> statement-breakpoint
CREATE INDEX "media_item_invitation_idx" ON "media_item" USING btree ("invitation_id");
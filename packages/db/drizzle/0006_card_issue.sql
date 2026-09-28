ALTER TABLE "event" ADD COLUMN "next_guest_seq" integer DEFAULT 1 NOT NULL;--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "guest_seq" integer;--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "card_number" text;--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "qr_token_hash" text;--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "link_token_hash" text;--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "qr_token_enc" text;--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "link_token_enc" text;--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "issued_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "invitation" ADD COLUMN "cancelled_at" timestamp with time zone;--> statement-breakpoint
ALTER TABLE "invitation" ADD CONSTRAINT "invitation_qr_token_hash_unique" UNIQUE("qr_token_hash");--> statement-breakpoint
ALTER TABLE "invitation" ADD CONSTRAINT "invitation_link_token_hash_unique" UNIQUE("link_token_hash");--> statement-breakpoint
ALTER TABLE "invitation" ADD CONSTRAINT "invitation_event_card_number_unique" UNIQUE("event_id","card_number");--> statement-breakpoint
ALTER TABLE "invitation" ADD CONSTRAINT "invitation_event_guest_seq_unique" UNIQUE("event_id","guest_seq");--> statement-breakpoint
ALTER TABLE "invitation" ADD CONSTRAINT "invitation_card_number_format" CHECK ("invitation"."card_number" IS NULL OR "invitation"."card_number" ~ '^[0-9]{3,}-[0-9]{4}$');
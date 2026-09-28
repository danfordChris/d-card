CREATE TYPE "public"."payment_kind" AS ENUM('payment', 'refund');--> statement-breakpoint
CREATE TYPE "public"."payment_method" AS ENUM('mpesa', 'mixx_by_yas', 'airtel_money', 'halopesa', 'bank', 'cash', 'other');--> statement-breakpoint
CREATE TYPE "public"."pledge_status" AS ENUM('not_paid', 'part_paid', 'fully_paid');--> statement-breakpoint
CREATE TABLE "payment" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"event_id" uuid NOT NULL,
	"pledge_id" uuid NOT NULL,
	"kind" "payment_kind" NOT NULL,
	"amount" integer NOT NULL,
	"method" "payment_method" NOT NULL,
	"reference" text,
	"paid_on" date NOT NULL,
	"recorded_by" uuid,
	"recorded_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "payment_sign_matches_kind" CHECK (("payment"."kind" = 'payment' AND "payment"."amount" > 0) OR ("payment"."kind" = 'refund' AND "payment"."amount" < 0))
);
--> statement-breakpoint
CREATE TABLE "pledge" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"event_id" uuid NOT NULL,
	"invitation_id" uuid NOT NULL,
	"amount_pledged" integer NOT NULL,
	"card_type" "card_type" NOT NULL,
	"amount_paid" integer DEFAULT 0 NOT NULL,
	"amount_extra" integer DEFAULT 0 NOT NULL,
	"status" "pledge_status" DEFAULT 'not_paid' NOT NULL,
	"upgraded_at" timestamp with time zone,
	"created_by" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "pledge_invitation_id_unique" UNIQUE("invitation_id"),
	CONSTRAINT "pledge_amount_positive" CHECK ("pledge"."amount_pledged" > 0)
);
--> statement-breakpoint
ALTER TABLE "event" ADD COLUMN "budget_amount" integer;--> statement-breakpoint
ALTER TABLE "payment" ADD CONSTRAINT "payment_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment" ADD CONSTRAINT "payment_pledge_id_pledge_id_fk" FOREIGN KEY ("pledge_id") REFERENCES "public"."pledge"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment" ADD CONSTRAINT "payment_recorded_by_user_account_id_fk" FOREIGN KEY ("recorded_by") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "pledge" ADD CONSTRAINT "pledge_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "pledge" ADD CONSTRAINT "pledge_invitation_id_invitation_id_fk" FOREIGN KEY ("invitation_id") REFERENCES "public"."invitation"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "pledge" ADD CONSTRAINT "pledge_created_by_user_account_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "payment_pledge_idx" ON "payment" USING btree ("pledge_id");--> statement-breakpoint
CREATE INDEX "pledge_event_idx" ON "pledge" USING btree ("event_id");
CREATE TYPE "public"."host_payment_method" AS ENUM('mobile', 'session');--> statement-breakpoint
CREATE TYPE "public"."payment_attempt_status" AS ENUM('pending', 'completed', 'failed', 'expired');--> statement-breakpoint
CREATE TABLE "billing_setting" (
	"id" integer PRIMARY KEY DEFAULT 1 NOT NULL,
	"launch_offer_enabled" boolean DEFAULT true NOT NULL,
	"launch_offer_percent" integer DEFAULT 20 NOT NULL,
	"updated_by" uuid,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "billing_setting_single_row" CHECK ("billing_setting"."id" = 1),
	CONSTRAINT "billing_setting_percent" CHECK ("billing_setting"."launch_offer_percent" BETWEEN 0 AND 90)
);
--> statement-breakpoint
CREATE TABLE "host_payment" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"attempt_id" uuid NOT NULL,
	"event_id" uuid NOT NULL,
	"host_user_id" uuid NOT NULL,
	"plan_id" uuid NOT NULL,
	"guest_cards" integer NOT NULL,
	"amount" integer NOT NULL,
	"discount_amount" integer DEFAULT 0 NOT NULL,
	"method" "host_payment_method" NOT NULL,
	"reference" text NOT NULL,
	"paid_at" timestamp with time zone NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "host_payment_attempt_id_unique" UNIQUE("attempt_id")
);
--> statement-breakpoint
CREATE TABLE "payment_attempt" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"event_id" uuid NOT NULL,
	"host_user_id" uuid NOT NULL,
	"plan_id" uuid NOT NULL,
	"price_per_guest" integer NOT NULL,
	"guest_cards" integer NOT NULL,
	"subtotal" integer NOT NULL,
	"discount_amount" integer DEFAULT 0 NOT NULL,
	"amount" integer NOT NULL,
	"method" "host_payment_method" NOT NULL,
	"phone" text,
	"provider" text DEFAULT 'snippe' NOT NULL,
	"provider_reference" text,
	"idempotency_key" text NOT NULL,
	"checkout_url" text,
	"status" "payment_attempt_status" DEFAULT 'pending' NOT NULL,
	"failure_reason" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"completed_at" timestamp with time zone,
	CONSTRAINT "payment_attempt_provider_reference_unique" UNIQUE("provider_reference"),
	CONSTRAINT "payment_attempt_idempotency_key_unique" UNIQUE("idempotency_key"),
	CONSTRAINT "payment_attempt_amounts" CHECK ("payment_attempt"."amount" >= 0 AND "payment_attempt"."guest_cards" > 0),
	CONSTRAINT "payment_attempt_phone_format" CHECK ("payment_attempt"."phone" IS NULL OR "payment_attempt"."phone" ~ '^255[0-9]{9}$')
);
--> statement-breakpoint
CREATE TABLE "webhook_event" (
	"id" text PRIMARY KEY NOT NULL,
	"provider" text NOT NULL,
	"type" text NOT NULL,
	"received_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
ALTER TABLE "billing_setting" ADD CONSTRAINT "billing_setting_updated_by_user_account_id_fk" FOREIGN KEY ("updated_by") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "host_payment" ADD CONSTRAINT "host_payment_attempt_id_payment_attempt_id_fk" FOREIGN KEY ("attempt_id") REFERENCES "public"."payment_attempt"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "host_payment" ADD CONSTRAINT "host_payment_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "host_payment" ADD CONSTRAINT "host_payment_host_user_id_user_account_id_fk" FOREIGN KEY ("host_user_id") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "host_payment" ADD CONSTRAINT "host_payment_plan_id_plan_id_fk" FOREIGN KEY ("plan_id") REFERENCES "public"."plan"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_attempt" ADD CONSTRAINT "payment_attempt_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_attempt" ADD CONSTRAINT "payment_attempt_host_user_id_user_account_id_fk" FOREIGN KEY ("host_user_id") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "payment_attempt" ADD CONSTRAINT "payment_attempt_plan_id_plan_id_fk" FOREIGN KEY ("plan_id") REFERENCES "public"."plan"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
CREATE INDEX "host_payment_host_idx" ON "host_payment" USING btree ("host_user_id");--> statement-breakpoint
CREATE INDEX "payment_attempt_event_idx" ON "payment_attempt" USING btree ("event_id","created_at");--> statement-breakpoint
CREATE INDEX "payment_attempt_pending_idx" ON "payment_attempt" USING btree ("status","created_at");
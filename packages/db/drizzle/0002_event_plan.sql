CREATE TABLE "event_plan" (
	"event_id" uuid PRIMARY KEY NOT NULL,
	"plan_id" uuid NOT NULL,
	"price_per_guest" integer NOT NULL,
	"guest_limit" integer DEFAULT 0 NOT NULL,
	"amount_paid" integer DEFAULT 0 NOT NULL,
	"purchased_at" timestamp with time zone,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now() NOT NULL,
	CONSTRAINT "event_plan_amounts_non_negative" CHECK ("event_plan"."guest_limit" >= 0 AND "event_plan"."amount_paid" >= 0)
);
--> statement-breakpoint
ALTER TABLE "event_plan" ADD CONSTRAINT "event_plan_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "event_plan" ADD CONSTRAINT "event_plan_plan_id_plan_id_fk" FOREIGN KEY ("plan_id") REFERENCES "public"."plan"("id") ON DELETE no action ON UPDATE no action;
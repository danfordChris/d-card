CREATE TYPE "public"."import_source" AS ENUM('file', 'past_event');--> statement-breakpoint
CREATE TYPE "public"."import_status" AS ENUM('previewed', 'completed');--> statement-breakpoint
CREATE TABLE "import_job" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"event_id" uuid NOT NULL,
	"source" "import_source" NOT NULL,
	"status" "import_status" DEFAULT 'previewed' NOT NULL,
	"file_name" text,
	"source_event_id" uuid,
	"rows" jsonb NOT NULL,
	"report" jsonb NOT NULL,
	"total" integer NOT NULL,
	"imported" integer DEFAULT 0 NOT NULL,
	"created_by" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"completed_at" timestamp with time zone
);
--> statement-breakpoint
ALTER TABLE "import_job" ADD CONSTRAINT "import_job_event_id_event_id_fk" FOREIGN KEY ("event_id") REFERENCES "public"."event"("id") ON DELETE cascade ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "import_job" ADD CONSTRAINT "import_job_source_event_id_event_id_fk" FOREIGN KEY ("source_event_id") REFERENCES "public"."event"("id") ON DELETE set null ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "import_job" ADD CONSTRAINT "import_job_created_by_user_account_id_fk" FOREIGN KEY ("created_by") REFERENCES "public"."user_account"("id") ON DELETE no action ON UPDATE no action;
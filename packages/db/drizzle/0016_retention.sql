ALTER TABLE "user_account" ADD COLUMN "deleted_at" timestamp with time zone;--> statement-breakpoint
-- W13 retention (docs/design/features/privacy-and-audit.md) may clear an issued card's
-- tokens, never change them: only inside the retention job, which sets the
-- transaction-local flag `dcard.retention = 'on'`.
CREATE OR REPLACE FUNCTION invitation_card_immutable() RETURNS trigger AS $$
BEGIN
  IF OLD.issued_at IS NOT NULL AND current_setting('dcard.retention', true) = 'on'
     AND NEW.qr_token_hash IS NULL AND NEW.link_token_hash IS NULL
     AND NEW.card_type IS NOT DISTINCT FROM OLD.card_type
     AND NEW.total_entries IS NOT DISTINCT FROM OLD.total_entries
     AND NEW.card_number IS NOT DISTINCT FROM OLD.card_number
     AND NEW.guest_seq IS NOT DISTINCT FROM OLD.guest_seq THEN
    RETURN NEW;
  END IF;
  IF OLD.issued_at IS NOT NULL AND (
       NEW.card_type IS DISTINCT FROM OLD.card_type
    OR NEW.total_entries IS DISTINCT FROM OLD.total_entries
    OR NEW.card_number IS DISTINCT FROM OLD.card_number
    OR NEW.guest_seq IS DISTINCT FROM OLD.guest_seq
    OR NEW.qr_token_hash IS DISTINCT FROM OLD.qr_token_hash
    OR NEW.link_token_hash IS DISTINCT FROM OLD.link_token_hash
  ) THEN
    RAISE EXCEPTION 'card type, card number and tokens cannot change after issue'
      USING ERRCODE = 'check_violation';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

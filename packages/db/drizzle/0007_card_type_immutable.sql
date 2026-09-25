-- GST-9: card type is fixed once issued; card number and tokens never change after issue
-- (docs/design/data-models/postgres.md). Service code enforces the same rules.
CREATE OR REPLACE FUNCTION invitation_card_immutable() RETURNS trigger AS $$
BEGIN
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
--> statement-breakpoint
CREATE TRIGGER invitation_card_immutable_trg
  BEFORE UPDATE ON invitation
  FOR EACH ROW EXECUTE FUNCTION invitation_card_immutable();

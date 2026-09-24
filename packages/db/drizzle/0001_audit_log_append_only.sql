-- audit_log is append-only (docs/design/data-models/postgres.md).
-- UPDATE is allowed only inside the retention masking procedure, which sets
-- the transaction-local flag `dcard.audit_mask = 'on'`. DELETE is never allowed.
CREATE OR REPLACE FUNCTION audit_log_append_only() RETURNS trigger AS $$
BEGIN
  IF TG_OP = 'UPDATE' AND current_setting('dcard.audit_mask', true) = 'on' THEN
    RETURN NEW;
  END IF;
  RAISE EXCEPTION 'audit_log is append-only (% blocked)', TG_OP
    USING ERRCODE = 'insufficient_privilege';
END;
$$ LANGUAGE plpgsql;
--> statement-breakpoint
CREATE TRIGGER audit_log_append_only_trg
  BEFORE UPDATE OR DELETE ON audit_log
  FOR EACH ROW EXECUTE FUNCTION audit_log_append_only();
--> statement-breakpoint
CREATE TRIGGER audit_log_no_truncate_trg
  BEFORE TRUNCATE ON audit_log
  FOR EACH STATEMENT EXECUTE FUNCTION audit_log_append_only();

# PostgreSQL Data Model

## Context

- Source of truth for all business data. ORM: Drizzle.

## Entities and Integrity Rules
| Entity | Main fields |
|--------|-------------|
| **person** | id, phone (unique), name, language, created_at, updated_at |
| **user_account** | id, **firebase_uid (unique)**, email (nullable), auth_provider (password/google/apple), person_id (nullable), is_admin, email_verified_at, created_at. *Passwords are held by Firebase Auth, not in Postgres.* |
| **event_type** | id, key, name_sw, name_en, active (admin-managed) |
| **card_template** | id, event_type_id, name, assets, active |
| **event** | id, host_user_id, event_type_id, title, starts_at, ends_at, time_zone, venue fields, contact_name, contact_phone, contact2_name, contact2_phone, status, confirmation_enabled, confirmation_offset, headcount_pct, auto_upgrade_enabled (default true), single_amount, double_amount, currency, photo_album_url, reminder_frequency, retention_processed_at |
| **event_role** | event_id, user_id, role (treasurer / committee / door_staff / walkin_approver) |
| **invitation** | id, event_id, person_id (nullable after anonymisation), **guest_name, guest_phone** (host-owned snapshot), partner_name, card_type, total_entries, entries_used (derived), over_used, guest_seq, card_number, qr_token_hash, link_token_hash, status, rsvp_status, confirmation_status, dietary_notes, table_id, issued_at, cancelled_at, anonymised_at. **Unique (event_id, person_id).** |
| **pledge** | id, invitation_id, amount_pledged, card_type, amount_paid, amount_extra, status, upgraded_at |
| **payment** | id, pledge_id, kind (payment/refund), amount, method, reference, paid_on, recorded_by, recorded_at |
| **reply_window** *(backlog)* | id, phone, invitation_id, status, opened_at, expires_at |
| **entry** | **id (UUID from device)**, event_id, invitation_id (nullable), walkin_request_id (nullable), staff_user_id, device_id, admitted_count, method, **occurred_at**, received_at, source (online/offline) |
| **door_device** | id, event_id, staff_user_id, last_sync_at, revoked_at |
| **walkin_request** | id (UUID from device), event_id, staff_user_id, device_id, invitation_id, description, source (online/offline), offline_reason, status (pending/approved/refused/admitted_offline/accepted/flagged), decided_by, decided_at, occurred_at |
| **message_log** | id, event_id, invitation_id, channel, direction, type, provider_message_id, status, cost, created_at |
| **audit_log** | id, created_at, actor, event_id, action, target_type, target_id, old_value, new_value, ip, device. Append-only. |
| **team_invite** | id, event_id, role, email (nullable), token_hash (unique), created_by, expires_at, accepted_by, accepted_at, revoked_at, created_at |
| **import_job** | id, event_id, source (csv/contacts/past_event), status, total, imported, errors (jsonb) |
| **table, programme_item, menu_item, poll, poll_option, vote** | Phase 2, all linked to one event. |
| **host_payment** | id, host_user_id, event_id, plan, guest_cards, amount, discount (e.g. launch offer), method, reference, paid_on |
| **google_connection** | id, user_id, google_account_email, refresh_token (encrypted), scopes, connected_at, revoked_at |
| **event_media_folder** | event_id, google_connection_id, root_folder_id, card_folder_id, story_folder_id, gallery_folder_id, **sharing_mode (private/link, default private)**, share_link (link mode only) |
| **media_item** | id, event_id, kind (card/story/gallery), type (photo/video), uploaded_by_invitation_id or user_id, **drive_file_id**, mime_type, size_bytes, duration_s, status (visible/hidden/reported/deleted/missing), created_at |
| **event_message_setting** | event_id, message_type (NTF-1…8), enabled, channels (whatsapp/sms/both), sms_text_sw, sms_text_en, whatsapp_template_id, whatsapp_params (jsonb), schedule (offset_days, time_of_day, frequency_days, max_count, stop_offset_days), updated_by, updated_at |
| **whatsapp_template** | id, message_type, variant_name, language, meta_template_name, category (utility/marketing), editable_params, status (pending/approved/rejected), active |
| **plan** | id, name, price_per_guest, billing (per event/subscription), entitlements (jsonb: unlocked controls, max reminders, max SMS segments, max manual sends, marketing allowed, …), active |
| **event_plan** | event_id, plan_id, guest_limit, price_per_guest, amount_paid, purchased_at (plus extra guest-slot purchases) |
| **provider_rate** | id, provider (meta/nextsms), channel, category (marketing/utility/service/sms_segment), market, price_usd / price_tzs, fx_rate, effective_from (admin-managed; used for internal cost tracking) |
| **whatsapp_optout** | person_id, event_id, created_at (STOP handling) |
| **guest_consent** | event_id, confirmed_by, confirmed_at, source (form/import/contacts/copy) |

**Integrity rules**
- Money is stored as whole Tsh (integer). Refunds are negative.
- Online check-in is a single conditional insert/update that only succeeds if the entries used plus the new entry stay within the allowance for an `issued` card.
- `entry.id` is unique, so re-synced entries are ignored.
- The card type cannot change once issued (service rule + DB trigger).
- The application role has no UPDATE/DELETE rights on `audit_log`. Retention masks personal fields through a dedicated, audited procedure.
- Tokens are stored hashed.

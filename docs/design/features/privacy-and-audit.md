# Audit, Privacy and Data Retention

## Context

- Applies to all features.

## Workflow: Post-event Retention
1. **2 weeks after the event ends**, a scheduled job processes every invitation of that event.
2. If the invitation's Person is **not a registered guest** (no linked account):
   - the invitation's link to the Person is removed, and the link and QR tokens are invalidated,
   - the Person record is deleted if it has no other remaining invitations or roles,
   - personal fields in message logs and audit entries are masked.
3. **The host's records are kept:** the invitation keeps the host-owned snapshot (name, phone, pledge, payments, entries), so the host's contribution and attendance records stay complete until the host deletes the event.
4. **Registered guests** keep their full link. The event stays in their history.

## Audited Actions
Logins and failed logins · event settings · guests/contributors added, edited or removed · imports · cards issued, upgraded, sent, cancelled or reinstated · payments, refunds and edits (old and new values) · confirmation answers and overrides · **every** check-in attempt (online and offline) · lockouts · over-used cards · walk-in requests and decisions · role changes · device registrations and revocations · retention runs.

## Privacy and Data Retention
- **Registered guests** (signed in with Google/Apple) keep their data and event history until they delete their account.
- **Guests without an account** (including all basic-phone guests) are **anonymised 2 weeks after the event** (W13). The host keeps their own event records, which the host can delete by deleting the event.
- **MVP privacy basics:** a privacy notice for guests · a consent checkbox when hosts add or import guest data · "download my data" and "delete my account" for registered guests · data minimisation.
- **Before launch:** confirm obligations under Tanzania's **Personal Data Protection Act 2022** (e.g. registration with the PDPC, consent wording, whether the host is the data controller) with a legal adviser. [OPEN O3]

# Email Integration

## Context

- Use: team invitation emails (AUTH-8). Firebase Auth sends its own verification and password-reset emails.
- Decision: `docs/adr/0003-technical-stack.md`.

## Requirements

- Provider: **Resend** (free tier 3,000 emails/month). API `POST https://api.resend.com/emails`, `Authorization: Bearer <RESEND_API_KEY>`.
- Sender: `EMAIL_FROM` on a verified domain (SPF/DKIM configured in Resend).
- Emails are sent through the worker queue with retries; failures never block creating the invite (the link still works).

## Decisions

- Adapter behind an `EmailSender` interface.
- Bilingual (Swahili + English) plain templates.

## Contracts

- Queue `email`, job `team-invite` with `{ inviteId, to, eventTitle, role, link, language }`.

## Acceptance Criteria

- Creating an invite with an email enqueues exactly one `team-invite` email job.
- With a dummy `RESEND_API_KEY`, the job is skipped with a logged reason and the invite is still created.

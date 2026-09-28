import { scrub, scrubText } from "@dcard/core";
import * as Sentry from "@sentry/node";

let started = false;

export function initSentry(): void {
  if (started || !process.env.SENTRY_DSN) return;
  started = true;
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.VERCEL_ENV ?? process.env.NODE_ENV,
    release: process.env.VERCEL_GIT_COMMIT_SHA,
    tracesSampleRate: 0,
    // No user info, cookies, headers or bodies: they carry tokens and phone numbers.
    dataCollection: { userInfo: false, cookies: false, httpHeaders: false, httpBodies: [] },
    beforeSend: (event) => scrubEvent(event),
    beforeBreadcrumb: (crumb) => scrub(crumb),
  });
}

/** Removes phones, tokens and secrets from a Sentry event (exported for tests). */
export function scrubEvent<T extends { message?: string; request?: unknown; extra?: unknown; exception?: { values?: { value?: string }[] } }>(event: T): T {
  const copy = scrub(event);
  if (copy.message) copy.message = scrubText(copy.message);
  for (const v of copy.exception?.values ?? []) if (v.value) v.value = scrubText(v.value);
  return copy;
}

/** Reports an unexpected server error (no-op without SENTRY_DSN). */
export function captureError(err: unknown, context: Record<string, string> = {}): void {
  if (!process.env.SENTRY_DSN) return;
  initSentry();
  Sentry.captureException(err, { extra: scrub(context) });
}

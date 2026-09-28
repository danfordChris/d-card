import { scrub, scrubText } from "@dcard/core";
import * as Sentry from "@sentry/node";

/** Error tracking for the worker (T06-06): Sentry free plan, only with SENTRY_DSN, scrubbed. */
export function workerErrorReporter(): ((err: Error, queue: string, job: string | undefined) => void) | undefined {
  if (!process.env.SENTRY_DSN) return undefined;
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.RAILWAY_ENVIRONMENT_NAME ?? process.env.NODE_ENV,
    release: process.env.RAILWAY_GIT_COMMIT_SHA,
    tracesSampleRate: 0,
    // No user info, cookies, headers or bodies: they carry tokens and phone numbers.
    dataCollection: { userInfo: false, cookies: false, httpHeaders: false, httpBodies: [] },
    beforeSend: (event) => {
      const copy = scrub(event);
      if (copy.message) copy.message = scrubText(copy.message);
      for (const v of copy.exception?.values ?? []) if (v.value) v.value = scrubText(v.value);
      return copy;
    },
  });
  return (err, queue, job) => Sentry.captureException(err, { tags: { queue, job: job ?? "unknown" } });
}

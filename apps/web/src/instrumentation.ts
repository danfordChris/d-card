// Next.js instrumentation: error tracking for the API (T06-06). Sentry's free Developer plan,
// enabled only when SENTRY_DSN is set; everything is scrubbed of personal data first.

export async function register(): Promise<void> {
  if (process.env.NEXT_RUNTIME !== "nodejs" || !process.env.SENTRY_DSN) return;
  const { initSentry } = await import("./server/sentry");
  initSentry();
}

export async function onRequestError(err: unknown, request: { path: string; method: string }): Promise<void> {
  if (process.env.NEXT_RUNTIME !== "nodejs" || !process.env.SENTRY_DSN) return;
  const { captureError } = await import("./server/sentry");
  captureError(err, { path: request.path, method: request.method });
}

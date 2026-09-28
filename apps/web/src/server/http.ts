import { createLogger, DomainError, ValidationError } from "@dcard/core";
import type { z } from "zod";
import type { ErrorResponse } from "@dcard/api-contract";

const STATUS_BY_CODE: Record<string, number> = {
  unauthorized: 401,
  forbidden: 403,
  not_found: 404,
  invalid_phone: 422,
  validation_error: 422,
  consent_required: 422,
  conflict: 409,
  person_linked: 409,
  account_disabled: 403,
  second_factor_required: 403,
  second_factor_not_enrolled: 403,
  second_factor_invalid: 422,
  second_factor_locked: 429,
  account_linked: 409,
  plan_limit: 409,
  account_not_provisioned: 403,
  invite_gone: 410,
  rate_limited: 429,
  // Billing (T05-01)
  payment_required: 409,
  guest_limit: 409,
  quote_changed: 409,
  nothing_to_pay: 409,
  payment_in_progress: 409,
  event_closed: 409,
  provider_unavailable: 502,
  // Media (T05-04)
  drive_not_connected: 409,
  drive_full: 409,
  drive_unavailable: 502,
  uploads_closed: 409,
  upload_limit: 409,
  gallery_closed: 410,
};

export function jsonError(status: number, code: string, message: string): Response {
  const body: ErrorResponse = { error: { code, message } };
  return Response.json(body, { status });
}

/** Maps domain errors to their HTTP status; anything else is a 500 without internals. */
export function toErrorResponse(err: unknown): Response {
  if (err instanceof ValidationError) {
    const body: ErrorResponse = { error: { code: err.code, message: err.message, issues: err.issues } };
    return Response.json(body, { status: 422 });
  }
  if (err instanceof DomainError) {
    return jsonError(STATUS_BY_CODE[err.code] ?? 400, err.code, err.message);
  }
  reportUnexpected(err);
  return jsonError(500, "internal", "Something went wrong.");
}

const log = createLogger({ service: "web" });

/** Logs an unexpected error as JSON with the request id (set in proxy.ts) and sends it to Sentry. */
function reportUnexpected(err: unknown): void {
  void (async () => {
    let requestId: string | null = null;
    try {
      requestId = (await (await import("next/headers")).headers()).get("x-request-id");
    } catch {
      // Outside a request (tests, scripts).
    }
    log.error("request failed", { requestId, err: err instanceof Error ? err : new Error(String(err)) });
    if (process.env.SENTRY_DSN) (await import("./sentry")).captureError(err, requestId ? { requestId } : {});
  })();
}

/** Parses a JSON body with a zod schema; invalid input becomes a 422 ValidationError. */
export async function parseBody<T extends z.ZodType>(request: Request, schema: T): Promise<z.infer<T>> {
  let raw: unknown;
  try {
    raw = await request.json();
  } catch {
    throw new ValidationError("Request body must be JSON.");
  }
  const result = schema.safeParse(raw);
  if (!result.success) {
    throw new ValidationError(
      "Some fields are invalid.",
      result.error.issues.map((i) => ({ path: i.path.join("."), message: i.message })),
    );
  }
  return result.data;
}

/** JSON-safe copy: Date values become ISO strings. */
export function toJson<T>(value: T): unknown {
  return JSON.parse(JSON.stringify(value));
}

/** Parses URL query parameters with a zod schema; invalid input becomes a 422 ValidationError. */
export function parseQuery<T extends z.ZodType>(request: Request, schema: T): z.infer<T> {
  const result = schema.safeParse(Object.fromEntries(new URL(request.url).searchParams));
  if (!result.success) {
    throw new ValidationError(
      "Some fields are invalid.",
      result.error.issues.map((i) => ({ path: i.path.join("."), message: i.message })),
    );
  }
  return result.data;
}

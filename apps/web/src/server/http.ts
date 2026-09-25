import { DomainError, ValidationError } from "@dcard/core";
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
  plan_limit: 409,
  account_not_provisioned: 403,
  invite_gone: 410,
  rate_limited: 429,
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
  console.error(err);
  return jsonError(500, "internal", "Something went wrong.");
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

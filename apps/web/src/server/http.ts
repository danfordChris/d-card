import { DomainError } from "@dcard/core";
import type { ErrorResponse } from "@dcard/api-contract";

const STATUS_BY_CODE: Record<string, number> = {
  unauthorized: 401,
  forbidden: 403,
  not_found: 404,
  invalid_phone: 422,
};

export function jsonError(status: number, code: string, message: string): Response {
  const body: ErrorResponse = { error: { code, message } };
  return Response.json(body, { status });
}

/** Maps domain errors to their HTTP status; anything else is a 500 without internals. */
export function toErrorResponse(err: unknown): Response {
  if (err instanceof DomainError) {
    return jsonError(STATUS_BY_CODE[err.code] ?? 400, err.code, err.message);
  }
  console.error(err);
  return jsonError(500, "internal", "Something went wrong.");
}

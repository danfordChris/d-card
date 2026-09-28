"use client";

import type { EventFormErrors } from "./event-form";
import { errorsFromIssues } from "./event-form";
import { apiFetch } from "../../lib/api-fetch";

type ApiError = { error?: { code?: string; message?: string; issues?: { path: string }[] } };

export type SubmitResult<T> = { ok: true; data: T } | { ok: false; fieldErrors: EventFormErrors; message?: string };

/** Sends JSON to the API (session cookie auth) and maps errors onto form fields. */
export async function sendJson<T>(url: string, method: string, body?: unknown): Promise<SubmitResult<T>> {
  let res: Response;
  try {
    res = await apiFetch(url, {
      method,
      headers: { "content-type": "application/json" },
      ...(body !== undefined ? { body: JSON.stringify(body) } : {}),
    });
  } catch {
    return { ok: false, fieldErrors: {} };
  }
  if (res.ok) return { ok: true, data: (await res.json()) as T };
  const payload = (await res.json().catch(() => ({}))) as ApiError;
  const code = payload.error?.code;
  if (code === "invalid_phone") return { ok: false, fieldErrors: { contactPhone: "phone" } };
  return {
    ok: false,
    fieldErrors: errorsFromIssues(payload.error?.issues),
    ...(payload.error?.message ? { message: payload.error.message } : {}),
  };
}

import { apiFetch } from "../../lib/api-fetch";

export type ApiResult<T> = { ok: true; data: T } | { ok: false; status: number; code: string | undefined };

export const SECOND_FACTOR_REQUIRED = "second_factor_required";

/** Calls an admin API route; a 204/empty body resolves to `null` data. */
export async function adminCall<T>(url: string, init?: RequestInit): Promise<ApiResult<T>> {
  const res = await apiFetch(url, init).catch(() => null);
  if (!res) return { ok: false, status: 0, code: undefined };
  const text = await res.text().catch(() => "");
  let data: unknown = null;
  if (text) {
    try {
      data = JSON.parse(text);
    } catch {
      data = null;
    }
  }
  if (res.ok) return { ok: true, data: data as T };
  const code = (data as { error?: { code?: string } } | null)?.error?.code;
  return { ok: false, status: res.status, code };
}

export const jsonInit = (method: string, body?: unknown): RequestInit =>
  body === undefined ? { method } : { method, headers: { "content-type": "application/json" }, body: JSON.stringify(body) };

/** `?a=1&b=2` from the non-empty values. */
export function queryString(params: Record<string, string | number | undefined>): string {
  const q = new URLSearchParams();
  for (const [key, value] of Object.entries(params)) if (value !== undefined && value !== "") q.set(key, String(value));
  const s = q.toString();
  return s ? `?${s}` : "";
}

/** Start of a local calendar day (yyyy-mm-dd) as ISO, or undefined. */
export function dayStartIso(day: string): string | undefined {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(day)) return undefined;
  const d = new Date(`${day}T00:00:00`);
  return Number.isNaN(d.getTime()) ? undefined : d.toISOString();
}

/** Start of the day after a local calendar day, as ISO (exclusive upper bound), or undefined. */
export function dayEndIso(day: string): string | undefined {
  const start = dayStartIso(day);
  if (!start) return undefined;
  const d = new Date(`${day}T00:00:00`);
  d.setDate(d.getDate() + 1);
  return d.toISOString();
}

export const admin2fa = {
  status: () => adminCall<{ enrolled: boolean; verified: boolean; recoveryCodesLeft: number }>("/api/v1/admin/2fa"),
  enrol: () => adminCall<{ secret: string; otpauthUri: string }>("/api/v1/admin/2fa/enrol", jsonInit("POST")),
  confirm: (code: string) => adminCall<{ recoveryCodes: string[] }>("/api/v1/admin/2fa/confirm", jsonInit("POST", { code })),
  verify: (code: string) => adminCall<null>("/api/v1/admin/2fa/verify", jsonInit("POST", { code })),
  disable: (code: string) => adminCall<null>("/api/v1/admin/2fa/disable", jsonInit("POST", { code })),
};

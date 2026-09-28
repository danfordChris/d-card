import { apiFetch } from "../../lib/api-fetch";
import type { MediaItem, MediaKind, MediaSettings, SharingMode, UploadSession } from "./types";

// Thin wrappers over the host media API. Each returns null (or an error code) instead of throwing.

export const connectUrl = (eventId: string) => `/api/v1/media/google/connect?eventId=${encodeURIComponent(eventId)}`;

const JSON_HEADERS = { "content-type": "application/json" };

export type ApiResult<T> = { ok: true; data: T } | { ok: false; status: number; code: string | null };

async function read<T>(res: Response | null): Promise<ApiResult<T>> {
  if (!res) return { ok: false, status: 0, code: null };
  if (res.ok) {
    const data = res.status === 204 ? null : await res.json().catch(() => null);
    return { ok: true, data: data as T };
  }
  const body = (await res.json().catch(() => null)) as { error?: { code?: string } } | null;
  return { ok: false, status: res.status, code: body?.error?.code ?? null };
}

export async function fetchSettings(eventId: string): Promise<ApiResult<MediaSettings>> {
  return read(await apiFetch(`/api/v1/events/${eventId}/media/settings`).catch(() => null));
}

export async function saveSettings(eventId: string, input: { sharingMode?: SharingMode; googlePhotosUrl?: string }): Promise<ApiResult<MediaSettings>> {
  const res = await apiFetch(`/api/v1/events/${eventId}/media/settings`, { method: "PUT", headers: JSON_HEADERS, body: JSON.stringify(input) }).catch(() => null);
  return read(res);
}

export async function disconnectDrive(): Promise<ApiResult<null>> {
  return read(await apiFetch("/api/v1/media/google", { method: "DELETE" }).catch(() => null));
}

export async function fetchItems(eventId: string, kind: MediaKind): Promise<MediaItem[] | null> {
  const result = await read<{ items: MediaItem[] }>(await apiFetch(`/api/v1/events/${eventId}/media?kind=${kind}`).catch(() => null));
  return result.ok ? (result.data?.items ?? []) : null;
}

export async function createUploadSession(
  eventId: string,
  input: { kind: MediaKind; fileName: string; mimeType: string; sizeBytes: number; durationSeconds?: number | null },
): Promise<ApiResult<UploadSession>> {
  const res = await apiFetch(`/api/v1/events/${eventId}/media/upload-sessions`, { method: "POST", headers: JSON_HEADERS, body: JSON.stringify(input) }).catch(() => null);
  return read(res);
}

export async function completeUpload(eventId: string, itemId: string, driveFileId: string): Promise<ApiResult<MediaItem>> {
  const res = await apiFetch(`/api/v1/events/${eventId}/media/${itemId}/complete`, { method: "POST", headers: JSON_HEADERS, body: JSON.stringify({ driveFileId }) }).catch(() => null);
  return read(res);
}

export async function setItemStatus(eventId: string, itemId: string, status: "visible" | "hidden"): Promise<ApiResult<MediaItem>> {
  const res = await apiFetch(`/api/v1/events/${eventId}/media/${itemId}`, { method: "PATCH", headers: JSON_HEADERS, body: JSON.stringify({ status }) }).catch(() => null);
  return read(res);
}

export async function deleteItem(eventId: string, itemId: string): Promise<ApiResult<null>> {
  return read(await apiFetch(`/api/v1/events/${eventId}/media/${itemId}`, { method: "DELETE" }).catch(() => null));
}

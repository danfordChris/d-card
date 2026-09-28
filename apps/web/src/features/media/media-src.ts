"use client";

import { useEffect, useState } from "react";
import { apiFetch } from "../../lib/api-fetch";

// Private mode serves media through D-Card ("/api/…"), which needs the web API key header, so
// those URLs are fetched and shown as object URLs. Link mode URLs point at Drive and load directly.

export const isProxyUrl = (url: string) => url.startsWith("/api/");

/** Resolves a media URL to something an <img>/<video> can use; the caller revokes blob: URLs. */
export async function loadMediaSrc(url: string): Promise<string | null> {
  if (!isProxyUrl(url)) return url;
  const res = await apiFetch(url).catch(() => null);
  if (!res?.ok) return null;
  const blob = await res.blob().catch(() => null);
  return blob ? URL.createObjectURL(blob) : null;
}

export function releaseMediaSrc(src: string | null | undefined) {
  if (src?.startsWith("blob:")) URL.revokeObjectURL(src);
}

/** undefined while loading, null when it failed. */
export function useMediaSrc(url: string): string | null | undefined {
  const [state, setState] = useState<{ url: string; src: string | null | undefined }>({ url, src: isProxyUrl(url) ? undefined : url });
  useEffect(() => {
    if (!isProxyUrl(url)) return;
    let cancelled = false;
    let loaded: string | null = null;
    void loadMediaSrc(url).then((src) => {
      loaded = src;
      if (cancelled) releaseMediaSrc(src);
      else setState({ url, src });
    });
    return () => {
      cancelled = true;
      releaseMediaSrc(loaded);
    };
  }, [url]);
  if (!isProxyUrl(url)) return url;
  return state.url === url ? state.src : undefined;
}

"use client";

import { useEffect, useRef, useState } from "react";
import { apiFetch } from "../../lib/api-fetch";
import { isProxyUrl } from "./guest-media-api";

/** True once the element is near the viewport (always true where IntersectionObserver is missing). */
export function useNearViewport<T extends Element>(): [React.RefObject<T | null>, boolean] {
  const ref = useRef<T>(null);
  const [near, setNear] = useState(false);
  useEffect(() => {
    const el = ref.current;
    if (!el || near) return;
    if (typeof IntersectionObserver === "undefined") {
      setNear(true);
      return;
    }
    const io = new IntersectionObserver(
      (entries) => {
        if (entries.some((e) => e.isIntersecting)) {
          setNear(true);
          io.disconnect();
        }
      },
      { rootMargin: "200px" },
    );
    io.observe(el);
    return () => io.disconnect();
  }, [near]);
  return [ref, near];
}

/**
 * Resolves a media URL for <img>/<video>. Drive URLs are used as they are; D-Card proxy URLs
 * (private sharing) are fetched with the API key and shown as an object URL, only when `enabled`.
 */
export function useMediaSrc(url: string, enabled: boolean): { src: string | null; failed: boolean } {
  const proxy = isProxyUrl(url);
  const [state, setState] = useState<{ url: string; src: string | null; failed: boolean }>({ url: "", src: null, failed: false });
  useEffect(() => {
    if (!proxy || !enabled) return;
    let cancelled = false;
    let objectUrl: string | null = null;
    apiFetch(url)
      .then(async (res) => {
        if (!res.ok) throw new Error(String(res.status));
        const blob = await res.blob();
        if (cancelled) return;
        objectUrl = URL.createObjectURL(blob);
        setState({ url, src: objectUrl, failed: false });
      })
      .catch(() => {
        if (!cancelled) setState({ url, src: null, failed: true });
      });
    return () => {
      cancelled = true;
      if (objectUrl) URL.revokeObjectURL(objectUrl);
    };
  }, [url, proxy, enabled]);
  if (!proxy) return { src: enabled ? url : null, failed: false };
  return state.url === url ? { src: state.src, failed: state.failed } : { src: null, failed: false };
}

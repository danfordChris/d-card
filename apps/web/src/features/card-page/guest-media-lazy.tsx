"use client";

import dynamic from "next/dynamic";
import { useEffect, useRef, useState } from "react";

// The story and gallery (uploads, resizing, viewer) are the heaviest part of the card page and sit
// below the card. Keep them out of the first-load bundle: fetch the code once the browser is idle
// or the reader nears that part of the page, whichever comes first.
const GuestMediaSections = dynamic(() => import("./guest-media").then((m) => m.GuestMediaSections), { ssr: false });

type IdleWindow = Window & {
  requestIdleCallback?: (cb: () => void, opts?: { timeout: number }) => number;
  cancelIdleCallback?: (id: number) => void;
};

export function LazyGuestMedia({ token }: { token: string }) {
  const marker = useRef<HTMLDivElement>(null);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    if (ready) return;
    const w = window as IdleWindow;
    const go = () => setReady(true);
    let idle: number | undefined;
    let timer: ReturnType<typeof setTimeout> | undefined;
    const schedule = () => {
      if (w.requestIdleCallback) idle = w.requestIdleCallback(go, { timeout: 3000 });
      else timer = setTimeout(go, 1500);
    };
    if (document.readyState === "complete") schedule();
    else window.addEventListener("load", schedule, { once: true });

    let io: IntersectionObserver | undefined;
    if (marker.current && typeof IntersectionObserver !== "undefined") {
      io = new IntersectionObserver((entries) => entries.some((e) => e.isIntersecting) && go(), { rootMargin: "400px" });
      io.observe(marker.current);
    }
    return () => {
      window.removeEventListener("load", schedule);
      if (idle !== undefined) w.cancelIdleCallback?.(idle);
      if (timer) clearTimeout(timer);
      io?.disconnect();
    };
  }, [ready]);

  return ready ? <GuestMediaSections token={token} /> : <div ref={marker} />;
}

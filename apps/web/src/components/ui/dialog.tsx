"use client";

import { useEffect, useId, useRef, type ReactNode } from "react";

/** Minimal accessible modal: labelled, Escape closes, focus moves inside and returns on close. */
export function Dialog({ title, onClose, children }: { title: string; onClose: () => void; children: ReactNode }) {
  const titleId = useId();
  const panel = useRef<HTMLDivElement>(null);
  useEffect(() => {
    const previous = document.activeElement as HTMLElement | null;
    panel.current?.querySelector<HTMLElement>("input, select, textarea, button")?.focus();
    const onKey = (e: KeyboardEvent) => {
      if (e.key === "Escape") onClose();
    };
    document.addEventListener("keydown", onKey);
    return () => {
      document.removeEventListener("keydown", onKey);
      previous?.focus();
    };
  }, [onClose]);
  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center bg-black/40 p-4 sm:items-center">
      <div ref={panel} role="dialog" aria-modal="true" aria-labelledby={titleId} className="w-full max-w-lg max-h-[90vh] overflow-y-auto rounded-hero bg-bg p-6">
        <h2 id={titleId} className="mb-4 font-display text-2xl font-bold">
          {title}
        </h2>
        {children}
      </div>
    </div>
  );
}

"use client";

import { useState } from "react";
import { cn } from "./cn";
import { THEME_COOKIE, parseTheme, type ThemeChoice } from "./theme";

const OPTIONS: ThemeChoice[] = ["light", "dark", "system"];

/** Light / Dark / System switch. Labels come from the caller (sw/en). */
export function ThemeToggle({ initial, labels, legend }: { initial: string | undefined; labels: Record<ThemeChoice, string>; legend: string }) {
  const [choice, setChoice] = useState<ThemeChoice>(parseTheme(initial));
  function pick(next: ThemeChoice) {
    setChoice(next);
    document.cookie = `${THEME_COOKIE}=${next}; Path=/; Max-Age=31536000; SameSite=Lax`;
    if (next === "system") document.documentElement.removeAttribute("data-theme");
    else document.documentElement.setAttribute("data-theme", next);
  }
  return (
    <fieldset className="inline-flex gap-1 rounded-2xl bg-tile p-1">
      <legend className="sr-only">{legend}</legend>
      {OPTIONS.map((o) => (
        <label
          key={o}
          className={cn(
            "cursor-pointer rounded-xl px-3 py-2 text-sm font-semibold focus-within:outline-2 focus-within:outline-primary",
            choice === o ? "bg-primary text-on-primary" : "text-ink",
          )}
        >
          <input type="radio" name="theme" value={o} checked={choice === o} onChange={() => pick(o)} className="sr-only" />
          {labels[o]}
        </label>
      ))}
    </fieldset>
  );
}

"use client";

import { useTranslations } from "next-intl";
import { useId, useRef, useState, type KeyboardEvent } from "react";
import { Button } from "../../components/ui";
import { cn } from "../../components/ui/cn";
import { apiFetch } from "../../lib/api-fetch";

export type RsvpState = { status: "none" | "yes" | "no"; dietaryNotes: string | null; open: boolean };

/**
 * GST-12: Yes/No RSVP with an optional dietary note, no login (ADR 0001 O19).
 * The chosen answer uses the design system's primary pill; `accent` (the event's card colour) is accepted for
 * compatibility but not used here, so the answer keeps its contrast in both themes.
 */
export function RsvpForm({ token, initial }: { token: string; initial: RsvpState; accent?: string }) {
  const t = useTranslations("cardPage");
  const [rsvp, setRsvp] = useState(initial);
  const [answer, setAnswer] = useState<"yes" | "no" | null>(initial.status === "none" ? null : initial.status);
  const [dietary, setDietary] = useState(initial.dietaryNotes ?? "");
  const [message, setMessage] = useState<{ tone: "success" | "error"; text: string }>();
  const [busy, setBusy] = useState(false);
  const ids = useId();
  const radios = useRef<(HTMLButtonElement | null)[]>([]);

  if (!rsvp.open) {
    return (
      <div className="space-y-2">
        {rsvp.status !== "none" && <p className="font-medium">{t("yourAnswer", { answer: t(rsvp.status === "yes" ? "answerYes" : "answerNo") })}</p>}
        <p className="text-sm text-muted">{t("rsvpClosed")}</p>
      </div>
    );
  }

  async function submit() {
    if (!answer) return;
    setBusy(true);
    setMessage(undefined);
    const res = await apiFetch(`/api/v1/cards/${encodeURIComponent(token)}/rsvp`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ answer, dietaryNotes: dietary.trim() || null }),
    }).catch(() => null);
    setBusy(false);
    if (res?.ok) {
      const saved = (await res.json()) as RsvpState;
      setRsvp(saved);
      setDietary(saved.dietaryNotes ?? "");
      return setMessage({ tone: "success", text: t("saved") });
    }
    const text = res?.status === 429 ? t("errors.rateLimited") : res?.status === 409 ? t("errors.closed") : t("errors.generic");
    setMessage({ tone: "error", text });
  }

  const choices = ["yes", "no"] as const;
  // Roving tab stop: one Tab reaches the group, arrow keys move and select (WAI-ARIA radio group).
  const tabStop = answer ?? "yes";
  function onRadioKey(e: KeyboardEvent<HTMLButtonElement>, i: number) {
    const step = e.key === "ArrowDown" || e.key === "ArrowRight" ? 1 : e.key === "ArrowUp" || e.key === "ArrowLeft" ? -1 : 0;
    if (!step) return;
    e.preventDefault();
    const next = (i + step + choices.length) % choices.length;
    setAnswer(choices[next]!);
    radios.current[next]?.focus();
  }

  return (
    <div className="space-y-4">
      <div role="radiogroup" aria-label={t("rsvpTitle")} className="grid gap-2 sm:grid-cols-2">
        {choices.map((value, i) => (
          <button
            key={value}
            ref={(el) => {
              radios.current[i] = el;
            }}
            type="button"
            role="radio"
            aria-checked={answer === value}
            tabIndex={tabStop === value ? 0 : -1}
            onClick={() => setAnswer(value)}
            onKeyDown={(e) => onRadioKey(e, i)}
            className={cn(
              "min-h-12 rounded-field px-4 py-3 text-left text-sm font-bold transition-colors",
              "focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-primary",
              answer === value ? "bg-primary text-on-primary" : "bg-bg text-ink hover:bg-tile2",
            )}
          >
            {t(value === "yes" ? "rsvpYes" : "rsvpNo")}
          </button>
        ))}
      </div>
      <div className="space-y-1">
        <label htmlFor={`${ids}-diet`} className="block text-sm font-medium">
          {t("dietary")}
        </label>
        <textarea
          id={`${ids}-diet`}
          aria-describedby={`${ids}-diet-hint`}
          value={dietary}
          maxLength={300}
          rows={2}
          onChange={(e) => setDietary(e.target.value)}
          className="block w-full rounded-field border-0 bg-field px-4 py-3 text-sm text-ink placeholder:text-muted focus:ring-2 focus:ring-primary focus:outline-none"
        />
        <p id={`${ids}-diet-hint`} className="text-xs text-muted">
          {t("dietaryHint")}
        </p>
      </div>
      {/* Always mounted, so screen readers announce the result when it appears. */}
      <div role="status" aria-live="polite" aria-atomic="true">
        {message && (
          <p className={cn("rounded-field p-3 text-sm", message.tone === "error" ? "bg-danger-bg text-danger" : "bg-success-bg text-success")}>
            {message.text}
          </p>
        )}
      </div>
      <Button onClick={submit} disabled={!answer || busy} aria-busy={busy} className="w-full sm:w-auto">
        {t("save")}
      </Button>
      <p className="text-xs text-muted">{t("change")}</p>
    </div>
  );
}

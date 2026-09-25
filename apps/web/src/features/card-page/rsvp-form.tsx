"use client";

import { useTranslations } from "next-intl";
import { useState } from "react";
import { Alert, Button } from "../../components/ui";
import { cn } from "../../components/ui/cn";
import { apiFetch } from "../../lib/api-fetch";

export type RsvpState = { status: "none" | "yes" | "no"; dietaryNotes: string | null; open: boolean };

/** GST-12: Yes/No RSVP with an optional dietary note, no login (ADR 0001 O19). */
export function RsvpForm({ token, initial, accent }: { token: string; initial: RsvpState; accent: string }) {
  const t = useTranslations("cardPage");
  const [rsvp, setRsvp] = useState(initial);
  const [answer, setAnswer] = useState<"yes" | "no" | null>(initial.status === "none" ? null : initial.status);
  const [dietary, setDietary] = useState(initial.dietaryNotes ?? "");
  const [message, setMessage] = useState<{ tone: "success" | "error"; text: string }>();
  const [busy, setBusy] = useState(false);

  if (!rsvp.open) {
    return (
      <div className="space-y-2">
        {rsvp.status !== "none" && <p className="font-medium">{t("yourAnswer", { answer: t(rsvp.status === "yes" ? "answerYes" : "answerNo") })}</p>}
        <p className="text-sm text-gray-600">{t("rsvpClosed")}</p>
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

  return (
    <div className="space-y-4">
      <div role="radiogroup" aria-label={t("rsvpTitle")} className="grid gap-2 sm:grid-cols-2">
        {(["yes", "no"] as const).map((value) => (
          <button
            key={value}
            type="button"
            role="radio"
            aria-checked={answer === value}
            onClick={() => setAnswer(value)}
            className={cn(
              "rounded-lg px-4 py-3 text-left text-sm font-medium ring-1 transition",
              answer === value ? "text-white ring-transparent" : "bg-white text-gray-800 ring-gray-300 hover:bg-gray-50",
            )}
            style={answer === value ? { backgroundColor: accent } : undefined}
          >
            {t(value === "yes" ? "rsvpYes" : "rsvpNo")}
          </button>
        ))}
      </div>
      <label className="block space-y-1">
        <span className="text-sm font-medium">{t("dietary")}</span>
        <textarea
          value={dietary}
          maxLength={300}
          rows={2}
          onChange={(e) => setDietary(e.target.value)}
          className="block w-full rounded-lg border-0 bg-white px-3 py-2 text-sm ring-1 ring-gray-300 focus:ring-2 focus:ring-brand-600"
        />
        <span className="text-xs text-gray-500">{t("dietaryHint")}</span>
      </label>
      {message && <Alert tone={message.tone}>{message.text}</Alert>}
      <Button onClick={submit} disabled={!answer || busy} className="w-full sm:w-auto">
        {t("save")}
      </Button>
      <p className="text-xs text-gray-500">{t("change")}</p>
    </div>
  );
}

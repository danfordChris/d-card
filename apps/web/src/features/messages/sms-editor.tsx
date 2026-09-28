"use client";

import { gsmProblems, PLACEHOLDERS, renderTemplate, SAMPLE_VARS, smsLength } from "@dcard/core/sms";
import { useTranslations } from "next-intl";
import { useRef } from "react";
import { cn } from "../../components/ui";

/** MSG-4: live counter, GSM warning, placeholder chips and a sample preview. */
export function SmsEditor({
  id,
  value,
  onChange,
  locked,
  invalid,
}: {
  id: string;
  value: string;
  onChange: (v: string) => void;
  locked: boolean;
  invalid?: boolean;
}) {
  const t = useTranslations("messageSettings");
  const area = useRef<HTMLTextAreaElement>(null);
  const preview = renderTemplate(value, SAMPLE_VARS);
  const length = smsLength(preview);
  const bad = gsmProblems(value);

  function insert(p: string) {
    const el = area.current;
    const token = `{${p}}`;
    if (!el) return onChange(value + token);
    const start = el.selectionStart ?? value.length;
    const end = el.selectionEnd ?? value.length;
    onChange(value.slice(0, start) + token + value.slice(end));
    requestAnimationFrame(() => {
      el.focus();
      el.setSelectionRange(start + token.length, start + token.length);
    });
  }

  return (
    <div className="space-y-2">
      <textarea
        id={id}
        ref={area}
        value={value}
        readOnly={locked}
        rows={4}
        onChange={(e) => onChange(e.target.value)}
        aria-invalid={invalid || bad.length > 0 || undefined}
        className={cn(
          "block w-full rounded-field border-0 bg-field px-4 py-3 font-mono text-sm text-ink focus:ring-2 focus:ring-primary focus:outline-none",
          locked && "text-muted",
          (invalid || bad.length > 0) && "ring-2 ring-danger",
        )}
      />
      <p className="text-xs text-muted" data-testid={`${id}-counter`}>
        {t("counter", { chars: length.units, segments: length.segments })}
      </p>
      {bad.length > 0 && (
        <p className="text-xs text-danger" role="alert">
          {t("gsmWarning", { chars: bad.join(" ") })}
        </p>
      )}
      {!locked && (
        <div className="flex flex-wrap items-center gap-1.5">
          <span className="text-xs text-muted">{t("insert")}:</span>
          {PLACEHOLDERS.filter((p) => p !== "note").map((p) => (
            <button
              key={p}
              type="button"
              onClick={() => insert(p)}
              className="min-h-8 rounded-full bg-soft px-2.5 py-0.5 font-mono text-xs text-on-soft hover:bg-tile2"
            >
              {`{${p}}`}
            </button>
          ))}
        </div>
      )}
      <p className="text-xs text-muted">{t("contactRequired")}</p>
      <div className="rounded-lg bg-tile2 p-3 text-sm">
        <p className="mb-1 text-xs font-medium text-muted">{t("preview")}</p>
        <p className="whitespace-pre-wrap" data-testid={`${id}-preview`}>
          {preview}
        </p>
      </div>
    </div>
  );
}

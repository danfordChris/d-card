"use client";

import { Tag01Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useTranslations } from "next-intl";
import { formatMoney } from "./format";
import type { BillingQuote } from "./types";

const KNOWN_LINES = new Set(["new_cards", "extra_cards", "upgrade", "minimum_top_up"]);

/** Server quote as label/value rows with a bold total (never computed on the client). */
export function QuoteBreakdown({ quote }: { quote: BillingQuote }) {
  const t = useTranslations("billing.checkout");
  const row = (label: string, value: string, testId?: string) => (
    <div className="flex items-baseline justify-between gap-4 py-1.5" data-testid={testId}>
      <dt className="text-gray-600">{label}</dt>
      <dd className="tabular-nums text-gray-900">{value}</dd>
    </div>
  );
  return (
    <dl className="text-sm" data-testid="quote-breakdown">
      {quote.lines.map((line, i) =>
        row(
          t(`lines.${KNOWN_LINES.has(line.code) ? line.code : "other"}`, {
            quantity: line.quantity,
            unitPrice: formatMoney(line.unitPrice),
          }),
          formatMoney(line.amount),
          `quote-line-${line.code}-${i}`,
        ),
      )}
      <div className="mt-1 border-t border-gray-200 pt-1">{row(t("subtotal"), formatMoney(quote.subtotal))}</div>
      {quote.discountPercent > 0 && (
        <div className="flex items-baseline justify-between gap-4 py-1.5 text-green-700" data-testid="launch-offer">
          <dt className="flex items-center gap-1.5">
            <HugeiconsIcon icon={Tag01Icon} size={16} strokeWidth={1.8} aria-hidden="true" />
            {t("launchOffer", { percent: quote.discountPercent })}
          </dt>
          <dd className="tabular-nums">{formatMoney(-quote.discountAmount)}</dd>
        </div>
      )}
      <div className="mt-1 flex items-baseline justify-between gap-4 border-t border-gray-200 pt-2 text-base font-semibold" data-testid="quote-total">
        <dt>{t("total")}</dt>
        <dd className="tabular-nums">{formatMoney(quote.total)}</dd>
      </div>
    </dl>
  );
}

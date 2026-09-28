"use client";

import { useLocale, useTranslations } from "next-intl";
import { formatMoney, formatPaymentDate } from "./format";

export interface ReceiptData {
  reference: string | null;
  amount: number;
  guestCards: number;
  planName: string;
  date: string;
  discountAmount?: number;
}

/** Receipt rows: reference, amount, cards, plan, date (Africa/Dar_es_Salaam). */
export function Receipt({ receipt }: { receipt: ReceiptData }) {
  const t = useTranslations("billing.receipt");
  const locale = useLocale();
  const row = (label: string, value: string) => (
    <div className="flex items-baseline justify-between gap-4 py-1.5">
      <dt className="text-gray-500">{label}</dt>
      <dd className="text-right tabular-nums text-gray-900">{value}</dd>
    </div>
  );
  return (
    <dl className="divide-y divide-gray-100 text-sm" data-testid="receipt">
      {row(t("reference"), receipt.reference ?? "—")}
      {row(t("amount"), formatMoney(receipt.amount))}
      {receipt.discountAmount ? row(t("discount"), formatMoney(-receipt.discountAmount)) : null}
      {row(t("cards"), t("cardsValue", { count: receipt.guestCards }))}
      {row(t("plan"), receipt.planName)}
      {row(t("date"), formatPaymentDate(receipt.date, locale))}
    </dl>
  );
}

"use client";

import { ArrowUp01Icon, Clock01Icon, Invoice01Icon, PlusSignIcon, Ticket01Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useLocale, useTranslations } from "next-intl";
import { useCallback, useEffect, useState } from "react";
import { Alert, Button, Card } from "../../components/ui";
import { billingApi } from "./api";
import { CheckoutFlow, upwardPlans } from "./checkout-flow";
import { formatMoney, formatPaymentDate } from "./format";
import { Receipt } from "./receipt";
import type { BillingPlan, BillingSummary, CheckoutMode, PaymentAttempt } from "./types";

type Open = { mode: CheckoutMode; resume?: PaymentAttempt } | undefined;

/** Host billing: plan, cards paid/issued/guests, receipts, pending payment and checkout entry points. */
export function BillingView({
  eventId,
  plans,
  initialMode,
  quoteDelayMs,
  pollMs,
}: {
  eventId: string;
  plans: BillingPlan[];
  /** Opens the checkout straight away (e.g. from the "Pay for cards" banner). */
  initialMode?: CheckoutMode | undefined;
  quoteDelayMs?: number;
  pollMs?: number;
}) {
  const t = useTranslations("billing");
  const locale = useLocale();
  const [summary, setSummary] = useState<BillingSummary>();
  const [loadError, setLoadError] = useState(false);
  const [open, setOpen] = useState<Open>(initialMode ? { mode: initialMode } : undefined);

  const load = useCallback(async () => {
    const r = await billingApi.summary(eventId);
    if (r.ok) {
      setSummary(r.data);
      setLoadError(false);
    } else {
      setLoadError(true);
    }
  }, [eventId]);

  useEffect(() => {
    // Initial fetch; state is set after the request resolves.
    void load();
  }, [load]);

  if (!summary) {
    return loadError ? (
      <div className="space-y-3">
        <Alert tone="error">{t("loadError")}</Alert>
        <Button variant="secondary" onClick={() => void load()}>
          {t("retry")}
        </Button>
      </div>
    ) : (
      <p className="text-sm text-gray-500">{t("loading")}</p>
    );
  }

  const canUpgrade = upwardPlans(plans, summary).length > 1;
  const pending = summary.pendingAttempt?.status === "pending" ? summary.pendingAttempt : null;
  const planNameOf = (key: string) => plans.find((p) => p.key === key)?.name ?? (key === summary.planKey ? summary.planName : key);
  const stat = (label: string, value: string, testId: string) => (
    <div className="rounded-lg p-4 ring-1 ring-gray-200" data-testid={testId}>
      <p className="text-sm text-gray-500">{label}</p>
      <p className="mt-1 text-xl font-semibold tabular-nums">{value}</p>
    </div>
  );

  return (
    <div className="space-y-6">
      <Card className="space-y-4">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div className="flex items-center gap-3">
            <span className="flex h-10 w-10 items-center justify-center rounded-full bg-brand-50 text-brand-700">
              <HugeiconsIcon icon={Ticket01Icon} size={20} strokeWidth={1.8} aria-hidden="true" />
            </span>
            <div>
              <h2 className="font-semibold">{t("summary.plan", { name: summary.planName })}</h2>
              <p className="text-sm text-gray-600">{t("summary.pricePerGuest", { amount: formatMoney(summary.pricePerGuest) })}</p>
            </div>
          </div>
          <span
            className={
              summary.paid
                ? "rounded-full bg-green-50 px-2.5 py-0.5 text-xs font-medium text-green-700 ring-1 ring-green-200"
                : "rounded-full bg-amber-50 px-2.5 py-0.5 text-xs font-medium text-amber-800 ring-1 ring-amber-200"
            }
          >
            {summary.paid ? t("summary.paid") : t("summary.unpaidBadge")}
          </span>
        </div>
        <div className="grid gap-3 sm:grid-cols-4">
          {stat(t("summary.cardsPaid"), String(summary.guestLimit), "stat-paid")}
          {stat(t("summary.cardsIssued"), String(summary.issuedCards), "stat-issued")}
          {stat(t("summary.guests"), String(summary.guestCount), "stat-guests")}
          {stat(t("summary.amountPaid"), formatMoney(summary.amountPaid), "stat-amount")}
        </div>
        {!summary.paid && <Alert>{t("summary.unpaid")}</Alert>}
        {summary.paid && summary.guestCount > summary.guestLimit && (
          <Alert>{t("summary.overLimit", { guests: summary.guestCount, paid: summary.guestLimit })}</Alert>
        )}
        {summary.launchOfferEligible && summary.launchOfferPercent > 0 && (
          <p className="text-sm text-green-700">{t("summary.launchOffer", { percent: summary.launchOfferPercent })}</p>
        )}
        {!open && (
          <div className="flex flex-wrap gap-2">
            {!summary.paid ? (
              <Button onClick={() => setOpen({ mode: "buy" })} disabled={pending !== null}>
                <HugeiconsIcon icon={Ticket01Icon} size={16} strokeWidth={1.8} aria-hidden="true" />
                {t("actions.buy")}
              </Button>
            ) : (
              <Button onClick={() => setOpen({ mode: "add" })} disabled={pending !== null}>
                <HugeiconsIcon icon={PlusSignIcon} size={16} strokeWidth={1.8} aria-hidden="true" />
                {t("actions.addBlock")}
              </Button>
            )}
            {canUpgrade && (
              <Button variant="secondary" onClick={() => setOpen({ mode: "upgrade" })} disabled={pending !== null}>
                <HugeiconsIcon icon={ArrowUp01Icon} size={16} strokeWidth={1.8} aria-hidden="true" />
                {t("actions.upgrade")}
              </Button>
            )}
          </div>
        )}
      </Card>

      {pending && !open && (
        <Card className="flex flex-wrap items-center justify-between gap-3" data-testid="pending-attempt">
          <div className="flex items-center gap-3">
            <span className="flex h-10 w-10 items-center justify-center rounded-full bg-amber-50 text-amber-700">
              <HugeiconsIcon icon={Clock01Icon} size={20} strokeWidth={1.8} aria-hidden="true" />
            </span>
            <div>
              <h2 className="font-semibold">{t("pending.title")}</h2>
              <p className="text-sm text-gray-600">
                {t("pending.body", { amount: formatMoney(pending.amount), date: formatPaymentDate(pending.createdAt, locale) })}
              </p>
            </div>
          </div>
          <Button variant="secondary" onClick={() => setOpen({ mode: summary.paid ? "add" : "buy", resume: pending })}>
            {t("pending.resume")}
          </Button>
        </Card>
      )}

      {open && (
        <CheckoutFlow
          key={`${open.mode}-${open.resume?.id ?? "new"}`}
          eventId={eventId}
          summary={summary}
          plans={plans}
          mode={open.mode}
          resume={open.resume}
          onClose={() => {
            setOpen(undefined);
            void load();
          }}
          onChanged={() => void load()}
          {...(quoteDelayMs !== undefined ? { quoteDelayMs } : {})}
          {...(pollMs !== undefined ? { pollMs } : {})}
        />
      )}

      <section className="space-y-3">
        <h2 className="flex items-center gap-2 font-semibold">
          <HugeiconsIcon icon={Invoice01Icon} size={18} strokeWidth={1.8} aria-hidden="true" />
          {t("history.title")}
        </h2>
        {summary.payments.length === 0 ? (
          <p className="text-sm text-gray-500">{t("history.empty")}</p>
        ) : (
          <div className="grid gap-3 md:grid-cols-2">
            {summary.payments.map((p) => (
              <Card key={p.id} className="p-4" data-testid="payment-receipt">
                <Receipt
                  receipt={{
                    reference: p.reference,
                    amount: p.amount,
                    discountAmount: p.discountAmount,
                    guestCards: p.guestCards,
                    planName: planNameOf(p.planKey),
                    date: p.paidAt,
                  }}
                />
              </Card>
            ))}
          </div>
        )}
      </section>
    </div>
  );
}

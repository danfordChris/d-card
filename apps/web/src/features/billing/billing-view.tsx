"use client";

import { ArrowUp01Icon, Clock01Icon, Invoice01Icon, PlusSignIcon, Ticket01Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useLocale, useTranslations } from "next-intl";
import { useCallback, useEffect, useState } from "react";
import { Alert, Badge, Button, Card } from "../../components/ui";
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
      <p className="text-sm text-muted">{t("loading")}</p>
    );
  }

  const canUpgrade = upwardPlans(plans, summary).length > 1;
  const pending = summary.pendingAttempt?.status === "pending" ? summary.pendingAttempt : null;
  const planNameOf = (key: string) => plans.find((p) => p.key === key)?.name ?? (key === summary.planKey ? summary.planName : key);
  const stat = (label: string, value: string, testId: string) => (
    <div className="rounded-2xl bg-bg p-4" data-testid={testId}>
      <p className="text-sm text-muted">{label}</p>
      <p className="mt-1 font-display text-2xl font-extrabold tabular-nums">{value}</p>
    </div>
  );

  return (
    <div className="space-y-6">
      <Card className="space-y-4">
        <div className="flex flex-wrap items-start justify-between gap-3">
          <div className="flex items-center gap-3">
            <span className="flex h-10 w-10 items-center justify-center rounded-full bg-soft text-primary">
              <HugeiconsIcon icon={Ticket01Icon} size={20} strokeWidth={1.8} aria-hidden="true" />
            </span>
            <div>
              <h2 className="font-display text-xl font-bold">{t("summary.plan", { name: summary.planName })}</h2>
              <p className="text-sm text-muted">{t("summary.pricePerGuest", { amount: formatMoney(summary.pricePerGuest) })}</p>
            </div>
          </div>
          <Badge tone={summary.paid ? "success" : "warning"}>{summary.paid ? t("summary.paid") : t("summary.unpaidBadge")}</Badge>
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
          <p className="text-sm text-success">{t("summary.launchOffer", { percent: summary.launchOfferPercent })}</p>
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
            <span className="flex h-10 w-10 items-center justify-center rounded-full bg-warning-bg text-warning">
              <HugeiconsIcon icon={Clock01Icon} size={20} strokeWidth={1.8} aria-hidden="true" />
            </span>
            <div>
              <h2 className="font-display text-xl font-bold">{t("pending.title")}</h2>
              <p className="text-sm text-muted">
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
        <h2 className="font-display flex items-center gap-2 font-bold">
          <HugeiconsIcon icon={Invoice01Icon} size={18} strokeWidth={1.8} aria-hidden="true" />
          {t("history.title")}
        </h2>
        {summary.payments.length === 0 ? (
          <p className="text-sm text-muted">{t("history.empty")}</p>
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

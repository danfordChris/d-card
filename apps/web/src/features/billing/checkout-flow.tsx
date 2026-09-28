"use client";

import { normalisePhone, isValidPhone } from "@dcard/core/phone";
import {
  Alert02Icon,
  CheckmarkCircle02Icon,
  CreditCardIcon,
  Link03Icon,
  MinusSignIcon,
  PlusSignIcon,
  SecurityCheckIcon,
  SmartPhone01Icon,
} from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useTranslations } from "next-intl";
import { useEffect, useState } from "react";
import { Alert, Button, Card, Field, Input, cn } from "../../components/ui";
import { localPhone } from "../events/format";
import { billingApi } from "./api";
import { formatMoney } from "./format";
import { QuoteBreakdown } from "./quote-breakdown";
import { Receipt } from "./receipt";
import type { BillingPlan, BillingQuote, BillingSummary, CheckoutMode, HostPaymentMethod, PaymentAttempt } from "./types";

type Step = "form" | "review" | "waiting" | "success" | "failure";
type Notice = { tone: "info" | "error"; text: string };

const selectClass =
  "block w-full rounded-field border-0 bg-field px-3 py-2 text-sm text-ink focus:ring-2 focus:ring-primary focus:outline-none";
const DEFAULT_BLOCK = 10;

/** Plans the host may choose: the current one and those priced above it (upgrades only). */
export function upwardPlans(plans: BillingPlan[], summary: Pick<BillingSummary, "planKey" | "pricePerGuest">): BillingPlan[] {
  return plans
    .filter((p) => p.key === summary.planKey || p.pricePerGuest > summary.pricePerGuest)
    .sort((a, b) => a.pricePerGuest - b.pricePerGuest);
}

function initialCards(summary: BillingSummary, mode: CheckoutMode): number {
  if (mode === "add") return summary.guestLimit + DEFAULT_BLOCK;
  if (mode === "upgrade") return Math.max(summary.guestLimit, 1);
  return Math.max(summary.guestCount, summary.guestLimit, 1);
}

function initialPlan(summary: BillingSummary, plans: BillingPlan[], mode: CheckoutMode): string {
  if (mode !== "upgrade") return summary.planKey;
  return upwardPlans(plans, summary).find((p) => p.key !== summary.planKey)?.key ?? summary.planKey;
}

// Solomon money flow: choose (live server quote) → review → pay → waiting (poll) → receipt.
export function CheckoutFlow({
  eventId,
  summary,
  plans,
  mode,
  resume,
  onClose,
  onChanged,
  quoteDelayMs = 400,
  pollMs = 3000,
}: {
  eventId: string;
  summary: BillingSummary;
  plans: BillingPlan[];
  mode: CheckoutMode;
  /** A pending attempt to resume (opens straight on the waiting step). */
  resume?: PaymentAttempt | undefined;
  onClose: () => void;
  /** Billing changed (paid, or another payment is running): reload the summary. */
  onChanged?: () => void;
  quoteDelayMs?: number;
  pollMs?: number;
}) {
  const t = useTranslations("billing.checkout");
  const options = upwardPlans(plans, summary);
  const [step, setStep] = useState<Step>(resume ? "waiting" : "form");
  const [planKey, setPlanKey] = useState(resume?.planKey ?? initialPlan(summary, plans, mode));
  const [cards, setCards] = useState(resume?.guestCards ?? initialCards(summary, mode));
  const [quote, setQuote] = useState<BillingQuote>();
  const [quoteKey, setQuoteKey] = useState<string>();
  const [quoteState, setQuoteState] = useState<"loading" | "ready" | "error" | "invalid">("loading");
  const [reloadToken, setReloadToken] = useState(0);
  const [method, setMethod] = useState<HostPaymentMethod>("mobile");
  const [phone, setPhone] = useState("");
  const [phoneError, setPhoneError] = useState<string>();
  const [notice, setNotice] = useState<Notice>();
  const [busy, setBusy] = useState(false);
  const [attempt, setAttempt] = useState<PaymentAttempt | undefined>(resume);

  const blockSize = quote?.blockSize ?? DEFAULT_BLOCK;
  const minCards = summary.paid ? Math.max(summary.guestLimit, 1) : 1;
  const currentKey = `${planKey}|${cards}`;
  const fresh = quoteState === "ready" && quoteKey === currentKey && quote !== undefined;
  const planName = (key: string) => plans.find((p) => p.key === key)?.name ?? (key === summary.planKey ? summary.planName : key);

  // Live quote from the server, debounced while the host changes cards or plan.
  useEffect(() => {
    if (!Number.isInteger(cards) || cards < minCards) {
      setQuoteState("invalid");
      return;
    }
    let cancelled = false;
    setQuoteState("loading");
    const key = `${planKey}|${cards}`;
    const timer = setTimeout(async () => {
      const r = await billingApi.quote(eventId, { planKey, guestCards: cards });
      if (cancelled) return;
      if (r.ok) {
        setQuote(r.data);
        setQuoteKey(key);
        setQuoteState("ready");
      } else {
        setQuoteState(r.status === 422 ? "invalid" : "error");
      }
    }, quoteDelayMs);
    return () => {
      cancelled = true;
      clearTimeout(timer);
    };
  }, [eventId, planKey, cards, minCards, quoteDelayMs, reloadToken]);

  // Poll the attempt every pollMs while it is pending; stop on completed/failed/expired.
  const attemptId = step === "waiting" ? attempt?.id : undefined;
  useEffect(() => {
    if (!attemptId) return;
    let stopped = false;
    let timer: ReturnType<typeof setTimeout>;
    const tick = async () => {
      const r = await billingApi.attempt(eventId, attemptId);
      if (stopped) return;
      if (r.ok && r.data.status !== "pending") {
        finish(r.data);
        return;
      }
      timer = setTimeout(tick, pollMs);
    };
    timer = setTimeout(tick, pollMs);
    return () => {
      stopped = true;
      clearTimeout(timer);
    };
    // finish only sets state and calls onChanged; the poll restarts only for a new attempt.
  }, [attemptId, eventId, pollMs]);

  function finish(a: PaymentAttempt) {
    setAttempt(a);
    if (a.status === "completed") {
      setStep("success");
      onChanged?.();
    } else {
      setStep("failure");
    }
  }

  function changeCards(next: number) {
    setNotice(undefined);
    setCards(Math.max(minCards, next));
  }

  async function pay() {
    if (!quote || !fresh) return;
    setNotice(undefined);
    let payPhone: string | null = null;
    if (method === "mobile") {
      if (!phone.trim()) return setPhoneError(t("errors.phoneRequired"));
      if (!isValidPhone(phone)) return setPhoneError(t("errors.phoneInvalid"));
      setPhoneError(undefined);
      payPhone = normalisePhone(phone);
    }
    // Open the tab inside the click so pop-up blockers allow it; filled once the session exists.
    const tab = method === "session" && typeof window !== "undefined" ? window.open("", "_blank") : null;
    setBusy(true);
    const r = await billingApi.checkout(eventId, { planKey, guestCards: cards, method, phone: payPhone, expectedTotal: quote.total });
    setBusy(false);
    if (r.ok) {
      const started = r.data;
      if (tab && started.checkoutUrl) {
        tab.opener = null;
        tab.location.href = started.checkoutUrl;
      } else {
        tab?.close();
      }
      setAttempt(started);
      if (started.status === "pending") setStep("waiting");
      else finish(started);
      return;
    }
    tab?.close();
    if (r.code === "quote_changed") {
      const q = await billingApi.quote(eventId, { planKey, guestCards: cards });
      if (q.ok) {
        setQuote(q.data);
        setQuoteKey(currentKey);
        setQuoteState("ready");
      }
      return setNotice({ tone: "info", text: t("errors.quote_changed") });
    }
    if (r.code === "payment_in_progress") onChanged?.();
    const known = ["nothing_to_pay", "payment_in_progress"];
    let text = t("errors.generic");
    if (r.code && known.includes(r.code)) text = t(`errors.${r.code as "nothing_to_pay" | "payment_in_progress"}`);
    else if (r.status === 502) text = t("errors.provider");
    else if (r.status === 422) text = t("errors.validation");
    else if (r.status === 403) text = t("errors.forbidden");
    setNotice({ tone: "error", text });
  }

  function retry() {
    setAttempt(undefined);
    setNotice(undefined);
    setStep("review");
    setReloadToken((n) => n + 1);
  }

  const heading = t(`titles.${resume ? "resume" : mode}`);

  if (step === "waiting" && attempt) {
    const mobile = attempt.method === "mobile";
    return (
      <Card className="space-y-4" data-testid="checkout-waiting">
        <div className="flex items-start gap-3" role="status" aria-live="polite">
          <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-soft text-primary">
            <HugeiconsIcon icon={mobile ? SmartPhone01Icon : CreditCardIcon} size={20} strokeWidth={1.8} aria-hidden="true" />
          </span>
          <div>
            <h2 className="font-display text-xl font-bold">{mobile ? t("waiting.mobileTitle") : t("waiting.sessionTitle")}</h2>
            <p className="text-sm text-muted">
              {mobile
                ? t("waiting.mobileBody", { amount: formatMoney(attempt.amount), phone: attempt.phone ? localPhone(attempt.phone) : "" })
                : t("waiting.sessionBody", { amount: formatMoney(attempt.amount) })}
            </p>
          </div>
        </div>
        {!mobile && attempt.checkoutUrl && (
          <a
            href={attempt.checkoutUrl}
            target="_blank"
            rel="noopener noreferrer"
            className="inline-flex items-center gap-1.5 text-sm font-medium text-primary hover:underline"
          >
            <HugeiconsIcon icon={Link03Icon} size={16} strokeWidth={1.8} aria-hidden="true" />
            {t("waiting.openPage")}
          </a>
        )}
        <p className="text-sm text-muted">{t("waiting.polling")}</p>
        <Button variant="secondary" onClick={onClose}>
          {t("waiting.later")}
        </Button>
      </Card>
    );
  }

  if (step === "success" && attempt) {
    return (
      <Card className="space-y-4" data-testid="checkout-success">
        <div className="flex items-start gap-3" role="status">
          <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-success-bg text-success">
            <HugeiconsIcon icon={CheckmarkCircle02Icon} size={20} strokeWidth={1.8} aria-hidden="true" />
          </span>
          <div>
            <h2 className="font-display text-xl font-bold">{t("success.title")}</h2>
            <p className="text-sm text-muted">{t("success.next", { count: attempt.guestCards })}</p>
          </div>
        </div>
        <Receipt
          receipt={{
            reference: attempt.reference,
            amount: attempt.amount,
            guestCards: attempt.guestCards,
            planName: planName(attempt.planKey),
            date: attempt.completedAt ?? attempt.createdAt,
          }}
        />
        <Button onClick={onClose}>{t("success.done")}</Button>
      </Card>
    );
  }

  if (step === "failure" && attempt) {
    return (
      <Card className="space-y-4" data-testid="checkout-failure">
        <div className="flex items-start gap-3" role="alert">
          <span className="flex h-10 w-10 shrink-0 items-center justify-center rounded-full bg-danger-bg text-danger">
            <HugeiconsIcon icon={Alert02Icon} size={20} strokeWidth={1.8} aria-hidden="true" />
          </span>
          <div>
            <h2 className="font-display text-xl font-bold">{attempt.status === "expired" ? t("failure.expiredTitle") : t("failure.title")}</h2>
            <p className="text-sm text-muted">{t("failure.body")}</p>
            {attempt.failureReason && <p className="mt-1 text-sm text-muted">{attempt.failureReason}</p>}
          </div>
        </div>
        <div className="flex flex-wrap gap-2">
          <Button onClick={retry}>{t("failure.retry")}</Button>
          <Button variant="secondary" onClick={onClose}>
            {t("cancel")}
          </Button>
        </div>
      </Card>
    );
  }

  if (step === "review" && quote) {
    return (
      <Card className="space-y-5" data-testid="checkout-review">
        <div>
          <h2 className="font-display text-xl font-bold">{t("review.title")}</h2>
          <p className="text-sm text-muted">{t("review.intro", { plan: quote.planName, count: quote.guestCards })}</p>
        </div>
        <div className={cn(!fresh && "opacity-60")}>
          <QuoteBreakdown quote={quote} />
        </div>
        <fieldset className="space-y-2">
          <legend className="mb-1 text-sm font-medium text-ink">{t("review.method")}</legend>
          {(["mobile", "session"] as const).map((m) => (
            <label
              key={m}
              className={cn(
                "flex cursor-pointer items-start gap-3 rounded-2xl p-3 text-sm focus-within:outline-2 focus-within:outline-primary",
                method === m ? "bg-soft text-on-soft" : "bg-bg hover:bg-tile2",
              )}
            >
              <input type="radio" name="method" value={m} checked={method === m} onChange={() => setMethod(m)} className="mt-1" />
              <HugeiconsIcon icon={m === "mobile" ? SmartPhone01Icon : CreditCardIcon} size={20} strokeWidth={1.8} aria-hidden="true" className="mt-0.5 text-muted" />
              <span>
                <span className="block font-medium text-ink">{t(`review.methods.${m}`)}</span>
                <span className="block text-muted">{t(`review.methods.${m}Hint`)}</span>
              </span>
            </label>
          ))}
        </fieldset>
        {method === "mobile" && (
          <Field label={t("review.phone")} error={phoneError} hint={t("review.phoneHint")}>
            <Input
              type="tel"
              inputMode="tel"
              autoComplete="tel"
              value={phone}
              onChange={(e) => {
                setPhone(e.target.value);
                setPhoneError(undefined);
              }}
            />
          </Field>
        )}
        {notice && <Alert tone={notice.tone}>{notice.text}</Alert>}
        <p className="flex items-center gap-1.5 text-xs text-muted">
          <HugeiconsIcon icon={SecurityCheckIcon} size={14} strokeWidth={1.8} aria-hidden="true" />
          {t("review.secure")}
        </p>
        <div className="flex flex-wrap gap-2">
          <Button onClick={pay} disabled={busy || !fresh || !quote.payable}>
            {busy ? t("review.paying") : t("review.pay", { amount: formatMoney(quote.total) })}
          </Button>
          <Button
            variant="secondary"
            disabled={busy}
            onClick={() => {
              setNotice(undefined);
              setStep("form");
            }}
          >
            {t("back")}
          </Button>
        </div>
      </Card>
    );
  }

  return (
    <Card className="space-y-5" data-testid="checkout-form">
      <div>
        <h2 className="font-display text-xl font-bold">{heading}</h2>
        <p className="text-sm text-muted">{t("intro")}</p>
      </div>
      {options.length > 1 && (
        <label className="block space-y-1 text-sm">
          <span className="font-medium text-ink">{t("plan")}</span>
          <select className={selectClass} value={planKey} onChange={(e) => setPlanKey(e.target.value)}>
            {options.map((p) => (
              <option key={p.key} value={p.key}>
                {t(p.key === summary.planKey ? "planCurrent" : "planOption", { name: p.name, price: formatMoney(p.pricePerGuest) })}
              </option>
            ))}
          </select>
        </label>
      )}
      <div className="space-y-1 text-sm">
        <label htmlFor="billing-cards" className="block font-medium text-ink">
          {t("cards")}
        </label>
        <div className="flex items-center gap-2">
          <Button
            variant="secondary"
            className="px-3"
            aria-label={t("decrease", { size: blockSize })}
            disabled={cards - blockSize < minCards}
            onClick={() => changeCards(cards - blockSize)}
          >
            <HugeiconsIcon icon={MinusSignIcon} size={16} strokeWidth={2} aria-hidden="true" />
          </Button>
          <Input
            id="billing-cards"
            type="number"
            min={minCards}
            step={summary.paid ? blockSize : 1}
            readOnly={summary.paid}
            className="w-28 text-center tabular-nums"
            value={Number.isFinite(cards) ? cards : ""}
            onChange={(e) => {
              setNotice(undefined);
              setCards(Number.parseInt(e.target.value, 10));
            }}
          />
          <Button variant="secondary" className="px-3" aria-label={t("increase", { size: blockSize })} onClick={() => changeCards(cards + blockSize)}>
            <HugeiconsIcon icon={PlusSignIcon} size={16} strokeWidth={2} aria-hidden="true" />
          </Button>
        </div>
        <p className="text-muted">
          {summary.paid ? t("blockHint", { size: blockSize, paid: summary.guestLimit }) : t("suggestHint", { count: summary.guestCount })}
        </p>
      </div>

      <div className="rounded-lg p-4" aria-live="polite">
        {quoteState === "error" && <Alert tone="error">{t("errors.quote")}</Alert>}
        {quoteState === "invalid" && <Alert tone="error">{t("errors.quoteInvalid", { min: minCards })}</Alert>}
        {quoteState === "loading" && !quote && <p className="text-sm text-muted">{t("calculating")}</p>}
        {quote && quoteState !== "error" && quoteState !== "invalid" && (
          <div className={cn("space-y-3", !fresh && "opacity-60")}>
            <QuoteBreakdown quote={quote} />
            <p className="text-xs text-muted" data-testid="minimum-note">
              {t("minimumNote", { amount: formatMoney(quote.minimumCharge) })}
            </p>
            {!quote.payable && <Alert>{t("nothingToPay")}</Alert>}
          </div>
        )}
      </div>

      {notice && <Alert tone={notice.tone}>{notice.text}</Alert>}
      <div className="flex flex-wrap gap-2">
        <Button disabled={!fresh || !quote?.payable} onClick={() => setStep("review")}>
          {t("continue")}
        </Button>
        <Button variant="secondary" onClick={onClose}>
          {t("cancel")}
        </Button>
      </div>
    </Card>
  );
}

"use client";

import { useTranslations } from "next-intl";
import { useEffect, useState, type FormEvent } from "react";
import { Alert, Button, Dialog, Field, Input } from "../../components/ui";
import { localPhone } from "../events/format";
import { parseAmount, todayInTanzania, validatePayment, type FieldError, type PaymentValues } from "./contribution-form-logic";
import { PAYMENT_METHODS, tsh, type Payment, type Pledge } from "./types";
import { apiFetch } from "../../lib/api-fetch";

const selectClass = "block w-full rounded-lg border-0 bg-white px-3 py-2 text-sm ring-1 ring-gray-300 focus:ring-2 focus:ring-brand-600";

/** Contributor detail: pledge, balance, payment history; record payment/refund and edit pledge (host, treasurer). */
export function ContributorDialog({
  eventId,
  pledge: initial,
  canRecord,
  onChange,
  onClose,
}: {
  eventId: string;
  pledge: Pledge;
  canRecord: boolean;
  onChange: (p: Pledge) => void;
  onClose: () => void;
}) {
  const t = useTranslations("contributions");
  const [pledge, setPledge] = useState(initial);
  const [payments, setPayments] = useState<Payment[] | null>(null);
  const [values, setValues] = useState<PaymentValues>({ kind: "payment", amount: "", method: "mpesa", reference: "", paidOn: todayInTanzania() });
  const [errors, setErrors] = useState<Partial<Record<keyof PaymentValues, FieldError>>>({});
  const [editing, setEditing] = useState(false);
  const [edit, setEdit] = useState({ amount: String(initial.amountPledged), cardType: initial.cardType });
  const [notice, setNotice] = useState<string>();
  const [error, setError] = useState<string>();
  const [busy, setBusy] = useState(false);
  const base = `/api/v1/events/${eventId}`;

  useEffect(() => {
    let live = true;
    apiFetch(`${base}/pledges/${initial.id}`)
      .then((r) => (r.ok ? r.json() : null))
      .then((body: { payments: Payment[] } | null) => live && setPayments(body?.payments ?? []))
      .catch(() => live && setPayments([]));
    return () => {
      live = false;
    };
  }, [base, initial.id]);

  function apply(next: Pledge, message?: string) {
    const justIssued = pledge.invitationStatus !== "issued" && next.invitationStatus === "issued";
    setPledge(next);
    onChange(next);
    setNotice(justIssued ? t("cardIssued", { number: next.cardNumber ?? "" }) : message);
  }

  async function record(e: FormEvent) {
    e.preventDefault();
    const found = validatePayment(values, pledge.amountPaid);
    setErrors(found);
    setError(undefined);
    if (Object.keys(found).length) return;
    setBusy(true);
    const res = await apiFetch(`${base}/pledges/${pledge.id}/payments`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ kind: values.kind, amount: parseAmount(values.amount), method: values.method, reference: values.reference.trim() || null, paidOn: values.paidOn }),
    }).catch(() => null);
    setBusy(false);
    if (!res?.ok) return setError(t("errors.generic"));
    const body = (await res.json()) as { pledge: Pledge; payment: Payment };
    setPayments((all) => [...(all ?? []), body.payment]);
    setValues((v) => ({ ...v, amount: "", reference: "" }));
    apply(body.pledge, t("recorded"));
  }

  async function savePledge(e: FormEvent) {
    e.preventDefault();
    const amount = parseAmount(edit.amount);
    if (amount === null) return setError(t("errors.amount"));
    setBusy(true);
    const res = await apiFetch(`${base}/pledges/${pledge.id}`, {
      method: "PATCH",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ amount, cardType: edit.cardType }),
    }).catch(() => null);
    setBusy(false);
    if (!res?.ok) return setError(res?.status === 409 ? t("errors.alreadyIssued") : t("errors.generic"));
    setEditing(false);
    apply((await res.json()) as Pledge, t("pledgeSaved"));
  }

  const err = (k: keyof PaymentValues) => (errors[k] ? t(`errors.${errors[k]}`) : undefined);
  const canEditPledge = canRecord && pledge.invitationStatus === "pending";

  return (
    <Dialog title={pledge.name} onClose={onClose}>
      <div className="max-h-[75vh] space-y-4 overflow-y-auto pr-1">
        <p className="text-sm text-gray-600">
          {localPhone(pledge.phone)} · {t(`cardTypes.${pledge.cardType}`)}
          {pledge.cardNumber && ` · ${t("cardNumber")} ${pledge.cardNumber}`}
        </p>
        <dl className="grid grid-cols-2 gap-3 text-sm sm:grid-cols-4">
          {(["amountPledged", "amountPaid", "balance", "amountExtra"] as const).map((k) => (
            <div key={k} className="rounded-lg bg-gray-50 p-2">
              <dt className="text-xs text-gray-500">{t(`fields.${k}`)}</dt>
              <dd className="font-semibold" data-testid={`detail-${k}`}>
                {tsh(pledge[k])}
              </dd>
            </div>
          ))}
        </dl>
        {notice && <Alert tone="success">{notice}</Alert>}
        {error && <Alert tone="error">{error}</Alert>}

        {canEditPledge &&
          (editing ? (
            <form onSubmit={savePledge} className="grid gap-3 rounded-lg p-3 ring-1 ring-gray-200 sm:grid-cols-3">
              <Field label={t("fields.amountPledged")}>
                <Input inputMode="numeric" value={edit.amount} onChange={(e) => setEdit({ ...edit, amount: e.target.value })} />
              </Field>
              <Field label={t("fields.cardType")}>
                <select className={selectClass} value={edit.cardType} onChange={(e) => setEdit({ ...edit, cardType: e.target.value as "single" | "double" })}>
                  <option value="single">{t("cardTypes.single")}</option>
                  <option value="double">{t("cardTypes.double")}</option>
                </select>
              </Field>
              <div className="flex items-end gap-2">
                <Button type="submit" disabled={busy}>
                  {t("savePledge")}
                </Button>
                <Button variant="ghost" onClick={() => setEditing(false)}>
                  {t("cancel")}
                </Button>
              </div>
            </form>
          ) : (
            <Button variant="secondary" onClick={() => setEditing(true)}>
              {t("editPledge")}
            </Button>
          ))}

        <section>
          <h3 className="mb-2 text-sm font-semibold">{t("history")}</h3>
          {payments === null ? (
            <p className="text-sm text-gray-500">…</p>
          ) : payments.length === 0 ? (
            <p className="text-sm text-gray-500">{t("noPayments")}</p>
          ) : (
            <ul className="divide-y divide-gray-100 text-sm">
              {payments.map((p) => (
                <li key={p.id} className="flex justify-between py-1.5">
                  <span>
                    {p.paidOn} · {t(`methods.${p.method}`)}
                    {p.reference && ` · ${p.reference}`}
                  </span>
                  <span className={p.kind === "refund" ? "text-red-700" : ""}>{p.kind === "refund" ? `− ${tsh(-p.amount)}` : tsh(p.amount)}</span>
                </li>
              ))}
            </ul>
          )}
        </section>

        {canRecord && (
          <form onSubmit={record} noValidate className="grid gap-3 rounded-lg p-3 ring-1 ring-gray-200 sm:grid-cols-2">
            <h3 className="text-sm font-semibold sm:col-span-2">{t("recordHeading")}</h3>
            <Field label={t("fields.kind")}>
              <select className={selectClass} value={values.kind} onChange={(e) => setValues({ ...values, kind: e.target.value as "payment" | "refund" })}>
                <option value="payment">{t("kinds.payment")}</option>
                <option value="refund">{t("kinds.refund")}</option>
              </select>
            </Field>
            <Field label={t("fields.amount")} error={err("amount")}>
              <Input inputMode="numeric" value={values.amount} onChange={(e) => setValues({ ...values, amount: e.target.value })} />
            </Field>
            <Field label={t("fields.method")}>
              <select className={selectClass} value={values.method} onChange={(e) => setValues({ ...values, method: e.target.value as PaymentValues["method"] })}>
                {PAYMENT_METHODS.map((m) => (
                  <option key={m} value={m}>
                    {t(`methods.${m}`)}
                  </option>
                ))}
              </select>
            </Field>
            <Field label={t("fields.reference")}>
              <Input value={values.reference} maxLength={100} onChange={(e) => setValues({ ...values, reference: e.target.value })} />
            </Field>
            <Field label={t("fields.paidOn")} error={err("paidOn")}>
              <Input type="date" value={values.paidOn} onChange={(e) => setValues({ ...values, paidOn: e.target.value })} />
            </Field>
            <div className="flex items-end">
              <Button type="submit" disabled={busy}>
                {values.kind === "refund" ? t("recordRefund") : t("recordPayment")}
              </Button>
            </div>
          </form>
        )}
      </div>
    </Dialog>
  );
}

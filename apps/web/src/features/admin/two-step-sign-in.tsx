"use client";

import { Copy01Icon, Download01Icon, SecurityCheckIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useTranslations } from "next-intl";
import QRCode from "qrcode";
import { useEffect, useState, type FormEvent } from "react";
import { Alert, Button, Field, Input } from "../../components/ui";
import { admin2fa, type ApiResult } from "./platform-api";
import type { TotpEnrolment, TotpStatus } from "./platform-types";

type Step = "intro" | "enrol" | "codes" | "verify";

/** Maps a failed 2FA call to a message key under adminPlatform.twoStep.errors. */
export function twoStepErrorKey(result: ApiResult<unknown>): "invalid" | "locked" | "generic" {
  if (result.ok) return "generic";
  if (result.code === "second_factor_invalid" || result.status === 422) return "invalid";
  if (result.code === "second_factor_locked" || result.status === 429) return "locked";
  return "generic";
}

/** AUTH-7: the admin area asks for an authenticator code (set it up on first use). */
export function TwoStepSignIn({ status, onVerified }: { status: Pick<TotpStatus, "enrolled">; onVerified: () => void }) {
  const t = useTranslations("adminPlatform.twoStep");
  const [step, setStep] = useState<Step>(status.enrolled ? "verify" : "intro");
  const [enrolment, setEnrolment] = useState<TotpEnrolment>();
  const [recoveryCodes, setRecoveryCodes] = useState<string[]>([]);
  const [code, setCode] = useState("");
  const [error, setError] = useState<string>();
  const [busy, setBusy] = useState(false);

  async function start() {
    setBusy(true);
    setError(undefined);
    const r = await admin2fa.enrol();
    setBusy(false);
    if (r.ok) {
      setEnrolment(r.data);
      setStep("enrol");
    } else if (r.status === 409) {
      setStep("verify");
    } else {
      setError(t("errors.generic"));
    }
  }

  async function submit(e: FormEvent) {
    e.preventDefault();
    const value = code.trim();
    if (value.length < 6) return setError(t("errors.short"));
    setBusy(true);
    setError(undefined);
    if (step === "enrol") {
      const r = await admin2fa.confirm(value);
      setBusy(false);
      if (!r.ok) return setError(t(`errors.${twoStepErrorKey(r)}`));
      setRecoveryCodes(r.data.recoveryCodes);
      setCode("");
      setStep("codes");
    } else {
      const r = await admin2fa.verify(value);
      setBusy(false);
      if (!r.ok) return setError(t(`errors.${twoStepErrorKey(r)}`));
      onVerified();
    }
  }

  return (
    <section aria-labelledby="two-step-title" className="mx-auto max-w-xl space-y-5 rounded-tile bg-tile p-6">
      <div className="flex items-start gap-3">
        <span className="rounded-full bg-soft p-3 text-primary">
          <HugeiconsIcon icon={SecurityCheckIcon} size={22} aria-hidden="true" />
        </span>
        <div>
          <h1 id="two-step-title" className="font-display text-2xl font-bold">
            {t("title")}
          </h1>
          <p className="mt-1 text-sm text-muted">{t(`intro.${step}`)}</p>
        </div>
      </div>

      {step === "intro" && (
        <Button onClick={start} disabled={busy}>
          {t("setUp")}
        </Button>
      )}

      {step === "enrol" && enrolment && <EnrolmentKey enrolment={enrolment} />}

      {(step === "enrol" || step === "verify") && (
        <form onSubmit={submit} noValidate className="space-y-4">
          <Field label={step === "enrol" ? t("codeLabel") : t("codeOrRecoveryLabel")} hint={step === "verify" ? t("recoveryHint") : undefined}>
            <Input
              value={code}
              onChange={(e) => setCode(e.target.value)}
              autoComplete="one-time-code"
              inputMode={step === "enrol" ? "numeric" : "text"}
              maxLength={20}
              className="max-w-xs font-mono tracking-widest"
            />
          </Field>
          <Button type="submit" disabled={busy}>
            {step === "enrol" ? t("confirm") : t("verify")}
          </Button>
        </form>
      )}

      {step === "codes" && <RecoveryCodes codes={recoveryCodes} onDone={onVerified} />}

      {error && <Alert tone="error">{error}</Alert>}
    </section>
  );
}

function EnrolmentKey({ enrolment }: { enrolment: TotpEnrolment }) {
  const t = useTranslations("adminPlatform.twoStep");
  const [svg, setSvg] = useState<string>();
  useEffect(() => {
    let cancelled = false;
    QRCode.toString(enrolment.otpauthUri, { type: "svg", margin: 1, errorCorrectionLevel: "M" })
      .then((value) => !cancelled && setSvg(value))
      .catch(() => undefined);
    return () => {
      cancelled = true;
    };
  }, [enrolment.otpauthUri]);

  return (
    <div className="space-y-3">
      <ol className="list-decimal space-y-1 pl-5 text-sm text-ink">
        <li>{t("stepApp")}</li>
        <li>{t("stepScan")}</li>
        <li>{t("stepCode")}</li>
      </ol>
      <div className="flex flex-wrap items-start gap-4">
        {svg ? (
          // A locally generated SVG data URI; next/image adds nothing here.
          <img src={`data:image/svg+xml;utf8,${encodeURIComponent(svg)}`} alt={t("qrAlt")} width={176} height={176} className="rounded-lg" />
        ) : (
          <div className="h-44 w-44 animate-pulse rounded-lg bg-tile2" aria-hidden="true" />
        )}
        <div className="min-w-0 flex-1 space-y-2 text-sm">
          <p className="text-muted">{t("manualKey")}</p>
          <code data-testid="totp-secret" className="block break-all rounded-lg bg-tile2 p-2 font-mono text-xs">
            {enrolment.secret}
          </code>
          <a href={enrolment.otpauthUri} className="text-primary underline">
            {t("openInApp")}
          </a>
        </div>
      </div>
    </div>
  );
}

function RecoveryCodes({ codes, onDone }: { codes: string[]; onDone: () => void }) {
  const t = useTranslations("adminPlatform.twoStep");
  const [copied, setCopied] = useState(false);
  const text = codes.join("\n");

  async function copy() {
    try {
      await navigator.clipboard.writeText(text);
      setCopied(true);
    } catch {
      setCopied(false);
    }
  }

  function download() {
    const url = URL.createObjectURL(new Blob([`${t("fileHeading")}\n\n${text}\n`], { type: "text/plain" }));
    const a = document.createElement("a");
    a.href = url;
    a.download = "dcard-admin-recovery-codes.txt";
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(() => URL.revokeObjectURL(url), 1000);
  }

  return (
    <div className="space-y-4">
      <Alert tone="info">{t("codesWarning")}</Alert>
      <ul aria-label={t("codesLabel")} className="grid grid-cols-2 gap-2 rounded-lg bg-tile2 p-4 font-mono text-sm">
        {codes.map((c) => (
          <li key={c}>{c}</li>
        ))}
      </ul>
      <div className="flex flex-wrap gap-2">
        <Button variant="secondary" onClick={copy}>
          <HugeiconsIcon icon={Copy01Icon} size={16} aria-hidden="true" />
          {copied ? t("copied") : t("copy")}
        </Button>
        <Button variant="secondary" onClick={download}>
          <HugeiconsIcon icon={Download01Icon} size={16} aria-hidden="true" />
          {t("download")}
        </Button>
      </div>
      <Button onClick={onDone}>{t("saved")}</Button>
    </div>
  );
}

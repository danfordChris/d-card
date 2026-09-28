"use client";

import { Shield01Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useTranslations } from "next-intl";
import { useRouter } from "next/navigation";
import { useCallback, useEffect, useState, type FormEvent } from "react";
import { Alert, Button, Field, Input } from "../../components/ui";
import { useAdminCall } from "./admin-gate-context";
import { ListBody } from "./admin-ui";
import { jsonInit } from "./platform-api";
import type { TotpStatus } from "./platform-types";
import { twoStepErrorKey } from "./two-step-sign-in";

/** AUTH-7: this admin's two-step sign-in: recovery codes left, and turning it off (needs a code). */
export function SecurityAdmin({ onDisabled }: { onDisabled?: () => void }) {
  const t = useTranslations("adminPlatform.security");
  const tErr = useTranslations("adminPlatform.twoStep.errors");
  const router = useRouter();
  const call = useAdminCall();
  const [status, setStatus] = useState<TotpStatus>();
  const [loadError, setLoadError] = useState(false);
  const [code, setCode] = useState("");
  const [error, setError] = useState<string>();
  const [busy, setBusy] = useState(false);

  const load = useCallback(async () => {
    setLoadError(false);
    const r = await call<TotpStatus>("/api/v1/admin/2fa");
    if (!r.ok) return setLoadError(true);
    setStatus(r.data);
  }, [call]);

  useEffect(() => {
    void load();
  }, [load]);

  async function disable(e: FormEvent) {
    e.preventDefault();
    if (code.trim().length < 6) return setError(tErr("short"));
    setBusy(true);
    setError(undefined);
    const r = await call<null>("/api/v1/admin/2fa/disable", jsonInit("POST", { code: code.trim() }));
    setBusy(false);
    if (!r.ok) return setError(tErr(twoStepErrorKey(r)));
    setCode("");
    if (onDisabled) onDisabled();
    else router.refresh();
  }

  if (!status)
    return (
      <div className="rounded-2xl bg-white ring-1 ring-gray-200">
        <ListBody state={loadError ? "error" : "loading"} columns={2} empty={{ title: "" }} onRetry={load}>
          {null}
        </ListBody>
      </div>
    );

  return (
    <div className="max-w-xl space-y-4 rounded-2xl bg-white p-6 ring-1 ring-gray-200">
      <div className="flex items-start gap-3">
        <span className="rounded-full bg-brand-50 p-3 text-brand-700">
          <HugeiconsIcon icon={Shield01Icon} size={22} aria-hidden="true" />
        </span>
        <div>
          <h2 className="font-semibold">{t("statusTitle")}</h2>
          <p className="mt-1 text-sm text-gray-600">{status.enrolled ? t("on") : t("off")}</p>
          {status.enrolled && (
            <p className="mt-1 text-sm text-gray-600" data-testid="recovery-left">
              {t("recoveryLeft", { count: status.recoveryCodesLeft })}
            </p>
          )}
        </div>
      </div>
      {status.enrolled && (
        <form onSubmit={disable} noValidate className="space-y-3 border-t border-gray-200 pt-4">
          <h3 className="text-sm font-semibold">{t("disableTitle")}</h3>
          <p className="text-sm text-gray-600">{t("disableBody")}</p>
          <Field label={t("codeLabel")}>
            <Input value={code} onChange={(e) => setCode(e.target.value)} autoComplete="one-time-code" maxLength={20} className="max-w-xs font-mono tracking-widest" />
          </Field>
          {error && <Alert tone="error">{error}</Alert>}
          <Button type="submit" variant="danger" disabled={busy}>
            {t("disable")}
          </Button>
        </form>
      )}
    </div>
  );
}

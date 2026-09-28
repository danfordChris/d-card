"use client";

import { useTranslations } from "next-intl";
import { useState } from "react";
import { Alert, Button, Card } from "../../components/ui";
import { apiFetch } from "../../lib/api-fetch";
import {
  MANUAL_GROUPS,
  MANUAL_MESSAGE_TYPES,
  type ManualGroup,
  type ManualMessageType,
  type ManualSendBody,
  type ManualSendPreview,
  type ManualSendResult,
} from "./log-types";

const selectClass = "block w-full rounded-lg border-0 bg-white px-3 py-2 text-sm ring-1 ring-gray-300 focus:ring-2 focus:ring-brand-600 disabled:bg-gray-50 disabled:text-gray-500";

type Notice = { tone: "success" | "error"; text: string };

// MSG-13: the host sends a chosen message now to a group, within the plan's manual-send limit.
export function ManualSend({ eventId, planName, sendsAllowed: initialAllowed, onSent }: { eventId: string; planName: string; sendsAllowed: number; onSent?: () => void }) {
  const t = useTranslations("messageLog.send");
  const tTypes = useTranslations("messageSettings.types");
  const [messageType, setMessageType] = useState<ManualMessageType>(MANUAL_MESSAGE_TYPES[0]);
  const [group, setGroup] = useState<ManualGroup>("all");
  const [preview, setPreview] = useState<ManualSendPreview>();
  const [usage, setUsage] = useState<{ used: number | null; allowed: number }>({ used: null, allowed: initialAllowed });
  const [notice, setNotice] = useState<Notice>();
  const [busy, setBusy] = useState<"check" | "send">();
  const locked = usage.allowed === 0;
  const exhausted = usage.used !== null && usage.used >= usage.allowed;

  async function call(body: ManualSendBody): Promise<{ res: Response | null; data: unknown }> {
    const res = await apiFetch(`/api/v1/events/${eventId}/messages/send`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(body),
    }).catch(() => null);
    const data: unknown = await res?.json().catch(() => null);
    return { res, data };
  }

  function errorText(res: Response | null, data: unknown): string {
    const code = (data as { error?: { code?: string } } | null)?.error?.code;
    if (code === "plan_limit") return t("errors.plan_limit");
    if (code === "validation_error") return t("errors.validation");
    if (res?.status === 403) return t("errors.forbidden");
    return t("errors.generic");
  }

  async function check() {
    setBusy("check");
    setNotice(undefined);
    setPreview(undefined);
    const { res, data } = await call({ messageType, group, preview: true });
    setBusy(undefined);
    if (res?.ok) {
      const p = data as ManualSendPreview;
      setPreview(p);
      setUsage({ used: p.sendsUsed, allowed: p.sendsAllowed });
      return;
    }
    setNotice({ tone: "error", text: errorText(res, data) });
  }

  async function send() {
    setBusy("send");
    setNotice(undefined);
    const { res, data } = await call({ messageType, group });
    setBusy(undefined);
    if (res?.ok) {
      const r = data as ManualSendResult;
      setUsage({ used: r.sendsUsed, allowed: r.sendsAllowed });
      setPreview(undefined);
      setNotice({ tone: "success", text: t("queued", { count: r.queued }) });
      onSent?.();
      return;
    }
    setNotice({ tone: "error", text: errorText(res, data) });
  }

  const reset = () => {
    setPreview(undefined);
    setNotice(undefined);
  };

  return (
    <Card className="space-y-4" data-testid="manual-send">
      <div>
        <h2 className="font-semibold">{t("title")}</h2>
        <p className="text-sm text-gray-600">{t("intro")}</p>
      </div>
      {locked && <Alert>{t("locked", { plan: planName })}</Alert>}
      <div className="grid gap-4 sm:grid-cols-2">
        <label className="block space-y-1 text-sm">
          <span className="font-medium">{t("messageType")}</span>
          <select
            className={selectClass}
            value={messageType}
            disabled={locked || busy !== undefined}
            onChange={(e) => {
              setMessageType(e.target.value as ManualMessageType);
              reset();
            }}
          >
            {MANUAL_MESSAGE_TYPES.map((type) => (
              <option key={type} value={type}>
                {tTypes(`${type}.name`)}
              </option>
            ))}
          </select>
        </label>
        <label className="block space-y-1 text-sm">
          <span className="font-medium">{t("group")}</span>
          <select
            className={selectClass}
            value={group}
            disabled={locked || busy !== undefined}
            onChange={(e) => {
              setGroup(e.target.value as ManualGroup);
              reset();
            }}
          >
            {MANUAL_GROUPS.map((g) => (
              <option key={g} value={g}>
                {t(`groups.${g}`)}
              </option>
            ))}
          </select>
        </label>
      </div>

      {usage.used !== null && !locked && (
        <p className="text-sm text-gray-600" data-testid="manual-send-usage">
          {t("usage", { used: usage.used, allowed: usage.allowed })}
        </p>
      )}

      {preview && (
        <div className="rounded-lg bg-gray-50 p-3 text-sm ring-1 ring-gray-200" data-testid="manual-send-preview">
          {t("recipients", { count: preview.recipients })}
        </div>
      )}

      {notice && <Alert tone={notice.tone}>{notice.text}</Alert>}

      <div className="flex flex-wrap gap-2">
        {preview ? (
          <>
            <Button onClick={send} disabled={busy !== undefined || preview.recipients === 0 || exhausted}>
              {busy === "send" ? t("sending") : t("confirm")}
            </Button>
            <Button variant="secondary" onClick={reset} disabled={busy !== undefined}>
              {t("cancel")}
            </Button>
          </>
        ) : (
          <Button variant="secondary" onClick={check} disabled={locked || busy !== undefined}>
            {busy === "check" ? t("checking") : t("check")}
          </Button>
        )}
      </div>
    </Card>
  );
}

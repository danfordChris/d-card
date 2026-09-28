"use client";

import { DEFAULT_SMS, type MessageType } from "@dcard/core/sms";
import { useTranslations } from "next-intl";
import { useState } from "react";
import { Alert, Button, Card, cn } from "../../components/ui";
import { apiFetch } from "../../lib/api-fetch";
import { SmsEditor } from "./sms-editor";
import type { ChannelChoice, Limits, MessageSetting, Schedule, SettingsView } from "./types";

const SCHEDULED: Partial<Record<MessageType, "before" | "after" | "reminder">> = {
  attendance_confirmation: "before",
  event_reminder: "before",
  post_event_thanks: "after",
  contribution_reminder: "reminder",
};
const WITH_NOTE: MessageType[] = ["invitation_card", "post_event_thanks"];

function Lock({ label }: { label: string }) {
  return (
    <span title={label} aria-label={label} className="ml-1 text-xs text-gray-400">
      🔒
    </span>
  );
}

const inputClass = "block w-full rounded-lg border-0 bg-white px-3 py-2 text-sm ring-1 ring-gray-300 focus:ring-2 focus:ring-brand-600 disabled:bg-gray-50 disabled:text-gray-500";

export function MessageSettings({ eventId, planName, initial, canEdit }: { eventId: string; planName: string; initial: SettingsView; canEdit: boolean }) {
  const t = useTranslations("messageSettings");
  const [settings, setSettings] = useState(initial.settings);
  const [lang, setLang] = useState<"sw" | "en">("sw");
  const [notice, setNotice] = useState<{ tone: "success" | "error"; text: string }>();
  const [invalid, setInvalid] = useState<Set<string>>(new Set());
  const [busy, setBusy] = useState(false);
  const limits: Limits = initial.limits;
  const anyLocked = !limits.channelPerMessage || !limits.smsWordingEdit || !limits.customTiming || !limits.whatsappTemplateStyles;

  const update = (type: MessageType, patch: Partial<MessageSetting>) =>
    setSettings((all) => all.map((s) => (s.messageType === type ? { ...s, ...patch } : s)));

  async function save() {
    setBusy(true);
    setNotice(undefined);
    const res = await apiFetch(`/api/v1/events/${eventId}/messages`, {
      method: "PUT",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ settings }),
    }).catch(() => null);
    setBusy(false);
    if (res?.ok) {
      setSettings(((await res.json()) as SettingsView).settings);
      setInvalid(new Set());
      return setNotice({ tone: "success", text: t("saved") });
    }
    const body = (await res?.json().catch(() => null)) as { error?: { code?: string; issues?: { path: string }[] } } | null;
    const code = body?.error?.code;
    setInvalid(new Set((body?.error?.issues ?? []).map((i) => i.path)));
    setNotice({ tone: "error", text: code === "plan_limit" ? t("errors.plan_limit") : code === "validation_error" ? t("errors.validation") : t("errors.generic") });
  }

  async function test(type: MessageType) {
    const res = await apiFetch(`/api/v1/events/${eventId}/messages/${type}/test`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: "{}",
    }).catch(() => null);
    setNotice(res?.ok ? { tone: "success", text: t("testSent") } : { tone: "error", text: t("errors.generic") });
  }

  return (
    <div className="space-y-6">
      <p className="max-w-3xl text-sm text-gray-600">{t("intro")}</p>
      {anyLocked && <Alert>{t("planNote", { plan: planName })}</Alert>}
      <div className="flex gap-2" role="tablist" aria-label={t("sms")}>
        {(["sw", "en"] as const).map((l) => (
          <button
            key={l}
            role="tab"
            aria-selected={lang === l}
            onClick={() => setLang(l)}
            className={cn("rounded-full px-3 py-1 text-sm ring-1", lang === l ? "bg-brand-600 text-white ring-brand-600" : "bg-white ring-gray-300")}
          >
            {t(`languages.${l}`)}
          </button>
        ))}
      </div>

      {settings.map((s) => {
        const type = s.messageType;
        const isCard = type === "invitation_card";
        const marketingLocked = type === "post_event_thanks" && !limits.marketingMessages;
        const smsField = lang === "sw" ? "smsTextSw" : "smsTextEn";
        const text = s[smsField] ?? DEFAULT_SMS[type][lang];
        const variants = initial.templates.filter((tpl) => tpl.messageType === type && tpl.language === lang).map((tpl) => tpl.variantName);
        const sched = SCHEDULED[type];
        const schedule: Schedule = s.schedule ?? {};
        const setSchedule = (patch: Schedule) => update(type, { schedule: { ...schedule, ...patch } });
        return (
          <Card key={type} className={cn("space-y-4", !s.enabled && !isCard && "opacity-75")} data-testid={`message-${type}`}>
            <div className="flex flex-wrap items-start justify-between gap-3">
              <div>
                <h2 className="font-semibold">{t(`types.${type}.name`)}</h2>
                <p className="text-sm text-gray-500">{t(`types.${type}.when`)}</p>
              </div>
              {isCard ? (
                <span className="text-sm text-gray-600">{t("alwaysOn")}</span>
              ) : (
                <label className="flex items-center gap-2 text-sm">
                  <input
                    type="checkbox"
                    checked={s.enabled}
                    disabled={!canEdit || (marketingLocked && !s.enabled)}
                    onChange={(e) => update(type, { enabled: e.target.checked })}
                  />
                  {t("enabled")}
                  {marketingLocked && <Lock label={t("locked")} />}
                </label>
              )}
            </div>

            <div className="grid gap-4 md:grid-cols-3">
              <label className="block space-y-1 text-sm">
                <span className="font-medium">
                  {t("channel")}
                  {!limits.channelPerMessage && <Lock label={t("locked")} />}
                </span>
                <select
                  className={inputClass}
                  value={s.channels}
                  disabled={!canEdit || !limits.channelPerMessage}
                  onChange={(e) => update(type, { channels: e.target.value as ChannelChoice })}
                >
                  {(["both", "sms", "whatsapp"] as const).map((c) => (
                    <option key={c} value={c}>
                      {t(`channels.${c}`)}
                    </option>
                  ))}
                </select>
                {s.channels === "whatsapp" && <span className="block text-xs text-amber-700">{t("whatsappOnlyWarning")}</span>}
              </label>
              <label className="block space-y-1 text-sm">
                <span className="font-medium">
                  {t("whatsapp")} · {t("variant")}
                  {!limits.whatsappTemplateStyles && <Lock label={t("locked")} />}
                </span>
                <select
                  className={inputClass}
                  value={s.whatsappTemplateVariant ?? "standard"}
                  disabled={!canEdit || !limits.whatsappTemplateStyles || variants.length < 2}
                  onChange={(e) => update(type, { whatsappTemplateVariant: e.target.value })}
                >
                  {(variants.length ? variants : ["standard"]).map((v) => (
                    <option key={v} value={v}>
                      {v}
                    </option>
                  ))}
                </select>
              </label>
              {WITH_NOTE.includes(type) && (
                <label className="block space-y-1 text-sm">
                  <span className="font-medium">{t("note")}</span>
                  <input
                    className={inputClass}
                    maxLength={200}
                    value={s.whatsappNote ?? ""}
                    disabled={!canEdit}
                    onChange={(e) => update(type, { whatsappNote: e.target.value || null })}
                  />
                </label>
              )}
            </div>

            <div className="space-y-1">
              <div className="flex items-center justify-between">
                <label htmlFor={`${type}-${lang}`} className="text-sm font-medium">
                  {t("sms")} ({t(`languages.${lang}`)})
                  {!limits.smsWordingEdit && <Lock label={t("locked")} />}
                </label>
                {canEdit && limits.smsWordingEdit && text !== DEFAULT_SMS[type][lang] && (
                  <button type="button" className="text-xs text-brand-600 hover:underline" onClick={() => update(type, { [smsField]: DEFAULT_SMS[type][lang] })}>
                    {t("reset")}
                  </button>
                )}
              </div>
              <SmsEditor
                id={`${type}-${lang}`}
                value={text}
                locked={!canEdit || !limits.smsWordingEdit}
                invalid={invalid.has(smsField)}
                onChange={(v) => update(type, { [smsField]: v })}
              />
            </div>

            {sched && (
              <fieldset className="grid gap-4 sm:grid-cols-2 md:grid-cols-4">
                <legend className="mb-1 text-sm font-medium">
                  {t("timing")}
                  {!limits.customTiming && <Lock label={t("locked")} />}
                </legend>
                {sched === "reminder" ? (
                  <>
                    <NumberField label={t("frequencyDays")} value={schedule.frequencyDays} min={1} max={60} disabled={!canEdit || !limits.customTiming} onChange={(v) => setSchedule({ frequencyDays: v })} />
                    <NumberField
                      label={t("maxCount")}
                      value={schedule.maxCount ?? limits.maxContributionReminders}
                      min={1}
                      max={Math.max(1, limits.maxContributionReminders)}
                      disabled={!canEdit || !limits.customTiming}
                      onChange={(v) => setSchedule({ maxCount: v })}
                    />
                  </>
                ) : (
                  <NumberField
                    label={sched === "after" ? t("offsetDaysAfter") : t("offsetDays")}
                    value={schedule.offsetDays === undefined ? undefined : Math.abs(schedule.offsetDays)}
                    min={0}
                    max={30}
                    disabled={!canEdit || !limits.customTiming}
                    onChange={(v) => setSchedule({ offsetDays: sched === "after" ? -v : v })}
                  />
                )}
                <label className="block space-y-1 text-sm">
                  <span>{t("timeOfDay")}</span>
                  <input
                    type="time"
                    className={inputClass}
                    value={schedule.timeOfDay ?? "10:00"}
                    disabled={!canEdit || !limits.customTiming}
                    onChange={(e) => setSchedule({ timeOfDay: e.target.value })}
                  />
                </label>
              </fieldset>
            )}

            {canEdit && (
              <Button variant="secondary" onClick={() => test(type)}>
                {t("test")}
              </Button>
            )}
          </Card>
        );
      })}

      {notice && <Alert tone={notice.tone}>{notice.text}</Alert>}
      {canEdit && (
        <div className="sticky bottom-4 flex justify-end">
          <Button onClick={save} disabled={busy} className="shadow-lg">
            {busy ? t("saving") : t("save")}
          </Button>
        </div>
      )}
    </div>
  );
}

function NumberField({
  label,
  value,
  min,
  max,
  disabled,
  onChange,
}: {
  label: string;
  value: number | undefined;
  min: number;
  max: number;
  disabled: boolean;
  onChange: (v: number) => void;
}) {
  return (
    <label className="block space-y-1 text-sm">
      <span>{label}</span>
      <input
        type="number"
        className={inputClass}
        min={min}
        max={max}
        value={value ?? ""}
        disabled={disabled}
        onChange={(e) => onChange(Math.min(max, Math.max(min, Number(e.target.value) || min)))}
      />
    </label>
  );
}

"use client";

import { Alert02Icon, GoogleDriveIcon, Image01Icon, Link01Icon } from "@hugeicons/core-free-icons";
import { useLocale, useTranslations } from "next-intl";
import { useState, type FormEvent } from "react";
import { Alert, Button, Dialog, Field, Input, cn } from "../../components/ui";
import { connectUrl, disconnectDrive, saveSettings } from "./api";
import { Icon, Panel, PanelHeader, formatBytes, linkButton } from "./parts";
import type { MediaSettings, SharingMode } from "./types";

type Notice = { tone: "success" | "error"; text: string };

// MED-1 / MED-1a / MED-9 / MED-10 / MED-13 / MED-14.
export function DrivePanel({
  eventId,
  settings,
  canEdit,
  onSaved,
  onReload,
}: {
  eventId: string;
  settings: MediaSettings;
  canEdit: boolean;
  onSaved: (settings: MediaSettings) => void;
  onReload: () => Promise<void>;
}) {
  const t = useTranslations("media.drive");
  const locale = useLocale();
  const [mode, setMode] = useState<SharingMode>(settings.sharingMode);
  const [savedMode, setSavedMode] = useState<SharingMode>(settings.sharingMode);
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<Notice>();
  const [confirmDisconnect, setConfirmDisconnect] = useState(false);

  // Keep the local choice in step when the server copy changes (e.g. after a reload).
  if (settings.sharingMode !== savedMode) {
    setSavedMode(settings.sharingMode);
    setMode(settings.sharingMode);
  }

  async function saveMode() {
    setBusy(true);
    setNotice(undefined);
    const result = await saveSettings(eventId, { sharingMode: mode });
    setBusy(false);
    if (result.ok) {
      onSaved(result.data);
      setNotice({ tone: "success", text: t("modeSaved") });
    } else {
      setNotice({ tone: "error", text: result.code === "drive_not_connected" ? t("errors.notConnected") : t("errors.generic") });
    }
  }

  async function disconnect() {
    setConfirmDisconnect(false);
    setBusy(true);
    const result = await disconnectDrive();
    setBusy(false);
    if (!result.ok) return setNotice({ tone: "error", text: t("errors.generic") });
    setNotice({ tone: "success", text: t("disconnected") });
    await onReload();
  }

  const quota =
    settings.quotaUsedBytes !== null
      ? {
          used: formatBytes(settings.quotaUsedBytes, locale),
          limit: settings.quotaLimitBytes ? formatBytes(settings.quotaLimitBytes, locale) : null,
          pct: settings.quotaLimitBytes ? Math.min(100, Math.round((settings.quotaUsedBytes / settings.quotaLimitBytes) * 100)) : null,
          free: settings.quotaLimitBytes ? formatBytes(Math.max(0, settings.quotaLimitBytes - settings.quotaUsedBytes), locale) : null,
        }
      : null;

  return (
    <div className="space-y-6">
      {settings.mediaEnabled && (
        <Panel data-testid="media-drive">
          <PanelHeader icon={GoogleDriveIcon} title={t("title")} intro={t("intro")} />

          {settings.needsReconnect && (
            <div role="alert" className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-red-200 bg-red-50 p-4 text-sm text-red-800">
              <span className="flex items-start gap-2">
                <Icon icon={Alert02Icon} />
                {t("needsReconnect")}
              </span>
              {canEdit && (
                <a href={connectUrl(eventId)} className={linkButton.primary}>
                  {t("reconnect")}
                </a>
              )}
            </div>
          )}

          {settings.connected ? (
            <div className="space-y-4">
              <div className="flex flex-wrap items-center justify-between gap-3">
                <p className="text-sm text-gray-700">
                  {settings.googleEmail ? t("connectedAs", { email: settings.googleEmail }) : t("connected")}
                </p>
                <div className="flex flex-wrap gap-2">
                  {settings.folderUrl && (
                    <a href={settings.folderUrl} target="_blank" rel="noopener noreferrer" className={linkButton.secondary}>
                      <Icon icon={Link01Icon} />
                      {t("openFolder")}
                    </a>
                  )}
                  {canEdit && (
                    <Button variant="secondary" onClick={() => setConfirmDisconnect(true)} disabled={busy}>
                      {t("disconnect")}
                    </Button>
                  )}
                </div>
              </div>
              {settings.folderUrl && <p className="text-sm text-gray-500">{t("downloadHint")}</p>}

              {quota && (
                <div className="space-y-2" data-testid="media-quota">
                  <div className="flex flex-wrap justify-between gap-2 text-sm">
                    <span className="font-medium text-gray-700">{t("quota.title")}</span>
                    <span className="text-gray-600 tabular-nums">
                      {quota.limit ? t("quota.used", { used: quota.used, limit: quota.limit }) : t("quota.usedNoLimit", { used: quota.used })}
                    </span>
                  </div>
                  {quota.pct !== null && (
                    <div
                      className="h-2 overflow-hidden rounded-full bg-gray-100"
                      role="progressbar"
                      aria-label={t("quota.title")}
                      aria-valuemin={0}
                      aria-valuemax={100}
                      aria-valuenow={quota.pct}
                    >
                      <div className={cn("h-full rounded-full", settings.quotaWarning ? "bg-amber-500" : "bg-brand-600")} style={{ width: `${quota.pct}%` }} />
                    </div>
                  )}
                  {quota.free && <p className="text-sm text-gray-500">{t("quota.free", { free: quota.free })}</p>}
                </div>
              )}
              {settings.quotaWarning && (
                <div role="status" className="flex items-start gap-2 rounded-xl border border-amber-200 bg-amber-50 p-3 text-sm text-amber-900">
                  <Icon icon={Alert02Icon} />
                  {t("quota.warning")}
                </div>
              )}
            </div>
          ) : (
            !settings.needsReconnect && (
              <div className="space-y-3">
                <p className="text-sm text-gray-700">{t("notConnected")}</p>
                {canEdit ? (
                  <a href={connectUrl(eventId)} className={linkButton.primary} data-testid="media-connect">
                    <Icon icon={GoogleDriveIcon} />
                    {t("connect")}
                  </a>
                ) : (
                  <p className="text-sm text-gray-500">{t("hostOnly")}</p>
                )}
                <p className="text-xs text-gray-500">{t("scopeNote")}</p>
              </div>
            )
          )}

          <fieldset className="space-y-3 border-t border-gray-100 pt-4" disabled={!canEdit || busy}>
            <legend className="text-sm font-semibold text-gray-900">{t("sharing.title")}</legend>
            <p className="text-sm text-gray-600">{t("sharing.intro")}</p>
            <div className="grid gap-3 md:grid-cols-2">
              {(["private", "link"] as const).map((m) => (
                <label
                  key={m}
                  className={cn(
                    "flex cursor-pointer gap-3 rounded-xl border p-4 text-sm",
                    mode === m ? "border-brand-600 bg-brand-50/40" : "border-gray-200 hover:border-gray-300",
                  )}
                >
                  <input type="radio" name="sharingMode" value={m} checked={mode === m} onChange={() => setMode(m)} className="mt-1 accent-brand-600" />
                  <span className="space-y-1">
                    <span className="block font-medium text-gray-900">
                      {t(`sharing.${m}.title`)}
                      {m === "private" && <span className="ml-2 text-xs font-normal text-gray-500">{t("sharing.default")}</span>}
                    </span>
                    <span className="block text-gray-600">{t(`sharing.${m}.body`)}</span>
                  </span>
                </label>
              ))}
            </div>
            {canEdit && (
              <div className="flex flex-wrap items-center gap-3">
                <Button onClick={() => void saveMode()} disabled={busy || mode === settings.sharingMode || !settings.connected}>
                  {t("sharing.save")}
                </Button>
                {!settings.connected && <span className="text-sm text-gray-500">{t("sharing.connectFirst")}</span>}
              </div>
            )}
          </fieldset>

          {notice && <Alert tone={notice.tone}>{notice.text}</Alert>}
        </Panel>
      )}

      <PhotosLink eventId={eventId} settings={settings} canEdit={canEdit} onSaved={onSaved} />

      {confirmDisconnect && (
        <Dialog title={t("disconnectConfirm.title")} onClose={() => setConfirmDisconnect(false)}>
          <p className="text-sm text-gray-600">{t("disconnectConfirm.body")}</p>
          <div className="mt-6 flex justify-end gap-2">
            <Button variant="secondary" onClick={() => setConfirmDisconnect(false)}>
              {t("cancel")}
            </Button>
            <Button variant="danger" onClick={() => void disconnect()}>
              {t("disconnect")}
            </Button>
          </div>
        </Dialog>
      )}
    </div>
  );
}

function PhotosLink({ eventId, settings, canEdit, onSaved }: { eventId: string; settings: MediaSettings; canEdit: boolean; onSaved: (s: MediaSettings) => void }) {
  const t = useTranslations("media.photosLink");
  const [value, setValue] = useState(settings.googlePhotosUrl ?? "");
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<Notice>();

  async function save(e: FormEvent) {
    e.preventDefault();
    const url = value.trim();
    if (url && !/^https:\/\/\S+$/i.test(url)) return setNotice({ tone: "error", text: t("invalid") });
    setBusy(true);
    setNotice(undefined);
    const result = await saveSettings(eventId, { googlePhotosUrl: url });
    setBusy(false);
    if (result.ok) {
      onSaved(result.data);
      setNotice({ tone: "success", text: url ? t("saved") : t("cleared") });
    } else {
      setNotice({ tone: "error", text: result.status === 422 ? t("invalid") : t("error") });
    }
  }

  return (
    <Panel data-testid="media-photos-link">
      <PanelHeader icon={Image01Icon} title={t("title")} intro={settings.mediaEnabled ? t("intro") : t("introMsingi")} />
      <form onSubmit={(e) => void save(e)} className="flex flex-col gap-3 sm:flex-row sm:items-end">
        <div className="flex-1">
          <Field label={t("label")} hint={t("hint")}>
            <Input type="url" inputMode="url" value={value} onChange={(e) => setValue(e.target.value)} placeholder="https://photos.app.goo.gl/…" disabled={!canEdit || busy} />
          </Field>
        </div>
        {canEdit && (
          <Button type="submit" disabled={busy || value.trim() === (settings.googlePhotosUrl ?? "")} className="sm:mb-6">
            {t("save")}
          </Button>
        )}
      </form>
      {notice && <Alert tone={notice.tone}>{notice.text}</Alert>}
    </Panel>
  );
}

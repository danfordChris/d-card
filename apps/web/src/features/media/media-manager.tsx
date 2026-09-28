"use client";

import { Tv01Icon } from "@hugeicons/core-free-icons";
import Link from "next/link";
import { useTranslations } from "next-intl";
import { useCallback, useEffect, useState } from "react";
import { Alert, Button } from "../../components/ui";
import { fetchSettings } from "./api";
import { DrivePanel } from "./drive-panel";
import { GalleryModeration } from "./gallery-moderation";
import { MediaEditor } from "./media-editor";
import { Icon, Panel, PanelHeader, linkButton } from "./parts";
import type { MediaSettings } from "./types";

/** Host media page body: Drive, sharing, card media, story, gallery moderation and the slideshow link. */
export function MediaManager({ eventId, canEdit }: { eventId: string; canEdit: boolean }) {
  const t = useTranslations("media");
  const [settings, setSettings] = useState<MediaSettings | null>(null);
  const [failed, setFailed] = useState(false);

  const reload = useCallback(async () => {
    const result = await fetchSettings(eventId);
    setFailed(!result.ok);
    if (result.ok) setSettings(result.data);
  }, [eventId]);

  useEffect(() => {
    let cancelled = false;
    void fetchSettings(eventId).then((result) => {
      if (cancelled) return;
      setFailed(!result.ok);
      if (result.ok) setSettings(result.data);
    });
    return () => {
      cancelled = true;
    };
  }, [eventId]);

  if (!settings) {
    return failed ? (
      <Alert tone="error">
        {t("loadError")}{" "}
        <Button variant="ghost" className="px-2 py-0.5" onClick={() => void reload()}>
          {t("retry")}
        </Button>
      </Alert>
    ) : (
      <div className="space-y-4" aria-busy="true" aria-label={t("loading")}>
        <div className="h-40 animate-pulse rounded-2xl border border-gray-200 bg-gray-50" />
        <div className="h-56 animate-pulse rounded-2xl border border-gray-200 bg-gray-50" />
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {!canEdit && <Alert>{t("readOnly")}</Alert>}
      {!settings.mediaEnabled && <Alert>{t("msingi")}</Alert>}
      <DrivePanel eventId={eventId} settings={settings} canEdit={canEdit} onSaved={setSettings} onReload={reload} />
      {settings.mediaEnabled && (
        <>
          <MediaEditor eventId={eventId} kind="card" settings={settings} canEdit={canEdit} />
          <MediaEditor eventId={eventId} kind="story" settings={settings} canEdit={canEdit} />
          {settings.limits.galleryEnabled && <GalleryModeration eventId={eventId} canEdit={canEdit} />}
          {settings.limits.slideshow && (
            <Panel data-testid="media-slideshow-link">
              <PanelHeader
                icon={Tv01Icon}
                title={t("slideshow.title")}
                intro={t("slideshow.intro")}
                action={
                  <Link href={`/events/${eventId}/slideshow`} className={linkButton.primary}>
                    <Icon icon={Tv01Icon} />
                    {t("slideshow.open")}
                  </Link>
                }
              />
            </Panel>
          )}
        </>
      )}
    </div>
  );
}

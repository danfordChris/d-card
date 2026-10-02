"use client";

import { Download01Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useTranslations } from "next-intl";
import { useState } from "react";
import { Alert, Button } from "../../components/ui";
import { apiFetch, downloadFromApi } from "../../lib/api-fetch";
import { AUDIT_GROUPS, type AuditChange, type AuditEntry, type AuditPage, type ExportKind } from "./types";

const selectClass =
  "rounded-field border-0 bg-field px-3 py-2 text-sm text-ink focus:ring-2 focus:ring-primary focus:outline-none";
const PAGE_SIZE = 50;

export function AuditLog({
  eventId,
  initial,
  exports,
  locale,
}: {
  eventId: string;
  initial: AuditPage;
  /** Export kinds this viewer may download (host: all; treasurer: contributions). */
  exports: ExportKind[];
  locale: string;
}) {
  const t = useTranslations("audit");
  const [entries, setEntries] = useState(initial.entries);
  const [cursor, setCursor] = useState(initial.nextCursor);
  const [group, setGroup] = useState<string>("");
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string>();
  const [downloading, setDownloading] = useState<ExportKind>();

  async function load(nextGroup: string, after: string | null) {
    setLoading(true);
    setError(undefined);
    const query = new URLSearchParams({ limit: String(PAGE_SIZE) });
    if (nextGroup) query.set("action", nextGroup);
    if (after) query.set("cursor", after);
    const res = await apiFetch(`/api/v1/events/${eventId}/audit?${query}`).catch(() => null);
    setLoading(false);
    if (!res?.ok) {
      setError(t("error"));
      return;
    }
    const page = (await res.json()) as AuditPage;
    setEntries((current) => (after ? [...current, ...page.entries] : page.entries));
    setCursor(page.nextCursor);
  }

  function changeGroup(value: string) {
    setGroup(value);
    void load(value, null);
  }

  async function download(kind: ExportKind) {
    setDownloading(kind);
    setError(undefined);
    const stamp = new Date().toISOString().slice(0, 10);
    const ok = await downloadFromApi(`/api/v1/events/${eventId}/exports/${kind}?lang=${locale === "en" ? "en" : "sw"}`, `${t(`exports.${kind}`).toLowerCase()}-${stamp}.csv`);
    setDownloading(undefined);
    if (!ok) setError(t("exports.failed"));
    // The download itself is audited; show it when the list is unfiltered or filtered to downloads.
    else if (group === "" || group === "export") void load(group, null);
  }

  const time = new Intl.DateTimeFormat(locale, { dateStyle: "medium", timeStyle: "short" });
  const label = (action: string) => {
    const key = `actions.${action}`;
    return t.has(key) ? t(key) : action;
  };
  const actor = (entry: AuditEntry) => (entry.actorType === "system" ? t("system") : (entry.actorName ?? t("unknownActor")));

  return (
    <div className="space-y-6">
      {exports.length > 0 && (
        <div className="rounded-tile bg-tile p-4">
          <h2 className="font-display text-sm font-bold text-ink">{t("exports.title")}</h2>
          <div className="mt-3 flex flex-wrap gap-2">
            {exports.map((kind) => (
              <Button key={kind} variant="secondary" disabled={downloading !== undefined} onClick={() => download(kind)}>
                <HugeiconsIcon icon={Download01Icon} size={16} aria-hidden="true" />
                {t(`exports.${kind}`)}
              </Button>
            ))}
          </div>
        </div>
      )}

      <div className="flex flex-wrap items-center gap-2">
        <label htmlFor="audit-filter" className="text-sm text-muted">{t("filter.label")}</label>
        <select id="audit-filter" className={selectClass} value={group} onChange={(event) => changeGroup(event.target.value)}>
          <option value="">{t("filter.all")}</option>
          {AUDIT_GROUPS.map((value) => (
            <option key={value} value={value}>{t(`filter.groups.${value}`)}</option>
          ))}
        </select>
      </div>

      {error && <Alert tone="error">{error}</Alert>}

      <div className="overflow-x-auto rounded-tile bg-tile">
        {entries.length === 0 ? (
          <p className="p-6 text-center text-sm text-muted">{loading ? t("loading") : t("empty")}</p>
        ) : (
          <table className="w-full min-w-[720px] text-left text-sm">
            <thead className="border-b border-line text-xs text-muted">
              <tr>
                <th className="px-4 py-3 font-medium">{t("columns.time")}</th>
                <th className="px-4 py-3 font-medium">{t("columns.actor")}</th>
                <th className="px-4 py-3 font-medium">{t("columns.action")}</th>
                <th className="px-4 py-3 font-medium">{t("columns.changes")}</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-line">
              {entries.map((entry) => (
                <tr key={entry.id} className="align-top">
                  <td className="px-4 py-3 whitespace-nowrap text-muted">
                    <time dateTime={entry.createdAt}>{time.format(new Date(entry.createdAt))}</time>
                  </td>
                  <td className="px-4 py-3">{actor(entry)}</td>
                  <td className="px-4 py-3">
                    <span className="font-medium">{label(entry.action)}</span>
                    <span className="block font-mono text-xs text-muted">{entry.action}</span>
                  </td>
                  <td className="px-4 py-3"><Changes changes={entry.changes} empty={t("noChanges")} /></td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>

      {cursor && (
        <div className="flex justify-center">
          <Button variant="secondary" disabled={loading} onClick={() => load(group, cursor)}>
            {loading ? t("loading") : t("loadMore")}
          </Button>
        </div>
      )}
    </div>
  );
}

function Changes({ changes, empty }: { changes: AuditChange[]; empty: string }) {
  if (changes.length === 0) return <span className="text-muted">{empty}</span>;
  return (
    <ul className="space-y-1 text-xs">
      {changes.map((change) => (
        <li key={change.field} className="break-words">
          <span className="font-medium text-ink">{change.field}:</span>{" "}
          {change.from !== null && <span className="text-muted line-through">{change.from}</span>}
          {change.from !== null && change.to !== null && <span className="text-muted"> → </span>}
          {change.to !== null && <span className="text-ink">{change.to}</span>}
        </li>
      ))}
    </ul>
  );
}

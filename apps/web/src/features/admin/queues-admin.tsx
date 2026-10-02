"use client";

import { RefreshIcon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useTranslations } from "next-intl";
import { useCallback, useEffect, useState } from "react";
import { Alert, Button } from "../../components/ui";
import { useAdminCall } from "./admin-gate-context";
import { ConfirmDialog, ListBody, listState, panelClass, tdClass, thClass } from "./admin-ui";
import { formatCount } from "./format";
import { jsonInit } from "./platform-api";
import type { QueueStats } from "./platform-types";

const COUNTS = ["waiting", "active", "delayed", "failed", "completed"] as const;

/** T06-03: job counts per queue, with a retry for failed jobs. */
export function QueuesAdmin() {
  const t = useTranslations("adminPlatform.queues");
  const call = useAdminCall();
  const [queues, setQueues] = useState<QueueStats[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState(false);
  const [retrying, setRetrying] = useState<QueueStats>();
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<{ tone: "success" | "error"; text: string }>();

  const load = useCallback(async () => {
    setLoading(true);
    setLoadError(false);
    const r = await call<{ queues: QueueStats[] }>("/api/v1/admin/queues");
    setLoading(false);
    if (!r.ok) return setLoadError(true);
    setQueues(r.data.queues);
  }, [call]);

  useEffect(() => {
    void load();
  }, [load]);

  async function retry() {
    if (!retrying) return;
    setBusy(true);
    setNotice(undefined);
    const r = await call<{ retried: number }>(`/api/v1/admin/queues/${encodeURIComponent(retrying.name)}/retry`, jsonInit("POST"));
    setBusy(false);
    const name = retrying.name;
    setRetrying(undefined);
    if (!r.ok) return setNotice({ tone: "error", text: t("retryFailed") });
    setNotice({ tone: "success", text: t("retried", { count: r.data.retried, name }) });
    void load();
  }

  const state = listState(loading, loadError, queues.length, false);

  return (
    <div className="space-y-4">
      <div className="flex justify-end">
        <Button variant="secondary" disabled={loading} onClick={load}>
          <HugeiconsIcon icon={RefreshIcon} size={16} aria-hidden="true" />
          {t("refresh")}
        </Button>
      </div>

      {notice && <Alert tone={notice.tone}>{notice.text}</Alert>}

      <div className={panelClass}>
        <ListBody state={state} columns={7} empty={{ title: t("empty") }} onRetry={load}>
          <table className="w-full min-w-[640px] text-left text-sm">
            <thead className="border-b border-line text-xs text-muted">
              <tr>
                <th className={thClass}>{t("columns.name")}</th>
                {COUNTS.map((c) => (
                  <th key={c} className={`${thClass} text-right`}>
                    {t(`columns.${c}`)}
                  </th>
                ))}
                <th className={thClass} />
              </tr>
            </thead>
            <tbody className="divide-y divide-line">
              {queues.map((q) => (
                <tr key={q.name}>
                  <td className={`${tdClass} font-mono text-xs`}>{q.name}</td>
                  {COUNTS.map((c) => (
                    <td key={c} className={`${tdClass} text-right tabular-nums ${c === "failed" && q.failed > 0 ? "font-semibold text-danger" : ""}`}>
                      {formatCount(q[c])}
                    </td>
                  ))}
                  <td className={`${tdClass} text-right`}>
                    <Button variant="ghost" disabled={q.failed === 0} onClick={() => setRetrying(q)} aria-label={t("retryLabel", { name: q.name })}>
                      {t("retry")}
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </ListBody>
      </div>

      {retrying && (
        <ConfirmDialog
          title={t("confirmTitle", { name: retrying.name })}
          body={t("confirmBody", { count: retrying.failed })}
          confirmLabel={t("retry")}
          busy={busy}
          onConfirm={retry}
          onClose={() => setRetrying(undefined)}
        />
      )}
    </div>
  );
}

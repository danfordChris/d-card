"use client";

import { useTranslations } from "next-intl";
import Link from "next/link";
import { useState, type FormEvent } from "react";
import { Alert, Button, Card, Field, Input } from "../../components/ui";
import { ImportReportView, type ImportReport } from "./import-report";
import { apiFetch } from "../../lib/api-fetch";

type Preview = { jobId: string; report: ImportReport; kind: "file" | "copy" };

export function ImportPanel({ eventId, pastEvents }: { eventId: string; pastEvents: { id: string; title: string }[] }) {
  const t = useTranslations("imports");
  const [file, setFile] = useState<File | null>(null);
  const [fromEventId, setFromEventId] = useState(pastEvents[0]?.id ?? "");
  const [preview, setPreview] = useState<Preview | null>(null);
  const [consent, setConsent] = useState(false);
  const [error, setError] = useState<string>();
  const [done, setDone] = useState<number | null>(null);
  const [busy, setBusy] = useState(false);
  const base = `/api/v1/events/${eventId}/imports`;

  async function readError(res: Response): Promise<string> {
    const body = (await res.json().catch(() => ({}))) as { error?: { message?: string } };
    return body.error?.message ?? t("errors.generic");
  }

  async function previewFile(e: FormEvent) {
    e.preventDefault();
    if (!file) return setError(t("errors.file"));
    setBusy(true);
    setError(undefined);
    const form = new FormData();
    form.append("file", file);
    const res = await apiFetch(base, { method: "POST", body: form }).catch(() => null);
    setBusy(false);
    if (!res?.ok) return setError(res ? await readError(res) : t("errors.generic"));
    setPreview({ ...(await res.json()), kind: "file" });
    setConsent(false);
    setDone(null);
  }

  async function previewCopy(e: FormEvent) {
    e.preventDefault();
    setBusy(true);
    setError(undefined);
    const res = await apiFetch(`${base}/copy`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ fromEventId }),
    }).catch(() => null);
    setBusy(false);
    if (!res?.ok) return setError(res ? await readError(res) : t("errors.generic"));
    setPreview({ ...(await res.json()), kind: "copy" });
    setConsent(false);
    setDone(null);
  }

  async function confirm() {
    if (!preview) return;
    if (!consent) return setError(t("errors.consent"));
    setBusy(true);
    setError(undefined);
    const res = await apiFetch(`${base}/${preview.jobId}/confirm`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ consent: true }),
    }).catch(() => null);
    setBusy(false);
    if (!res?.ok) return setError(res ? await readError(res) : t("errors.generic"));
    setDone(((await res.json()) as { imported: number }).imported);
    setPreview(null);
  }

  return (
    <div className="space-y-6">
      {error && <Alert tone="error">{error}</Alert>}
      {done !== null && (
        <Alert tone="success">
          {t("done", { count: done })}{" "}
          <Link className="font-semibold underline" href={`/events/${eventId}/guests`}>
            {t("viewGuests")}
          </Link>
        </Alert>
      )}
      <div className="grid gap-6 lg:grid-cols-2">
        <Card className="space-y-4">
          <h2 className="font-semibold">{t("file.heading")}</h2>
          <p className="text-sm text-gray-600">{t("file.intro")}</p>
          <p className="text-xs text-gray-500">{t("file.example")}</p>
          <div className="flex flex-wrap gap-3 text-sm">
            <a className="text-brand-600 underline" href="/templates/guests-template.xlsx" download>
              {t("file.templateXlsx")}
            </a>
            <a className="text-brand-600 underline" href="/templates/guests-template.csv" download>
              {t("file.templateCsv")}
            </a>
          </div>
          <form onSubmit={previewFile} className="space-y-3">
            <Field label={t("file.choose")}>
              <Input type="file" accept=".xlsx,.csv" onChange={(e) => setFile(e.target.files?.[0] ?? null)} />
            </Field>
            <Button type="submit" disabled={busy}>
              {t("file.preview")}
            </Button>
          </form>
        </Card>
        <Card className="space-y-4">
          <h2 className="font-semibold">{t("copy.heading")}</h2>
          <p className="text-sm text-gray-600">{t("copy.intro")}</p>
          {pastEvents.length === 0 ? (
            <p className="text-sm text-gray-500">{t("copy.none")}</p>
          ) : (
            <form onSubmit={previewCopy} className="space-y-3">
              <Field label={t("copy.choose")}>
                <select
                  className="block w-full rounded-lg border-0 bg-white px-3 py-2 text-sm ring-1 ring-gray-300 focus:ring-2 focus:ring-brand-600"
                  value={fromEventId}
                  onChange={(e) => setFromEventId(e.target.value)}
                >
                  {pastEvents.map((e) => (
                    <option key={e.id} value={e.id}>
                      {e.title}
                    </option>
                  ))}
                </select>
              </Field>
              <Button type="submit" disabled={busy}>
                {t("copy.preview")}
              </Button>
            </form>
          )}
        </Card>
      </div>
      {preview && (
        <Card className="space-y-4">
          <h2 className="font-semibold">{t("report.heading")}</h2>
          <ImportReportView report={preview.report} showRows={preview.kind === "file"} />
          {preview.report.valid > 0 ? (
            <>
              <label className="flex items-start gap-2 text-sm">
                <input type="checkbox" className="mt-0.5 size-4 accent-brand-600" checked={consent} onChange={(e) => setConsent(e.target.checked)} />
                {t("report.consent")}
              </label>
              <Button onClick={confirm} disabled={busy}>
                {t("report.import", { count: preview.report.valid })}
              </Button>
            </>
          ) : (
            <p className="text-sm text-gray-500">{t("report.nothing")}</p>
          )}
        </Card>
      )}
    </div>
  );
}

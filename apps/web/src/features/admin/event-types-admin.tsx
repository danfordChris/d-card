"use client";

import { useTranslations } from "next-intl";
import { useState, type FormEvent } from "react";
import { Alert, Button, Card, Field, Input } from "../../components/ui";
import { apiFetch } from "../../lib/api-fetch";

export type AdminEventType = { id: string; key: string; nameSw: string; nameEn: string; active: boolean };

const KEY = /^[a-z][a-z0-9_]{1,39}$/;
const API = "/api/v1/admin/event-types";

type Draft = { key: string; nameSw: string; nameEn: string };
type DraftErrors = Partial<Record<keyof Draft, string>>;

async function errorCode(res: Response | null): Promise<string | undefined> {
  if (!res) return undefined;
  return ((await res.json().catch(() => ({}))) as { error?: { code?: string } }).error?.code;
}

export function EventTypesAdmin({ initial }: { initial: AdminEventType[] }) {
  const t = useTranslations("adminEventTypes");
  const [types, setTypes] = useState(initial);
  const [draft, setDraft] = useState<Draft>({ key: "", nameSw: "", nameEn: "" });
  const [errors, setErrors] = useState<DraftErrors>({});
  const [error, setError] = useState<string>();
  const [busy, setBusy] = useState(false);

  function replace(updated: AdminEventType) {
    setTypes((all) => all.map((x) => (x.key === updated.key ? updated : x)));
  }

  async function create(e: FormEvent) {
    e.preventDefault();
    const next: DraftErrors = {};
    const key = draft.key.trim().toLowerCase();
    if (!key) next.key = t("errors.required");
    else if (!KEY.test(key)) next.key = t("errors.key");
    if (!draft.nameSw.trim()) next.nameSw = t("errors.required");
    if (!draft.nameEn.trim()) next.nameEn = t("errors.required");
    setErrors(next);
    setError(undefined);
    if (Object.keys(next).length) return;
    setBusy(true);
    const res = await apiFetch(API, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ ...draft, key }),
    }).catch(() => null);
    setBusy(false);
    if (!res?.ok) {
      if ((await errorCode(res)) === "conflict") return setErrors({ key: t("errors.duplicate") });
      return setError(t("errors.generic"));
    }
    const created = (await res.json()) as AdminEventType;
    setTypes((all) => [...all, created].sort((a, b) => a.key.localeCompare(b.key)));
    setDraft({ key: "", nameSw: "", nameEn: "" });
  }

  async function patch(key: string, body: Partial<AdminEventType>): Promise<boolean> {
    setError(undefined);
    const res = await apiFetch(`${API}/${encodeURIComponent(key)}`, {
      method: "PATCH",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(body),
    }).catch(() => null);
    if (!res?.ok) {
      setError(t("errors.generic"));
      return false;
    }
    replace((await res.json()) as AdminEventType);
    return true;
  }

  return (
    <div className="space-y-6">
      {error && <Alert tone="error">{error}</Alert>}
      <Card className="overflow-x-auto p-0">
        <table className="w-full text-left text-sm">
          <thead className="border-b border-gray-200 bg-gray-50 text-gray-600">
            <tr>
              <th className="px-4 py-2 font-medium">{t("key")}</th>
              <th className="px-4 py-2 font-medium">{t("nameSw")}</th>
              <th className="px-4 py-2 font-medium">{t("nameEn")}</th>
              <th className="px-4 py-2 font-medium">{t("status")}</th>
              <th className="px-4 py-2" />
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {types.map((type) => (
              <TypeRow key={type.key} type={type} onPatch={(body) => patch(type.key, body)} />
            ))}
          </tbody>
        </table>
      </Card>
      <Card className="space-y-4">
        <h2 className="font-semibold">{t("createHeading")}</h2>
        <form onSubmit={create} noValidate className="grid gap-3 sm:grid-cols-3">
          <Field label={t("key")} error={errors.key} hint={t("keyHint")}>
            <Input value={draft.key} onChange={(e) => setDraft({ ...draft, key: e.target.value })} />
          </Field>
          <Field label={t("nameSw")} error={errors.nameSw}>
            <Input value={draft.nameSw} onChange={(e) => setDraft({ ...draft, nameSw: e.target.value })} />
          </Field>
          <Field label={t("nameEn")} error={errors.nameEn}>
            <Input value={draft.nameEn} onChange={(e) => setDraft({ ...draft, nameEn: e.target.value })} />
          </Field>
          <div className="sm:col-span-3">
            <Button type="submit" disabled={busy}>
              {t("create")}
            </Button>
          </div>
        </form>
      </Card>
    </div>
  );
}

function TypeRow({ type, onPatch }: { type: AdminEventType; onPatch: (body: Partial<AdminEventType>) => Promise<boolean> }) {
  const t = useTranslations("adminEventTypes");
  const [nameSw, setNameSw] = useState(type.nameSw);
  const [nameEn, setNameEn] = useState(type.nameEn);
  const [saved, setSaved] = useState(false);
  const dirty = nameSw.trim() !== type.nameSw || nameEn.trim() !== type.nameEn;
  const valid = nameSw.trim() !== "" && nameEn.trim() !== "";

  return (
    <tr className={type.active ? "" : "bg-gray-50 text-gray-500"}>
      <td className="px-4 py-2 font-mono text-xs">{type.key}</td>
      <td className="px-4 py-2">
        <Input aria-label={`${t("nameSw")} ${type.key}`} value={nameSw} onChange={(e) => (setNameSw(e.target.value), setSaved(false))} />
      </td>
      <td className="px-4 py-2">
        <Input aria-label={`${t("nameEn")} ${type.key}`} value={nameEn} onChange={(e) => (setNameEn(e.target.value), setSaved(false))} />
      </td>
      <td className="px-4 py-2">{type.active ? t("active") : t("inactive")}</td>
      <td className="space-x-2 whitespace-nowrap px-4 py-2 text-right">
        {dirty ? (
          <Button
            variant="secondary"
            disabled={!valid}
            onClick={async () => setSaved(await onPatch({ nameSw: nameSw.trim(), nameEn: nameEn.trim() }))}
          >
            {t("save")}
          </Button>
        ) : (
          saved && <span className="text-xs text-green-700">{t("saved")}</span>
        )}
        <Button variant="ghost" onClick={() => onPatch({ active: !type.active })}>
          {type.active ? t("deactivate") : t("activate")}
        </Button>
      </td>
    </tr>
  );
}

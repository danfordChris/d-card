"use client";

import { useTranslations } from "next-intl";
import { useState, type FormEvent } from "react";
import { Alert, Button, Card, Field, Input } from "../../components/ui";
import { apiFetch } from "../../lib/api-fetch";
import type { AdminWhatsappTemplate } from "./messaging-types";

const API = "/api/v1/admin/whatsapp-templates";
const MESSAGE_TYPES: AdminWhatsappTemplate["messageType"][] = [
  "contribution_request",
  "thank_you",
  "contribution_reminder",
  "invitation_card",
  "card_upgraded",
  "attendance_confirmation",
  "event_reminder",
  "post_event_thanks",
];
const STATUSES: AdminWhatsappTemplate["status"][] = ["pending", "approved", "rejected", "paused"];
const CATEGORIES: AdminWhatsappTemplate["category"][] = ["utility", "marketing", "authentication"];

type Draft = Omit<AdminWhatsappTemplate, "id" | "createdAt" | "updatedAt">;

const emptyDraft: Draft = {
  messageType: "contribution_request",
  variantName: "",
  language: "sw",
  metaTemplateName: "",
  category: "utility",
  bodyParams: [],
  editableParams: [],
  headerImage: false,
  confirmButtons: false,
  status: "pending",
  active: true,
};

const selectClass =
  "block w-full rounded-lg border-0 bg-white px-3 py-2 text-sm text-gray-900 ring-1 ring-gray-300 focus:ring-2 focus:ring-brand-600 focus:outline-none";
const splitParams = (value: string) => value.split(",").map((part) => part.trim()).filter(Boolean);

export function WhatsappTemplatesAdmin({ initial }: { initial: AdminWhatsappTemplate[] }) {
  const t = useTranslations("adminMessaging");
  const [templates, setTemplates] = useState(initial);
  const [draft, setDraft] = useState(emptyDraft);
  const [bodyParams, setBodyParams] = useState("");
  const [editableParams, setEditableParams] = useState("");
  const [error, setError] = useState<string>();
  const [busy, setBusy] = useState(false);

  async function create(event: FormEvent) {
    event.preventDefault();
    setError(undefined);
    if (!draft.variantName.trim() || !draft.metaTemplateName.trim()) return setError(t("errors.required"));
    setBusy(true);
    const res = await apiFetch(API, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ ...draft, bodyParams: splitParams(bodyParams), editableParams: splitParams(editableParams) }),
    }).catch(() => null);
    setBusy(false);
    if (!res?.ok) return setError(t(res?.status === 409 ? "errors.duplicateTemplate" : "errors.generic"));
    const created = (await res.json()) as AdminWhatsappTemplate;
    setTemplates((all) => [...all, created]);
    setDraft(emptyDraft);
    setBodyParams("");
    setEditableParams("");
  }

  async function patch(id: string, body: Partial<AdminWhatsappTemplate>) {
    setError(undefined);
    const res = await apiFetch(`${API}/${id}`, {
      method: "PATCH",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(body),
    }).catch(() => null);
    if (!res?.ok) {
      setError(t("errors.generic"));
      return false;
    }
    const updated = (await res.json()) as AdminWhatsappTemplate;
    setTemplates((all) => all.map((item) => (item.id === id ? updated : item)));
    return true;
  }

  return (
    <div className="space-y-6">
      {error && <Alert tone="error">{error}</Alert>}
      <Card className="overflow-x-auto p-0">
        <table className="w-full min-w-[960px] text-left text-sm">
          <thead className="border-b border-gray-200 bg-gray-50 text-gray-600">
            <tr>
              {(["messageType", "variant", "language", "metaName", "category", "editableParams", "status", "active", "actions"] as const).map((key) => (
                <th key={key} className="px-3 py-2 font-medium">{t(`templates.${key}`)}</th>
              ))}
            </tr>
          </thead>
          <tbody className="divide-y divide-gray-100">
            {templates.map((template) => <TemplateRow key={template.id} template={template} onPatch={patch} />)}
          </tbody>
        </table>
      </Card>

      <Card className="space-y-4">
        <h2 className="font-semibold">{t("templates.createHeading")}</h2>
        <form className="grid gap-3 md:grid-cols-2 lg:grid-cols-3" onSubmit={create} noValidate>
          <Field label={t("templates.messageType")}>
            <select className={selectClass} value={draft.messageType} onChange={(e) => setDraft({ ...draft, messageType: e.target.value as Draft["messageType"] })}>
              {MESSAGE_TYPES.map((value) => <option key={value} value={value}>{t(`messageTypes.${value}`)}</option>)}
            </select>
          </Field>
          <Field label={t("templates.variant")}><Input value={draft.variantName} onChange={(e) => setDraft({ ...draft, variantName: e.target.value })} /></Field>
          <Field label={t("templates.language")}>
            <select className={selectClass} value={draft.language} onChange={(e) => setDraft({ ...draft, language: e.target.value as Draft["language"] })}>
              <option value="sw">{t("languages.sw")}</option><option value="en">{t("languages.en")}</option>
            </select>
          </Field>
          <Field label={t("templates.metaName")}><Input value={draft.metaTemplateName} onChange={(e) => setDraft({ ...draft, metaTemplateName: e.target.value })} /></Field>
          <Field label={t("templates.category")}>
            <select className={selectClass} value={draft.category} onChange={(e) => setDraft({ ...draft, category: e.target.value as Draft["category"] })}>
              {CATEGORIES.map((value) => <option key={value} value={value}>{t(`categories.${value}`)}</option>)}
            </select>
          </Field>
          <Field label={t("templates.status")}>
            <select className={selectClass} value={draft.status} onChange={(e) => setDraft({ ...draft, status: e.target.value as Draft["status"] })}>
              {STATUSES.map((value) => <option key={value} value={value}>{t(`statuses.${value}`)}</option>)}
            </select>
          </Field>
          <Field label={t("templates.bodyParams")} hint={t("templates.paramsHint")}><Input value={bodyParams} onChange={(e) => setBodyParams(e.target.value)} /></Field>
          <Field label={t("templates.editableParams")} hint={t("templates.paramsHint")}><Input value={editableParams} onChange={(e) => setEditableParams(e.target.value)} /></Field>
          <div className="flex items-center gap-5 pt-7 text-sm">
            <label className="flex items-center gap-2"><input type="checkbox" checked={draft.headerImage} onChange={(e) => setDraft({ ...draft, headerImage: e.target.checked })} />{t("templates.headerImage")}</label>
            <label className="flex items-center gap-2"><input type="checkbox" checked={draft.confirmButtons} onChange={(e) => setDraft({ ...draft, confirmButtons: e.target.checked })} />{t("templates.confirmButtons")}</label>
          </div>
          <div className="lg:col-span-3"><Button type="submit" disabled={busy}>{t("templates.create")}</Button></div>
        </form>
      </Card>
    </div>
  );
}

function TemplateRow({ template, onPatch }: { template: AdminWhatsappTemplate; onPatch: (id: string, body: Partial<AdminWhatsappTemplate>) => Promise<boolean> }) {
  const t = useTranslations("adminMessaging");
  const [metaTemplateName, setMetaTemplateName] = useState(template.metaTemplateName);
  const [category, setCategory] = useState(template.category);
  const [status, setStatus] = useState(template.status);
  const [editableParams, setEditableParams] = useState(template.editableParams.join(", "));
  const [saved, setSaved] = useState(false);
  const dirty = metaTemplateName !== template.metaTemplateName || category !== template.category || status !== template.status || editableParams !== template.editableParams.join(", ");
  return (
    <tr className={template.active ? "" : "bg-gray-50 text-gray-500"}>
      <td className="px-3 py-2">{t(`messageTypes.${template.messageType}`)}</td>
      <td className="px-3 py-2 font-mono text-xs">{template.variantName}</td>
      <td className="px-3 py-2">{t(`languages.${template.language}`)}</td>
      <td className="px-3 py-2"><Input aria-label={`${t("templates.metaName")} ${template.variantName} ${template.language}`} value={metaTemplateName} onChange={(e) => (setMetaTemplateName(e.target.value), setSaved(false))} /></td>
      <td className="px-3 py-2"><select aria-label={`${t("templates.category")} ${template.variantName} ${template.language}`} className={selectClass} value={category} onChange={(e) => (setCategory(e.target.value as AdminWhatsappTemplate["category"]), setSaved(false))}>{CATEGORIES.map((value) => <option key={value} value={value}>{t(`categories.${value}`)}</option>)}</select></td>
      <td className="px-3 py-2"><Input aria-label={`${t("templates.editableParams")} ${template.variantName} ${template.language}`} value={editableParams} onChange={(e) => (setEditableParams(e.target.value), setSaved(false))} /></td>
      <td className="px-3 py-2"><select aria-label={`${t("templates.status")} ${template.variantName} ${template.language}`} className={selectClass} value={status} onChange={(e) => (setStatus(e.target.value as AdminWhatsappTemplate["status"]), setSaved(false))}>{STATUSES.map((value) => <option key={value} value={value}>{t(`statuses.${value}`)}</option>)}</select></td>
      <td className="px-3 py-2">{template.active ? t("active") : t("inactive")}</td>
      <td className="space-y-1 px-3 py-2 text-right">
        {dirty && <Button variant="secondary" onClick={async () => setSaved(await onPatch(template.id, { metaTemplateName: metaTemplateName.trim(), category, status, editableParams: splitParams(editableParams) }))}>{t("save")}</Button>}
        {saved && !dirty && <span className="block text-xs text-green-700">{t("saved")}</span>}
        <Button variant="ghost" onClick={() => onPatch(template.id, { active: !template.active })}>{template.active ? t("deactivate") : t("activate")}</Button>
      </td>
    </tr>
  );
}

"use client";

import { useLocale, useTranslations } from "next-intl";
import { useState, type FormEvent } from "react";
import { Alert, Button, Card, Field, Input } from "../../components/ui";
import { apiFetch } from "../../lib/api-fetch";

type Role = "treasurer" | "committee" | "door_staff" | "walkin_approver";
export type TeamData = {
  members: { userId: string; email: string | null; role: Role; since: string }[];
  invites: { id: string; role: Role; email: string | null; expiresAt: string }[];
};

const ROLES: Role[] = ["treasurer", "committee", "door_staff", "walkin_approver"];
const EMAIL = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

export function TeamManager({ eventId, initial }: { eventId: string; initial: TeamData }) {
  const t = useTranslations("team");
  const locale = useLocale();
  const [team, setTeam] = useState(initial);
  const [role, setRole] = useState<Role>("committee");
  const [email, setEmail] = useState("");
  const [emailError, setEmailError] = useState<string>();
  const [error, setError] = useState<string>();
  const [created, setCreated] = useState<{ link: string; email: string | null; emailQueued: boolean } | null>(null);
  const [copied, setCopied] = useState(false);
  const [busy, setBusy] = useState(false);
  const base = `/api/v1/events/${eventId}/team`;

  async function refresh() {
    const res = await apiFetch(base);
    if (res.ok) setTeam(await res.json());
  }

  async function invite(e: FormEvent) {
    e.preventDefault();
    const trimmed = email.trim();
    if (trimmed && !EMAIL.test(trimmed)) return setEmailError(t("errors.email"));
    setEmailError(undefined);
    setError(undefined);
    setBusy(true);
    const res = await apiFetch(`${base}/invites`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ role, email: trimmed || null }),
    }).catch(() => null);
    setBusy(false);
    if (!res?.ok) {
      const code = res ? ((await res.json().catch(() => ({}))) as { error?: { code?: string } }).error?.code : undefined;
      return setError(code === "plan_limit" ? t("invite.planLimit") : t("errors.generic"));
    }
    const body = (await res.json()) as { link: string; emailQueued: boolean; invite: { email: string | null } };
    setCreated({ link: body.link, email: body.invite.email, emailQueued: body.emailQueued });
    setCopied(false);
    setEmail("");
    await refresh();
  }

  async function revoke(id: string) {
    const res = await apiFetch(`${base}/invites/${id}`, { method: "DELETE" });
    if (res.ok) await refresh();
  }

  async function remove(m: TeamData["members"][number]) {
    if (!window.confirm(t("members.removeConfirm", { email: m.email ?? "—", role: t(`roles.${m.role}`) }))) return;
    const res = await apiFetch(`${base}/members/${m.userId}?role=${m.role}`, { method: "DELETE" });
    if (res.ok) await refresh();
  }

  const date = (iso: string) => new Intl.DateTimeFormat(locale === "sw" ? "sw-TZ" : "en-GB", { dateStyle: "medium" }).format(new Date(iso));

  return (
    <div className="grid gap-6 lg:grid-cols-2">
      <Card className="space-y-4">
        <h2 className="font-semibold">{t("invite.heading")}</h2>
        {error && <Alert tone="error">{error}</Alert>}
        <form onSubmit={invite} noValidate className="space-y-3">
          <Field label={t("invite.role")}>
            <select
              className="block w-full rounded-lg border-0 bg-white px-3 py-2 text-sm ring-1 ring-gray-300 focus:ring-2 focus:ring-brand-600"
              value={role}
              onChange={(e) => setRole(e.target.value as Role)}
            >
              {ROLES.map((r) => (
                <option key={r} value={r}>
                  {t(`roles.${r}`)}
                </option>
              ))}
            </select>
          </Field>
          <Field label={t("invite.email")} error={emailError} hint={t("invite.emailHint")}>
            <Input type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
          </Field>
          <Button type="submit" disabled={busy}>
            {t("invite.create")}
          </Button>
        </form>
        {created && (
          <div className="space-y-2 rounded-lg bg-brand-50 p-3">
            <p className="text-sm font-medium">{t("invite.link")}</p>
            <div className="flex gap-2">
              <Input readOnly value={created.link} aria-label={t("invite.link")} onFocus={(e) => e.target.select()} />
              <Button
                variant="secondary"
                onClick={async () => {
                  await navigator.clipboard?.writeText(created.link);
                  setCopied(true);
                }}
              >
                {copied ? t("invite.copied") : t("invite.copy")}
              </Button>
            </div>
            {created.emailQueued && created.email && <p className="text-sm text-gray-600">{t("invite.emailQueued", { email: created.email })}</p>}
          </div>
        )}
      </Card>
      <div className="space-y-6">
        <Card className="space-y-3">
          <h2 className="font-semibold">{t("members.heading")}</h2>
          {team.members.length === 0 ? (
            <p className="text-sm text-gray-500">{t("members.empty")}</p>
          ) : (
            <ul className="divide-y divide-gray-100 text-sm">
              {team.members.map((m) => (
                <li key={`${m.userId}-${m.role}`} className="flex items-center justify-between py-2">
                  <span>
                    {m.email ?? "—"} <span className="text-gray-500">· {t(`roles.${m.role}`)}</span>
                  </span>
                  <Button variant="ghost" className="text-red-600 hover:bg-red-50" onClick={() => remove(m)}>
                    {t("members.remove")}
                  </Button>
                </li>
              ))}
            </ul>
          )}
        </Card>
        <Card className="space-y-3">
          <h2 className="font-semibold">{t("pending.heading")}</h2>
          {team.invites.length === 0 ? (
            <p className="text-sm text-gray-500">{t("pending.empty")}</p>
          ) : (
            <ul className="divide-y divide-gray-100 text-sm">
              {team.invites.map((i) => (
                <li key={i.id} className="flex items-center justify-between py-2">
                  <span>
                    {i.email ?? t("pending.anyone")} <span className="text-gray-500">· {t(`roles.${i.role}`)} · {t("pending.expires", { date: date(i.expiresAt) })}</span>
                  </span>
                  <Button variant="ghost" onClick={() => revoke(i.id)}>
                    {t("pending.revoke")}
                  </Button>
                </li>
              ))}
            </ul>
          )}
        </Card>
      </div>
    </div>
  );
}

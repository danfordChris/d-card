"use client";

import { useTranslations } from "next-intl";
import Link from "next/link";
import { useCallback, useEffect, useRef, useState } from "react";
import { Alert, Button, Card, cn, Input } from "../../components/ui";
import { localPhone } from "../events/format";
import { GuestFormDialog } from "./guest-form";
import { toGuestPayload, type GuestFormValues } from "./guest-form-logic";
import { apiFetch } from "../../lib/api-fetch";

export type GuestRow = {
  id: string;
  name: string;
  phone: string;
  partnerName: string | null;
  cardType: "single" | "double";
  status: "pending" | "issued" | "cancelled";
  cardNumber?: string | null;
};

type CardAction = "issue" | "cancel" | "reinstate";

type Page = { guests: GuestRow[]; nextCursor: string | null };
type Editing = { mode: "add" } | { mode: "edit"; guest: GuestRow } | null;

export function GuestList({
  eventId,
  initial,
  canManage,
  canManageCards = false,
  canViewCards = false,
}: {
  eventId: string;
  initial: Page;
  canManage: boolean;
  /** Host on an open event: issue, cancel, reinstate (docs/design/features/guests-and-cards.md › Access). */
  canManageCards?: boolean;
  /** Host and committee: copy/open the card link. */
  canViewCards?: boolean;
}) {
  const t = useTranslations("guests");
  const [guests, setGuests] = useState(initial.guests);
  const [nextCursor, setNextCursor] = useState(initial.nextCursor);
  const [q, setQ] = useState("");
  const [editing, setEditing] = useState<Editing>(null);
  const [formError, setFormError] = useState<string>();
  const [notice, setNotice] = useState<string>();
  const [busy, setBusy] = useState(false);
  const [cardError, setCardError] = useState<string>();
  const firstSearch = useRef(true);
  const base = `/api/v1/events/${eventId}/guests`;

  const load = useCallback(
    async (query: string, cursor?: string) => {
      const params = new URLSearchParams({ limit: "50" });
      if (query.trim()) params.set("q", query.trim());
      if (cursor) params.set("cursor", cursor);
      const res = await apiFetch(`${base}?${params}`);
      if (!res.ok) return null;
      return (await res.json()) as Page;
    },
    [base],
  );

  useEffect(() => {
    if (firstSearch.current) {
      firstSearch.current = false;
      return;
    }
    const timer = setTimeout(async () => {
      const page = await load(q);
      if (page) {
        setGuests(page.guests);
        setNextCursor(page.nextCursor);
      }
    }, 300);
    return () => clearTimeout(timer);
  }, [q, load]);

  async function loadMore() {
    if (!nextCursor) return;
    const page = await load(q, nextCursor);
    if (page) {
      setGuests((g) => [...g, ...page.guests]);
      setNextCursor(page.nextCursor);
    }
  }

  async function save(values: GuestFormValues) {
    setBusy(true);
    setFormError(undefined);
    const isAdd = editing?.mode === "add";
    const res = await apiFetch(isAdd ? base : `${base}/${editing?.mode === "edit" ? editing.guest.id : ""}`, {
      method: isAdd ? "POST" : "PATCH",
      headers: { "content-type": "application/json" },
      body: JSON.stringify(isAdd ? { ...toGuestPayload(values), phone: values.phone, consent: values.consent } : toGuestPayload(values)),
    }).catch(() => null);
    setBusy(false);
    if (!res || !res.ok) {
      const code = res ? ((await res.json().catch(() => ({}))) as { error?: { code?: string } }).error?.code : undefined;
      setFormError(code === "invalid_phone" ? t("errors.phone") : t("errors.generic"));
      return;
    }
    const body = await res.json();
    if (isAdd) {
      const row = body.guest as GuestRow;
      if (body.existing) {
        setNotice(t("alreadyInvited", { name: row.name }));
        setEditing({ mode: "edit", guest: row });
        return;
      }
      setGuests((g) => [row, ...g]);
      setNotice(t("added", { name: row.name }));
    } else {
      const row = body as GuestRow;
      setGuests((g) => g.map((x) => (x.id === row.id ? row : x)));
    }
    setEditing(null);
  }

  async function cardAction(guest: GuestRow, action: CardAction) {
    if (!window.confirm(t(`cardActions.${action}Confirm`, { name: guest.name }))) return;
    setNotice(undefined);
    setCardError(undefined);
    const res = await apiFetch(`${base}/${guest.id}/${action}`, { method: "POST" }).catch(() => null);
    if (!res?.ok) return setCardError(t("cardActions.error"));
    const card = (await res.json()) as { status: GuestRow["status"]; cardNumber: string | null };
    setGuests((all) => all.map((x) => (x.id === guest.id ? { ...x, status: card.status, cardNumber: card.cardNumber } : x)));
    setNotice(t(`cardActions.${action}Done`, { name: guest.name, number: card.cardNumber ?? "" }));
  }

  async function cardLink(guest: GuestRow, mode: "copy" | "open") {
    // Open the tab synchronously so pop-up blockers allow it, then point it at the link.
    const tab = mode === "open" ? window.open("", "_blank") : null;
    const res = await apiFetch(`${base}/${guest.id}/card`).catch(() => null);
    if (!res?.ok) {
      tab?.close();
      return setCardError(t("cardActions.error"));
    }
    const { link } = (await res.json()) as { link: string };
    if (tab) {
      tab.opener = null;
      tab.location.href = link;
      return;
    }
    await navigator.clipboard?.writeText(link);
    setNotice(t("cardActions.copied", { name: guest.name }));
  }

  async function remove(guest: GuestRow) {
    if (!window.confirm(t("removeConfirm", { name: guest.name }))) return;
    const res = await apiFetch(`${base}/${guest.id}`, { method: "DELETE" });
    if (res.ok) setGuests((g) => g.filter((x) => x.id !== guest.id));
  }

  return (
    <div className="space-y-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <div className="w-full max-w-sm">
          <Input type="search" aria-label={t("search")} placeholder={t("search")} value={q} onChange={(e) => setQ(e.target.value)} />
        </div>
        {canManage && (
          <div className="flex gap-2">
            <Link
              href={`/events/${eventId}/guests/import`}
              className="rounded-lg bg-white px-4 py-2 text-sm font-semibold ring-1 ring-gray-300 hover:bg-gray-50"
            >
              {t("import")}
            </Link>
            <Button
              onClick={() => {
                setFormError(undefined);
                setEditing({ mode: "add" });
              }}
            >
              {t("add")}
            </Button>
          </div>
        )}
      </div>
      {!canManage && <Alert>{t("readOnly")}</Alert>}
      {notice && <Alert tone="success">{notice}</Alert>}
      {cardError && <Alert tone="error">{cardError}</Alert>}
      <Card className="overflow-x-auto p-0">
        {guests.length === 0 ? (
          <p className="p-6 text-center text-gray-600">{q ? t("noResults") : t("empty")}</p>
        ) : (
          <table className="w-full text-left text-sm">
            <thead className="border-b border-gray-200 text-gray-500">
              <tr>
                <th className="px-4 py-3 font-medium">{t("columns.name")}</th>
                <th className="px-4 py-3 font-medium">{t("columns.phone")}</th>
                <th className="px-4 py-3 font-medium">{t("columns.card")}</th>
                <th className="px-4 py-3 font-medium">{t("columns.status")}</th>
                <th className="px-4 py-3 font-medium">{t("columns.cardNumber")}</th>
                {(canManage || canViewCards) && <th className="px-4 py-3 font-medium">{t("columns.actions")}</th>}
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-100">
              {guests.map((g) => (
                <tr key={g.id}>
                  <td className="px-4 py-3">
                    {g.name}
                    {g.partnerName && <span className="block text-xs text-gray-500">+ {g.partnerName}</span>}
                  </td>
                  <td className="px-4 py-3 whitespace-nowrap">{localPhone(g.phone)}</td>
                  <td className="px-4 py-3">{t(`card.${g.cardType}`)}</td>
                  <td className="px-4 py-3">
                    <span
                      className={cn(
                        "rounded-full px-2 py-0.5 text-xs",
                        g.status === "pending" ? "bg-gray-100" : g.status === "cancelled" ? "bg-red-100 text-red-700" : "bg-green-100 text-green-800",
                      )}
                    >
                      {t(`status.${g.status}`)}
                    </span>
                  </td>
                  <td className="px-4 py-3 font-mono text-xs whitespace-nowrap">{g.cardNumber ?? "—"}</td>
                  {(canManage || canViewCards) && (
                    <td className="px-4 py-3 whitespace-nowrap">
                      {canManageCards && g.status === "pending" && (
                        <Button variant="ghost" onClick={() => cardAction(g, "issue")}>
                          {t("cardActions.issue")}
                        </Button>
                      )}
                      {canViewCards && g.cardNumber && g.status !== "pending" && (
                        <>
                          <Button variant="ghost" onClick={() => cardLink(g, "copy")}>
                            {t("cardActions.copyLink")}
                          </Button>
                          <Button variant="ghost" onClick={() => cardLink(g, "open")}>
                            {t("cardActions.open")}
                          </Button>
                        </>
                      )}
                      {canManageCards && g.status !== "cancelled" && (
                        <Button variant="ghost" className="text-red-600 hover:bg-red-50" onClick={() => cardAction(g, "cancel")}>
                          {t("cardActions.cancel")}
                        </Button>
                      )}
                      {canManageCards && g.status === "cancelled" && (
                        <Button variant="ghost" onClick={() => cardAction(g, "reinstate")}>
                          {t("cardActions.reinstate")}
                        </Button>
                      )}
                      {canManage && g.status === "pending" && (
                        <>
                          <Button
                            variant="ghost"
                            onClick={() => {
                              setFormError(undefined);
                              setEditing({ mode: "edit", guest: g });
                            }}
                          >
                            {t("edit")}
                          </Button>
                          <Button variant="ghost" className="text-red-600 hover:bg-red-50" onClick={() => remove(g)}>
                            {t("remove")}
                          </Button>
                        </>
                      )}
                    </td>
                  )}
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </Card>
      {nextCursor && (
        <div className="text-center">
          <Button variant="secondary" onClick={loadMore}>
            {t("loadMore")}
          </Button>
        </div>
      )}
      {editing && (
        <GuestFormDialog
          key={editing.mode === "edit" ? editing.guest.id : "add"}
          mode={editing.mode}
          initial={
            editing.mode === "edit"
              ? {
                  name: editing.guest.name,
                  phone: localPhone(editing.guest.phone),
                  cardType: editing.guest.cardType,
                  partnerName: editing.guest.partnerName ?? "",
                  consent: true,
                }
              : undefined
          }
          error={formError}
          busy={busy}
          onSubmit={save}
          onClose={() => setEditing(null)}
        />
      )}
    </div>
  );
}

"use client";

import { Search01Icon } from "@hugeicons/core-free-icons";
import { HugeiconsIcon } from "@hugeicons/react";
import { useLocale, useTranslations } from "next-intl";
import { useCallback, useEffect, useState, type FormEvent } from "react";
import { Alert, Badge, Button, Input } from "../../components/ui";
import { useAdminCall } from "./admin-gate-context";
import { ConfirmDialog, ListBody, listState, Pagination, panelClass, tdClass, thClass } from "./admin-ui";
import { jsonInit, queryString } from "./platform-api";
import type { AdminUser, Paged } from "./platform-types";

type Action = { user: AdminUser; kind: "grantAdmin" | "revokeAdmin" | "disable" | "enable" };

/** T06-03: search accounts, grant/revoke admin, disable/enable (never your own account). */
export function UsersAdmin({ currentUserId }: { currentUserId?: string }) {
  const t = useTranslations("adminPlatform.users");
  const locale = useLocale();
  const call = useAdminCall();
  const [draft, setDraft] = useState("");
  const [q, setQ] = useState("");
  const [page, setPage] = useState(1);
  const [data, setData] = useState<Paged<AdminUser>>();
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState(false);
  const [action, setAction] = useState<Action>();
  const [busy, setBusy] = useState(false);
  const [notice, setNotice] = useState<{ tone: "success" | "error"; text: string }>();

  const load = useCallback(async () => {
    setLoading(true);
    setLoadError(false);
    const r = await call<Paged<AdminUser>>(`/api/v1/admin/users${queryString({ q, page })}`);
    setLoading(false);
    if (!r.ok) return setLoadError(true);
    setData(r.data);
  }, [call, q, page]);

  useEffect(() => {
    void load();
  }, [load]);

  function search(e: FormEvent) {
    e.preventDefault();
    setPage(1);
    setQ(draft.trim());
  }

  async function apply() {
    if (!action) return;
    const { user, kind } = action;
    const isAdminChange = kind === "grantAdmin" || kind === "revokeAdmin";
    const body = isAdminChange ? { isAdmin: kind === "grantAdmin" } : { disabled: kind === "disable" };
    setBusy(true);
    setNotice(undefined);
    const r = await call<null>(`/api/v1/admin/users/${user.id}`, jsonInit("PATCH", body));
    setBusy(false);
    setAction(undefined);
    if (!r.ok) return setNotice({ tone: "error", text: r.status === 409 ? t("errors.self") : t("errors.generic") });
    const updated: AdminUser = isAdminChange
      ? { ...user, isAdmin: kind === "grantAdmin" }
      : { ...user, disabledAt: kind === "disable" ? new Date().toISOString() : null };
    setData((d) => d && { ...d, items: d.items.map((u) => (u.id === user.id ? updated : u)) });
    setNotice({ tone: "success", text: t(`done.${kind}`, { name: label(user) }) });
  }

  const label = (u: AdminUser) => u.name ?? u.email ?? u.phone ?? u.id;
  const date = new Intl.DateTimeFormat(locale, { dateStyle: "medium" });
  const items = data?.items ?? [];
  const state = listState(loading, loadError, loading ? 0 : items.length, q !== "");

  return (
    <div className="space-y-4">
      <form onSubmit={search} role="search" className="flex max-w-xl gap-2">
        <Input aria-label={t("search")} placeholder={t("searchPlaceholder")} value={draft} onChange={(e) => setDraft(e.target.value)} />
        <Button type="submit" variant="secondary">
          <HugeiconsIcon icon={Search01Icon} size={16} aria-hidden="true" />
          {t("searchButton")}
        </Button>
      </form>

      {notice && <Alert tone={notice.tone}>{notice.text}</Alert>}

      <div className={panelClass}>
        <ListBody state={state} columns={6} empty={{ title: t("empty") }} onRetry={load}>
          <table className="w-full min-w-[820px] text-left text-sm">
            <thead className="border-b border-line text-xs text-muted">
              <tr>
                <th className={thClass}>{t("columns.user")}</th>
                <th className={thClass}>{t("columns.phone")}</th>
                <th className={thClass}>{t("columns.roles")}</th>
                <th className={thClass}>{t("columns.events")}</th>
                <th className={thClass}>{t("columns.status")}</th>
                <th className={thClass}>{t("columns.joined")}</th>
                <th className={thClass} />
              </tr>
            </thead>
            <tbody className="divide-y divide-line">
              {items.map((u) => {
                const self = u.id === currentUserId;
                const deleted = u.deletedAt !== null;
                return (
                  <tr key={u.id} className={u.disabledAt || deleted ? "text-muted" : ""}>
                    <td className={tdClass}>
                      <span className="block font-medium text-ink">{u.name ?? u.email ?? "—"}</span>
                      {u.name && u.email && <span className="block text-xs text-muted">{u.email}</span>}
                      <span className="block text-xs text-muted">{t(`provider.${u.authProvider}`)}</span>
                    </td>
                    <td className={`${tdClass} whitespace-nowrap tabular-nums`}>{u.phone ?? "—"}</td>
                    <td className={tdClass}>
                      {u.isAdmin ? <Badge tone="brand">{t("admin")}</Badge> : null}{" "}
                      <span className="text-xs text-muted">{t("teamRoles", { count: u.teamRoles })}</span>
                    </td>
                    <td className={`${tdClass} tabular-nums`}>{u.eventsHosted}</td>
                    <td className={tdClass}>
                      {deleted ? (
                        <Badge tone="neutral">{t("status.deleted")}</Badge>
                      ) : u.disabledAt ? (
                        <Badge tone="danger">{t("status.disabled")}</Badge>
                      ) : (
                        <Badge tone="success">{t("status.active")}</Badge>
                      )}
                    </td>
                    <td className={`${tdClass} whitespace-nowrap`}>{date.format(new Date(u.createdAt))}</td>
                    <td className={`${tdClass} space-x-1 whitespace-nowrap text-right`}>
                      {self ? (
                        <span className="text-xs text-muted">{t("you")}</span>
                      ) : (
                        !deleted && (
                          <>
                            <Button variant="ghost" onClick={() => setAction({ user: u, kind: u.isAdmin ? "revokeAdmin" : "grantAdmin" })}>
                              {u.isAdmin ? t("actions.revokeAdmin") : t("actions.grantAdmin")}
                            </Button>
                            <Button variant="ghost" onClick={() => setAction({ user: u, kind: u.disabledAt ? "enable" : "disable" })}>
                              {u.disabledAt ? t("actions.enable") : t("actions.disable")}
                            </Button>
                          </>
                        )
                      )}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </ListBody>
      </div>

      {data && <Pagination page={data.page} hasMore={data.hasMore} disabled={loading} onPage={setPage} />}

      {action && (
        <ConfirmDialog
          title={t(`confirm.${action.kind}.title`, { name: label(action.user) })}
          body={t(`confirm.${action.kind}.body`)}
          confirmLabel={t(`actions.${action.kind}`)}
          danger={action.kind === "disable" || action.kind === "revokeAdmin"}
          busy={busy}
          onConfirm={apply}
          onClose={() => setAction(undefined)}
        />
      )}
    </div>
  );
}

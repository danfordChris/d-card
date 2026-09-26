import { getBackupList } from "@dcard/core";
import { getLocale, getTranslations } from "next-intl/server";
import Link from "next/link";
import { notFound } from "next/navigation";
import { PrintButton } from "../../../../../features/dashboard/print-button";
import { formatEventDate } from "../../../../../features/events/format";
import { getDb } from "../../../../../server/db";
import { loadEventOr404, requireAccount } from "../../../../../server/events-page-data";

// CHK-9: printable last-resort guest list (A4), sorted by name. Host and committee.
// Tailwind print: variants do the layout; the small style block below only sets the A4 page
// (no Tailwind utility for @page) and hides the app header around this page when printing.
const PRINT_CSS = `@page { size: A4; margin: 12mm; }
@media print {
  body { background: #fff; }
  header:has(+ main [data-backup-list]) { display: none; }
  main:has([data-backup-list]) { max-width: none; padding: 0; }
}`;

export default async function BackupListPage({ params }: { params: Promise<{ id: string }> }) {
  const account = await requireAccount();
  const event = await loadEventOr404(account.id, (await params).id);
  if (event.access !== "host" && event.access !== "committee") notFound();
  const [t, locale, list] = await Promise.all([getTranslations("dashboard.backup"), getLocale(), getBackupList(getDb(), account.id, event.id)]);
  const printedAt = new Intl.DateTimeFormat(locale === "sw" ? "sw-TZ" : "en-GB", { dateStyle: "medium", timeStyle: "short", timeZone: list.timeZone }).format(new Date());
  return (
    <section data-backup-list className="space-y-4 print:space-y-2 print:text-black">
      <style>{PRINT_CSS}</style>
      <div className="flex flex-wrap items-start justify-between gap-3 print:hidden">
        <Link href={`/events/${event.id}/dashboard`} className="text-sm text-brand-600 hover:underline">
          ← {t("back")}
        </Link>
        <PrintButton label={t("print")} />
      </div>
      <header className="border-b border-gray-300 pb-2">
        <h1 className="text-2xl font-semibold print:text-xl">{list.title}</h1>
        <p className="text-sm text-gray-600 print:text-black">
          {[formatEventDate(list.startsAt, locale, list.timeZone), list.venueName].filter(Boolean).join(" · ")}
        </p>
        <p className="text-xs text-gray-500 print:text-black">
          {t("title")} · {t("count", { count: list.rows.length })} · {t("printedAt", { date: printedAt })}
        </p>
      </header>
      {list.rows.length === 0 ? (
        <p className="text-sm text-gray-500">{t("empty")}</p>
      ) : (
        <table className="w-full border-collapse text-left text-sm print:text-[10pt]">
          <thead className="print:table-header-group">
            <tr className="border-b-2 border-gray-400">
              <th className="w-10 py-1.5 pr-2 font-semibold">#</th>
              <th className="py-1.5 pr-2 font-semibold">{t("name")}</th>
              <th className="py-1.5 pr-2 font-semibold">{t("cardNumber")}</th>
              <th className="py-1.5 pr-2 font-semibold">{t("type")}</th>
              <th className="py-1.5 pr-2 font-semibold">{t("entries")}</th>
              <th className="w-16 py-1.5 font-semibold">{t("tick")}</th>
            </tr>
          </thead>
          <tbody>
            {list.rows.map((r, i) => (
              <tr key={r.invitationId} className="border-b border-gray-200 break-inside-avoid">
                <td className="py-1.5 pr-2 text-gray-500 tabular-nums print:text-black">{i + 1}</td>
                <td className="py-1.5 pr-2">
                  <span className="font-medium">{r.guestName}</span>
                  {r.partnerName && <span className="text-gray-600 print:text-black"> &amp; {r.partnerName}</span>}
                </td>
                <td className="py-1.5 pr-2 font-mono tabular-nums">{r.cardNumber ?? "—"}</td>
                <td className="py-1.5 pr-2">{t(r.cardType)}</td>
                <td className="py-1.5 pr-2 tabular-nums">
                  {r.entriesUsed}/{r.totalEntries}
                </td>
                <td className="py-1.5">
                  <span className="inline-block size-4 border border-gray-500 align-middle" />
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </section>
  );
}

"use client";

import { useTranslations } from "next-intl";
import type { ReactNode } from "react";

export type ImportReport = {
  total: number;
  valid: number;
  invalid: { row: number; phone: string; reason: "invalid_phone" | "name_required" | "invalid_card_type" }[];
  duplicatesInFile: { row: number; phone: string; firstRow: number }[];
  existing: { row: number; phone: string; name: string }[];
};

function Section({ title, children }: { title: string; children: ReactNode }) {
  return (
    <div>
      <h3 className="text-sm font-semibold text-gray-700">{title}</h3>
      <ul className="mt-1 max-h-48 space-y-1 overflow-y-auto text-sm text-gray-600">{children}</ul>
    </div>
  );
}

export function ImportReportView({ report, showRows = true }: { report: ImportReport; showRows?: boolean }) {
  const t = useTranslations("imports.report");
  return (
    <div className="space-y-4">
      <div className="flex flex-wrap gap-4 text-sm">
        <span>{t("total", { count: report.total })}</span>
        <span className="font-semibold text-green-700">{t("valid", { count: report.valid })}</span>
      </div>
      {report.invalid.length > 0 && (
        <Section title={`${t("invalid")} (${report.invalid.length})`}>
          {report.invalid.map((r) => (
            <li key={`i${r.row}`}>
              {showRows && `${t("row", { row: r.row })}: `}
              {r.phone || "—"} — {t(`reasons.${r.reason}`)}
            </li>
          ))}
        </Section>
      )}
      {report.duplicatesInFile.length > 0 && (
        <Section title={`${t("duplicates")} (${report.duplicatesInFile.length})`}>
          {report.duplicatesInFile.map((r) => (
            <li key={`d${r.row}`}>
              {t("row", { row: r.row })}: {t("sameAs", { row: r.firstRow })}
            </li>
          ))}
        </Section>
      )}
      {report.existing.length > 0 && (
        <Section title={`${t("existing")} (${report.existing.length})`}>
          {report.existing.map((r) => (
            <li key={`e${r.row}`}>
              {showRows && `${t("row", { row: r.row })}: `}
              {r.name}
            </li>
          ))}
        </Section>
      )}
    </div>
  );
}

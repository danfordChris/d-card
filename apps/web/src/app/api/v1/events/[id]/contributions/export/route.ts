import { getContributions } from "@dcard/core";
import { createTranslator } from "next-intl";
import en from "../../../../../../../../messages/en.json";
import sw from "../../../../../../../../messages/sw.json";
import Papa from "papaparse";
import writeXlsxFile from "write-excel-file/node";
import { localPhone } from "../../../../../../../features/events/format";
import { LOCALE_COOKIE, toLocale } from "../../../../../../../i18n/config";
import { readCookie } from "../../../../../../../server/auth/verifier";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { toErrorResponse } from "../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

// CON-10: one row per contributor for committee meetings (xlsx or csv).
export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const eventId = eventIdFrom((await params).id);
    const format = new URL(request.url).searchParams.get("format") === "csv" ? "csv" : "xlsx";
    const locale = toLocale(readCookie(request.headers.get("cookie"), LOCALE_COOKIE));
    const t = createTranslator({ locale, messages: locale === "en" ? en : sw, namespace: "contributions" });
    const { contributors } = await getContributions(getDb(), user.id, eventId);
    const header = [
      t("fields.name"),
      t("fields.phone"),
      t("fields.cardType"),
      t("fields.partnerName"),
      t("fields.amountPledged"),
      t("fields.amountPaid"),
      t("fields.balance"),
      t("fields.amountExtra"),
      t("fields.status"),
      t("cardNumber"),
    ];
    const rows = contributors.map((p) => [
      p.name,
      localPhone(p.phone),
      t(`cardTypes.${p.cardType}`),
      p.partnerName ?? "",
      p.amountPledged,
      p.amountPaid,
      p.balance,
      p.amountExtra,
      t(`filters.${p.invitationStatus === "cancelled" ? "cancelled" : p.status}`),
      p.cardNumber ?? "",
    ]);
    const stamp = new Date().toISOString().slice(0, 10);
    if (format === "csv") {
      // BOM so Excel opens UTF-8 names correctly.
      return new Response(`\uFEFF${Papa.unparse([header, ...rows], { escapeFormulae: true })}`, {
        headers: {
          "content-type": "text/csv; charset=utf-8",
          "content-disposition": `attachment; filename="michango-${stamp}.csv"`,
          "cache-control": "private, no-store",
        },
      });
    }
    const sheet = [header.map((value) => ({ value, fontWeight: "bold" as const })), ...rows.map((r) => r.map((value) => ({ value })))];
    const buffer = await writeXlsxFile(sheet).toBuffer();
    return new Response(new Uint8Array(buffer), {
      headers: {
        "content-type": "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
        "content-disposition": `attachment; filename="michango-${stamp}.xlsx"`,
        "cache-control": "private, no-store",
      },
    });
  } catch (err) {
    return toErrorResponse(err);
  }
}

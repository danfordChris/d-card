import { buildEventExport, isExportKind, NotFoundError } from "@dcard/core";
import { LOCALE_COOKIE, toLocale } from "../../../../../../../i18n/config";
import { readCookie } from "../../../../../../../server/auth/verifier";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { toErrorResponse } from "../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string; kind: string }> };

// T06-04: guests | contributions | attendance as CSV (UTF-8 with BOM). Host; treasurer for contributions.
// Headers follow ?lang=sw|en, else the locale cookie. Every download is audited as export.downloaded.
export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const { id, kind } = await params;
    const eventId = eventIdFrom(id);
    if (!isExportKind(kind)) throw new NotFoundError("Export not found.");
    const lang = new URL(request.url).searchParams.get("lang");
    const language = lang === "en" || lang === "sw" ? lang : toLocale(readCookie(request.headers.get("cookie"), LOCALE_COOKIE));
    const out = await buildEventExport(getDb(), user.id, eventId, kind, { language });
    return new Response(out.csv, {
      headers: {
        "content-type": "text/csv; charset=utf-8",
        "content-disposition": `attachment; filename="${out.fileName}"`,
        "cache-control": "private, no-store",
      },
    });
  } catch (err) {
    return toErrorResponse(err);
  }
}

import { listEventAudit } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../server/http";
import { eventIdFrom } from "../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

// T06-04: the event's audit trail, newest first (host and treasurer).
// Query: action (dotted prefix, e.g. "payment"), limit (1–200, default 50), cursor.
export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const eventId = eventIdFrom((await params).id);
    const search = new URL(request.url).searchParams;
    const limit = Number(search.get("limit") ?? 50);
    const page = await listEventAudit(getDb(), user.id, eventId, {
      action: search.get("action"),
      cursor: search.get("cursor"),
      limit: Number.isFinite(limit) ? limit : 50,
    });
    return Response.json(toJson(page), { headers: { "cache-control": "private, no-store" } });
  } catch (err) {
    return toErrorResponse(err);
  }
}

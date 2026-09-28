import { eventIcs, getPublicCard } from "@dcard/core";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ token: string }> };

export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const { token } = await params;
    const card = await getPublicCard(getDb(), token);
    const appUrl = (process.env.APP_URL ?? new URL(request.url).origin).replace(/\/$/, "");
    return new Response(eventIcs(card, `${appUrl}/c/${token}`), {
      headers: {
        "content-type": "text/calendar; charset=utf-8",
        "content-disposition": 'attachment; filename="dcard-event.ics"',
        "cache-control": "private, no-store",
      },
    });
  } catch (err) {
    return toErrorResponse(err);
  }
}

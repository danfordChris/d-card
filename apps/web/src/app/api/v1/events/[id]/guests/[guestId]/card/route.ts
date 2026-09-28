import { getCardLink } from "@dcard/core";
import { requireUser } from "../../../../../../../../server/current-user";
import { getDb } from "../../../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../../../server/http";
import { eventIdFrom, guestIdFrom } from "../../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string; guestId: string }> };

export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const p = await params;
    const { linkToken, ...card } = await getCardLink(getDb(), user.id, eventIdFrom(p.id), guestIdFrom(p.guestId));
    const appUrl = (process.env.APP_URL ?? new URL(request.url).origin).replace(/\/$/, "");
    return Response.json(toJson({ ...card, link: `${appUrl}/c/${linkToken}` }));
  } catch (err) {
    return toErrorResponse(err);
  }
}

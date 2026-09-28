import { MediaKindSchema } from "@dcard/api-contract";
import { listEventMedia, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../server/http";
import { eventIdFrom } from "../../../../../../server/ids";

export const dynamic = "force-dynamic";
type Params = { params: Promise<{ id: string }> };

export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const raw = new URL(request.url).searchParams.get("kind");
    const kind = raw ? MediaKindSchema.safeParse(raw) : null;
    if (kind && !kind.success) throw new ValidationError("Unknown kind.");
    return Response.json(toJson({ items: await listEventMedia(getDb(), user.id, eventIdFrom((await params).id), kind?.data) }));
  } catch (error) {
    return toErrorResponse(error);
  }
}

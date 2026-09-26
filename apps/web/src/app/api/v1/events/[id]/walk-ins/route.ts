import { WalkInStatusSchema } from "@dcard/api-contract";
import { listWalkIns, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../server/http";
import { eventIdFrom } from "../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const raw = new URL(request.url).searchParams.get("status");
    const status = raw ? WalkInStatusSchema.safeParse(raw) : null;
    if (status && !status.success) throw new ValidationError("Unknown status.");
    return Response.json(toJson({ walkIns: await listWalkIns(getDb(), user.id, eventIdFrom((await params).id), status?.data) }));
  } catch (error) {
    return toErrorResponse(error);
  }
}

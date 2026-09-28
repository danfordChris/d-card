import { getDoorWalkIn, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { doorErrorResponse } from "../../../../../../server/door";
import { toJson } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ walkInId: string }> };
const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const { walkInId } = await params;
    const deviceId = new URL(request.url).searchParams.get("deviceId") ?? "";
    if (!UUID.test(walkInId) || !UUID.test(deviceId)) throw new ValidationError("Unknown walk-in or device.");
    return Response.json(toJson(await getDoorWalkIn(getDb(), user.id, deviceId, walkInId)), { headers: { "cache-control": "no-store" } });
  } catch (error) {
    return doorErrorResponse(error);
  }
}

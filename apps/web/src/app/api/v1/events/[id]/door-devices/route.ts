import { listDoorDevices } from "@dcard/core";
import { requireUser } from "../../../../../../server/current-user";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../server/http";
import { eventIdFrom } from "../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    return Response.json(toJson({ devices: await listDoorDevices(getDb(), user.id, eventIdFrom((await params).id)) }));
  } catch (error) {
    return toErrorResponse(error);
  }
}

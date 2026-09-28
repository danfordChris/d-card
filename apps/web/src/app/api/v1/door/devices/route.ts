import { DoorDeviceRegisterInput } from "@dcard/api-contract";
import { registerDoorDevice } from "@dcard/core";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../server/http";

export const dynamic = "force-dynamic";

export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, DoorDeviceRegisterInput);
    const { created, device } = await registerDoorDevice(getDb(), user.id, input);
    return Response.json(toJson(device), { status: created ? 201 : 200 });
  } catch (error) {
    return toErrorResponse(error);
  }
}

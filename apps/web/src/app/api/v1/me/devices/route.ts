import { DeviceRegisterInput } from "@dcard/api-contract";
import { registerDeviceToken } from "@dcard/core";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../server/http";

export const dynamic = "force-dynamic";

/** Registers (upserts) the caller's FCM token for this app install. */
export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, DeviceRegisterInput);
    const { device, created } = await registerDeviceToken(getDb(), user.id, input);
    return Response.json(toJson(device), { status: created ? 201 : 200 });
  } catch (err) {
    return toErrorResponse(err);
  }
}

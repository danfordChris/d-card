import { revokeDoorDevice, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { toErrorResponse } from "../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string; deviceId: string }> };

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export async function DELETE(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const { id, deviceId } = await params;
    if (!UUID.test(deviceId)) throw new ValidationError("Unknown device.");
    await revokeDoorDevice(getDb(), user.id, eventIdFrom(id), deviceId);
    return new Response(null, { status: 204 });
  } catch (error) {
    return toErrorResponse(error);
  }
}

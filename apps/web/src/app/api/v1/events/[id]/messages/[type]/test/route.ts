import { MessageTestInput, MessageTypeSchema } from "@dcard/api-contract";
import { queueTestMessage, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../../../../server/current-user";
import { getDb } from "../../../../../../../../server/db";
import { parseBody, toErrorResponse } from "../../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../../server/ids";
import { enforceRateLimit } from "../../../../../../../../server/rate-limit";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string; type: string }> };

export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const values = await params;
    const parsedType = MessageTypeSchema.safeParse(values.type);
    if (!parsedType.success) throw new ValidationError("Unknown message type.");
    const eventId = eventIdFrom(values.id);
    await enforceRateLimit(`message-test:${user.id}:${eventId}`, 5, 3600);
    const input = await parseBody(request, MessageTestInput);
    await queueTestMessage(getDb(), user.id, eventId, parsedType.data, input.channels);
    return Response.json({ queued: true }, { status: 202 });
  } catch (error) {
    return toErrorResponse(error);
  }
}

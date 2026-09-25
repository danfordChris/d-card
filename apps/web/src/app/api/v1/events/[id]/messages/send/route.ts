import { ManualSendInput } from "@dcard/api-contract";
import { manualSend } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { parseBody, toErrorResponse } from "../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

// MSG-13: `preview: true` returns the recipient count shown before the host confirms.
export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, ManualSendInput);
    const result = await manualSend(getDb(), user.id, eventIdFrom((await params).id), input);
    return input.preview
      ? Response.json({ recipients: result.recipients, sendsUsed: result.sendsUsed, sendsAllowed: result.sendsAllowed })
      : Response.json({ queued: result.queued, sendsUsed: result.sendsUsed, sendsAllowed: result.sendsAllowed }, { status: 202 });
  } catch (error) {
    return toErrorResponse(error);
  }
}

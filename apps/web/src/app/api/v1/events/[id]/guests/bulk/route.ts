import { GuestBulkInput } from "@dcard/api-contract";
import { addGuestsBulk } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../server/ids";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

// GST-6: guests picked from phone contacts in the D-Card app; one consent record (source `contacts`).
export async function POST(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireUser(request);
    const eventId = eventIdFrom((await params).id);
    const input = await parseBody(request, GuestBulkInput);
    const result = await addGuestsBulk(getDb(), user.id, eventId, input.guests, { consent: input.consent, source: "contacts" });
    return Response.json(toJson(result), { status: result.added.length > 0 ? 201 : 200 });
  } catch (err) {
    return toErrorResponse(err);
  }
}

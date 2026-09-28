import { ImportConfirmInput } from "@dcard/api-contract";
import { confirmImport } from "@dcard/core";
import { requireUser } from "../../../../../../../../server/current-user";
import { getDb } from "../../../../../../../../server/db";
import { parseBody, toErrorResponse } from "../../../../../../../../server/http";
import { eventIdFrom, uuidFrom } from "../../../../../../../../server/ids";

export const dynamic = "force-dynamic";

export async function POST(request: Request, { params }: { params: Promise<{ id: string; jobId: string }> }): Promise<Response> {
  try {
    const user = await requireUser(request);
    const p = await params;
    const { consent } = await parseBody(request, ImportConfirmInput);
    const result = await confirmImport(getDb(), user.id, eventIdFrom(p.id), uuidFrom(p.jobId, "Import"), consent);
    return Response.json(result);
  } catch (err) {
    return toErrorResponse(err);
  }
}

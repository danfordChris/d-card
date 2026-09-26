import { AdminWhatsappTemplateInput } from "@dcard/api-contract";
import {
  createWhatsappTemplate,
  listWhatsappTemplates,
} from "@dcard/core";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { parseBody, toErrorResponse } from "../../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    return Response.json({ templates: await listWhatsappTemplates(getDb(), user.id) });
  } catch (err) {
    return toErrorResponse(err);
  }
}

export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, AdminWhatsappTemplateInput);
    return Response.json(await createWhatsappTemplate(getDb(), user.id, input), { status: 201 });
  } catch (err) {
    return toErrorResponse(err);
  }
}

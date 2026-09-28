import { AdminWhatsappTemplateUpdateInput } from "@dcard/api-contract";
import { updateWhatsappTemplate } from "@dcard/core";
import { requireAdminUser } from "../../../../../../server/admin-auth";
import { getDb } from "../../../../../../server/db";
import { parseBody, toErrorResponse } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ id: string }> };

export async function PATCH(request: Request, { params }: Params): Promise<Response> {
  try {
    const user = await requireAdminUser(request);
    const input = await parseBody(request, AdminWhatsappTemplateUpdateInput);
    return Response.json(await updateWhatsappTemplate(getDb(), user.id, (await params).id, input));
  } catch (err) {
    return toErrorResponse(err);
  }
}

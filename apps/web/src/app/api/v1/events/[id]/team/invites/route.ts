import { InviteCreateInput } from "@dcard/api-contract";
import { createInvite } from "@dcard/core";
import { toLocale } from "../../../../../../../i18n/config";
import { readCookie } from "../../../../../../../server/auth/verifier";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../server/ids";
import { enqueueTeamInviteEmail } from "../../../../../../../server/queue";

export const dynamic = "force-dynamic";

export async function POST(request: Request, { params }: { params: Promise<{ id: string }> }): Promise<Response> {
  try {
    const user = await requireUser(request);
    const eventId = eventIdFrom((await params).id);
    const input = await parseBody(request, InviteCreateInput);
    const { invite, token, eventTitle } = await createInvite(getDb(), user.id, eventId, input);
    const appUrl = (process.env.APP_URL ?? new URL(request.url).origin).replace(/\/$/, "");
    const link = `${appUrl}/invite/${token}`;
    let emailQueued = false;
    if (invite.email) {
      try {
        await enqueueTeamInviteEmail({
          inviteId: invite.id,
          to: invite.email,
          eventTitle,
          role: invite.role,
          link,
          language: toLocale(readCookie(request.headers.get("cookie"), "NEXT_LOCALE")),
        });
        emailQueued = true;
      } catch (err) {
        // The invite still works through the link (docs/design/integrations/email.md).
        console.error("team invite email not queued", err);
      }
    }
    return Response.json(toJson({ invite, link, emailQueued }), { status: 201 });
  } catch (err) {
    return toErrorResponse(err);
  }
}

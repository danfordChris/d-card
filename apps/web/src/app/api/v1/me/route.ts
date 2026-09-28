import { deleteMyAccount } from "@dcard/core";
import { getAccount, provisionAccount } from "../../../../server/accounts";
import { deleteFirebaseUser } from "../../../../server/auth/firebase-admin";
import { requireUser } from "../../../../server/current-user";
import { authenticate } from "../../../../server/auth/verifier";
import { getDb } from "../../../../server/db";
import { toErrorResponse } from "../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(request: Request): Promise<Response> {
  try {
    const token = await authenticate(request);
    return Response.json(await getAccount(getDb(), token.uid));
  } catch (err) {
    return toErrorResponse(err);
  }
}

export async function POST(request: Request): Promise<Response> {
  try {
    const token = await authenticate(request);
    const { account, created } = await provisionAccount(getDb(), token, {
      ip: request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? null,
      device: request.headers.get("user-agent"),
    });
    return Response.json(account, { status: created ? 201 : 200 });
  } catch (err) {
    return toErrorResponse(err);
  }
}

/** "Delete my account": tombstones the D-Card account, then removes the Firebase user. */
export async function DELETE(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const { firebaseUid } = await deleteMyAccount(getDb(), user.id, new Date(), {
      ip: request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? null,
      device: request.headers.get("user-agent"),
    });
    await deleteFirebaseUser(firebaseUid);
    return new Response(null, { status: 204 });
  } catch (err) {
    return toErrorResponse(err);
  }
}


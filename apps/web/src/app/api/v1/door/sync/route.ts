import { DoorSyncQuery, DoorSyncUpload } from "@dcard/api-contract";
import { doorSyncDownload, doorSyncUpload, ValidationError } from "@dcard/core";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { parseBody, toErrorResponse, toJson } from "../../../../../server/http";
import { enqueuePush } from "../../../../../server/queue";

export const dynamic = "force-dynamic";

/** Offline cache: full snapshot without `since`, changes only with it (offline-sync 9.1). */
export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const query = DoorSyncQuery.safeParse(Object.fromEntries(new URL(request.url).searchParams));
    if (!query.success) {
      throw new ValidationError("Some fields are invalid.", query.error.issues.map((i) => ({ path: i.path.join("."), message: i.message })));
    }
    return Response.json(toJson(await doorSyncDownload(getDb(), user.id, query.data)), { headers: { "cache-control": "no-store" } });
  } catch (error) {
    return toErrorResponse(error);
  }
}

/** Upload offline entries and attempts; idempotent and order-free (offline-sync 9.2). */
export async function POST(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const input = await parseBody(request, DoorSyncUpload);
    const { push, ...result } = await doorSyncUpload(getDb(), user.id, input);
    await enqueuePush(push);
    return Response.json(toJson(result));
  } catch (error) {
    return toErrorResponse(error);
  }
}

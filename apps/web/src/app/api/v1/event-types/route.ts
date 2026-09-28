import { listEventTypes } from "@dcard/core";
import { getDb } from "../../../../server/db";
import { toErrorResponse } from "../../../../server/http";

export const dynamic = "force-dynamic";

export async function GET(): Promise<Response> {
  try {
    const types = await listEventTypes(getDb());
    return Response.json({ eventTypes: types.map((t) => ({ key: t.key, nameSw: t.nameSw, nameEn: t.nameEn })) });
  } catch (err) {
    return toErrorResponse(err);
  }
}

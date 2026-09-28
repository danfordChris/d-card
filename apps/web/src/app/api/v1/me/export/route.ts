import { exportMyData } from "@dcard/core";
import { requireUser } from "../../../../../server/current-user";
import { getDb } from "../../../../../server/db";
import { toErrorResponse } from "../../../../../server/http";

export const dynamic = "force-dynamic";

/** "Download my data" (docs/design/features/privacy-and-audit.md). */
export async function GET(request: Request): Promise<Response> {
  try {
    const user = await requireUser(request);
    const data = await exportMyData(getDb(), user.id, {
      ip: request.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ?? null,
      device: request.headers.get("user-agent"),
    });
    return new Response(JSON.stringify(data, null, 2), {
      headers: {
        "content-type": "application/json; charset=utf-8",
        "content-disposition": `attachment; filename="dcard-my-data-${data.exportedAt.slice(0, 10)}.json"`,
        "cache-control": "no-store",
      },
    });
  } catch (err) {
    return toErrorResponse(err);
  }
}

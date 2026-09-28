import { getEventDashboard } from "@dcard/core";
import { requireUser } from "../../../../../../../server/current-user";
import { getDb } from "../../../../../../../server/db";
import { toErrorResponse, toJson } from "../../../../../../../server/http";
import { eventIdFrom } from "../../../../../../../server/ids";

// Live dashboard as Server-Sent Events. The first frame is the full dashboard; after that the
// server re-reads every CHECK_MS and sends a frame only when `version` changes, with a comment
// ping to keep proxies from closing the connection. The response ends after MAX_MS so it stays
// inside serverless function limits; the client simply reconnects (and polls if streaming fails).
//
// The browser reads this with fetch() + a stream reader, not EventSource: every /api request
// must carry the X-API-Key header (proxy.ts) and EventSource cannot send headers.

export const dynamic = "force-dynamic";
export const runtime = "nodejs";
export const maxDuration = 60;

const CHECK_MS = 3_000;
const PING_MS = 15_000;
const MAX_MS = 50_000;

type Params = { params: Promise<{ id: string }> };

export async function GET(request: Request, { params }: Params): Promise<Response> {
  let userId: string;
  let eventId: string;
  let first: Awaited<ReturnType<typeof getEventDashboard>>;
  try {
    userId = (await requireUser(request)).id;
    eventId = eventIdFrom((await params).id);
    // Access is checked here, before the stream starts, so errors keep their JSON status.
    first = await getEventDashboard(getDb(), userId, eventId);
  } catch (error) {
    return toErrorResponse(error);
  }

  const encoder = new TextEncoder();
  const signal = request.signal;
  let cleanup = () => {};

  const stream = new ReadableStream<Uint8Array>({
    start(controller) {
      let closed = false;
      let version = first.version;
      let busy = false;
      const send = (text: string) => {
        if (!closed) controller.enqueue(encoder.encode(text));
      };
      const frame = (data: unknown) => send(`event: dashboard\ndata: ${JSON.stringify(toJson(data))}\n\n`);
      const close = () => {
        if (closed) return;
        closed = true;
        clearInterval(check);
        clearInterval(ping);
        clearTimeout(end);
        signal.removeEventListener("abort", close);
        try {
          controller.close();
        } catch {
          // already closed by the client
        }
      };
      cleanup = close;

      send(`retry: ${CHECK_MS}\n\n`);
      frame(first);

      const check = setInterval(async () => {
        if (busy || closed) return;
        busy = true;
        try {
          const next = await getEventDashboard(getDb(), userId, eventId);
          if (next.version !== version) {
            version = next.version;
            frame(next);
          }
        } catch {
          // Access revoked or a transient database error: end; the client reconnects or polls.
          close();
        } finally {
          busy = false;
        }
      }, CHECK_MS);
      const ping = setInterval(() => send(": ping\n\n"), PING_MS);
      const end = setTimeout(close, MAX_MS);
      if (signal.aborted) close();
      else signal.addEventListener("abort", close);
    },
    cancel() {
      cleanup();
    },
  });

  return new Response(stream, {
    headers: {
      "content-type": "text/event-stream; charset=utf-8",
      "cache-control": "no-cache, no-transform",
      "x-accel-buffering": "no",
    },
  });
}

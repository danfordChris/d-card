import { getPublicCard, NotFoundError } from "@dcard/core";
import { renderCardImage } from "../../../../../../server/card-image/card-image";
import { getDb } from "../../../../../../server/db";
import { toErrorResponse } from "../../../../../../server/http";

export const dynamic = "force-dynamic";

type Params = { params: Promise<{ token: string }> };

// PNG card with QR (1080×1350) for download now and WhatsApp sending in phase 03. Not stored.
export async function GET(request: Request, { params }: Params): Promise<Response> {
  try {
    const card = await getPublicCard(getDb(), (await params).token);
    if (card.status !== "issued") throw new NotFoundError("Card not found.");
    const lang = new URL(request.url).searchParams.get("lang") === "en" ? "en" : "sw";
    return await renderCardImage(card, lang);
  } catch (err) {
    return toErrorResponse(err);
  }
}

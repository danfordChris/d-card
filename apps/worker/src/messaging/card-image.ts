// The card image is rendered by the web app (GET /api/v1/cards/{token}/image, next/og) and never
// stored; the worker fetches it with its own API key and uploads it to Meta for the card header.

export async function fetchCardImage(
  opts: { appUrl: string; apiKey: string },
  linkToken: string,
  language: "sw" | "en",
  fetchImpl: typeof fetch = fetch,
): Promise<Uint8Array> {
  const url = `${opts.appUrl.replace(/\/$/, "")}/api/v1/cards/${encodeURIComponent(linkToken)}/image?lang=${language}`;
  const res = await fetchImpl(url, { headers: { "x-api-key": opts.apiKey } });
  if (!res.ok) throw new Error(`card image HTTP ${res.status}`);
  if (!(res.headers.get("content-type") ?? "").startsWith("image/png")) throw new Error("card image is not a PNG");
  return new Uint8Array(await res.arrayBuffer());
}

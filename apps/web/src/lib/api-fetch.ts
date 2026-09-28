// Browser calls to our own API. Adds the web app's X-API-Key (NEXT_PUBLIC_DCARD_API_KEY);
// the session cookie still authenticates the user.

const WEB_API_KEY = process.env.NEXT_PUBLIC_DCARD_API_KEY ?? "";

export function apiFetch(input: string, init: RequestInit = {}): Promise<Response> {
  const headers = new Headers(init.headers);
  headers.set("x-api-key", WEB_API_KEY);
  return fetch(input, { ...init, headers });
}

/** Downloads an API file (export, calendar, card image) with the key, then saves it. */
export async function downloadFromApi(url: string, fileName: string): Promise<boolean> {
  const res = await apiFetch(url).catch(() => null);
  if (!res?.ok) return false;
  const blobUrl = URL.createObjectURL(await res.blob());
  const a = document.createElement("a");
  a.href = blobUrl;
  a.download = fileName;
  document.body.appendChild(a);
  a.click();
  a.remove();
  setTimeout(() => URL.revokeObjectURL(blobUrl), 1000);
  return true;
}

// Spike: create an event folder in a test Google Drive and upload a file through a
// resumable session — the same flow the client uses for direct uploads
// (docs/design/integrations/google-drive.md).
import { env, log, postJson, requireKeys, requireProvider, run } from "./_shared.js";

await run("drive-upload", async () => {
  const g = requireProvider(env, "google");
  const { GOOGLE_TEST_REFRESH_TOKEN } = requireKeys(env, ["GOOGLE_TEST_REFRESH_TOKEN"]);

  const tokenRes = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "content-type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      client_id: g.GOOGLE_OAUTH_CLIENT_ID ?? "",
      client_secret: g.GOOGLE_OAUTH_CLIENT_SECRET ?? "",
      refresh_token: GOOGLE_TEST_REFRESH_TOKEN ?? "",
      grant_type: "refresh_token",
    }),
  }).then((r) => r.json() as Promise<{ access_token?: string; error?: string }>);
  if (!tokenRes.access_token) throw new Error(`Token exchange failed: ${JSON.stringify(tokenRes)}`);
  const auth = { authorization: `Bearer ${tokenRes.access_token}` };

  const folder = (await postJson(
    "https://www.googleapis.com/drive/v3/files",
    { name: `D-Card – Spike ${new Date().toISOString()}`, mimeType: "application/vnd.google-apps.folder" },
    auth,
  )) as { id: string };
  log("folder created", folder);

  // 1) Server side: start a resumable session (this URL is what the phone/browser receives).
  const session = await fetch("https://www.googleapis.com/upload/drive/v3/files?uploadType=resumable", {
    method: "POST",
    headers: { ...auth, "content-type": "application/json", "x-upload-content-type": "text/plain" },
    body: JSON.stringify({ name: "spike.txt", parents: [folder.id] }),
  });
  const uploadUrl = session.headers.get("location");
  if (!session.ok || !uploadUrl) throw new Error(`Session failed: ${session.status} ${await session.text()}`);
  log("resumable session created (no auth header needed to upload)");

  // 2) Client side: upload bytes straight to Google with only the session URL.
  const upload = await fetch(uploadUrl, { method: "PUT", body: "D-Card spike upload" });
  const file = await upload.json();
  if (!upload.ok) throw new Error(`Upload failed: ${JSON.stringify(file)}`);
  log("PASS: file uploaded to Drive", file);
});

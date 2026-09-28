import { createHmac, randomUUID, timingSafeEqual } from "node:crypto";

// Storage behind one interface (MED-16). Google Drive through its REST API with the host's
// token (scope drive.file: only files D-Card created); a fake store for tests and local dev.
// File bytes never pass through D-Card except when streaming private-mode media to a viewer.

export type DriveFile = {
  id: string;
  name: string;
  mimeType: string;
  size: number;
  parents: string[];
  trashed: boolean;
  thumbnailLink: string | null;
};

export type Quota = { limitBytes: number | null; usageBytes: number };

export interface MediaStore {
  readonly name: string;
  createFolder(refreshToken: string, name: string, parentId?: string): Promise<{ id: string; url: string }>;
  setLinkSharing(refreshToken: string, folderId: string, anyoneWithLink: boolean): Promise<void>;
  /** Resumable upload URL the browser/app PUTs bytes to directly (CORS allowed for `origin`). */
  createUploadSession(refreshToken: string, file: { folderId: string; name: string; mimeType: string; size: number }, origin: string): Promise<string>;
  getFile(refreshToken: string, fileId: string): Promise<DriveFile | null>;
  deleteFile(refreshToken: string, fileId: string): Promise<void>;
  getQuota(refreshToken: string): Promise<Quota>;
  /** Streams the file (or a large thumbnail) for private mode; passes Range through. */
  stream(refreshToken: string, fileId: string, opts: { thumbnail: boolean; range?: string | null }): Promise<Response>;
}

export class DriveAccessError extends Error {
  constructor(
    message: string,
    /** Access revoked / folder gone: the host must reconnect (MED-13). */
    readonly needsReconnect: boolean,
    readonly driveFull = false,
  ) {
    super(message);
  }
}

type Fetch = typeof fetch;
const API = "https://www.googleapis.com/drive/v3";
const UPLOAD = "https://www.googleapis.com/upload/drive/v3/files";

export class GoogleDriveStore implements MediaStore {
  readonly name = "google-drive";
  private readonly tokens = new Map<string, { token: string; expires: number }>();

  constructor(
    private readonly opts: { clientId: string; clientSecret: string },
    private readonly fetchImpl: Fetch = fetch,
  ) {}

  private async accessToken(refreshToken: string): Promise<string> {
    const cached = this.tokens.get(refreshToken);
    if (cached && cached.expires > Date.now() + 60_000) return cached.token;
    const res = await this.fetchImpl("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "content-type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({ grant_type: "refresh_token", refresh_token: refreshToken, client_id: this.opts.clientId, client_secret: this.opts.clientSecret }),
    });
    const json = (await res.json().catch(() => ({}))) as { access_token?: string; expires_in?: number; error?: string };
    if (!res.ok || !json.access_token) throw new DriveAccessError(`Google token refresh failed: ${json.error ?? res.status}`, json.error === "invalid_grant");
    this.tokens.set(refreshToken, { token: json.access_token, expires: Date.now() + (json.expires_in ?? 3600) * 1000 });
    return json.access_token;
  }

  private async call(refreshToken: string, url: string, init: RequestInit = {}): Promise<Response> {
    const token = await this.accessToken(refreshToken);
    const res = await this.fetchImpl(url, { ...init, headers: { authorization: `Bearer ${token}`, ...(init.headers ?? {}) } });
    if (res.status === 401) throw new DriveAccessError("Google Drive access was revoked.", true);
    if (res.status === 403) {
      const body = await res.clone().text();
      if (body.includes("storageQuotaExceeded")) throw new DriveAccessError("The host's Google Drive is full.", false, true);
      throw new DriveAccessError(`Google Drive refused the request (403).`, body.includes("insufficientPermissions") || body.includes("appNotAuthorizedToFile"));
    }
    return res;
  }

  private async json<T>(refreshToken: string, url: string, init: RequestInit = {}): Promise<T> {
    const res = await this.call(refreshToken, url, init);
    if (!res.ok) throw new DriveAccessError(`Google Drive error ${res.status}: ${(await res.text()).slice(0, 200)}`, res.status === 404);
    return (await res.json()) as T;
  }

  async createFolder(refreshToken: string, name: string, parentId?: string) {
    const f = await this.json<{ id: string; webViewLink: string }>(refreshToken, `${API}/files?fields=id,webViewLink`, {
      method: "POST",
      headers: { "content-type": "application/json" },
      body: JSON.stringify({ name, mimeType: "application/vnd.google-apps.folder", ...(parentId ? { parents: [parentId] } : {}) }),
    });
    return { id: f.id, url: f.webViewLink };
  }

  async setLinkSharing(refreshToken: string, folderId: string, anyoneWithLink: boolean): Promise<void> {
    const { permissions = [] } = await this.json<{ permissions?: { id: string; type: string }[] }>(refreshToken, `${API}/files/${folderId}/permissions?fields=permissions(id,type)`);
    const anyone = permissions.find((p) => p.type === "anyone");
    if (anyoneWithLink && !anyone) {
      await this.json(refreshToken, `${API}/files/${folderId}/permissions`, {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ role: "reader", type: "anyone", allowFileDiscovery: false }),
      });
    } else if (!anyoneWithLink && anyone) {
      await this.call(refreshToken, `${API}/files/${folderId}/permissions/${anyone.id}`, { method: "DELETE" });
    }
  }

  async createUploadSession(refreshToken: string, file: { folderId: string; name: string; mimeType: string; size: number }, origin: string) {
    const res = await this.call(refreshToken, `${UPLOAD}?uploadType=resumable&fields=id`, {
      method: "POST",
      headers: {
        "content-type": "application/json; charset=UTF-8",
        "x-upload-content-type": file.mimeType,
        "x-upload-content-length": String(file.size),
        // Google allows the browser at this origin to PUT to the session URL (CORS).
        origin,
      },
      body: JSON.stringify({ name: file.name, parents: [file.folderId] }),
    });
    const location = res.headers.get("location");
    if (!res.ok || !location) throw new DriveAccessError(`Could not start the upload (${res.status}).`, res.status === 404);
    return location;
  }

  async getFile(refreshToken: string, fileId: string): Promise<DriveFile | null> {
    const res = await this.call(refreshToken, `${API}/files/${encodeURIComponent(fileId)}?fields=id,name,mimeType,size,parents,trashed,thumbnailLink`);
    if (res.status === 404) return null;
    if (!res.ok) throw new DriveAccessError(`Google Drive error ${res.status}`, false);
    const f = (await res.json()) as { id: string; name: string; mimeType: string; size?: string; parents?: string[]; trashed?: boolean; thumbnailLink?: string };
    return { id: f.id, name: f.name, mimeType: f.mimeType, size: Number(f.size ?? 0), parents: f.parents ?? [], trashed: Boolean(f.trashed), thumbnailLink: f.thumbnailLink ?? null };
  }

  async deleteFile(refreshToken: string, fileId: string): Promise<void> {
    const res = await this.call(refreshToken, `${API}/files/${encodeURIComponent(fileId)}`, { method: "DELETE" });
    if (!res.ok && res.status !== 404) throw new DriveAccessError(`Delete failed (${res.status}).`, false);
  }

  async getQuota(refreshToken: string): Promise<Quota> {
    const a = await this.json<{ storageQuota?: { limit?: string; usage?: string } }>(refreshToken, `${API}/about?fields=storageQuota(limit,usage)`);
    return { limitBytes: a.storageQuota?.limit ? Number(a.storageQuota.limit) : null, usageBytes: Number(a.storageQuota?.usage ?? 0) };
  }

  async stream(refreshToken: string, fileId: string, opts: { thumbnail: boolean; range?: string | null }): Promise<Response> {
    if (opts.thumbnail) {
      const f = await this.getFile(refreshToken, fileId);
      if (!f?.thumbnailLink) return new Response(null, { status: 404 });
      // Drive thumbnails default to 220 px; ask for a size that looks sharp on a venue screen.
      const url = f.thumbnailLink.replace(/=s\d+$/, "=s1600");
      return this.call(refreshToken, url);
    }
    return this.call(refreshToken, `${API}/files/${encodeURIComponent(fileId)}?alt=media`, { headers: opts.range ? { range: opts.range } : {} });
  }
}

/** In-memory store for tests and local development without Google. */
export class FakeMediaStore implements MediaStore {
  readonly name = "fake";
  readonly files = new Map<string, DriveFile & { anyone?: boolean }>();
  quota: Quota = { limitBytes: 15 * 1024 ** 3, usageBytes: 1024 ** 3 };
  revoked = false;
  sessions: { folderId: string; name: string; mimeType: string; size: number; origin: string }[] = [];

  private check() {
    if (this.revoked) throw new DriveAccessError("Google Drive access was revoked.", true);
  }
  async createFolder(_t: string, name: string, parentId?: string) {
    this.check();
    const id = `folder_${randomUUID().slice(0, 8)}`;
    this.files.set(id, { id, name, mimeType: "application/vnd.google-apps.folder", size: 0, parents: parentId ? [parentId] : [], trashed: false, thumbnailLink: null });
    return { id, url: `https://drive.google.com/drive/folders/${id}` };
  }
  async setLinkSharing(_t: string, folderId: string, anyone: boolean) {
    this.check();
    const f = this.files.get(folderId);
    if (f) f.anyone = anyone;
  }
  async createUploadSession(_t: string, file: { folderId: string; name: string; mimeType: string; size: number }, origin: string) {
    this.check();
    if (this.quota.limitBytes !== null && this.quota.usageBytes + file.size > this.quota.limitBytes) throw new DriveAccessError("The host's Google Drive is full.", false, true);
    this.sessions.push({ ...file, origin });
    return `https://upload.fake-drive.test/session/${this.sessions.length}`;
  }
  /** Test helper: what the browser upload would create. */
  addUploadedFile(folderId: string, file: { name: string; mimeType: string; size: number }): string {
    const id = `file_${randomUUID().slice(0, 8)}`;
    this.files.set(id, { id, ...file, parents: [folderId], trashed: false, thumbnailLink: `https://thumb.fake/${id}=s220` });
    return id;
  }
  async getFile(_t: string, fileId: string) {
    this.check();
    const f = this.files.get(fileId);
    return f && !f.trashed ? f : null;
  }
  async deleteFile(_t: string, fileId: string) {
    this.check();
    this.files.delete(fileId);
  }
  async getQuota() {
    this.check();
    return this.quota;
  }
  async stream(_t: string, fileId: string, opts: { thumbnail: boolean }): Promise<Response> {
    this.check();
    const f = this.files.get(fileId);
    if (!f) return new Response(null, { status: 404 });
    return new Response(opts.thumbnail ? "thumb" : "bytes", { status: 200, headers: { "content-type": opts.thumbnail ? "image/jpeg" : f.mimeType } });
  }
}

// ── OAuth (connect) ─────────────────────────────────────────────────────────

export const DRIVE_SCOPES = "https://www.googleapis.com/auth/drive.file openid email";

/** Signed OAuth state: which user connects Drive for which event; expires in 15 minutes. */
export function signOAuthState(payload: { userId: string; eventId: string }, secret: string, now = Date.now()): string {
  const body = Buffer.from(JSON.stringify({ ...payload, exp: now + 15 * 60_000, n: randomUUID() })).toString("base64url");
  const sig = createHmac("sha256", secret).update(body).digest("base64url");
  return `${body}.${sig}`;
}

export function verifyOAuthState(state: string, secret: string, now = Date.now()): { userId: string; eventId: string } | null {
  const [body, sig] = state.split(".");
  if (!body || !sig) return null;
  const expected = createHmac("sha256", secret).update(body).digest("base64url");
  if (sig.length !== expected.length || !timingSafeEqual(Buffer.from(sig), Buffer.from(expected))) return null;
  try {
    const p = JSON.parse(Buffer.from(body, "base64url").toString("utf8")) as { userId: string; eventId: string; exp: number };
    return p.exp > now ? { userId: p.userId, eventId: p.eventId } : null;
  } catch {
    return null;
  }
}

export function googleAuthUrl(opts: { clientId: string; redirectUri: string; state: string }): string {
  const q = new URLSearchParams({
    client_id: opts.clientId,
    redirect_uri: opts.redirectUri,
    response_type: "code",
    scope: DRIVE_SCOPES,
    access_type: "offline",
    prompt: "consent",
    include_granted_scopes: "true",
    state: opts.state,
  });
  return `https://accounts.google.com/o/oauth2/v2/auth?${q}`;
}

export interface GoogleOAuth {
  exchange(code: string): Promise<{ refreshToken: string; email: string; scopes: string }>;
}

export class GoogleOAuthClient implements GoogleOAuth {
  constructor(
    private readonly opts: { clientId: string; clientSecret: string; redirectUri: string },
    private readonly fetchImpl: Fetch = fetch,
  ) {}
  async exchange(code: string) {
    const res = await this.fetchImpl("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: { "content-type": "application/x-www-form-urlencoded" },
      body: new URLSearchParams({ grant_type: "authorization_code", code, client_id: this.opts.clientId, client_secret: this.opts.clientSecret, redirect_uri: this.opts.redirectUri }),
    });
    const json = (await res.json().catch(() => ({}))) as { refresh_token?: string; id_token?: string; scope?: string; error?: string };
    if (!res.ok || !json.refresh_token) throw new DriveAccessError(`Google sign-in failed: ${json.error ?? "no refresh token"}`, false);
    if (!(json.scope ?? "").includes("drive.file")) throw new DriveAccessError("Google Drive permission was not granted.", false);
    const payload = json.id_token ? (JSON.parse(Buffer.from(json.id_token.split(".")[1] ?? "", "base64url").toString("utf8")) as { email?: string }) : {};
    return { refreshToken: json.refresh_token, email: payload.email ?? "", scopes: json.scope ?? DRIVE_SCOPES };
  }
}

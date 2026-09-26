// Every environment key D-Card uses, grouped by provider.
// Keep in sync with the root `.env.example` (enforced by test/env-example.test.ts).

/** Values starting with this prefix are placeholders the owner still has to replace. */
export const DUMMY_PREFIX = "dummy_";

export type KeySpec = {
  key: string;
  /** Required keys must be present (dummy values are allowed until the provider is used). */
  required: boolean;
  /** Optional format check applied to non-dummy values. */
  pattern?: RegExp;
  description: string;
};

export type ProviderGroup = {
  id: string;
  name: string;
  /** Where the owner obtains these values. */
  source: string;
  keys: KeySpec[];
};

const req = (key: string, description: string, pattern?: RegExp): KeySpec => ({
  key,
  required: true,
  description,
  ...(pattern ? { pattern } : {}),
});
const opt = (key: string, description: string, pattern?: RegExp): KeySpec => ({
  key,
  required: false,
  description,
  ...(pattern ? { pattern } : {}),
});

const URL_PATTERN = /^https?:\/\/\S+$/;

export const ENV_GROUPS: ProviderGroup[] = [
  {
    id: "core",
    name: "Core platform",
    source: "Local: infra/docker-compose.yml. Production: Neon (database), Railway/Redis Cloud (Redis), Vercel (APP_URL).",
    keys: [
      req("APP_URL", "Public base URL of the web app and API", URL_PATTERN),
      req("DATABASE_URL", "Postgres connection string (Neon pooled URL in production)", /^postgres(ql)?:\/\/\S+$/),
      opt("DATABASE_URL_UNPOOLED", "Direct (non-pooled) Postgres URL for migrations on Neon", /^postgres(ql)?:\/\/\S+$/),
      req("REDIS_URL", "Redis connection string for BullMQ", /^rediss?:\/\/\S+$/),
      req("AUTH_VERIFIER", "firebase (real), dev (local: fake: tokens + real Firebase) or fake (tests only); dev/fake are refused in production", /^(firebase|dev|fake)$/),
      req("TOKEN_HASH_SECRET", "Secret for hashing card QR/link tokens (32+ random chars)", /^.{32,}$/),
      req("DATA_ENCRYPTION_KEY", "Base64 32-byte key encrypting Google refresh tokens at rest", /^[A-Za-z0-9+/]{43}=$/),
      opt("DCARD_PG_PORT", "Local Postgres host port (default 55432)", /^\d+$/),
      opt("DCARD_REDIS_PORT", "Local Redis host port (default 56379)", /^\d+$/),
      opt("QUEUE_PREFIX", "BullMQ key prefix (default dcard; tests use unique prefixes)", /^[a-z0-9_-]+$/),
      req(
        "API_KEYS",
        "Client API keys accepted in the X-API-Key header, as client:key pairs (e.g. web:…,mobile:…,door:…,tools:…); 32+ chars each",
        /^[a-z]+:[A-Za-z0-9_-]{32,}(,[a-z]+:[A-Za-z0-9_-]{32,})*$/,
      ),
      req("WORKER_API_KEY", "The worker: key from API_KEYS; the worker uses it to fetch card images for WhatsApp", /^[A-Za-z0-9_-]{32,}$/),
      req("NEXT_PUBLIC_DCARD_API_KEY", "The web app's own key (the web: entry of API_KEYS); public in the browser", /^[A-Za-z0-9_-]{32,}$/),
    ],
  },
  {
    id: "firebase",
    name: "Firebase (Auth + FCM)",
    source: "Firebase console → Project settings → Service accounts (admin) and General → Your apps (web).",
    keys: [
      req("FIREBASE_PROJECT_ID", "Firebase project ID"),
      req("FIREBASE_CLIENT_EMAIL", "Service account client email", /^\S+@\S+$/),
      req("FIREBASE_PRIVATE_KEY", "Service account private key (\\n-escaped)", /BEGIN PRIVATE KEY/),
      req("NEXT_PUBLIC_FIREBASE_API_KEY", "Web app API key"),
      req("NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN", "Web app auth domain"),
      req("NEXT_PUBLIC_FIREBASE_PROJECT_ID", "Web app project ID"),
      req("NEXT_PUBLIC_FIREBASE_APP_ID", "Web app ID"),
    ],
  },
  {
    id: "whatsapp",
    name: "Meta WhatsApp Cloud API",
    source: "Meta for Developers → your app → WhatsApp → API Setup; webhook secret under App settings → Basic.",
    keys: [
      req("WHATSAPP_ACCESS_TOKEN", "System-user access token"),
      req("WHATSAPP_PHONE_NUMBER_ID", "Phone number ID of the D-Card WhatsApp number", /^\d+$/),
      req("WHATSAPP_BUSINESS_ACCOUNT_ID", "WhatsApp Business Account ID", /^\d+$/),
      req("WHATSAPP_APP_SECRET", "App secret used to verify X-Hub-Signature-256 on webhooks"),
      req("WHATSAPP_WEBHOOK_VERIFY_TOKEN", "Token you choose; entered in the Meta webhook setup"),
      opt("WHATSAPP_LIVE", "true = send real WhatsApp messages; anything else holds them without calling Meta. Set true in production only.", /^(true|false)$/),
      req("WHATSAPP_API_VERSION", "Graph API version, e.g. v23.0", /^v\d+\.\d+$/),
    ],
  },
  {
    id: "nextsms",
    name: "NextSMS",
    source: "NextSMS dashboard → API; sender ID after registration; webhook token under Customer Info → Customization → Webhooks.",
    keys: [
      req("NEXTSMS_BASE_URL", "API base URL", URL_PATTERN),
      req("NEXTSMS_API_TOKEN", "Basic auth token: Base64 of username:password (sent as Authorization: Basic …)"),
      req("NEXTSMS_SENDER_ID", "Registered sender ID (e.g. DCARD)"),
      opt("NEXTSMS_LIVE", "true = deliver real SMS; anything else uses the NextSMS test endpoint (no delivery). Set true in production only.", /^(true|false)$/),
      req("NEXTSMS_WEBHOOK_VERIFY_TOKEN", "Verify token for an optional delivery callback (not in the public API docs; delivery status is polled from /api/sms/v1/logs)"),
    ],
  },
  {
    id: "google",
    name: "Google Drive (host media)",
    source: "Google Cloud console → APIs & Services → Credentials → OAuth client (Web). Enable the Drive API.",
    keys: [
      req("GOOGLE_OAUTH_CLIENT_ID", "OAuth client ID", /\.apps\.googleusercontent\.com$/),
      req("GOOGLE_OAUTH_CLIENT_SECRET", "OAuth client secret"),
      req("GOOGLE_OAUTH_REDIRECT_URI", "OAuth redirect URI registered on the client", URL_PATTERN),
    ],
  },
  {
    id: "snippe",
    name: "Snippe payments",
    source: "Snippe Dashboard → Settings → API Keys (scopes collection:read, collection:create) and Settings → Webhook Secret.",
    keys: [
      req("SNIPPE_BASE_URL", "API base URL", URL_PATTERN),
      req("SNIPPE_API_KEY", "API key", /^snp_\S+$/),
      req("SNIPPE_WEBHOOK_SECRET", "Webhook signing secret (separate from the API key)"),
    ],
  },
  {
    id: "email",
    name: "Email (Resend)",
    source: "resend.com → API Keys; verify your sending domain (SPF/DKIM) under Domains.",
    keys: [
      req("RESEND_API_KEY", "Resend API key", /^re_\S+$/),
      req("EMAIL_FROM", "Sender, e.g. D-Card <noreply@your-domain>", /^.+<\S+@\S+>$|^\S+@\S+$/),
    ],
  },
  {
    id: "spikes",
    name: "Integration spikes (local only)",
    source: "Your own test phone and resources; only used by spikes/*.ts.",
    keys: [
      opt("SPIKE_TEST_PHONE", "Phone that receives test SMS/WhatsApp/USSD (255XXXXXXXXX)", /^255\d{9}$/),
      opt("SPIKE_PUBLIC_WEBHOOK_BASE_URL", "HTTPS tunnel URL forwarding to spikes/webhook-listener.ts", /^https:\/\/\S+$/),
      opt("WHATSAPP_TEST_TEMPLATE", "Approved template name with two quick-reply buttons"),
      opt("WHATSAPP_TEST_TEMPLATE_LANGUAGE", "Template language code, e.g. sw or en"),
      opt("GOOGLE_TEST_REFRESH_TOKEN", "Refresh token of a test Google account (drive.file scope)"),
    ],
  },
];

export const ALL_KEYS: KeySpec[] = ENV_GROUPS.flatMap((g) => g.keys);

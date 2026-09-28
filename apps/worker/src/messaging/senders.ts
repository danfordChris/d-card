// Provider adapters (docs/design/integrations/messaging.md). Both sit behind interfaces so
// tests and unconfigured environments use fakes; no provider code outside this file.

/** `segments`: provider-reported message parts (NextSMS `smsCount`), used for cost. */
export type SentResult = { providerMessageId: string; segments?: number };

/** The provider refused permanently (bad number, template rejected…): do not retry. */
export class PermanentSendError extends Error {}
/** Keys are still placeholders: hold the message instead of retrying. */
export class ProviderNotConfiguredError extends Error {}

export interface SmsSender {
  /** `reference` is our message_log id; NextSMS returns no message id, so delivery is matched by it. */
  send(to: string, text: string, reference: string): Promise<SentResult>;
}

export type SmsDeliveryReport = { messageId: string | null; group: string; doneAt: string | null; description: string | null };

export interface SmsDeliveryLookup {
  /** Latest status for a message we sent with this reference, or null if the provider has no record yet. */
  lookup(reference: string): Promise<SmsDeliveryReport | null>;
}

export type WhatsAppTemplateMessage = {
  to: string;
  templateName: string;
  language: "sw" | "en";
  bodyParams: string[];
  headerImageId?: string;
  confirmPayloads?: string[] | null;
};

export interface WhatsAppSender {
  sendTemplate(message: WhatsAppTemplateMessage): Promise<SentResult>;
  /** Free-form text; Meta only delivers it inside the 24 h customer-service window. */
  sendText(to: string, body: string): Promise<SentResult>;
  uploadImage(png: Uint8Array, fileName: string): Promise<string>;
}

type Fetch = typeof fetch;

async function readError(res: Response): Promise<string> {
  const text = await res.text().catch(() => "");
  return `HTTP ${res.status} ${text.slice(0, 300)}`;
}

/** 4xx other than 408/429 will not succeed on retry. */
const isPermanent = (status: number) => status >= 400 && status < 500 && status !== 408 && status !== 429;

/**
 * Meta returns throughput limits as HTTP 400 with an error code: 130429 (number throughput),
 * 131056 (too many messages to one recipient), 80007 (account rate limit), 4 (app rate limit).
 * These are retried with backoff, never marked failed.
 */
export const META_RETRYABLE_CODES = [130429, 131056, 80007, 4];
export function isMetaPermanent(status: number, message: string): boolean {
  const code = /"code"\s*:\s*(\d+)/.exec(message)?.[1];
  if (code && META_RETRYABLE_CODES.includes(Number(code))) return false;
  return isPermanent(status);
}

/**
 * NextSMS (https://documenter.getpostman.com/view/4680389/SW7dX7JL): Basic auth with Base64
 * `username:password`; send `POST /api/sms/v1/text/single` with `reference`; status by
 * `GET /api/sms/v1/logs?reference=`.
 */
export class NextSmsSender implements SmsSender, SmsDeliveryLookup {
  constructor(
    private readonly opts: { baseUrl: string; token: string; senderId: string; live?: boolean },
    private readonly fetchImpl: Fetch = fetch,
  ) {}

  private url(path: string) {
    return `${this.opts.baseUrl.replace(/\/$/, "")}${path}`;
  }

  private headers(json = true): Record<string, string> {
    return { authorization: `Basic ${this.opts.token}`, accept: "application/json", ...(json ? { "content-type": "application/json" } : {}) };
  }

  async send(to: string, text: string, reference: string): Promise<SentResult> {
    // Only `live` sends reach phones; otherwise NextSMS's test endpoint validates without delivering.
    const res = await this.fetchImpl(this.url(this.opts.live ? "/api/sms/v1/text/single" : "/api/sms/v1/test/text/single"), {
      method: "POST",
      headers: this.headers(),
      body: JSON.stringify({ from: this.opts.senderId, to, text, reference }),
    });
    if (!res.ok) {
      const message = await readError(res);
      throw isPermanent(res.status) ? new PermanentSendError(message) : new Error(message);
    }
    const body = (await res.json()) as { messages?: { status?: { groupName?: string; name?: string; description?: string }; smsCount?: number }[] };
    const first = body.messages?.[0];
    if (!first) throw new Error(`NextSMS response without messages: ${JSON.stringify(body).slice(0, 200)}`);
    // REJECTED_* at submission (no credit, no route, flooding filter, bad number…) will not improve on retry.
    if ((first.status?.groupName ?? "").toUpperCase() === "REJECTED") {
      throw new PermanentSendError(`NextSMS rejected: ${first.status?.name ?? ""} ${first.status?.description ?? ""}`.trim());
    }
    return { providerMessageId: reference, segments: first.smsCount };
  }

  async lookup(reference: string): Promise<SmsDeliveryReport | null> {
    const res = await this.fetchImpl(this.url(`/api/sms/v1/logs?reference=${encodeURIComponent(reference)}`), { headers: this.headers(false) });
    if (!res.ok) throw new Error(`NextSMS logs: ${await readError(res)}`);
    const body = (await res.json()) as { results?: { messageId?: string | number; doneAt?: string; status?: { groupName?: string; description?: string } | null }[] };
    const r = body.results?.[0];
    if (!r?.status?.groupName) return null;
    return {
      messageId: r.messageId === undefined ? null : String(r.messageId),
      group: r.status.groupName.toUpperCase(),
      doneAt: r.doneAt ?? null,
      description: r.status.description ?? null,
    };
  }
}

/** Meta WhatsApp Cloud API (Graph API): template messages and media upload. */
export class MetaWhatsAppSender implements WhatsAppSender {
  constructor(
    private readonly opts: { apiVersion: string; phoneNumberId: string; token: string; baseUrl?: string },
    private readonly fetchImpl: Fetch = fetch,
  ) {}

  private url(path: string) {
    return `${(this.opts.baseUrl ?? "https://graph.facebook.com").replace(/\/$/, "")}/${this.opts.apiVersion}/${this.opts.phoneNumberId}/${path}`;
  }

  async sendTemplate(m: WhatsAppTemplateMessage): Promise<SentResult> {
    const components: unknown[] = [];
    if (m.headerImageId) components.push({ type: "header", parameters: [{ type: "image", image: { id: m.headerImageId } }] });
    if (m.bodyParams.length) components.push({ type: "body", parameters: m.bodyParams.map((text) => ({ type: "text", text })) });
    (m.confirmPayloads ?? []).forEach((payload, index) =>
      components.push({ type: "button", sub_type: "quick_reply", index: String(index), parameters: [{ type: "payload", payload }] }),
    );
    const res = await this.fetchImpl(this.url("messages"), {
      method: "POST",
      headers: { authorization: `Bearer ${this.opts.token}`, "content-type": "application/json" },
      body: JSON.stringify({
        messaging_product: "whatsapp",
        to: m.to,
        type: "template",
        template: { name: m.templateName, language: { code: m.language }, components },
      }),
    });
    if (!res.ok) {
      const message = await readError(res);
      throw isMetaPermanent(res.status, message) ? new PermanentSendError(message) : new Error(message);
    }
    const body = (await res.json()) as { messages?: { id?: string }[] };
    const id = body.messages?.[0]?.id;
    if (!id) throw new Error(`Meta response without message id: ${JSON.stringify(body).slice(0, 200)}`);
    return { providerMessageId: id };
  }

  async sendText(to: string, body: string): Promise<SentResult> {
    const res = await this.fetchImpl(this.url("messages"), {
      method: "POST",
      headers: { authorization: `Bearer ${this.opts.token}`, "content-type": "application/json" },
      body: JSON.stringify({ messaging_product: "whatsapp", to, type: "text", text: { preview_url: false, body } }),
    });
    if (!res.ok) {
      const message = await readError(res);
      throw isMetaPermanent(res.status, message) ? new PermanentSendError(message) : new Error(message);
    }
    const json = (await res.json()) as { messages?: { id?: string }[] };
    const id = json.messages?.[0]?.id;
    if (!id) throw new Error(`Meta response without message id: ${JSON.stringify(json).slice(0, 200)}`);
    return { providerMessageId: id };
  }

  async uploadImage(png: Uint8Array, fileName: string): Promise<string> {
    const form = new FormData();
    form.append("messaging_product", "whatsapp");
    form.append("type", "image/png");
    form.append("file", new Blob([png], { type: "image/png" }), fileName);
    const res = await this.fetchImpl(this.url("media"), { method: "POST", headers: { authorization: `Bearer ${this.opts.token}` }, body: form });
    if (!res.ok) throw new Error(`Meta media upload failed: ${await readError(res)}`);
    const body = (await res.json()) as { id?: string };
    if (!body.id) throw new Error("Meta media upload returned no id");
    return body.id;
  }
}

const notConfigured = (what: string) => new ProviderNotConfiguredError(`${what} is not configured (placeholder keys)`);

export class UnconfiguredSmsSender implements SmsSender, SmsDeliveryLookup {
  send(): Promise<SentResult> {
    return Promise.reject(notConfigured("NextSMS"));
  }
  lookup(): Promise<SmsDeliveryReport | null> {
    return Promise.resolve(null);
  }
}

export class UnconfiguredWhatsAppSender implements WhatsAppSender {
  constructor(private readonly reason = "WhatsApp is not configured (placeholder keys)") {}
  sendTemplate(): Promise<SentResult> {
    return Promise.reject(new ProviderNotConfiguredError(this.reason));
  }
  sendText(): Promise<SentResult> {
    return Promise.reject(new ProviderNotConfiguredError(this.reason));
  }
  uploadImage(): Promise<string> {
    return Promise.reject(new ProviderNotConfiguredError(this.reason));
  }
}

/** Real keys but WHATSAPP_LIVE is not "true": nothing reaches Meta; messages are held with this reason. */
export const WHATSAPP_NOT_LIVE = "WhatsApp live sending is off (set WHATSAPP_LIVE=true in production only)";

const isPlaceholder = (v: string | undefined) => !v || v.startsWith("dummy_");

/** Builds real senders when provider keys are set, placeholders otherwise. */
export function sendersFromEnv(env: NodeJS.ProcessEnv = process.env): { sms: SmsSender & SmsDeliveryLookup; whatsapp: WhatsAppSender } {
  const sms =
    isPlaceholder(env.NEXTSMS_API_TOKEN) || isPlaceholder(env.NEXTSMS_BASE_URL)
      ? new UnconfiguredSmsSender()
      : new NextSmsSender({
          baseUrl: env.NEXTSMS_BASE_URL!,
          token: env.NEXTSMS_API_TOKEN!,
          senderId: env.NEXTSMS_SENDER_ID ?? "DCARD",
          live: env.NEXTSMS_LIVE === "true",
        });
  // Meta has no test endpoint, so without WHATSAPP_LIVE=true nothing is sent (messages are held).
  const whatsapp =
    isPlaceholder(env.WHATSAPP_ACCESS_TOKEN) || isPlaceholder(env.WHATSAPP_PHONE_NUMBER_ID)
      ? new UnconfiguredWhatsAppSender()
      : env.WHATSAPP_LIVE !== "true"
        ? new UnconfiguredWhatsAppSender(WHATSAPP_NOT_LIVE)
        : new MetaWhatsAppSender({ apiVersion: env.WHATSAPP_API_VERSION ?? "v23.0", phoneNumberId: env.WHATSAPP_PHONE_NUMBER_ID!, token: env.WHATSAPP_ACCESS_TOKEN! });
  return { sms, whatsapp };
}

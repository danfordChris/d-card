import { createHmac, timingSafeEqual } from "node:crypto";

// Payment provider behind one interface (docs/design/integrations/snippe.md). Snippe has no
// sandbox, so tests and local development use FakePaymentGateway; SnippeGateway only when
// SNIPPE_LIVE=true (production).

export type ProviderStatus = "pending" | "completed" | "failed" | "expired";

export type CreatePaymentRequest = {
  amount: number;
  idempotencyKey: string;
  webhookUrl: string;
  description: string;
  metadata: Record<string, string>;
  customer: { name: string; email: string; phone?: string | null };
};

export type CreatedPayment = { reference: string; status: ProviderStatus; checkoutUrl: string | null };

export interface PaymentGateway {
  readonly name: string;
  createMobilePayment(req: CreatePaymentRequest & { phone: string }): Promise<CreatedPayment>;
  createSession(req: CreatePaymentRequest & { redirectUrl: string }): Promise<CreatedPayment>;
  /** Current status by reference (payment or session). */
  getStatus(reference: string, method: "mobile" | "session"): Promise<ProviderStatus>;
}

export class PaymentProviderError extends Error {
  constructor(
    message: string,
    readonly retryable: boolean,
  ) {
    super(message);
  }
}

const mapStatus = (s: string | undefined): ProviderStatus => {
  switch ((s ?? "").toLowerCase()) {
    case "completed":
      return "completed";
    case "failed":
    case "voided":
    case "cancelled":
      return "failed";
    case "expired":
      return "expired";
    default:
      return "pending";
  }
};

type Fetch = typeof fetch;

export class SnippeGateway implements PaymentGateway {
  readonly name = "snippe";
  constructor(
    private readonly opts: { baseUrl: string; apiKey: string },
    private readonly fetchImpl: Fetch = fetch,
  ) {}

  private async call(method: string, path: string, body?: unknown, idempotencyKey?: string): Promise<Record<string, unknown>> {
    const res = await this.fetchImpl(`${this.opts.baseUrl.replace(/\/$/, "")}${path}`, {
      method,
      headers: {
        authorization: `Bearer ${this.opts.apiKey}`,
        accept: "application/json",
        ...(body ? { "content-type": "application/json" } : {}),
        ...(idempotencyKey ? { "idempotency-key": idempotencyKey } : {}),
      },
      body: body ? JSON.stringify(body) : undefined,
    });
    const text = await res.text();
    const json = (() => {
      try {
        return JSON.parse(text) as Record<string, unknown>;
      } catch {
        return {};
      }
    })();
    if (!res.ok) {
      const msg = String((json as { message?: unknown }).message ?? text.slice(0, 200));
      throw new PaymentProviderError(`Snippe ${res.status}: ${msg}`, res.status >= 500 || res.status === 429);
    }
    return (json.data as Record<string, unknown>) ?? json;
  }

  async createMobilePayment(req: CreatePaymentRequest & { phone: string }): Promise<CreatedPayment> {
    const [firstname, ...rest] = req.customer.name.trim().split(/\s+/);
    const data = await this.call(
      "POST",
      "/v1/payments",
      {
        payment_type: "mobile",
        details: { amount: req.amount, currency: "TZS" },
        phone_number: req.phone,
        customer: { firstname: firstname || "D-Card", lastname: rest.join(" ") || "Host", email: req.customer.email },
        webhook_url: req.webhookUrl,
        metadata: req.metadata,
      },
      req.idempotencyKey,
    );
    return { reference: String(data.reference), status: mapStatus(data.status as string), checkoutUrl: null };
  }

  async createSession(req: CreatePaymentRequest & { redirectUrl: string }): Promise<CreatedPayment> {
    const data = await this.call(
      "POST",
      "/api/v1/sessions",
      {
        amount: req.amount,
        currency: "TZS",
        customer: { name: req.customer.name, email: req.customer.email, ...(req.customer.phone ? { phone: req.customer.phone } : {}) },
        redirect_url: req.redirectUrl,
        webhook_url: req.webhookUrl,
        description: req.description,
        metadata: req.metadata,
        expires_in: 3600,
      },
      req.idempotencyKey,
    );
    return {
      reference: String(data.reference),
      status: mapStatus(data.status as string),
      checkoutUrl: (data.payment_link_url as string) ?? (data.checkout_url as string) ?? null,
    };
  }

  async getStatus(reference: string, method: "mobile" | "session"): Promise<ProviderStatus> {
    const path = method === "session" ? `/api/v1/sessions/${encodeURIComponent(reference)}` : `/v1/payments/${encodeURIComponent(reference)}`;
    const data = await this.call("GET", path);
    return mapStatus(data.status as string);
  }
}

/**
 * Local/test gateway: records calls and returns pending; tests and the local simulate endpoint
 * decide the outcome. Never touches a real provider.
 */
export class FakePaymentGateway implements PaymentGateway {
  readonly name = "fake";
  readonly calls: { kind: "mobile" | "session"; req: CreatePaymentRequest }[] = [];
  statuses = new Map<string, ProviderStatus>();
  failNext: PaymentProviderError | null = null;
  private n = 0;

  async createMobilePayment(req: CreatePaymentRequest & { phone: string }): Promise<CreatedPayment> {
    return this.create("mobile", req, null);
  }

  async createSession(req: CreatePaymentRequest & { redirectUrl: string }): Promise<CreatedPayment> {
    return this.create("session", req, "https://fake-pay.dcard.test/checkout");
  }

  private async create(kind: "mobile" | "session", req: CreatePaymentRequest, url: string | null): Promise<CreatedPayment> {
    if (this.failNext) {
      const e = this.failNext;
      this.failNext = null;
      throw e;
    }
    this.calls.push({ kind, req });
    const reference = `fake_${kind}_${++this.n}_${req.idempotencyKey}`;
    this.statuses.set(reference, "pending");
    return { reference, status: "pending", checkoutUrl: url ? `${url}/${reference}` : null };
  }

  async getStatus(reference: string): Promise<ProviderStatus> {
    return this.statuses.get(reference) ?? "pending";
  }
}

const isPlaceholder = (v: string | undefined) => !v || v.startsWith("dummy_");

/** Real Snippe only with SNIPPE_LIVE=true and real keys; otherwise the fake gateway. */
export function gatewayFromEnv(env: Record<string, string | undefined> = process.env): PaymentGateway {
  if (env.SNIPPE_LIVE === "true" && !isPlaceholder(env.SNIPPE_API_KEY) && !isPlaceholder(env.SNIPPE_BASE_URL)) {
    return new SnippeGateway({ baseUrl: env.SNIPPE_BASE_URL!, apiKey: env.SNIPPE_API_KEY! });
  }
  return sharedFakeGateway;
}

/** One fake per process so the local "simulate payment" action and status polling agree. */
export const sharedFakeGateway = new FakePaymentGateway();

/** Snippe webhook signature: hex HMAC-SHA256 of `{timestamp}.{raw body}`; timestamps older than 5 min are rejected. */
export function verifySnippeSignature(
  rawBody: string,
  headers: { timestamp: string | null; signature: string | null },
  secret: string | undefined,
  now = Date.now(),
): boolean {
  if (!secret || !headers.timestamp || !headers.signature) return false;
  const ts = Number(headers.timestamp);
  if (!Number.isFinite(ts) || Math.abs(now / 1000 - ts) > 300) return false;
  const expected = createHmac("sha256", secret).update(`${headers.timestamp}.${rawBody}`).digest("hex");
  const given = headers.signature.trim().toLowerCase();
  if (given.length !== expected.length) return false;
  return timingSafeEqual(Buffer.from(given, "hex"), Buffer.from(expected, "hex"));
}

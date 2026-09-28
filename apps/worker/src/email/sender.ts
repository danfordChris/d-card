// docs/design/integrations/email.md — adapter behind an EmailSender interface.

export type EmailMessage = { to: string; subject: string; text: string; html: string };
export type SendResult = { sent: true; providerId: string } | { sent: false; skipped: string };

export interface EmailSender {
  send(message: EmailMessage): Promise<SendResult>;
}

const isDummy = (v: string | undefined) => !v || v.startsWith("dummy_");

/** Resend (POST https://api.resend.com/emails). Skips (does not fail) while the key is missing or a dummy. */
export class ResendEmailSender implements EmailSender {
  constructor(
    private readonly apiKey = process.env.RESEND_API_KEY,
    private readonly from = process.env.EMAIL_FROM,
    private readonly fetchFn: typeof fetch = fetch,
  ) {}

  async send(message: EmailMessage): Promise<SendResult> {
    if (isDummy(this.apiKey)) return { sent: false, skipped: "RESEND_API_KEY is not configured" };
    if (!this.from) return { sent: false, skipped: "EMAIL_FROM is not configured" };
    const res = await this.fetchFn("https://api.resend.com/emails", {
      method: "POST",
      headers: { authorization: `Bearer ${this.apiKey}`, "content-type": "application/json" },
      body: JSON.stringify({ from: this.from, to: [message.to], subject: message.subject, text: message.text, html: message.html }),
    });
    if (!res.ok) {
      // Throwing lets BullMQ retry with backoff.
      throw new Error(`Resend responded ${res.status}: ${await res.text()}`);
    }
    const body = (await res.json()) as { id?: string };
    return { sent: true, providerId: body.id ?? "" };
  }
}

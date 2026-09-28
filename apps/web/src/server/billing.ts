import { gatewayFromEnv, type PaymentGateway } from "@dcard/core";

let gateway: PaymentGateway | null = null;
/** Real Snippe only with SNIPPE_LIVE=true (production); otherwise the shared fake gateway. */
export function paymentGateway(): PaymentGateway {
  gateway ??= gatewayFromEnv();
  return gateway;
}
/** Test helper. */
export function setPaymentGateway(g: PaymentGateway | null): void {
  gateway = g;
}

export function checkoutUrls(eventId: string): { webhookUrl: string; redirectUrl: string } {
  const base = (process.env.APP_URL ?? "http://localhost:3000").replace(/\/$/, "");
  return { webhookUrl: `${base}/api/webhooks/snippe`, redirectUrl: `${base}/events/${eventId}/billing?paid=1` };
}

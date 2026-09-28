// Spike: trigger a 500 TZS USSD push via Snippe and poll until it completes or fails
// (docs/design/integrations/snippe.md). With SPIKE_PUBLIC_WEBHOOK_BASE_URL set, the
// signed webhook also arrives at `pnpm spike:webhooks`.
import { randomBytes } from "node:crypto";
import { env, log, postJson, requireKeys, requireProvider, run } from "./_shared.js";

await run("snippe-ussd", async () => {
  const s = requireProvider(env, "snippe");
  const { SPIKE_TEST_PHONE } = requireKeys(env, ["SPIKE_TEST_PHONE"]);
  const auth = { authorization: `Bearer ${s.SNIPPE_API_KEY}` };
  const idempotencyKey = `spk-${randomBytes(8).toString("hex")}`; // ≤ 30 chars (Snippe rule)
  const webhookBase = env.SPIKE_PUBLIC_WEBHOOK_BASE_URL;
  const body = {
    payment_type: "mobile",
    details: { amount: 500, currency: "TZS" },
    phone_number: SPIKE_TEST_PHONE,
    customer: { firstname: "D-Card", lastname: "Spike", email: "spike@example.com" },
    metadata: { spike: "T00-10" },
    ...(webhookBase?.startsWith("https://") ? { webhook_url: `${webhookBase}/snippe` } : {}),
  };
  const created = (await postJson(`${s.SNIPPE_BASE_URL}/v1/payments`, body, {
    ...auth,
    "idempotency-key": idempotencyKey,
  })) as { data?: { reference?: string } };
  log("payment created — approve the USSD prompt on the phone", created);
  const reference = created.data?.reference;
  if (!reference) throw new Error("No payment reference returned");
  for (let i = 0; i < 24; i++) {
    await new Promise((r) => setTimeout(r, 10_000));
    const status = (await fetch(`${s.SNIPPE_BASE_URL}/v1/payments/${reference}`, { headers: auth }).then((r) =>
      r.json(),
    )) as { data?: { status?: string } };
    log(`status (poll ${i + 1}): ${status.data?.status}`);
    if (status.data?.status === "completed") return log("PASS: payment completed", status);
    if (status.data?.status === "failed" || status.data?.status === "expired") {
      throw new Error(`Payment ${status.data.status}`);
    }
  }
  throw new Error("Payment not completed within 4 minutes");
});

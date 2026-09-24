// Spike: send one SMS via NextSMS and poll its delivery report
// (docs/design/integrations/messaging.md). The delivery webhook also arrives at
// `pnpm spike:webhooks` if the Delivery Callback URL points to your tunnel.
import { env, log, postJson, requireKeys, requireProvider, run } from "./_shared.js";

await run("nextsms-send", async () => {
  const sms = requireProvider(env, "nextsms");
  const { SPIKE_TEST_PHONE } = requireKeys(env, ["SPIKE_TEST_PHONE"]);
  const auth = { authorization: `Bearer ${sms.NEXTSMS_API_TOKEN}` };
  const text = "D-Card test: Kadi yako 005-4827. Maswali: piga Asha 0754 123 456.";
  const res = (await postJson(
    `${sms.NEXTSMS_BASE_URL}/api/sms/v2/text/single`,
    { from: sms.NEXTSMS_SENDER_ID, to: SPIKE_TEST_PHONE, text },
    auth,
  )) as { messages?: { messageId?: string }[] };
  log("send response", res);
  const messageId = res.messages?.[0]?.messageId;
  if (!messageId) throw new Error("No messageId in response");
  for (let i = 0; i < 12; i++) {
    await new Promise((r) => setTimeout(r, 10_000));
    const report = await fetch(`${sms.NEXTSMS_BASE_URL}/api/v2/reports?messageId=${messageId}`, {
      headers: { ...auth, accept: "application/json" },
    }).then((r) => r.json());
    log(`delivery report (poll ${i + 1})`, report);
    if (JSON.stringify(report).includes("DELIVERED")) {
      log("PASS: message delivered");
      return;
    }
  }
  throw new Error("No DELIVERED status within 2 minutes");
});

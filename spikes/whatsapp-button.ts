// Spike: send a template with two quick-reply buttons whose payloads carry a
// per-invitation token. Tap a button on the phone and watch `pnpm spike:webhooks`
// for the webhook containing that payload (docs/design/integrations/messaging.md).
import { randomUUID } from "node:crypto";
import { env, log, postJson, requireKeys, requireProvider, run } from "./_shared.js";

await run("whatsapp-button", async () => {
  const wa = requireProvider(env, "whatsapp");
  const spike = requireKeys(env, ["SPIKE_TEST_PHONE", "WHATSAPP_TEST_TEMPLATE"]);
  const token = randomUUID().slice(0, 12);
  const url = `https://graph.facebook.com/${wa.WHATSAPP_API_VERSION}/${wa.WHATSAPP_PHONE_NUMBER_ID}/messages`;
  const body = {
    messaging_product: "whatsapp",
    to: spike.SPIKE_TEST_PHONE,
    type: "template",
    template: {
      name: spike.WHATSAPP_TEST_TEMPLATE,
      language: { code: env.WHATSAPP_TEST_TEMPLATE_LANGUAGE || "sw" },
      components: [
        { type: "button", sub_type: "quick_reply", index: "0", parameters: [{ type: "payload", payload: `cnf:${token}:yes` }] },
        { type: "button", sub_type: "quick_reply", index: "1", parameters: [{ type: "payload", payload: `cnf:${token}:no` }] },
      ],
    },
  };
  log("sending template", { to: spike.SPIKE_TEST_PHONE, token });
  const res = await postJson(url, body, { authorization: `Bearer ${wa.WHATSAPP_ACCESS_TOKEN}` });
  log("meta response", res);
  log(`PASS when the webhook shows button.payload = cnf:${token}:yes or cnf:${token}:no`);
});

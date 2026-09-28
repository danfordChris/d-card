// Local webhook listener for spikes. Expose it with an HTTPS tunnel
// (e.g. `cloudflared tunnel --url http://localhost:4040`) and set
// SPIKE_PUBLIC_WEBHOOK_BASE_URL to the tunnel URL.
//   /whatsapp  — Meta verification (GET) + events (POST, X-Hub-Signature-256 checked)
//   /nextsms   — delivery callbacks
//   /snippe    — payment webhooks (X-Webhook-Signature checked, 5-minute replay window)
import { createHmac, timingSafeEqual } from "node:crypto";
import { createServer } from "node:http";
import { env, log } from "./_shared.js";

const PORT = Number(env.SPIKE_WEBHOOK_PORT ?? 4040);

function safeEqualHex(a: string, b: string): boolean {
  const x = Buffer.from(a, "hex");
  const y = Buffer.from(b, "hex");
  return x.length === y.length && timingSafeEqual(x, y);
}

createServer((req, res) => {
  const url = new URL(req.url ?? "/", `http://localhost:${PORT}`);
  if (req.method === "GET" && url.pathname === "/whatsapp") {
    const ok = url.searchParams.get("hub.verify_token") === env.WHATSAPP_WEBHOOK_VERIFY_TOKEN;
    log(`whatsapp verification ${ok ? "accepted" : "rejected"}`);
    res.writeHead(ok ? 200 : 403).end(ok ? (url.searchParams.get("hub.challenge") ?? "") : "");
    return;
  }
  const chunks: Buffer[] = [];
  req.on("data", (c: Buffer) => chunks.push(c));
  req.on("end", () => {
    const raw = Buffer.concat(chunks).toString("utf8");
    let signature = "not checked";
    if (url.pathname === "/snippe" && env.SNIPPE_WEBHOOK_SECRET) {
      const ts = String(req.headers["x-webhook-timestamp"] ?? "");
      const sig = String(req.headers["x-webhook-signature"] ?? "");
      const expected = createHmac("sha256", env.SNIPPE_WEBHOOK_SECRET).update(`${ts}.${raw}`).digest("hex");
      const fresh = Math.abs(Date.now() / 1000 - Number(ts)) <= 300;
      signature = safeEqualHex(sig, expected) && fresh ? "valid" : "INVALID";
    }
    if (url.pathname === "/whatsapp" && env.WHATSAPP_APP_SECRET) {
      const sig = String(req.headers["x-hub-signature-256"] ?? "").replace(/^sha256=/, "");
      const expected = createHmac("sha256", env.WHATSAPP_APP_SECRET).update(raw).digest("hex");
      signature = safeEqualHex(sig, expected) ? "valid" : "INVALID";
    }
    let body: unknown = raw;
    try {
      body = JSON.parse(raw);
    } catch {
      // raw text
    }
    log(`${req.method} ${url.pathname} (signature: ${signature})`, body);
    res.writeHead(200, { "content-type": "application/json" }).end('{"received":true}');
  });
}).listen(PORT, () => log(`webhook listener on http://localhost:${PORT}`));

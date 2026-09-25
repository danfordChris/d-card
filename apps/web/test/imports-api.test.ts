import { createTestDatabase } from "@dcard/db/testing";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import writeExcelFile from "write-excel-file/node";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let imports: typeof import("../src/app/api/v1/events/[id]/imports/route");
let copy: typeof import("../src/app/api/v1/events/[id]/imports/copy/route");
let confirm: typeof import("../src/app/api/v1/events/[id]/imports/[jobId]/confirm/route");
let guests: typeof import("../src/app/api/v1/events/[id]/guests/route");
let resetDb: () => Promise<void>;
let target: string;
let past: string;

const HOST = "fake:i-host:host@example.com";
const OTHER = "fake:i-other:other@example.com";
const auth = (t: string) => ({ authorization: `Bearer ${t}` });
const json = (method: string, token: string, body: unknown) =>
  new Request("http://localhost/x", { method, headers: { ...auth(token), "content-type": "application/json" }, body: JSON.stringify(body) });
const upload = (token: string, file: File) => {
  const form = new FormData();
  form.append("file", file);
  return new Request("http://localhost/x", { method: "POST", headers: auth(token), body: form });
};
const ev = (id: string) => ({ params: Promise.resolve({ id }) });
const job = (id: string, jobId: string) => ({ params: Promise.resolve({ id, jobId }) });

async function makeEvent(token: string, title: string) {
  const res = await events.POST(
    json("POST", token, { planKey: "kawaida", eventTypeKey: "wedding", title, startsAt: "2026-12-12T15:00:00+03:00", contactName: "Asha", contactPhone: "0754123456" }),
  );
  return (await res.json()).id as string;
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_imports", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  imports = await import("../src/app/api/v1/events/[id]/imports/route");
  copy = await import("../src/app/api/v1/events/[id]/imports/copy/route");
  confirm = await import("../src/app/api/v1/events/[id]/imports/[jobId]/confirm/route");
  guests = await import("../src/app/api/v1/events/[id]/guests/route");
  ({ resetDb } = await import("../src/server/db"));
  for (const t of [HOST, OTHER]) await me.POST(new Request("http://localhost/x", { method: "POST", headers: auth(t) }));
  target = await makeEvent(HOST, "Target");
  past = await makeEvent(HOST, "Past");
});

afterAll(async () => {
  await resetDb?.();
  await handle?.close();
});

describe("POST /api/v1/events/{id}/imports", () => {
  it("previews an .xlsx upload and imports after confirmation with consent", async () => {
    const buffer = await writeExcelFile([
      ["name", "phone", "card_type", "partner_name"],
      ["Juma", "0713 000 001", "double", "Neema"],
      ["Bad", "123", null, null],
      ["Zawadi", "0713000002", null, null],
    ]).toBuffer();
    const res = await imports.POST(upload(HOST, new File([new Uint8Array(buffer)], "wageni.xlsx")), ev(target));
    expect(res.status).toBe(201);
    const preview = await res.json();
    expect(preview.report).toMatchObject({ total: 3, valid: 2, invalid: [{ row: 3, reason: "invalid_phone" }] });
    const before = await (await guests.GET(new Request("http://localhost/x", { headers: auth(HOST) }), ev(target))).json();
    expect(before.guests).toHaveLength(0);

    expect((await confirm.POST(json("POST", HOST, { consent: false }), job(target, preview.jobId))).status).toBe(422);
    const ok = await confirm.POST(json("POST", HOST, { consent: true }), job(target, preview.jobId));
    expect(ok.status).toBe(200);
    expect(await ok.json()).toEqual({ imported: 2, existing: 0, invalid: 0 });
    expect((await confirm.POST(json("POST", HOST, { consent: true }), job(target, preview.jobId))).status).toBe(409);
  });

  it("rejects a missing file, an unsupported type and other users", async () => {
    const noFile = new Request("http://localhost/x", { method: "POST", headers: auth(HOST), body: new FormData() });
    expect((await imports.POST(noFile, ev(target))).status).toBe(422);
    const pdf = await imports.POST(upload(HOST, new File(["x"], "guests.pdf")), ev(target));
    expect(pdf.status).toBe(422);
    const csv = new File(["name,phone\nA,0713000009\n"], "g.csv");
    expect((await imports.POST(upload(OTHER, csv), ev(target))).status).toBe(403);
  });
});

describe("POST /api/v1/events/{id}/imports/copy", () => {
  it("previews copying from the host's past event; other hosts get 403", async () => {
    await guests.POST(json("POST", HOST, { name: "Mzee Kassim", phone: "0713000050", consent: true }), ev(past));
    const res = await copy.POST(json("POST", HOST, { fromEventId: past }), ev(target));
    expect(res.status).toBe(201);
    expect((await res.json()).report.valid).toBe(1);
    const otherTarget = await makeEvent(OTHER, "Other's event");
    expect((await copy.POST(json("POST", OTHER, { fromEventId: past }), ev(otherTarget))).status).toBe(403);
  });
});

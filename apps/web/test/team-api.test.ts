import { QUEUES } from "@dcard/core";
import { createTestDatabase } from "@dcard/db/testing";
import { Queue } from "bullmq";
import { Redis } from "ioredis";
import { afterAll, beforeAll, describe, expect, it } from "vitest";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let me: typeof import("../src/app/api/v1/me/route");
let events: typeof import("../src/app/api/v1/events/route");
let eventById: typeof import("../src/app/api/v1/events/[id]/route");
let team: typeof import("../src/app/api/v1/events/[id]/team/route");
let invites: typeof import("../src/app/api/v1/events/[id]/team/invites/route");
let invite: typeof import("../src/app/api/v1/events/[id]/team/invites/[inviteId]/route");
let member: typeof import("../src/app/api/v1/events/[id]/team/members/[userId]/route");
let info: typeof import("../src/app/api/v1/invites/[token]/route");
let accept: typeof import("../src/app/api/v1/invites/[token]/accept/route");
let resetDb: () => Promise<void>;
let closeQueues: () => Promise<void>;
let inspectRedis: Redis;
let emailQueue: Queue;
let eventId: string;
let msingiId: string;

const HOST = "fake:t-host:host@example.com";
const ALICE = "fake:t-alice:alice@example.com";
const headers = (t: string) => ({ authorization: `Bearer ${t}`, "content-type": "application/json" });
const r = (method: string, t: string, body?: unknown, url = "http://localhost/x") =>
  new Request(url, { method, headers: headers(t), ...(body !== undefined ? { body: JSON.stringify(body) } : {}) });
const ev = (id: string) => ({ params: Promise.resolve({ id }) });
const tok = (token: string) => ({ params: Promise.resolve({ token }) });

async function makeEvent(planKey: string) {
  const res = await events.POST(
    r("POST", HOST, { planKey, eventTypeKey: "wedding", title: `Harusi ${planKey}`, startsAt: "2026-12-12T15:00:00+03:00", contactName: "Asha", contactPhone: "0754123456" }),
  );
  return (await res.json()).id as string;
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_web_team", { seed: true });
  process.env.DATABASE_URL = handle.url;
  me = await import("../src/app/api/v1/me/route");
  events = await import("../src/app/api/v1/events/route");
  eventById = await import("../src/app/api/v1/events/[id]/route");
  team = await import("../src/app/api/v1/events/[id]/team/route");
  invites = await import("../src/app/api/v1/events/[id]/team/invites/route");
  invite = await import("../src/app/api/v1/events/[id]/team/invites/[inviteId]/route");
  member = await import("../src/app/api/v1/events/[id]/team/members/[userId]/route");
  info = await import("../src/app/api/v1/invites/[token]/route");
  accept = await import("../src/app/api/v1/invites/[token]/accept/route");
  ({ resetDb } = await import("../src/server/db"));
  ({ closeQueues } = await import("../src/server/queue"));
  for (const t of [HOST, ALICE]) await me.POST(r("POST", t));
  eventId = await makeEvent("kawaida");
  msingiId = await makeEvent("msingi");
  inspectRedis = new Redis(process.env.REDIS_URL!, { maxRetriesPerRequest: null });
  emailQueue = new Queue(QUEUES.email, { connection: inspectRedis, prefix: process.env.QUEUE_PREFIX });
});

afterAll(async () => {
  await emailQueue?.obliterate({ force: true });
  await emailQueue?.close();
  await inspectRedis?.quit();
  await closeQueues?.();
  await resetDb?.();
  await handle?.close();
});

describe("team invitations", () => {
  it("host creates a link invite; with an email exactly one team-invite job is queued", async () => {
    const res = await invites.POST(r("POST", HOST, { role: "treasurer", email: "alice@example.com" }), ev(eventId));
    expect(res.status).toBe(201);
    const body = await res.json();
    expect(body.link).toMatch(/^https:\/\/dcard\.test\/invite\/[A-Za-z0-9_-]{40,}$/);
    expect(body.emailQueued).toBe(true);
    const jobs = await emailQueue.getJobs(["waiting", "delayed", "active", "completed", "failed"]);
    expect(jobs.map((j) => [j.name, j.data.to, j.data.link])).toEqual([["team-invite", "alice@example.com", body.link]]);

    const noEmail = await (await invites.POST(r("POST", HOST, { role: "committee" }), ev(eventId))).json();
    expect(noEmail.emailQueued).toBe(false);
    expect(await emailQueue.getJobCounts("waiting", "delayed", "active", "completed", "failed")).toMatchObject({ waiting: 1 });
  });

  it("invitee reads the public info, accepts once (then 410), and gains access to that event only", async () => {
    const { link } = await (await invites.POST(r("POST", HOST, { role: "committee" }), ev(eventId))).json();
    const token = link.split("/").pop();
    const publicInfo = await info.GET(new Request("http://localhost/x"), tok(token));
    expect(await publicInfo.json()).toMatchObject({ eventTitle: "Harusi kawaida", role: "committee" });
    expect((await eventById.GET(r("GET", ALICE), ev(eventId))).status).toBe(403);
    const ok = await accept.POST(r("POST", ALICE), tok(token));
    expect(ok.status).toBe(200);
    expect(await ok.json()).toEqual({ eventId, role: "committee" });
    expect((await eventById.GET(r("GET", ALICE), ev(eventId))).status).toBe(200);
    expect((await eventById.GET(r("GET", ALICE), ev(msingiId))).status).toBe(403);
    expect((await accept.POST(r("POST", ALICE), tok(token))).status).toBe(410);
    expect((await accept.POST(r("POST", ALICE), tok("unknown-token"))).status).toBe(404);
  });

  it("revoked invites return 410; door staff over the Msingi limit returns 409 plan_limit", async () => {
    const created = await (await invites.POST(r("POST", HOST, { role: "walkin_approver" }), ev(eventId))).json();
    const del = await invite.DELETE(r("DELETE", HOST), { params: Promise.resolve({ id: eventId, inviteId: created.invite.id }) });
    expect(del.status).toBe(204);
    expect((await accept.POST(r("POST", ALICE), tok(created.link.split("/").pop()))).status).toBe(410);

    expect((await invites.POST(r("POST", HOST, { role: "door_staff" }), ev(msingiId))).status).toBe(201);
    expect((await invites.POST(r("POST", HOST, { role: "door_staff" }), ev(msingiId))).status).toBe(201);
    const third = await invites.POST(r("POST", HOST, { role: "door_staff" }), ev(msingiId));
    expect(third.status).toBe(409);
    expect((await third.json()).error.code).toBe("plan_limit");
  });

  it("host lists the team and removes a member; others cannot manage", async () => {
    const list = await (await team.GET(r("GET", HOST), ev(eventId))).json();
    const alice = list.members.find((m: { email: string }) => m.email === "alice@example.com");
    expect(alice.role).toBe("committee");
    expect(list.invites.length).toBeGreaterThan(0);
    expect((await team.GET(r("GET", ALICE), ev(eventId))).status).toBe(403);
    expect((await invites.POST(r("POST", ALICE, { role: "committee" }), ev(eventId))).status).toBe(403);
    const url = `http://localhost/x?role=committee`;
    const res = await member.DELETE(r("DELETE", HOST, undefined, url), { params: Promise.resolve({ id: eventId, userId: alice.userId }) });
    expect(res.status).toBe(204);
    expect((await eventById.GET(r("GET", ALICE), ev(eventId))).status).toBe(403);
  });
});

import { EMAIL_JOBS, QUEUES, SYSTEM_JOBS, type PingJobResult, type TeamInviteEmailJob } from "@dcard/core";
import { Queue, QueueEvents } from "bullmq";
import { afterAll, beforeAll, describe, expect, it, vi } from "vitest";
import { ResendEmailSender, type EmailMessage, type EmailSender } from "../src/email/sender.js";
import { teamInviteEmail } from "../src/email/templates.js";
import { createRedis } from "../src/redis.js";
import { startWorkers, type RunningWorkers } from "../src/worker.js";

const prefix = `test_${process.pid}_${Date.now()}`;
const connection = createRedis();
const producer = createRedis();
const eventsConn = createRedis();
const emailEventsConn = createRedis();
const sent: EmailMessage[] = [];
const fakeSender: EmailSender = {
  send: async (m) => {
    sent.push(m);
    return { sent: true, providerId: "fake-1" };
  },
};
let running: RunningWorkers;
let system: Queue;
let email: Queue;
let systemEvents: QueueEvents;
let emailEvents: QueueEvents;
const logs: string[] = [];

const inviteJob: TeamInviteEmailJob = {
  inviteId: "inv-1",
  to: "alice@example.com",
  eventTitle: "Harusi ya Juma & Neema",
  role: "treasurer",
  link: "https://dcard.example/invite/abc",
  language: "sw",
};

beforeAll(async () => {
  running = await startWorkers(connection, (m) => logs.push(m), { emailSender: fakeSender, prefix });
  system = new Queue(QUEUES.system, { connection: producer, prefix });
  email = new Queue(QUEUES.email, { connection: producer, prefix });
  systemEvents = new QueueEvents(QUEUES.system, { connection: eventsConn, prefix });
  emailEvents = new QueueEvents(QUEUES.email, { connection: emailEventsConn, prefix });
  await Promise.all([systemEvents.waitUntilReady(), emailEvents.waitUntilReady()]);
});

afterAll(async () => {
  await Promise.all([systemEvents?.close(), emailEvents?.close()]);
  await Promise.all([system?.obliterate({ force: true }), email?.obliterate({ force: true })]);
  await Promise.all([system?.close(), email?.close()]);
  await running?.close();
  await Promise.all([connection.quit(), producer.quit(), eventsConn.quit(), emailEventsConn.quit()]);
});

describe("worker runtime", () => {
  it("logs worker:ready once connected", () => {
    expect(logs).toContain("worker:ready");
  });

  it("completes a system ping job within 5 seconds", async () => {
    const sentAt = new Date().toISOString();
    const job = await system.add(SYSTEM_JOBS.ping, { sentAt });
    const result = (await job.waitUntilFinished(systemEvents, 5_000)) as PingJobResult;
    expect(result).toMatchObject({ pong: true, sentAt });
  });
});

describe("email", () => {
  it("processes a team-invite job through the sender", async () => {
    const job = await email.add(EMAIL_JOBS.teamInvite, inviteJob);
    expect(await job.waitUntilFinished(emailEvents, 5_000)).toEqual({ sent: true, providerId: "fake-1" });
    expect(sent[0]).toMatchObject({ to: "alice@example.com", subject: "Mwaliko wa kujiunga na Harusi ya Juma & Neema kwenye D-Card" });
    expect(sent[0]?.text).toContain("https://dcard.example/invite/abc");
  });

  it("template puts the guest language first and escapes HTML", () => {
    const en = teamInviteEmail({ ...inviteJob, language: "en", eventTitle: "<b>Party</b>" });
    expect(en.subject).toBe("Invitation to join <b>Party</b> on D-Card");
    expect(en.text.indexOf("You have been invited")).toBeLessThan(en.text.indexOf("Umealikwa"));
    expect(en.html).toContain("&lt;b&gt;Party&lt;/b&gt;");
  });

  it("ResendEmailSender skips with a dummy key and calls Resend with a real one", async () => {
    const skipped = await new ResendEmailSender("dummy_resend_api_key", "D-Card <noreply@x.test>").send({ to: "a@b.c", subject: "s", text: "t", html: "h" });
    expect(skipped).toEqual({ sent: false, skipped: "RESEND_API_KEY is not configured" });
    const fetchFn = vi.fn(async () => new Response(JSON.stringify({ id: "re_123" }), { status: 200 }));
    const result = await new ResendEmailSender("re_live", "D-Card <noreply@x.test>", fetchFn as unknown as typeof fetch).send({
      to: "a@b.c",
      subject: "s",
      text: "t",
      html: "h",
    });
    expect(result).toEqual({ sent: true, providerId: "re_123" });
    const [url, init] = fetchFn.mock.calls[0] as unknown as [string, RequestInit];
    expect(url).toBe("https://api.resend.com/emails");
    expect((init.headers as Record<string, string>).authorization).toBe("Bearer re_live");
    expect(JSON.parse(String(init.body))).toMatchObject({ from: "D-Card <noreply@x.test>", to: ["a@b.c"] });
  });
});

import { QUEUES, SYSTEM_JOBS, type PingJobResult } from "@dcard/core";
import { Queue, QueueEvents } from "bullmq";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createRedis } from "../src/redis.js";
import { startWorkers, type RunningWorkers } from "../src/worker.js";

const connection = createRedis();
const producer = createRedis();
const eventsConn = createRedis();
let running: RunningWorkers;
let queue: Queue;
let events: QueueEvents;
const logs: string[] = [];

beforeAll(async () => {
  running = await startWorkers(connection, (m) => logs.push(m));
  queue = new Queue(QUEUES.system, { connection: producer });
  events = new QueueEvents(QUEUES.system, { connection: eventsConn });
  await events.waitUntilReady();
});

afterAll(async () => {
  await events?.close();
  await queue?.obliterate({ force: true });
  await queue?.close();
  await running?.close();
  await Promise.all([connection.quit(), producer.quit(), eventsConn.quit()]);
});

describe("worker runtime", () => {
  it("logs worker:ready once connected", () => {
    expect(logs).toContain("worker:ready");
  });

  it("completes a system ping job within 5 seconds", async () => {
    const sentAt = new Date().toISOString();
    const job = await queue.add(SYSTEM_JOBS.ping, { sentAt });
    const result = (await job.waitUntilFinished(events, 5_000)) as PingJobResult;
    expect(result).toMatchObject({ pong: true, sentAt });
  });
});

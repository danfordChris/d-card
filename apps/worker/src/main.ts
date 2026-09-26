import { confirmationToken } from "@dcard/core";
import { createDb } from "@dcard/db";
import { fetchCardImage } from "./messaging/card-image.js";
import { sendersFromEnv } from "./messaging/senders.js";
import { pushSenderFromEnv } from "./push/push.js";
import { createRedis } from "./redis.js";
import { startWorkers } from "./worker.js";

const connection = createRedis();
const database = createDb();
const appUrl = process.env.APP_URL;
const running = await startWorkers(connection, console.log, {
  push: { db: database.db, sender: await pushSenderFromEnv() },
  messaging: {
    db: database.db,
    ...sendersFromEnv(),
    appUrl,
    confirmToken: confirmationToken,
    cardImage: (linkToken, language) => fetchCardImage({ appUrl: appUrl ?? "", apiKey: process.env.WORKER_API_KEY ?? "" }, linkToken, language),
  },
});

let stopping = false;
async function shutdown(signal: string): Promise<void> {
  if (stopping) return;
  stopping = true;
  console.log(`worker:stopping (${signal})`);
  await running.close();
  await connection.quit();
  await database.close();
  console.log("worker:stopped");
  process.exit(0);
}

process.on("SIGTERM", () => void shutdown("SIGTERM"));
process.on("SIGINT", () => void shutdown("SIGINT"));

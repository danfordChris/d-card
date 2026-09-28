import { confirmationToken, createLogger } from "@dcard/core";
import { createDb } from "@dcard/db";
import { fetchCardImage } from "./messaging/card-image.js";
import { sendersFromEnv } from "./messaging/senders.js";
import { pushSenderFromEnv } from "./push/push.js";
import { createRedis } from "./redis.js";
import { workerErrorReporter } from "./sentry.js";
import { startWorkers } from "./worker.js";

const connection = createRedis();
const database = createDb();
const appUrl = process.env.APP_URL;
const logger = createLogger({ service: "worker" });
const running = await startWorkers(connection, (msg) => logger(msg), {
  onJobFailed: workerErrorReporter(),
  alertEmail: process.env.ALERT_EMAIL,
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
  logger("worker:stopping", { signal });
  await running.close();
  await connection.quit();
  await database.close();
  logger("worker:stopped");
  process.exit(0);
}

process.on("SIGTERM", () => void shutdown("SIGTERM"));
process.on("SIGINT", () => void shutdown("SIGINT"));

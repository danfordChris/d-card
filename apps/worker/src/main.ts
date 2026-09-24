import { createRedis } from "./redis.js";
import { startWorkers } from "./worker.js";

const connection = createRedis();
const running = await startWorkers(connection);

let stopping = false;
async function shutdown(signal: string): Promise<void> {
  if (stopping) return;
  stopping = true;
  console.log(`worker:stopping (${signal})`);
  await running.close();
  await connection.quit();
  console.log("worker:stopped");
  process.exit(0);
}

process.on("SIGTERM", () => void shutdown("SIGTERM"));
process.on("SIGINT", () => void shutdown("SIGINT"));

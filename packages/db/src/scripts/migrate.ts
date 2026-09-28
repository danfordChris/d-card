import { createDb } from "../client.js";
import { migrate } from "../migrate.js";

const { db, close } = createDb();
try {
  await migrate(db);
  console.log("db:migrate ok");
} finally {
  await close();
}

import { createDb } from "../client.js";
import { seed } from "../seed.js";

const { db, close } = createDb();
try {
  await seed(db);
  console.log("db:seed ok");
} finally {
  await close();
}

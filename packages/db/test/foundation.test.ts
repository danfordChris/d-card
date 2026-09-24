import { count, eq, sql } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { auditLog, eventType, person, plan, seed, userAccount } from "../src/index.js";
import { createTestDatabase } from "../src/testing.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;

/** Drizzle wraps driver errors; assert on the underlying Postgres message. */
async function expectDbError(query: PromiseLike<unknown>, pattern: RegExp): Promise<void> {
  const err = await Promise.resolve(query).then(
    () => undefined,
    (e: unknown) => e,
  );
  expect(err, "query should fail").toBeInstanceOf(Error);
  const cause = (err as Error & { cause?: Error }).cause;
  expect(cause?.message ?? (err as Error).message).toMatch(pattern);
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_db");
});

afterAll(async () => {
  await handle?.close();
});

describe("seed", () => {
  it("is idempotent: 6 event types and 3 plans after two runs", async () => {
    await seed(handle.db);
    await seed(handle.db);
    const [types] = await handle.db.select({ n: count() }).from(eventType);
    const plans = await handle.db.select().from(plan).orderBy(plan.pricePerGuest);
    expect(types?.n).toBe(6);
    expect(plans.map((p) => [p.key, p.pricePerGuest])).toEqual([
      ["msingi", 1000],
      ["kawaida", 1500],
      ["premium", 2000],
    ]);
  });
});

describe("constraints", () => {
  it("rejects duplicate person phones", async () => {
    await handle.db.insert(person).values({ phone: "255754000001", name: "A" });
    await expectDbError(
      handle.db.insert(person).values({ phone: "255754000001", name: "B" }),
      /person_phone_unique/,
    );
  });

  it("rejects phones not in 255 + 9 digits format", async () => {
    await expectDbError(
      handle.db.insert(person).values({ phone: "0754000002", name: "C" }),
      /person_phone_format/,
    );
  });

  it("rejects duplicate firebase_uid", async () => {
    await handle.db.insert(userAccount).values({ firebaseUid: "uid-1", authProvider: "password" });
    await expectDbError(
      handle.db.insert(userAccount).values({ firebaseUid: "uid-1", authProvider: "google" }),
      /user_account_firebase_uid_unique/,
    );
  });
});

describe("audit_log append-only", () => {
  it("blocks UPDATE and DELETE", async () => {
    const [row] = await handle.db
      .insert(auditLog)
      .values({ actorType: "system", action: "test.created", targetType: "test" })
      .returning();
    await expectDbError(
      handle.db.update(auditLog).set({ action: "changed" }).where(eq(auditLog.id, row!.id)),
      /append-only \(UPDATE blocked\)/,
    );
    await expectDbError(
      handle.db.delete(auditLog).where(eq(auditLog.id, row!.id)),
      /append-only \(DELETE blocked\)/,
    );
  });

  it("allows UPDATE only inside a masking transaction", async () => {
    const [row] = await handle.db
      .insert(auditLog)
      .values({ actorType: "system", action: "test.mask", targetType: "test", newValue: { name: "X" } })
      .returning();
    await handle.db.transaction(async (tx) => {
      await tx.execute(sql`select set_config('dcard.audit_mask', 'on', true)`);
      await tx.update(auditLog).set({ newValue: { name: null } }).where(eq(auditLog.id, row!.id));
    });
    const [after] = await handle.db.select().from(auditLog).where(eq(auditLog.id, row!.id));
    expect(after?.newValue).toEqual({ name: null });
  });
});

import { auditLog, eventRole, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import {
  addContributor,
  cancelCard,
  ConflictError,
  ConsentRequiredError,
  createEvent,
  ForbiddenError,
  getContributions,
  getPledge,
  recordPayment,
  updateEvent,
  updatePayment,
  updatePledge,
  ValidationError,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let treasurerId: string;
let committeeId: string;
let kawaida: string;
let msingi: string;

const base = {
  eventTypeKey: "wedding",
  startsAt: new Date("2026-12-12T12:00:00Z"),
  contactName: "Asha",
  contactPhone: "0754123456",
  singleAmount: 50_000,
  doubleAmount: 100_000,
};
const pay = (amount: number, extra: Partial<Parameters<typeof recordPayment>[4]> = {}) => ({ amount, method: "mpesa" as const, paidOn: "2026-10-01", ...extra });
let n = 0;
const contributor = (eventId: string, amount = 50_000, cardType: "single" | "double" = "single", by = hostId) =>
  addContributor(handle.db, by, eventId, { name: `C${++n}`, phone: `07134000${String(n).padStart(2, "0")}`, cardType, amount, consent: true });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_contributions", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "treasurer", "committee"].map((u) => ({ firebaseUid: u, email: `${u}@example.com`, authProvider: "password" as const })))
    .returning({ id: userAccount.id });
  [hostId, treasurerId, committeeId] = users.map((u) => u.id) as [string, string, string];
  kawaida = await createEvent(handle.db, hostId, { ...base, planKey: "kawaida", title: "Kawaida" });
  msingi = await createEvent(handle.db, hostId, { ...base, planKey: "msingi", title: "Msingi" });
  for (const eventId of [kawaida, msingi]) {
    await handle.db.insert(eventRole).values([
      { eventId, userId: treasurerId, role: "treasurer" },
      { eventId, userId: committeeId, role: "committee" },
    ]);
  }
});

afterAll(async () => {
  await handle?.close();
});

describe("addContributor", () => {
  it("needs consent, committee may add, treasurer may not; one pledge per invitation", async () => {
    await expect(addContributor(handle.db, hostId, kawaida, { name: "X", phone: "0713499999", amount: 1, consent: false })).rejects.toBeInstanceOf(ConsentRequiredError);
    await expect(contributor(kawaida, 50_000, "single", treasurerId)).rejects.toBeInstanceOf(ForbiddenError);
    const { pledge } = await contributor(kawaida, 50_000, "single", committeeId);
    expect(pledge).toMatchObject({ status: "not_paid", balance: 50_000, invitationStatus: "pending" });
    await expect(
      addContributor(handle.db, hostId, kawaida, { name: "Again", phone: pledge.phone, amount: 10_000, consent: true }),
    ).rejects.toBeInstanceOf(ConflictError);
    await expect(contributor(kawaida, 0)).rejects.toBeInstanceOf(ValidationError);
  });
});

describe("payments, auto-issue and auto-upgrade", () => {
  it("part payment then final payment issues the card; committee cannot record", async () => {
    const { pledge } = await contributor(kawaida);
    await expect(recordPayment(handle.db, committeeId, kawaida, pledge.id, pay(10_000))).rejects.toBeInstanceOf(ForbiddenError);
    const part = await recordPayment(handle.db, treasurerId, kawaida, pledge.id, pay(20_000, { reference: " QX12 " }));
    expect(part.pledge).toMatchObject({ status: "part_paid", amountPaid: 20_000, balance: 30_000, invitationStatus: "pending" });
    expect(part.payment.reference).toBe("QX12");
    const done = await recordPayment(handle.db, hostId, kawaida, pledge.id, pay(30_000));
    expect(done.pledge).toMatchObject({ status: "fully_paid", balance: 0, invitationStatus: "issued", cardType: "single" });
    expect(done.pledge.cardNumber).toMatch(/^\d{3}-\d{4}$/);
  });

  it("design example: 50k + 50k on Single issues Single after the first 50k; second is extra", async () => {
    const { pledge } = await contributor(kawaida);
    const first = await recordPayment(handle.db, treasurerId, kawaida, pledge.id, pay(50_000));
    expect(first.pledge).toMatchObject({ invitationStatus: "issued", cardType: "single" });
    const second = await recordPayment(handle.db, treasurerId, kawaida, pledge.id, pay(50_000));
    expect(second.pledge).toMatchObject({ cardType: "single", amountPaid: 100_000, amountExtra: 50_000 });
  });

  it("one payment of the Double amount upgrades on Kawaida and issues Double", async () => {
    const { pledge } = await contributor(kawaida);
    const r = await recordPayment(handle.db, treasurerId, kawaida, pledge.id, pay(120_000));
    expect(r.pledge).toMatchObject({ cardType: "double", amountPledged: 100_000, amountExtra: 20_000, invitationStatus: "issued" });
    expect(r.pledge.upgradedAt).not.toBeNull();
    const audits = await handle.db.select().from(auditLog).where(eq(auditLog.targetId, pledge.id));
    expect(audits.map((a) => a.action)).toContain("pledge.auto_upgraded");
  });

  it("no upgrade on Msingi or when the event setting is off; the excess is extra", async () => {
    const m = await contributor(msingi);
    expect((await recordPayment(handle.db, hostId, msingi, m.pledge.id, pay(100_000))).pledge).toMatchObject({ cardType: "single", amountExtra: 50_000 });
    const other = await createEvent(handle.db, hostId, { ...base, planKey: "kawaida", title: "Off" });
    await updateEvent(handle.db, hostId, other, { autoUpgradeEnabled: false });
    const o = await contributor(other);
    expect((await recordPayment(handle.db, hostId, other, o.pledge.id, pay(100_000))).pledge).toMatchObject({ cardType: "single", amountExtra: 50_000 });
  });

  it("refund moves fully_paid back to part_paid and keeps the card; refund > paid is rejected", async () => {
    const { pledge } = await contributor(kawaida);
    await recordPayment(handle.db, hostId, kawaida, pledge.id, pay(50_000));
    await expect(recordPayment(handle.db, hostId, kawaida, pledge.id, pay(60_000, { kind: "refund" }))).rejects.toBeInstanceOf(ValidationError);
    const r = await recordPayment(handle.db, hostId, kawaida, pledge.id, pay(10_000, { kind: "refund", method: "cash" }));
    expect(r.pledge).toMatchObject({ status: "part_paid", amountPaid: 40_000, invitationStatus: "issued" });
    expect(r.payment.amount).toBe(-10_000);
  });

  it("payment edit recomputes and is audited with old/new values", async () => {
    const { pledge } = await contributor(kawaida);
    const { payment } = await recordPayment(handle.db, hostId, kawaida, pledge.id, pay(10_000));
    const r = await updatePayment(handle.db, treasurerId, kawaida, payment.id, { amount: 50_000, reference: "FIX" });
    expect(r.pledge).toMatchObject({ amountPaid: 50_000, invitationStatus: "issued" });
    const [audit] = await handle.db.select().from(auditLog).where(eq(auditLog.targetId, payment.id)).then((a) => a.filter((x) => x.action === "payment.updated"));
    expect(audit!.oldValue).toMatchObject({ amount: 10_000 });
    expect(audit!.newValue).toMatchObject({ amount: 50_000, reference: "FIX" });
  });
});

describe("pledge edits", () => {
  it("edits before issue (issuing if covered), not after; Double → Single is not re-upgraded", async () => {
    const { pledge } = await contributor(kawaida, 100_000, "double");
    await recordPayment(handle.db, hostId, kawaida, pledge.id, pay(60_000));
    await expect(updatePledge(handle.db, committeeId, kawaida, pledge.id, { amount: 1 })).rejects.toBeInstanceOf(ForbiddenError);
    const edited = await updatePledge(handle.db, treasurerId, kawaida, pledge.id, { cardType: "single", amount: 50_000 });
    expect(edited).toMatchObject({ cardType: "single", amountPledged: 50_000, invitationStatus: "issued", amountExtra: 10_000 });
    await expect(updatePledge(handle.db, hostId, kawaida, pledge.id, { amount: 70_000 })).rejects.toBeInstanceOf(ConflictError);
  });
});

describe("dashboard", () => {
  it("totals exclude cancelled pledges from pledged/outstanding but keep their payments", async () => {
    const other = await createEvent(handle.db, hostId, { ...base, planKey: "kawaida", title: "Dash", budgetAmount: 1_000_000 });
    await handle.db.insert(eventRole).values({ eventId: other, userId: treasurerId, role: "treasurer" });
    const a = await contributor(other, 50_000);
    const b = await contributor(other, 80_000);
    const c = await contributor(other, 30_000);
    await recordPayment(handle.db, hostId, other, a.pledge.id, pay(70_000));
    await recordPayment(handle.db, hostId, other, b.pledge.id, pay(20_000));
    await recordPayment(handle.db, hostId, other, b.pledge.id, pay(5_000, { kind: "refund" }));
    await recordPayment(handle.db, hostId, other, c.pledge.id, pay(10_000));
    await cancelCard(handle.db, hostId, other, c.pledge.guestId);
    const { summary, contributors } = await getContributions(handle.db, treasurerId, other);
    expect(summary).toEqual({
      pledged: 130_000,
      collected: 95_000,
      outstanding: 65_000,
      extras: 20_000,
      refunds: 5_000,
      budget: 1_000_000,
      counts: { not_paid: 0, part_paid: 1, fully_paid: 1, cancelled: 1 },
    });
    expect(contributors).toHaveLength(3);
    expect((await getContributions(handle.db, hostId, other, { status: "part_paid" })).contributors.map((x) => x.id)).toEqual([b.pledge.id]);
    const detail = await getPledge(handle.db, treasurerId, other, b.pledge.id);
    expect(detail.payments.map((p) => p.amount)).toEqual([20_000, -5_000]);
  });
});

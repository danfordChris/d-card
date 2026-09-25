import { auditLog, eventRole, invitation, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import {
  addGuest,
  cancelCard,
  cancelEvent,
  ConflictError,
  createEvent,
  decryptSecret,
  encryptSecret,
  ForbiddenError,
  formatCardNumber,
  getCardLink,
  hashToken,
  issueCard,
  reinstateCard,
  updateGuest,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let committeeId: string;
let eventId: string;

const base = { eventTypeKey: "wedding", startsAt: new Date("2026-12-12T12:00:00Z"), contactName: "Asha", contactPhone: "0754123456" };

async function guest(phone: string, cardType: "single" | "double" = "single") {
  const { guest } = await addGuest(handle.db, hostId, eventId, { name: `G ${phone}`, phone, cardType, consent: true });
  return guest.id;
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_cards", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "committee"].map((u) => ({ firebaseUid: u, email: `${u}@example.com`, authProvider: "password" as const })))
    .returning({ id: userAccount.id });
  [hostId, committeeId] = users.map((u) => u.id) as [string, string];
  eventId = await createEvent(handle.db, hostId, { ...base, planKey: "kawaida", title: "Harusi" });
  await handle.db.insert(eventRole).values({ eventId, userId: committeeId, role: "committee" });
});

afterAll(async () => {
  await handle?.close();
});

describe("secrets", () => {
  it("round-trips and detects tampering", () => {
    const sealed = encryptSecret("hello");
    expect(sealed).toMatch(/^v1\./);
    expect(decryptSecret(sealed)).toBe("hello");
    const parts = sealed.split(".");
    parts[3] = Buffer.from("x").toString("base64url");
    expect(() => decryptSecret(parts.join("."))).toThrow();
  });
});

describe("issueCard", () => {
  it("formats card numbers", () => {
    expect(formatCardNumber(5, 482)).toBe("005-0482");
    expect(formatCardNumber(1234, 9999)).toBe("1234-9999");
  });

  it("issues with a card number and hashed + encrypted tokens; host only", async () => {
    const id = await guest("0713200001", "double");
    await expect(issueCard(handle.db, committeeId, eventId, id)).rejects.toBeInstanceOf(ForbiddenError);
    const card = await issueCard(handle.db, hostId, eventId, id);
    expect(card.status).toBe("issued");
    expect(card.cardNumber).toMatch(/^001-\d{4}$/);
    const [row] = await handle.db.select().from(invitation).where(eq(invitation.id, id));
    const link = decryptSecret(row!.linkTokenEnc!);
    expect(row!.linkTokenHash).toBe(hashToken(link));
    expect(row!.qrTokenHash).toBe(hashToken(decryptSecret(row!.qrTokenEnc!)));
    expect(link.length).toBeGreaterThanOrEqual(43);
    await expect(issueCard(handle.db, hostId, eventId, id)).rejects.toBeInstanceOf(ConflictError);
  });

  it("assigns unique sequences under concurrency", async () => {
    const ids = await Promise.all(Array.from({ length: 12 }, (_, i) => guest(`07132001${String(i + 10).padStart(2, "0")}`)));
    const cards = await Promise.all(ids.map((id) => issueCard(handle.db, hostId, eventId, id)));
    const seqs = cards.map((c) => c.cardNumber!.split("-")[0]);
    expect(new Set(seqs).size).toBe(12);
  });

  it("blocks card type changes after issue (service and trigger)", async () => {
    const id = await guest("0713200002");
    await issueCard(handle.db, hostId, eventId, id);
    await expect(updateGuest(handle.db, hostId, eventId, id, { cardType: "double" })).rejects.toBeInstanceOf(ConflictError);
    const err = await handle.db
      .update(invitation)
      .set({ cardType: "double", totalEntries: 2 })
      .where(eq(invitation.id, id))
      .catch((e: Error & { cause?: Error }) => e);
    expect(String((err as Error & { cause?: Error }).cause?.message ?? err)).toMatch(/cannot change after issue/);
  });
});

describe("cancel, reinstate and link", () => {
  it("keeps number and tokens through cancel/reinstate and audits", async () => {
    const id = await guest("0713200003");
    const issued = await issueCard(handle.db, hostId, eventId, id);
    const before = await getCardLink(handle.db, committeeId, eventId, id);
    expect((await cancelCard(handle.db, hostId, eventId, id)).status).toBe("cancelled");
    await expect(cancelCard(handle.db, hostId, eventId, id)).rejects.toBeInstanceOf(ConflictError);
    const back = await reinstateCard(handle.db, hostId, eventId, id);
    expect(back).toMatchObject({ status: "issued", cardNumber: issued.cardNumber, cancelledAt: null });
    expect((await getCardLink(handle.db, hostId, eventId, id)).linkToken).toBe(before.linkToken);
    const actions = (await handle.db.select().from(auditLog).where(and(eq(auditLog.targetId, id)))).map((a) => a.action);
    expect(actions).toEqual(expect.arrayContaining(["card.issued", "card.cancelled", "card.reinstated"]));
  });

  it("reinstates a never-issued card to pending; link needs a card", async () => {
    const id = await guest("0713200004");
    await cancelCard(handle.db, hostId, eventId, id);
    expect((await reinstateCard(handle.db, hostId, eventId, id)).status).toBe("pending");
    await expect(getCardLink(handle.db, hostId, eventId, id)).rejects.toBeInstanceOf(ConflictError);
    await expect(reinstateCard(handle.db, hostId, eventId, id)).rejects.toBeInstanceOf(ConflictError);
  });

  it("refuses to issue on a cancelled event", async () => {
    const other = await createEvent(handle.db, hostId, { ...base, planKey: "kawaida", title: "Other" });
    const { guest: g } = await addGuest(handle.db, hostId, other, { name: "X", phone: "0713200005", consent: true });
    await cancelEvent(handle.db, hostId, other);
    await expect(issueCard(handle.db, hostId, other, g.id)).rejects.toBeInstanceOf(ConflictError);
  });
});

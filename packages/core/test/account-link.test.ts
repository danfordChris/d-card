import { auditLog, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPaidEvent } from "./helpers.js";
import { addGuest, cancelCard, getCardLink, issueCard, linkCardToAccount, listMyCards } from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let n = 0;

async function account(uid: string) {
  const [a] = await handle.db.insert(userAccount).values({ firebaseUid: uid, email: `${uid}@example.com`, authProvider: "google" }).returning();
  return a!.id;
}
async function card(eventId: string, phone: string, name = "Zawadi") {
  const { guest } = await addGuest(handle.db, hostId, eventId, { name, phone, cardType: "double", consent: true });
  await issueCard(handle.db, hostId, eventId, guest.id);
  return { id: guest.id, token: (await getCardLink(handle.db, hostId, eventId, guest.id)).linkToken };
}
const makeEvent = (startsAt: string) =>
  createPaidEvent(handle.db, hostId, { planKey: "kawaida", eventTypeKey: "wedding", title: `Sherehe ${++n}`, startsAt: new Date(startsAt), contactName: "Asha", contactPhone: "0754123456" });

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_account_link", { seed: true });
  hostId = await account("host");
});

afterAll(async () => {
  await handle?.close();
});

describe("guest account linking (AUTH-4)", () => {
  it("links by card token, lists cards across events, first account wins", async () => {
    const e1 = await makeEvent("2027-02-01T12:00:00Z");
    const e2 = await makeEvent("2027-03-01T12:00:00Z");
    const a = await card(e1, "0716000001");
    const b = await card(e2, "0716000001");
    const other = await card(e2, "0716000002", "Juma");
    const zawadi = await account("zawadi");

    expect(await listMyCards(handle.db, zawadi)).toEqual([]);
    expect(await linkCardToAccount(handle.db, zawadi, a.token)).toMatchObject({ linked: true });
    expect(await linkCardToAccount(handle.db, zawadi, b.token)).toMatchObject({ linked: false }); // same Person
    const cards = await listMyCards(handle.db, zawadi);
    expect(cards.map((c) => c.eventTitle)).toEqual([`Sherehe ${n}`, `Sherehe ${n - 1}`]); // newest event first
    expect(cards[0]).toMatchObject({ guestName: "Zawadi", cardType: "double", status: "issued", rsvpStatus: "none", linkToken: b.token });

    await expect(linkCardToAccount(handle.db, zawadi, other.token)).rejects.toMatchObject({ code: "account_linked" });
    const second = await account("zawadi-2");
    await expect(linkCardToAccount(handle.db, second, a.token)).rejects.toMatchObject({ code: "person_linked" });
    await expect(linkCardToAccount(handle.db, second, "x".repeat(30))).rejects.toMatchObject({ code: "not_found" });
    expect(await handle.db.select().from(auditLog).where(and(eq(auditLog.action, "guest.linked"), eq(auditLog.actorUserId, zawadi)))).toHaveLength(1);

    await cancelCard(handle.db, hostId, e2, b.id);
    expect((await listMyCards(handle.db, zawadi))[0]).toMatchObject({ status: "cancelled" });
  });
});

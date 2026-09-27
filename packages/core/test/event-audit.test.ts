import { auditLog, entry, eventRole, userAccount, walkinRequest } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, eq } from "drizzle-orm";
import { randomUUID } from "node:crypto";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import { createPaidEvent } from "./helpers.js";
import {
  addContributor,
  addGuest,
  buildEventExport,
  csvCell,
  doorAdmit,
  ForbiddenError,
  issueCard,
  listEventAudit,
  NotFoundError,
  recordAudit,
  recordPayment,
  registerDoorDevice,
  summariseChanges,
  toCsv,
  ValidationError,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let treasurerId: string;
let committeeId: string;
let staffId: string;
let strangerId: string;
let eventId: string;
let otherEventId: string;
let ashaId: string;
let barakaId: string;
const gate = randomUUID();

/** Parses our CSV output (quoted cells, CRLF) back into rows for assertions. */
function parseCsv(csv: string): string[][] {
  expect(csv.startsWith("\uFEFF")).toBe(true);
  const text = csv.slice(1);
  const rows: string[][] = [];
  let row: string[] = [];
  let cell = "";
  let quoted = false;
  for (let i = 0; i < text.length; i++) {
    const ch = text[i]!;
    if (quoted) {
      if (ch === '"' && text[i + 1] === '"') {
        cell += '"';
        i++;
      } else if (ch === '"') {
        quoted = false;
      } else {
        cell += ch;
      }
    } else if (ch === '"') {
      quoted = true;
    } else if (ch === ",") {
      row.push(cell);
      cell = "";
    } else if (ch === "\r" && text[i + 1] === "\n") {
      row.push(cell);
      rows.push(row);
      row = [];
      cell = "";
      i++;
    } else {
      cell += ch;
    }
  }
  return rows;
}

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_event_audit", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values(["host", "treasurer", "committee", "staff", "stranger"].map((u) => ({ firebaseUid: `audit-${u}`, email: `${u}@example.com`, authProvider: "password" as const })))
    .returning();
  [hostId, treasurerId, committeeId, staffId, strangerId] = users.map((u) => u.id) as [string, string, string, string, string];
  const input = { planKey: "kawaida", eventTypeKey: "wedding", title: "Harusi ya Asha", startsAt: new Date("2026-12-12T12:00:00Z"), contactName: "Asha", contactPhone: "0754123456" };
  eventId = await createPaidEvent(handle.db, hostId, input);
  otherEventId = await createPaidEvent(handle.db, strangerId, { ...input, title: "Other" });
  await handle.db.insert(eventRole).values([
    { eventId, userId: treasurerId, role: "treasurer" },
    { eventId, userId: committeeId, role: "committee" },
    { eventId, userId: staffId, role: "door_staff" },
  ]);

  // A formula-looking name and a name with a comma and quotes exercise CSV escaping.
  ashaId = (await addGuest(handle.db, hostId, eventId, { name: "=HYPERLINK(\"x\")", phone: "0714300001", consent: true })).guest.id;
  barakaId = (await addGuest(handle.db, hostId, eventId, { name: 'Baraka, "Bob"', phone: "0714300002", cardType: "double", partnerName: "Neema", consent: true })).guest.id;
  await addGuest(handle.db, hostId, eventId, { name: "Chausiku", phone: "0714300003", consent: true });
  await issueCard(handle.db, hostId, eventId, ashaId);
  await issueCard(handle.db, hostId, eventId, barakaId);

  const { pledge } = await addContributor(handle.db, hostId, eventId, { name: "Daudi", phone: "0714300004", amount: 50_000, consent: true });
  await recordPayment(handle.db, treasurerId, eventId, pledge.id, { amount: 20_000, method: "mpesa", paidOn: "2026-11-01" });

  await registerDoorDevice(handle.db, staffId, { eventId, deviceId: gate, name: "Gate A" });
  await doorAdmit(handle.db, staffId, { id: randomUUID(), deviceId: gate, invitationId: barakaId, admittedCount: 2, method: "qr" });
  const walkInId = randomUUID();
  const at = new Date("2026-12-12T13:30:00Z");
  await handle.db.insert(walkinRequest).values({ id: walkInId, eventId, staffUserId: staffId, deviceId: gate, description: "Uncle Juma", admittedCount: 1, status: "approved", occurredAt: at });
  await handle.db.insert(entry).values({ id: randomUUID(), eventId, walkinRequestId: walkInId, admittedCount: 1, method: "name", staffUserId: staffId, deviceId: gate, occurredAt: at });

  await recordAudit(handle.db, { actorUserId: strangerId, eventId: otherEventId, action: "guest.added", targetType: "invitation" });
});

afterAll(async () => {
  await handle?.close();
});

describe("listEventAudit", () => {
  it("lets the host and treasurer read the event trail, newest first, with actor names", async () => {
    for (const userId of [hostId, treasurerId]) {
      const page = await listEventAudit(handle.db, userId, eventId, { limit: 200 });
      expect(page.entries.length).toBeGreaterThan(5);
      const times = page.entries.map((e) => e.createdAt.getTime());
      expect([...times].sort((a, b) => b - a)).toEqual(times);
      const added = page.entries.find((e) => e.action === "guest.added");
      expect(added).toMatchObject({ actorType: "user", actorName: "host@example.com", targetType: "invitation" });
      expect(page.entries.some((e) => e.action === "payment.recorded" && e.actorName === "treasurer@example.com")).toBe(true);
    }
  });

  it("refuses committee, door staff and strangers; unknown events are not found", async () => {
    for (const userId of [committeeId, staffId, strangerId]) {
      await expect(listEventAudit(handle.db, userId, eventId)).rejects.toBeInstanceOf(ForbiddenError);
    }
    await expect(listEventAudit(handle.db, hostId, randomUUID())).rejects.toBeInstanceOf(NotFoundError);
  });

  it("only shows entries of this event", async () => {
    const page = await listEventAudit(handle.db, hostId, eventId, { limit: 200 });
    expect(page.entries.every((e) => e.actorName !== "stranger@example.com")).toBe(true);
  });

  it("filters by action group or exact action and rejects malformed filters", async () => {
    const guests = await listEventAudit(handle.db, hostId, eventId, { action: "guest" });
    expect(guests.entries.length).toBe(4); // three added + the contributor's guest
    expect(guests.entries.every((e) => e.action.startsWith("guest."))).toBe(true);
    const cards = await listEventAudit(handle.db, hostId, eventId, { action: "card.issued" });
    expect(cards.entries.map((e) => e.action)).toEqual(["card.issued", "card.issued"]);
    const withDot = await listEventAudit(handle.db, hostId, eventId, { action: "card." });
    expect(withDot.entries.length).toBe(2);
    expect((await listEventAudit(handle.db, hostId, eventId, { action: "gues" })).entries).toEqual([]);
    await expect(listEventAudit(handle.db, hostId, eventId, { action: "guest%" })).rejects.toBeInstanceOf(ValidationError);
  });

  it("paginates with a cursor without repeats or gaps", async () => {
    const all = await listEventAudit(handle.db, hostId, eventId, { limit: 200 });
    const seen: string[] = [];
    let cursor: string | null = null;
    do {
      const page: Awaited<ReturnType<typeof listEventAudit>> = await listEventAudit(handle.db, hostId, eventId, { limit: 3, cursor });
      expect(page.entries.length).toBeLessThanOrEqual(3);
      seen.push(...page.entries.map((e) => e.id));
      cursor = page.nextCursor;
    } while (cursor);
    expect(seen).toEqual(all.entries.map((e) => e.id));
    await expect(listEventAudit(handle.db, hostId, eventId, { cursor: "bogus" })).rejects.toBeInstanceOf(ValidationError);
  });

  it("summarises changed fields only", () => {
    expect(summariseChanges({ status: "yes", source: "host" }, { status: "no", source: "host", note: "x" })).toEqual([
      { field: "status", from: "yes", to: "no" },
      { field: "note", from: null, to: "x" },
    ]);
    expect(summariseChanges(null, { amount: 5 })).toEqual([{ field: "amount", from: null, to: "5" }]);
    expect(summariseChanges(null, null)).toEqual([]);
    expect(summariseChanges(null, "masked")).toEqual([{ field: "value", from: null, to: "masked" }]);
  });
});

describe("CSV writer", () => {
  it("escapes quotes, commas and newlines and neutralises formulas", () => {
    expect(csvCell('a "b", c')).toBe('"a ""b"", c"');
    expect(csvCell("line1\nline2")).toBe('"line1\nline2"');
    for (const start of ["=", "+", "-", "@"]) expect(csvCell(`${start}1+1`)).toBe(`'${start}1+1`);
    expect(csvCell("=A1,B1")).toBe(`"'=A1,B1"`);
    expect(csvCell(-500)).toBe("-500");
    expect(csvCell(null)).toBe("");
    expect(toCsv(["a", "b"], [[1, "x"]])).toBe("\uFEFFa,b\r\n1,x\r\n");
  });
});

describe("buildEventExport", () => {
  it("exports guests for the host with escaped, formula-safe cells and local phones", async () => {
    const out = await buildEventExport(handle.db, hostId, eventId, "guests", { language: "en", now: new Date("2026-10-01T00:00:00Z") });
    expect(out.fileName).toBe("guests-2026-10-01.csv");
    const rows = parseCsv(out.csv);
    expect(rows[0]).toEqual(["Card number", "Name", "Partner", "Phone", "Card type", "Entries", "Card status", "RSVP", "Confirmation", "Dietary needs", "Added"]);
    expect(rows).toHaveLength(5); // header + 4 invitations (incl. the contributor)
    expect(out.rowCount).toBe(4);
    const names = rows.slice(1).map((r) => r[1]);
    expect(names).toContain(`'=HYPERLINK("x")`);
    expect(names).toContain('Baraka, "Bob"');
    const baraka = rows.find((r) => r[1] === 'Baraka, "Bob"')!;
    expect(baraka.slice(2, 7)).toEqual(["Neema", "0714 300 002", "Double", "2", "Issued"]);
    const chausiku = rows.find((r) => r[1] === "Chausiku")!;
    expect(chausiku[0]).toBe("");
    expect(chausiku[6]).toBe("Not issued");
  });

  it("uses Swahili headers by default", async () => {
    const out = await buildEventExport(handle.db, hostId, eventId, "guests");
    expect(out.fileName.startsWith("wageni-")).toBe(true);
    expect(parseCsv(out.csv)[0]![1]).toBe("Jina");
  });

  it("exports contributions for host and treasurer only", async () => {
    const out = await buildEventExport(handle.db, treasurerId, eventId, "contributions", { language: "en" });
    const rows = parseCsv(out.csv);
    expect(rows[0]).toEqual(["Name", "Phone", "Partner", "Card number", "Card type", "Pledged", "Paid", "Balance", "Extra", "Status"]);
    expect(rows[1]).toEqual(["Daudi", "0714 300 004", "", "", "Single", "50000", "20000", "30000", "0", "Part paid"]);
    await expect(buildEventExport(handle.db, hostId, eventId, "contributions")).resolves.toBeTruthy();
    await expect(buildEventExport(handle.db, committeeId, eventId, "contributions")).rejects.toBeInstanceOf(ForbiddenError);
  });

  it("keeps guests and attendance to the host", async () => {
    for (const kind of ["guests", "attendance"] as const) {
      for (const userId of [treasurerId, committeeId, staffId, strangerId]) {
        await expect(buildEventExport(handle.db, userId, eventId, kind)).rejects.toBeInstanceOf(ForbiddenError);
      }
    }
  });

  it("exports attendance per issued card plus walk-ins, in the event time zone", async () => {
    const rows = parseCsv((await buildEventExport(handle.db, hostId, eventId, "attendance", { language: "en" })).csv);
    expect(rows[0]).toEqual(["Type", "Name", "Partner", "Card number", "Card type", "Allowed", "Admitted", "First entry", "Last entry", "Confirmation"]);
    expect(rows).toHaveLength(4); // 2 issued cards + 1 walk-in
    const baraka = rows.find((r) => r[1] === 'Baraka, "Bob"')!;
    expect(baraka[0]).toBe("Card");
    expect(baraka.slice(4, 7)).toEqual(["Double", "2", "2"]);
    expect(baraka[7]).toMatch(/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}$/);
    const asha = rows.find((r) => r[1] === `'=HYPERLINK("x")`)!;
    expect(asha.slice(6, 9)).toEqual(["0", "", ""]);
    expect(rows[3]).toEqual(["Walk-in", "Uncle Juma", "", "", "", "", "1", "2026-12-12 16:30", "2026-12-12 16:30", ""]);
  });

  it("records export.downloaded for each download", async () => {
    await buildEventExport(handle.db, hostId, eventId, "attendance");
    const rows = await handle.db
      .select()
      .from(auditLog)
      .where(and(eq(auditLog.eventId, eventId), eq(auditLog.action, "export.downloaded"), eq(auditLog.actorUserId, hostId)));
    expect(rows.length).toBeGreaterThanOrEqual(1);
    expect(rows.some((r) => (r.newValue as { kind: string }).kind === "attendance")).toBe(true);
    const page = await listEventAudit(handle.db, hostId, eventId, { action: "export" });
    expect(page.entries[0]).toMatchObject({ action: "export.downloaded", targetType: "event" });
    expect(page.entries[0]!.changes.map((c) => c.field)).toEqual(["kind", "rows"]);
  });

  it("rejects unknown kinds", async () => {
    await expect(buildEventExport(handle.db, hostId, eventId, "payments" as never)).rejects.toBeInstanceOf(NotFoundError);
  });
});

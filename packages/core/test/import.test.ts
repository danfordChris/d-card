import { guestConsent, importJob, invitation, userAccount } from "@dcard/db";
import { createTestDatabase } from "@dcard/db/testing";
import { and, count, eq } from "drizzle-orm";
import { afterAll, beforeAll, describe, expect, it } from "vitest";
import writeExcelFile from "write-excel-file/node";
import {
  addGuest,
  ConflictError,
  ConsentRequiredError,
  confirmImport,
  createEvent,
  ForbiddenError,
  parseGuestFile,
  previewCopyFromEvent,
  previewFileImport,
  ValidationError,
} from "../src/index.js";

let handle: Awaited<ReturnType<typeof createTestDatabase>>;
let hostId: string;
let otherHostId: string;
let target: string;
let past: string;
let othersEvent: string;

const base = {
  planKey: "kawaida",
  eventTypeKey: "wedding",
  startsAt: new Date("2026-12-12T12:00:00Z"),
  contactName: "Asha",
  contactPhone: "0754123456",
};

const CSV = [
  "name,phone,card_type,partner_name",
  "Juma Hamisi,0713 000 001,double,Neema",
  "Bad Phone,12345,,",
  "Juma Again,+255713000001,single,",
  ",0713000003,,",
  "Zawadi,713000004,mbili,Salim",
  "Rehema,0713000005,triple,",
  "Existing Guest,0713000099,,",
].join("\n");

beforeAll(async () => {
  handle = await createTestDatabase("dcard_test_core_import", { seed: true });
  const users = await handle.db
    .insert(userAccount)
    .values([{ firebaseUid: "host", authProvider: "password" }, { firebaseUid: "other", authProvider: "password" }])
    .returning({ id: userAccount.id });
  [hostId, otherHostId] = users.map((u) => u.id) as [string, string];
  target = await createEvent(handle.db, hostId, { ...base, title: "Target" });
  past = await createEvent(handle.db, hostId, { ...base, title: "Past" });
  othersEvent = await createEvent(handle.db, otherHostId, { ...base, title: "Not mine" });
  await addGuest(handle.db, hostId, target, { name: "Existing Guest", phone: "0713000099", consent: true });
});

afterAll(async () => {
  await handle?.close();
});

describe("parseGuestFile", () => {
  it("reads CSV and XLSX with Swahili or English headers", async () => {
    const csv = await parseGuestFile(Buffer.from(CSV), "guests.csv");
    expect(csv).toHaveLength(7);
    expect(csv[0]).toEqual({ row: 2, name: "Juma Hamisi", phone: "0713 000 001", cardType: "double", partnerName: "Neema" });
    const xlsx = await writeExcelFile([
      ["Jina", "Simu", "Kadi", "Mwenza"],
      ["Ali", "0713000010", "moja", null],
      ["Amina", 713000011, "double", "Hassan"],
    ]).toBuffer();
    const rows = await parseGuestFile(xlsx, "wageni.xlsx");
    expect(rows.map((r) => [r.row, r.name, r.phone, r.cardType])).toEqual([
      [2, "Ali", "0713000010", "moja"],
      [3, "Amina", "713000011", "double"],
    ]);
  });

  it("rejects unsupported files and missing columns", async () => {
    await expect(parseGuestFile(Buffer.from("x"), "guests.pdf")).rejects.toThrow(ValidationError);
    await expect(parseGuestFile(Buffer.from("foo,bar\n1,2"), "g.csv")).rejects.toThrow(/name.*phone/);
    await expect(parseGuestFile(Buffer.from("not a zip"), "g.xlsx")).rejects.toThrow(ValidationError);
  });
});

describe("file import", () => {
  it("previews without writing: valid, invalid, duplicates and existing", async () => {
    const { jobId, report } = await previewFileImport(handle.db, hostId, target, { name: "guests.csv", buffer: Buffer.from(CSV) });
    expect(report).toEqual({
      total: 7,
      valid: 2,
      invalid: [
        { row: 3, phone: "12345", reason: "invalid_phone" },
        { row: 5, phone: "0713000003", reason: "name_required" },
        { row: 7, phone: "0713000005", reason: "invalid_card_type" },
      ],
      duplicatesInFile: [{ row: 4, phone: "255713000001", firstRow: 2 }],
      existing: [{ row: 8, phone: "255713000099", name: "Existing Guest" }],
    });
    const [n] = await handle.db.select({ n: count() }).from(invitation).where(eq(invitation.eventId, target));
    expect(n?.n).toBe(1); // only the pre-existing guest
    expect(jobId).toMatch(/^[0-9a-f-]{36}$/);
  });

  it("confirm requires consent, creates guests once, records consent source import", async () => {
    const { jobId } = await previewFileImport(handle.db, hostId, target, { name: "guests.csv", buffer: Buffer.from(CSV) });
    await expect(confirmImport(handle.db, hostId, target, jobId, false)).rejects.toThrow(ConsentRequiredError);
    expect(await confirmImport(handle.db, hostId, target, jobId, true)).toEqual({ imported: 2, existing: 0, invalid: 0 });
    await expect(confirmImport(handle.db, hostId, target, jobId, true)).rejects.toThrow(ConflictError);
    const [job] = await handle.db.select().from(importJob).where(eq(importJob.id, jobId));
    expect(job).toMatchObject({ status: "completed", imported: 2 });
    const consents = await handle.db
      .select()
      .from(guestConsent)
      .where(and(eq(guestConsent.eventId, target), eq(guestConsent.source, "import")));
    expect(consents.map((c) => c.guestCount)).toEqual([2]);
    const zawadi = await handle.db.select().from(invitation).where(eq(invitation.guestPhone, "255713000004"));
    expect(zawadi[0]).toMatchObject({ cardType: "double", partnerName: "Salim", totalEntries: 2 });
  });
});

describe("copy from past event", () => {
  it("copies people from the host's own past event, skipping already-invited", async () => {
    await addGuest(handle.db, hostId, past, { name: "Mzee Kassim", phone: "0713000050", cardType: "double", partnerName: "Bi Mwanaisha", consent: true });
    await addGuest(handle.db, hostId, past, { name: "Juma Hamisi", phone: "0713000001", consent: true });
    const { jobId, report } = await previewCopyFromEvent(handle.db, hostId, target, past);
    expect(report.valid).toBe(1);
    expect(report.existing.map((e) => e.phone)).toEqual(["255713000001"]);
    expect(await confirmImport(handle.db, hostId, target, jobId, true)).toMatchObject({ imported: 1 });
    const consents = await handle.db
      .select()
      .from(guestConsent)
      .where(and(eq(guestConsent.eventId, target), eq(guestConsent.source, "copy")));
    expect(consents).toHaveLength(1);
  });

  it("refuses another host's event and the same event", async () => {
    await expect(previewCopyFromEvent(handle.db, hostId, target, othersEvent)).rejects.toThrow(ForbiddenError);
    await expect(previewCopyFromEvent(handle.db, hostId, target, target)).rejects.toThrow(ValidationError);
  });
});

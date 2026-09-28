import { event, importJob, invitation, type ImportReport, type ImportRow } from "@dcard/db";
import { and, eq } from "drizzle-orm";
import Papa from "papaparse";
import { readSheet } from "read-excel-file/node";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole } from "../auth/roles.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { ConflictError, ForbiddenError, NotFoundError, ValidationError } from "../errors.js";
import { normalisePhone } from "../phone/phone.js";
import { addGuestsBulk, ConsentRequiredError } from "./guests.js";

// docs/design/features/guests-and-cards.md (GST-5 Excel/CSV import, GST-7 copy from past event).
// Flow: preview (validation report, nothing written) → confirm with consent → invitations created.

export const MAX_IMPORT_ROWS = 5000;

type RawRow = { row: number; name: string; phone: string; cardType: string; partnerName: string };

const HEADER_ALIASES: Record<keyof Omit<RawRow, "row">, string[]> = {
  name: ["name", "jina", "full name", "jina kamili"],
  phone: ["phone", "simu", "phone number", "namba ya simu"],
  cardType: ["card_type", "card type", "card", "kadi", "aina ya kadi"],
  partnerName: ["partner_name", "partner name", "partner", "mwenza", "jina la mwenza"],
};

function columnIndex(headers: string[]): Record<keyof Omit<RawRow, "row">, number> {
  const normalised = headers.map((h) => h.trim().toLowerCase());
  const find = (aliases: string[]) => normalised.findIndex((h) => aliases.includes(h));
  const index = {
    name: find(HEADER_ALIASES.name),
    phone: find(HEADER_ALIASES.phone),
    cardType: find(HEADER_ALIASES.cardType),
    partnerName: find(HEADER_ALIASES.partnerName),
  };
  if (index.name < 0 || index.phone < 0) {
    throw new ValidationError("The file must have 'name' and 'phone' columns (see the template).", [
      { path: "file", message: "Missing name/phone columns." },
    ]);
  }
  return index;
}

const cell = (value: unknown) => (value === null || value === undefined ? "" : String(value).trim());

function toRawRows(table: unknown[][]): RawRow[] {
  const [header, ...body] = table;
  if (!header) return [];
  const idx = columnIndex(header.map(cell));
  return body
    .map((r, i) => ({
      row: i + 2, // spreadsheet row number (header is row 1)
      name: cell(r[idx.name]),
      phone: cell(r[idx.phone]),
      cardType: idx.cardType >= 0 ? cell(r[idx.cardType]) : "",
      partnerName: idx.partnerName >= 0 ? cell(r[idx.partnerName]) : "",
    }))
    .filter((r) => r.name || r.phone);
}

/** Parses an .xlsx or .csv upload into raw rows (first sheet / header row required). */
export async function parseGuestFile(buffer: Buffer, fileName: string): Promise<RawRow[]> {
  const lower = fileName.toLowerCase();
  let rows: RawRow[];
  if (lower.endsWith(".csv")) {
    const parsed = Papa.parse<string[]>(buffer.toString("utf8").replace(/^\uFEFF/, ""), { skipEmptyLines: true });
    rows = toRawRows(parsed.data);
  } else if (lower.endsWith(".xlsx")) {
    try {
      rows = toRawRows((await readSheet(buffer)) as unknown[][]);
    } catch (err) {
      if (err instanceof ValidationError) throw err;
      throw new ValidationError("The file could not be read as an Excel workbook.", [{ path: "file", message: "Unreadable .xlsx." }]);
    }
  } else {
    throw new ValidationError("Upload an .xlsx or .csv file.", [{ path: "file", message: "Unsupported file type." }]);
  }
  if (rows.length > MAX_IMPORT_ROWS) {
    throw new ValidationError(`A file can have at most ${MAX_IMPORT_ROWS} guests.`, [{ path: "file", message: "Too many rows." }]);
  }
  return rows;
}

function parseCardType(value: string): "single" | "double" | null {
  const v = value.trim().toLowerCase();
  if (!v || ["single", "moja", "1"].includes(v)) return "single";
  if (["double", "mbili", "2"].includes(v)) return "double";
  return null;
}

/** Builds the validation report and the rows that would be created. Reads existing invitations only. */
export async function buildImportPreview(
  db: DbExecutor,
  eventId: string,
  raw: RawRow[],
): Promise<{ rows: ImportRow[]; report: ImportReport }> {
  const report: ImportReport = { total: raw.length, valid: 0, invalid: [], duplicatesInFile: [], existing: [] };
  const candidates: ImportRow[] = [];
  const firstSeen = new Map<string, number>();
  for (const r of raw) {
    if (!r.name) {
      report.invalid.push({ row: r.row, phone: r.phone, reason: "name_required" });
      continue;
    }
    let phone: string;
    try {
      phone = normalisePhone(r.phone);
    } catch {
      report.invalid.push({ row: r.row, phone: r.phone, reason: "invalid_phone" });
      continue;
    }
    const cardType = parseCardType(r.cardType);
    if (!cardType) {
      report.invalid.push({ row: r.row, phone: r.phone, reason: "invalid_card_type" });
      continue;
    }
    const first = firstSeen.get(phone);
    if (first !== undefined) {
      report.duplicatesInFile.push({ row: r.row, phone, firstRow: first });
      continue;
    }
    firstSeen.set(phone, r.row);
    candidates.push({
      row: r.row,
      name: r.name.replace(/\s+/g, " "),
      phone,
      cardType,
      partnerName: cardType === "double" && r.partnerName ? r.partnerName : null,
    });
  }
  const invited = new Map(
    (await db.select({ phone: invitation.guestPhone, name: invitation.guestName }).from(invitation).where(eq(invitation.eventId, eventId))).map(
      (i) => [i.phone, i.name],
    ),
  );
  const rows = candidates.filter((c) => {
    const name = invited.get(c.phone);
    if (name !== undefined) {
      report.existing.push({ row: c.row, phone: c.phone, name });
      return false;
    }
    return true;
  });
  report.valid = rows.length;
  return { rows, report };
}

export type ImportPreview = { jobId: string; report: ImportReport };

async function savePreview(
  db: DbExecutor,
  params: {
    actorId: string;
    eventId: string;
    source: "file" | "past_event";
    fileName?: string;
    sourceEventId?: string;
    preview: { rows: ImportRow[]; report: ImportReport };
  },
): Promise<ImportPreview> {
  const [job] = await db
    .insert(importJob)
    .values({
      eventId: params.eventId,
      source: params.source,
      fileName: params.fileName ?? null,
      sourceEventId: params.sourceEventId ?? null,
      rows: params.preview.rows,
      report: params.preview.report,
      total: params.preview.report.total,
      createdBy: params.actorId,
    })
    .returning({ id: importJob.id });
  return { jobId: job!.id, report: params.preview.report };
}

/** Step 1 (file): validates an uploaded file and stores a preview. Host and committee. */
export async function previewFileImport(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  file: { name: string; buffer: Buffer },
): Promise<ImportPreview> {
  await requireEventRole(db, { userId: actorId, eventId, roles: ["committee"] });
  const raw = await parseGuestFile(file.buffer, file.name);
  const preview = await buildImportPreview(db, eventId, raw);
  return savePreview(db, { actorId, eventId, source: "file", fileName: file.name, preview });
}

/** Step 1 (copy): previews copying people from the same host's past event (no pledges or answers). */
export async function previewCopyFromEvent(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  fromEventId: string,
): Promise<ImportPreview> {
  await requireEventRole(db, { userId: actorId, eventId, roles: ["committee"] });
  const [source] = await db.select({ hostUserId: event.hostUserId }).from(event).where(eq(event.id, fromEventId));
  if (!source) throw new NotFoundError("Source event not found.");
  if (source.hostUserId !== actorId) throw new ForbiddenError("You can only copy guests from your own events.");
  if (fromEventId === eventId) throw new ValidationError("Choose a different event.", [{ path: "fromEventId", message: "Same event." }]);
  const guests = await db
    .select({ name: invitation.guestName, phone: invitation.guestPhone, cardType: invitation.cardType, partnerName: invitation.partnerName })
    .from(invitation)
    .where(eq(invitation.eventId, fromEventId));
  const raw: RawRow[] = guests.map((g, i) => ({
    row: i + 1,
    name: g.name,
    phone: g.phone,
    cardType: g.cardType,
    partnerName: g.partnerName ?? "",
  }));
  const preview = await buildImportPreview(db, eventId, raw);
  return savePreview(db, { actorId, eventId, source: "past_event", sourceEventId: fromEventId, preview });
}

/** Step 2: creates invitations for the previewed rows, with one consent record. */
export async function confirmImport(
  db: DbExecutor,
  actorId: string,
  eventId: string,
  jobId: string,
  consent: boolean,
): Promise<{ imported: number; existing: number; invalid: number }> {
  await requireEventRole(db, { userId: actorId, eventId, roles: ["committee"] });
  if (!consent) throw new ConsentRequiredError();
  const [job] = await db.select().from(importJob).where(and(eq(importJob.id, jobId), eq(importJob.eventId, eventId)));
  if (!job) throw new NotFoundError("Import not found.");
  if (job.status !== "previewed") throw new ConflictError("This import was already completed.");
  const result = await addGuestsBulk(db, actorId, eventId, job.rows, {
    consent: true,
    source: job.source === "past_event" ? "copy" : "import",
  });
  await inTransaction(db, async (tx) => {
    const [updated] = await tx
      .update(importJob)
      .set({ status: "completed", imported: result.added.length, completedAt: new Date() })
      .where(and(eq(importJob.id, jobId), eq(importJob.status, "previewed")))
      .returning({ id: importJob.id });
    if (!updated) throw new ConflictError("This import was already completed.");
    await recordAudit(tx, {
      actorUserId: actorId,
      eventId,
      action: "guests.imported",
      targetType: "import_job",
      targetId: jobId,
      newValue: { source: job.source, imported: result.added.length, skipped: result.existing.length + result.invalid.length },
    });
  });
  return { imported: result.added.length, existing: result.existing.length, invalid: result.invalid.length };
}

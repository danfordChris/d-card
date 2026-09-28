import { entry, event, invitation, walkinRequest } from "@dcard/db";
import { and, asc, eq, isNotNull, sql } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole, type EventRoleName } from "../auth/roles.js";
import { getContributions } from "../contributions/contributions.js";
import type { DbExecutor } from "../db-types.js";
import { NotFoundError } from "../errors.js";
import { formatLocalPhone } from "../phone/phone.js";
import { toCsv, type CsvCell } from "./csv.js";

// T06-04 host exports: guests, contributions (CON-10) and attendance as CSV.
// Values come from the host-owned invitation snapshot, so anything masked by retention stays masked.

export const EXPORT_KINDS = ["guests", "contributions", "attendance"] as const;
export type ExportKind = (typeof EXPORT_KINDS)[number];
export type ExportLanguage = "sw" | "en";

export type EventExport = { kind: ExportKind; fileName: string; csv: string; rowCount: number };

/** Who may download each export besides the host. */
const EXPORT_ROLES: Record<ExportKind, readonly EventRoleName[]> = {
  guests: [],
  contributions: ["treasurer"],
  attendance: [],
};

export function isExportKind(value: string): value is ExportKind {
  return (EXPORT_KINDS as readonly string[]).includes(value);
}

const LABELS = {
  sw: {
    file: { guests: "wageni", contributions: "michango", attendance: "mahudhurio" },
    guests: ["Namba ya kadi", "Jina", "Mwenza", "Simu", "Aina ya kadi", "Idadi ya kuingia", "Hali ya kadi", "Jibu la RSVP", "Uthibitisho", "Mahitaji ya chakula", "Aliongezwa"],
    contributions: ["Jina", "Simu", "Mwenza", "Namba ya kadi", "Aina ya kadi", "Ahadi", "Kilicholipwa", "Salio", "Ziada", "Hali"],
    attendance: ["Aina", "Jina", "Mwenza", "Namba ya kadi", "Aina ya kadi", "Nafasi", "Walioingia", "Aliingia kwanza", "Aliingia mwisho", "Uthibitisho"],
    cardType: { single: "Moja", double: "Mbili" },
    cardStatus: { pending: "Haijatolewa", issued: "Imetolewa", cancelled: "Imefutwa" },
    answer: { none: "Hajajibu", yes: "Ndiyo", no: "Hapana" },
    pledge: { not_paid: "Hajalipa", part_paid: "Amelipa sehemu", fully_paid: "Amelipa yote", cancelled: "Imefutwa" },
    row: { card: "Kadi", walkIn: "Bila kadi" },
  },
  en: {
    file: { guests: "guests", contributions: "contributions", attendance: "attendance" },
    guests: ["Card number", "Name", "Partner", "Phone", "Card type", "Entries", "Card status", "RSVP", "Confirmation", "Dietary needs", "Added"],
    contributions: ["Name", "Phone", "Partner", "Card number", "Card type", "Pledged", "Paid", "Balance", "Extra", "Status"],
    attendance: ["Type", "Name", "Partner", "Card number", "Card type", "Allowed", "Admitted", "First entry", "Last entry", "Confirmation"],
    cardType: { single: "Single", double: "Double" },
    cardStatus: { pending: "Not issued", issued: "Issued", cancelled: "Cancelled" },
    answer: { none: "No response", yes: "Yes", no: "No" },
    pledge: { not_paid: "Not paid", part_paid: "Part paid", fully_paid: "Fully paid", cancelled: "Cancelled" },
    row: { card: "Card", walkIn: "Walk-in" },
  },
} as const;

/**
 * Builds one CSV export and records `export.downloaded`. Host for every kind; treasurer for
 * contributions. Headers and labels follow `language`; times use the event time zone.
 */
export async function buildEventExport(
  db: DbExecutor,
  userId: string,
  eventId: string,
  kind: ExportKind,
  options: { language?: ExportLanguage; now?: Date } = {},
): Promise<EventExport> {
  if (!isExportKind(kind)) throw new NotFoundError("Export not found.");
  await requireEventRole(db, { userId, eventId, roles: EXPORT_ROLES[kind] });
  const [ev] = await db.select({ timeZone: event.timeZone }).from(event).where(eq(event.id, eventId));
  if (!ev) throw new NotFoundError("Event not found.");
  const l = LABELS[options.language ?? "sw"];
  const time = timeFormatter(ev.timeZone);
  const rows =
    kind === "guests"
      ? await guestRows(db, eventId, l, time)
      : kind === "contributions"
        ? await contributionRows(db, userId, eventId, l)
        : await attendanceRows(db, eventId, l, time);
  await recordAudit(db, {
    actorUserId: userId,
    eventId,
    action: "export.downloaded",
    targetType: "event",
    targetId: eventId,
    newValue: { kind, rows: rows.length },
  });
  const stamp = (options.now ?? new Date()).toISOString().slice(0, 10);
  return { kind, fileName: `${l.file[kind]}-${stamp}.csv`, csv: toCsv(l[kind], rows), rowCount: rows.length };
}

type Labels = (typeof LABELS)[ExportLanguage];
type TimeFormat = (value: Date | null) => string;

function timeFormatter(timeZone: string): TimeFormat {
  // sv-SE renders "2026-12-12 15:10", which spreadsheets read as a date-time.
  const format = new Intl.DateTimeFormat("sv-SE", { timeZone, year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", minute: "2-digit", hour12: false });
  return (value) => (value ? format.format(value) : "");
}

/** Phones stay in the local "0754 123 456" form: Excel would turn 255XXXXXXXXX into 2.55E+11. */
function phone(stored: string): string {
  try {
    return formatLocalPhone(stored);
  } catch {
    return stored; // masked by retention: keep as stored
  }
}

async function guestRows(db: DbExecutor, eventId: string, l: Labels, time: TimeFormat): Promise<CsvCell[][]> {
  const rows = await db
    .select()
    .from(invitation)
    .where(eq(invitation.eventId, eventId))
    .orderBy(sql`lower(${invitation.guestName})`, asc(invitation.createdAt), asc(invitation.id));
  return rows.map((g) => [
    g.cardNumber,
    g.guestName,
    g.partnerName,
    phone(g.guestPhone),
    l.cardType[g.cardType],
    g.totalEntries,
    l.cardStatus[g.status],
    l.answer[g.rsvpStatus],
    l.answer[g.confirmationStatus],
    g.dietaryNotes,
    time(g.createdAt),
  ]);
}

async function contributionRows(db: DbExecutor, userId: string, eventId: string, l: Labels): Promise<CsvCell[][]> {
  const { contributors } = await getContributions(db, userId, eventId);
  return [...contributors]
    .sort((a, b) => a.name.localeCompare(b.name, "en", { sensitivity: "base" }))
    .map((p) => [
      p.name,
      phone(p.phone),
      p.partnerName,
      p.cardNumber,
      l.cardType[p.cardType],
      p.amountPledged,
      p.amountPaid,
      p.balance,
      p.amountExtra,
      l.pledge[p.invitationStatus === "cancelled" ? "cancelled" : p.status],
    ]);
}

async function attendanceRows(db: DbExecutor, eventId: string, l: Labels, time: TimeFormat): Promise<CsvCell[][]> {
  const [cards, walkIns] = await Promise.all([
    db
      .select({
        guestName: invitation.guestName,
        partnerName: invitation.partnerName,
        cardNumber: invitation.cardNumber,
        cardType: invitation.cardType,
        totalEntries: invitation.totalEntries,
        confirmation: invitation.confirmationStatus,
        admitted: sql<number>`coalesce(sum(${entry.admittedCount}), 0)::int`,
        firstAt: sql<Date | null>`min(${entry.occurredAt})`,
        lastAt: sql<Date | null>`max(${entry.occurredAt})`,
      })
      .from(invitation)
      .leftJoin(entry, eq(entry.invitationId, invitation.id))
      .where(and(eq(invitation.eventId, eventId), sql`(${invitation.status} = 'issued' or ${entry.id} is not null)`))
      .groupBy(invitation.id)
      .orderBy(sql`lower(${invitation.guestName})`, asc(invitation.cardNumber), asc(invitation.id)),
    db
      .select({ description: walkinRequest.description, admitted: entry.admittedCount, at: entry.occurredAt })
      .from(entry)
      .innerJoin(walkinRequest, eq(walkinRequest.id, entry.walkinRequestId))
      .where(and(eq(entry.eventId, eventId), isNotNull(entry.walkinRequestId)))
      .orderBy(asc(entry.occurredAt), asc(entry.id)),
  ]);
  const asDate = (v: Date | string | null) => (v === null ? null : new Date(v));
  return [
    ...cards.map((c) => [
      l.row.card,
      c.guestName,
      c.partnerName,
      c.cardNumber,
      l.cardType[c.cardType],
      c.totalEntries,
      c.admitted,
      time(asDate(c.firstAt)),
      time(asDate(c.lastAt)),
      l.answer[c.confirmation],
    ]),
    ...walkIns.map((w) => [l.row.walkIn, w.description, null, null, null, null, w.admitted, time(w.at), time(w.at), null]),
  ];
}

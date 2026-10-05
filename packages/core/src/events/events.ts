import { event, eventPlan, eventRole, eventType, invitation, plan, pledge, type PlanEntitlements } from "@dcard/db";
import { and, desc, eq, inArray, or, sql } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { requireEventRole, type EventAccess } from "../auth/roles.js";
import { inTransaction, type DbExecutor } from "../db-types.js";
import { ConflictError, NotFoundError, PlanLimitError, ValidationError } from "../errors.js";
import { normalisePhone } from "../phone/phone.js";

// docs/design/features/events.md (EVT-1..3), docs/design/features/plans-and-billing.md

export type EventSettingsInput = {
  confirmationEnabled?: boolean;
  confirmationOffsetDays?: number;
  headcountPct?: number;
  autoUpgradeEnabled?: boolean;
  singleAmount?: number | null;
  doubleAmount?: number | null;
  budgetAmount?: number | null;
  paymentDetails?: string | null;
  reminderFrequencyDays?: number | null;
  photoAlbumUrl?: string | null;
};

export type EventDetailsInput = {
  title?: string;
  startsAt?: Date;
  endsAt?: Date | null;
  timeZone?: string;
  venueName?: string | null;
  venueAddress?: string | null;
  venueMapUrl?: string | null;
  contactName?: string;
  contactPhone?: string;
  contact2Name?: string | null;
  contact2Phone?: string | null;
};

export type CreateEventInput = Required<Pick<EventDetailsInput, "title" | "startsAt" | "contactName" | "contactPhone">> &
  EventDetailsInput &
  EventSettingsInput & { planKey: string; eventTypeKey: string };

export type UpdateEventInput = EventDetailsInput & EventSettingsInput;

export type EventView = {
  id: string;
  title: string;
  status: "draft" | "published" | "completed" | "cancelled";
  eventType: { key: string; nameSw: string; nameEn: string };
  plan: { key: string; name: string; pricePerGuest: number; guestLimit: number; paid: boolean };
  startsAt: Date;
  endsAt: Date | null;
  timeZone: string;
  venueName: string | null;
  venueAddress: string | null;
  venueMapUrl: string | null;
  contactName: string;
  contactPhone: string;
  contact2Name: string | null;
  contact2Phone: string | null;
  confirmationEnabled: boolean;
  confirmationOffsetDays: number;
  headcountPct: number;
  autoUpgradeEnabled: boolean;
  singleAmount: number | null;
  doubleAmount: number | null;
  budgetAmount: number | null;
  paymentDetails: string | null;
  reminderFrequencyDays: number | null;
  photoAlbumUrl: string | null;
  access: EventAccess;
  /** Every role the user holds here (a person can be committee and walk-in approver at once). */
  roles: EventAccess[];
  stats?: { guestCount: number; cardsSent: number; collected: number; confirmed: number };
  createdAt: Date;
  updatedAt: Date;
};

const EDITABLE_STATUSES = new Set(["draft", "published"]);

function checkSettings(input: EventSettingsInput & { startsAt?: Date; endsAt?: Date | null }): void {
  const issues: { path: string; message: string }[] = [];
  if (input.headcountPct !== undefined && (input.headcountPct < 0 || input.headcountPct > 100)) {
    issues.push({ path: "headcountPct", message: "Must be between 0 and 100." });
  }
  if (input.confirmationOffsetDays !== undefined && (input.confirmationOffsetDays < 0 || input.confirmationOffsetDays > 30)) {
    issues.push({ path: "confirmationOffsetDays", message: "Must be between 0 and 30 days." });
  }
  for (const key of ["singleAmount", "doubleAmount", "budgetAmount"] as const) {
    const v = input[key];
    if (v !== undefined && v !== null && (!Number.isInteger(v) || v < 0)) {
      issues.push({ path: key, message: "Must be a whole, non-negative amount in TZS." });
    }
  }
  if (input.startsAt && input.endsAt && input.endsAt < input.startsAt) {
    issues.push({ path: "endsAt", message: "Must be after the start time." });
  }
  if (issues.length > 0) throw new ValidationError("Some fields are invalid.", issues);
}

function normaliseContacts<T extends EventDetailsInput>(input: T): T {
  return {
    ...input,
    ...(input.contactPhone !== undefined ? { contactPhone: normalisePhone(input.contactPhone) } : {}),
    ...(input.contact2Phone ? { contact2Phone: normalisePhone(input.contact2Phone) } : {}),
  };
}

function assertAutoUpgradeAllowed(entitlements: PlanEntitlements, requested: boolean | undefined): void {
  if (requested && !entitlements.autoUpgrade) {
    throw new PlanLimitError("Auto-upgrade is not included in this plan.");
  }
}

/** Creates a draft event with its chosen plan (unpaid). Audited. */
export async function createEvent(db: DbExecutor, hostUserId: string, input: CreateEventInput): Promise<string> {
  const title = input.title.trim();
  if (!title) throw new ValidationError("Some fields are invalid.", [{ path: "title", message: "Required." }]);
  if (!input.contactName.trim()) {
    throw new ValidationError("Some fields are invalid.", [{ path: "contactName", message: "Required." }]);
  }
  checkSettings(input);
  const details = normaliseContacts(input);

  const [chosenPlan] = await db.select().from(plan).where(and(eq(plan.key, input.planKey), eq(plan.active, true)));
  if (!chosenPlan) throw new ValidationError("Some fields are invalid.", [{ path: "planKey", message: "Unknown plan." }]);
  const [type] = await db
    .select()
    .from(eventType)
    .where(and(eq(eventType.key, input.eventTypeKey), eq(eventType.active, true)));
  if (!type) throw new ValidationError("Some fields are invalid.", [{ path: "eventTypeKey", message: "Unknown event type." }]);
  assertAutoUpgradeAllowed(chosenPlan.entitlements, input.autoUpgradeEnabled);

  const run = async (tx: DbExecutor) => {
    const [created] = await tx
      .insert(event)
      .values({
        hostUserId,
        eventTypeId: type.id,
        title,
        startsAt: input.startsAt,
        endsAt: input.endsAt ?? null,
        timeZone: input.timeZone ?? "Africa/Dar_es_Salaam",
        venueName: input.venueName ?? null,
        venueAddress: input.venueAddress ?? null,
        venueMapUrl: input.venueMapUrl ?? null,
        contactName: input.contactName.trim(),
        contactPhone: details.contactPhone,
        contact2Name: input.contact2Name ?? null,
        contact2Phone: details.contact2Phone ?? null,
        confirmationEnabled: input.confirmationEnabled ?? true,
        confirmationOffsetDays: input.confirmationOffsetDays ?? 2,
        headcountPct: input.headcountPct ?? 70,
        autoUpgradeEnabled: input.autoUpgradeEnabled ?? chosenPlan.entitlements.autoUpgrade,
        singleAmount: input.singleAmount ?? null,
        doubleAmount: input.doubleAmount ?? null,
        budgetAmount: input.budgetAmount ?? null,
        paymentDetails: input.paymentDetails?.trim() || null,
        reminderFrequencyDays: input.reminderFrequencyDays ?? null,
        photoAlbumUrl: input.photoAlbumUrl ?? null,
      })
      .returning();
    await tx.insert(eventPlan).values({ eventId: created!.id, planId: chosenPlan.id, pricePerGuest: chosenPlan.pricePerGuest });
    await recordAudit(tx, {
      actorUserId: hostUserId,
      eventId: created!.id,
      action: "event.created",
      targetType: "event",
      targetId: created!.id,
      newValue: { title, plan: chosenPlan.key, eventType: type.key, startsAt: input.startsAt.toISOString() },
    });
    return created!.id;
  };
  return inTransaction(db, run);
}

async function loadEvent(db: DbExecutor, eventId: string) {
  const [row] = await db
    .select({ event, eventType, plan, eventPlan })
    .from(event)
    .innerJoin(eventType, eq(eventType.id, event.eventTypeId))
    .innerJoin(eventPlan, eq(eventPlan.eventId, event.id))
    .innerJoin(plan, eq(plan.id, eventPlan.planId))
    .where(eq(event.id, eventId));
  return row;
}

type EventStats = EventView["stats"];

function toView(
  row: NonNullable<Awaited<ReturnType<typeof loadEvent>>>,
  access: EventAccess,
  roles: EventAccess[] = [access],
  stats?: EventStats,
): EventView {
  const e = row.event;
  return {
    id: e.id,
    title: e.title,
    status: e.status,
    eventType: { key: row.eventType.key, nameSw: row.eventType.nameSw, nameEn: row.eventType.nameEn },
    plan: {
      key: row.plan.key,
      name: row.plan.name,
      pricePerGuest: row.eventPlan.pricePerGuest,
      guestLimit: row.eventPlan.guestLimit,
      paid: row.eventPlan.purchasedAt !== null,
    },
    startsAt: e.startsAt,
    endsAt: e.endsAt,
    timeZone: e.timeZone,
    venueName: e.venueName,
    venueAddress: e.venueAddress,
    venueMapUrl: e.venueMapUrl,
    contactName: e.contactName,
    contactPhone: e.contactPhone,
    contact2Name: e.contact2Name,
    contact2Phone: e.contact2Phone,
    confirmationEnabled: e.confirmationEnabled,
    confirmationOffsetDays: e.confirmationOffsetDays,
    headcountPct: e.headcountPct,
    autoUpgradeEnabled: e.autoUpgradeEnabled,
    singleAmount: e.singleAmount,
    doubleAmount: e.doubleAmount,
    budgetAmount: e.budgetAmount,
    paymentDetails: e.paymentDetails,
    reminderFrequencyDays: e.reminderFrequencyDays,
    photoAlbumUrl: e.photoAlbumUrl,
    access,
    roles,
    stats,
    createdAt: e.createdAt,
    updatedAt: e.updatedAt,
  };
}

const ALL_ROLES = ["treasurer", "committee", "door_staff", "walkin_approver"] as const;

/** Any team member (or the host) can view an event. */
export async function getEvent(db: DbExecutor, userId: string, eventId: string): Promise<EventView> {
  const access = await requireEventRole(db, { userId, eventId, roles: ALL_ROLES });
  const held = await db.select({ role: eventRole.role }).from(eventRole).where(and(eq(eventRole.eventId, eventId), eq(eventRole.userId, userId)));
  const roles = [...new Set<EventAccess>([...(access === "host" ? (["host"] as const) : []), ...held.map((h) => h.role)])];
  const row = await loadEvent(db, eventId);
  if (!row) throw new NotFoundError("Event not found.");
  return toView(row, access, roles.length ? roles : [access]);
}

/** Events where the user is host or holds any event role, newest start first. */
export async function listEvents(db: DbExecutor, userId: string): Promise<EventView[]> {
  const memberships = await db.select({ eventId: eventRole.eventId, role: eventRole.role }).from(eventRole).where(eq(eventRole.userId, userId));
  const memberIds = [...new Set(memberships.map((m) => m.eventId))];
  const rows = await db
    .select({ event, eventType, plan, eventPlan })
    .from(event)
    .innerJoin(eventType, eq(eventType.id, event.eventTypeId))
    .innerJoin(eventPlan, eq(eventPlan.eventId, event.id))
    .innerJoin(plan, eq(plan.id, eventPlan.planId))
    .where(memberIds.length ? or(eq(event.hostUserId, userId), inArray(event.id, memberIds)) : eq(event.hostUserId, userId))
    .orderBy(desc(event.startsAt));

  const eventIds = rows.map((r) => r.event.id);
  const statsMap = eventIds.length > 0 ? await loadEventStats(db, eventIds) : new Map<string, NonNullable<EventStats>>();

  return rows.map((row) => {
    const held = memberships.filter((m) => m.eventId === row.event.id).map((m) => m.role);
    const access: EventAccess = row.event.hostUserId === userId ? "host" : held[0]!;
    return toView(
      row,
      access,
      [...new Set<EventAccess>([...(access === "host" ? (["host"] as const) : []), ...held])],
      statsMap.get(row.event.id),
    );
  });
}

async function loadEventStats(db: DbExecutor, eventIds: string[]): Promise<Map<string, NonNullable<EventStats>>> {
  const [invRows, pledgeRows] = await Promise.all([
    db
      .select({
        eventId: invitation.eventId,
        guestCount: sql<number>`count(*) filter (where ${invitation.status} != 'cancelled')::int`,
        cardsSent: sql<number>`count(*) filter (where ${invitation.status} = 'issued')::int`,
        confirmed: sql<number>`count(*) filter (where ${invitation.confirmationStatus} = 'yes')::int`,
      })
      .from(invitation)
      .where(inArray(invitation.eventId, eventIds))
      .groupBy(invitation.eventId),
    db
      .select({
        eventId: pledge.eventId,
        collected: sql<number>`coalesce(sum(${pledge.amountPaid}), 0)::int`,
      })
      .from(pledge)
      .where(inArray(pledge.eventId, eventIds))
      .groupBy(pledge.eventId),
  ]);
  const collectedMap = new Map(pledgeRows.map((r) => [r.eventId, r.collected]));
  const map = new Map<string, NonNullable<EventStats>>();
  for (const r of invRows) {
    map.set(r.eventId, { guestCount: r.guestCount, cardsSent: r.cardsSent, confirmed: r.confirmed, collected: collectedMap.get(r.eventId) ?? 0 });
  }
  for (const id of eventIds) {
    if (!map.has(id)) map.set(id, { guestCount: 0, cardsSent: 0, confirmed: 0, collected: 0 });
  }
  return map;
}

const DETAIL_FIELDS = [
  "title",
  "startsAt",
  "endsAt",
  "timeZone",
  "venueName",
  "venueAddress",
  "venueMapUrl",
  "contactName",
  "contactPhone",
  "contact2Name",
  "contact2Phone",
  "confirmationEnabled",
  "confirmationOffsetDays",
  "headcountPct",
  "autoUpgradeEnabled",
  "singleAmount",
  "doubleAmount",
  "budgetAmount",
  "paymentDetails",
  "reminderFrequencyDays",
  "photoAlbumUrl",
] as const;

const auditValue = (v: unknown) => (v instanceof Date ? v.toISOString() : v);

/** Host-only edit of details, contact and settings. Audits changed fields (old and new). */
export async function updateEvent(db: DbExecutor, userId: string, eventId: string, input: UpdateEventInput): Promise<EventView> {
  await requireEventRole(db, { userId, eventId, roles: [] });
  const row = await loadEvent(db, eventId);
  if (!row) throw new NotFoundError("Event not found.");
  if (!EDITABLE_STATUSES.has(row.event.status)) {
    throw new ConflictError(`A ${row.event.status} event cannot be edited.`);
  }
  if (input.title !== undefined && !input.title.trim()) {
    throw new ValidationError("Some fields are invalid.", [{ path: "title", message: "Required." }]);
  }
  checkSettings({ ...input, startsAt: input.startsAt ?? row.event.startsAt, endsAt: input.endsAt === undefined ? row.event.endsAt : input.endsAt });
  assertAutoUpgradeAllowed(row.plan.entitlements, input.autoUpgradeEnabled);
  const next = normaliseContacts(input);

  const changes: Record<string, unknown> = {};
  const oldValue: Record<string, unknown> = {};
  const newValue: Record<string, unknown> = {};
  for (const field of DETAIL_FIELDS) {
    const value = next[field];
    if (value === undefined) continue;
    const current = row.event[field];
    const same = current instanceof Date && value instanceof Date ? current.getTime() === value.getTime() : current === value;
    if (same) continue;
    changes[field] = typeof value === "string" && field === "title" ? value.trim() : value;
    oldValue[field] = auditValue(current);
    newValue[field] = auditValue(changes[field]);
  }
  if (Object.keys(changes).length > 0) {
    const run = async (tx: DbExecutor) => {
      await tx.update(event).set(changes).where(eq(event.id, eventId));
      await recordAudit(tx, { actorUserId: userId, eventId, action: "event.updated", targetType: "event", targetId: eventId, oldValue, newValue });
    };
    await inTransaction(db, run);
  }
  return getEvent(db, userId, eventId);
}

/** Host-only cancel of a draft or published event. Audited. */
export async function cancelEvent(db: DbExecutor, userId: string, eventId: string): Promise<EventView> {
  await requireEventRole(db, { userId, eventId, roles: [] });
  const [current] = await db.select({ status: event.status }).from(event).where(eq(event.id, eventId));
  if (!current) throw new NotFoundError("Event not found.");
  if (!EDITABLE_STATUSES.has(current.status)) {
    throw new ConflictError(`A ${current.status} event cannot be cancelled.`);
  }
  const run = async (tx: DbExecutor) => {
    await tx.update(event).set({ status: "cancelled" }).where(eq(event.id, eventId));
    await recordAudit(tx, {
      actorUserId: userId,
      eventId,
      action: "event.cancelled",
      targetType: "event",
      targetId: eventId,
      oldValue: { status: current.status },
      newValue: { status: "cancelled" },
    });
  };
  await inTransaction(db, run);
  return getEvent(db, userId, eventId);
}

export async function listPlans(db: DbExecutor) {
  return db.select().from(plan).where(eq(plan.active, true)).orderBy(plan.pricePerGuest);
}

export async function listEventTypes(db: DbExecutor) {
  return db.select().from(eventType).where(eq(eventType.active, true)).orderBy(eventType.key);
}

import { auditLog, event, eventPlan, person, plan, userAccount } from "@dcard/db";
import { and, desc, eq, gte, ilike, like, lte, or, sql, type SQL } from "drizzle-orm";
import { recordAudit } from "../audit/audit.js";
import { type DbExecutor } from "../db-types.js";
import { ConflictError, NotFoundError } from "../errors.js";
import { toCsv } from "../exports/csv.js";
import { requireAdmin } from "./event-types/event-types.js";

// Admin panel reads and account actions (docs/implementation/tasks/t06-03-admin-panel.md).
// Correlated subqueries use literal table names: Drizzle renders ${column} unqualified in select fields.

const PAGE_SIZE = 50;
export type Page<T> = { items: T[]; page: number; pageSize: number; hasMore: boolean };

function paged<T>(rows: T[], page: number): Page<T> {
  return { items: rows.slice(0, PAGE_SIZE), page, pageSize: PAGE_SIZE, hasMore: rows.length > PAGE_SIZE };
}
const offset = (page: number) => (Math.max(1, page) - 1) * PAGE_SIZE;
const escapeLike = (q: string) => q.replace(/[\\%_]/g, (c) => `\\${c}`);

export type AdminUser = {
  id: string;
  email: string | null;
  phone: string | null;
  name: string | null;
  authProvider: "password" | "google" | "apple";
  isAdmin: boolean;
  disabledAt: Date | null;
  deletedAt: Date | null;
  createdAt: Date;
  eventsHosted: number;
  teamRoles: number;
};

export async function searchUsers(db: DbExecutor, adminId: string, input: { q?: string; page?: number } = {}): Promise<Page<AdminUser>> {
  await requireAdmin(db, adminId);
  const page = input.page ?? 1;
  const q = input.q?.trim();
  const digits = q?.replace(/\D/g, "");
  const where = q
    ? or(ilike(userAccount.email, `%${escapeLike(q)}%`), ilike(person.name, `%${escapeLike(q)}%`), digits && digits.length >= 4 ? like(person.phone, `%${digits}%`) : undefined)
    : undefined;
  const rows = await db
    .select({
      id: userAccount.id,
      email: userAccount.email,
      phone: person.phone,
      name: person.name,
      authProvider: userAccount.authProvider,
      isAdmin: userAccount.isAdmin,
      disabledAt: userAccount.disabledAt,
      deletedAt: userAccount.deletedAt,
      createdAt: userAccount.createdAt,
      eventsHosted: sql<number>`(select count(*)::int from event e where e.host_user_id = "user_account"."id")`,
      teamRoles: sql<number>`(select count(*)::int from event_role r where r.user_id = "user_account"."id")`,
    })
    .from(userAccount)
    .leftJoin(person, eq(person.id, userAccount.personId))
    .where(where)
    .orderBy(desc(userAccount.createdAt))
    .limit(PAGE_SIZE + 1)
    .offset(offset(page));
  return paged(rows, page);
}

type Ctx = { ip?: string | null; device?: string | null };

async function targetUser(db: DbExecutor, adminId: string, userId: string) {
  await requireAdmin(db, adminId);
  if (userId === adminId) throw new ConflictError("You cannot change your own account here.");
  const [row] = await db.select().from(userAccount).where(eq(userAccount.id, userId));
  if (!row || row.deletedAt) throw new NotFoundError("User not found.");
  return row;
}

/** Grants or revokes platform admin. Revoking also removes the second factor. */
export async function setUserAdmin(db: DbExecutor, adminId: string, userId: string, isAdmin: boolean, ctx: Ctx = {}): Promise<void> {
  const row = await targetUser(db, adminId, userId);
  if (row.isAdmin === isAdmin) return;
  await db.update(userAccount).set({ isAdmin }).where(eq(userAccount.id, userId));
  if (!isAdmin) await db.execute(sql`delete from admin_totp where user_id = ${userId}`);
  await recordAudit(db, { actorUserId: adminId, action: isAdmin ? "admin.granted" : "admin.revoked", targetType: "user_account", targetId: userId, ...ctx });
}

/** Disables or re-enables an account (a disabled account is refused on every API call). */
export async function setUserDisabled(db: DbExecutor, adminId: string, userId: string, disabled: boolean, ctx: Ctx = {}): Promise<void> {
  const row = await targetUser(db, adminId, userId);
  if (!!row.disabledAt === disabled) return;
  await db.update(userAccount).set({ disabledAt: disabled ? new Date() : null }).where(eq(userAccount.id, userId));
  await recordAudit(db, { actorUserId: adminId, action: disabled ? "account.disabled" : "account.enabled", targetType: "user_account", targetId: userId, ...ctx });
}

export type AdminEvent = {
  id: string;
  title: string;
  hostEmail: string | null;
  startsAt: Date;
  status: "draft" | "published" | "completed" | "cancelled";
  planKey: string | null;
  guestLimit: number;
  amountPaid: number;
  guests: number;
  cardsIssued: number;
  messagesSent: number;
  createdAt: Date;
};

export async function searchEvents(
  db: DbExecutor,
  adminId: string,
  input: { q?: string; from?: Date; to?: Date; page?: number } = {},
): Promise<Page<AdminEvent>> {
  await requireAdmin(db, adminId);
  const page = input.page ?? 1;
  const q = input.q?.trim();
  const filters: (SQL | undefined)[] = [
    q ? or(ilike(event.title, `%${escapeLike(q)}%`), ilike(userAccount.email, `%${escapeLike(q)}%`)) : undefined,
    input.from ? gte(event.startsAt, input.from) : undefined,
    input.to ? lte(event.startsAt, input.to) : undefined,
  ];
  const rows = await db
    .select({
      id: event.id,
      title: event.title,
      hostEmail: userAccount.email,
      startsAt: event.startsAt,
      status: event.status,
      planKey: plan.key,
      guestLimit: sql<number>`coalesce(${eventPlan.guestLimit}, 0)`,
      amountPaid: sql<number>`coalesce(${eventPlan.amountPaid}, 0)`,
      guests: sql<number>`(select count(*)::int from invitation i where i.event_id = "event"."id")`,
      cardsIssued: sql<number>`(select count(*)::int from invitation i where i.event_id = "event"."id" and i.card_number is not null)`,
      messagesSent: sql<number>`(select count(*)::int from message_log m where m.event_id = "event"."id" and m.direction = 'outbound' and m.status in ('sent', 'delivered', 'read'))`,
      createdAt: event.createdAt,
    })
    .from(event)
    .innerJoin(userAccount, eq(userAccount.id, event.hostUserId))
    .leftJoin(eventPlan, eq(eventPlan.eventId, event.id))
    .leftJoin(plan, eq(plan.id, eventPlan.planId))
    .where(and(...filters))
    .orderBy(desc(event.startsAt))
    .limit(PAGE_SIZE + 1)
    .offset(offset(page));
  return paged(rows, page);
}

export type AuditSearch = { eventId?: string; actorUserId?: string; actionPrefix?: string; from?: Date; to?: Date; page?: number };
export type AdminAuditEntry = {
  id: string;
  createdAt: Date;
  actorType: "user" | "system";
  actorUserId: string | null;
  actorEmail: string | null;
  eventId: string | null;
  action: string;
  targetType: string;
  targetId: string | null;
  oldValue: unknown;
  newValue: unknown;
  ip: string | null;
};

function auditWhere(input: AuditSearch) {
  return and(
    input.eventId ? eq(auditLog.eventId, input.eventId) : undefined,
    input.actorUserId ? eq(auditLog.actorUserId, input.actorUserId) : undefined,
    input.actionPrefix ? like(auditLog.action, `${escapeLike(input.actionPrefix.trim())}%`) : undefined,
    input.from ? gte(auditLog.createdAt, input.from) : undefined,
    input.to ? lte(auditLog.createdAt, input.to) : undefined,
  );
}

async function auditRows(db: DbExecutor, input: AuditSearch, limit: number, skip: number): Promise<AdminAuditEntry[]> {
  return db
    .select({
      id: auditLog.id,
      createdAt: auditLog.createdAt,
      actorType: auditLog.actorType,
      actorUserId: auditLog.actorUserId,
      actorEmail: userAccount.email,
      eventId: auditLog.eventId,
      action: auditLog.action,
      targetType: auditLog.targetType,
      targetId: auditLog.targetId,
      oldValue: auditLog.oldValue,
      newValue: auditLog.newValue,
      ip: auditLog.ip,
    })
    .from(auditLog)
    .leftJoin(userAccount, eq(userAccount.id, auditLog.actorUserId))
    .where(auditWhere(input))
    .orderBy(desc(auditLog.createdAt), desc(auditLog.id))
    .limit(limit)
    .offset(skip);
}

export async function searchAudit(db: DbExecutor, adminId: string, input: AuditSearch = {}): Promise<Page<AdminAuditEntry>> {
  await requireAdmin(db, adminId);
  const page = input.page ?? 1;
  return paged(await auditRows(db, input, PAGE_SIZE + 1, offset(page)), page);
}

const json = (v: unknown) => (v == null ? null : JSON.stringify(v));

/** Audit search as CSV (at most 10,000 rows). */
export async function exportAuditCsv(db: DbExecutor, adminId: string, input: AuditSearch = {}, ctx: Ctx = {}): Promise<string> {
  await requireAdmin(db, adminId);
  const rows = await auditRows(db, input, 10_000, 0);
  await recordAudit(db, { actorUserId: adminId, action: "export.downloaded", targetType: "audit_log", newValue: { kind: "admin_audit", rows: rows.length }, ...ctx });
  return toCsv(
    ["time", "actor", "event", "action", "target_type", "target_id", "old_value", "new_value", "ip"],
    rows.map((r) => [r.createdAt.toISOString(), r.actorEmail ?? r.actorType, r.eventId, r.action, r.targetType, r.targetId, json(r.oldValue), json(r.newValue), r.ip]),
  );
}

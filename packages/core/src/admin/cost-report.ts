import { event, eventPlan, plan } from "@dcard/db";
import { and, asc, eq, gte, lt, sql } from "drizzle-orm";
import { type DbExecutor } from "../db-types.js";
import { ValidationError } from "../errors.js";
import { requireAdmin } from "./event-types/event-types.js";

// Internal cost and margin (docs/design/features/plans-and-billing.md, "Cost check"): revenue from
// completed host payments, message cost from message_log.cost_tzs (estimated at send from
// provider_rate), payment fee as a percentage the admin enters. Hosts never see this.

export type CostLine = {
  revenue: number;
  whatsappMessages: number;
  whatsappCost: number;
  smsMessages: number;
  smsCost: number;
  /** Sent messages without a cost estimate (no provider rate at send time). */
  uncostedMessages: number;
  paymentFee: number;
  margin: number;
  /** Margin as a share of revenue, 0–100 (null without revenue). */
  marginPct: number | null;
};

export type CostReportEvent = CostLine & {
  eventId: string;
  title: string;
  startsAt: Date;
  planKey: string | null;
  cardsPaid: number;
};

export type CostReport = {
  from: Date;
  to: Date;
  feePercent: number;
  events: CostReportEvent[];
  byPlan: (CostLine & { planKey: string })[];
  byMonth: (CostLine & { month: string })[];
  total: CostLine;
};

const round = (n: number) => Math.round(n * 100) / 100;

function finish(line: Omit<CostLine, "paymentFee" | "margin" | "marginPct">, feePercent: number): CostLine {
  const paymentFee = round((line.revenue * feePercent) / 100);
  const margin = round(line.revenue - line.whatsappCost - line.smsCost - paymentFee);
  return { ...line, whatsappCost: round(line.whatsappCost), smsCost: round(line.smsCost), paymentFee, margin, marginPct: line.revenue > 0 ? round((margin / line.revenue) * 100) : null };
}

function sum(lines: CostLine[], feePercent: number): CostLine {
  const base = { revenue: 0, whatsappMessages: 0, whatsappCost: 0, smsMessages: 0, smsCost: 0, uncostedMessages: 0 };
  for (const l of lines) {
    base.revenue += l.revenue;
    base.whatsappMessages += l.whatsappMessages;
    base.whatsappCost += l.whatsappCost;
    base.smsMessages += l.smsMessages;
    base.smsCost += l.smsCost;
    base.uncostedMessages += l.uncostedMessages;
  }
  return finish(base, feePercent);
}

/** Events starting in [from, to), with totals per plan and per month (event time zone ignored: UTC months). */
export async function getCostReport(db: DbExecutor, adminId: string, input: { from: Date; to: Date; feePercent?: number }): Promise<CostReport> {
  await requireAdmin(db, adminId);
  const feePercent = input.feePercent ?? 0;
  if (!(feePercent >= 0 && feePercent <= 50)) throw new ValidationError("Some fields are invalid.", [{ path: "feePercent", message: "Between 0 and 50." }]);
  if (!(input.from < input.to)) throw new ValidationError("Some fields are invalid.", [{ path: "to", message: "Must be after from." }]);

  const sent = `m.event_id = "event"."id" and m.direction = 'outbound' and m.status in ('sent', 'delivered', 'read')`;
  const rows = await db
    .select({
      eventId: event.id,
      title: event.title,
      startsAt: event.startsAt,
      planKey: plan.key,
      cardsPaid: sql<number>`coalesce(${eventPlan.guestLimit}, 0)`,
      revenue: sql<number>`(select coalesce(sum(p.amount), 0)::int from host_payment p where p.event_id = "event"."id")`,
      whatsappMessages: sql<number>`(select count(*)::int from message_log m where ${sql.raw(sent)} and m.channel = 'whatsapp')`,
      whatsappCost: sql<string>`(select coalesce(sum(m.cost_tzs), 0) from message_log m where ${sql.raw(sent)} and m.channel = 'whatsapp')`,
      smsMessages: sql<number>`(select count(*)::int from message_log m where ${sql.raw(sent)} and m.channel = 'sms')`,
      smsCost: sql<string>`(select coalesce(sum(m.cost_tzs), 0) from message_log m where ${sql.raw(sent)} and m.channel = 'sms')`,
      uncostedMessages: sql<number>`(select count(*)::int from message_log m where ${sql.raw(sent)} and m.cost_tzs is null)`,
    })
    .from(event)
    .leftJoin(eventPlan, eq(eventPlan.eventId, event.id))
    .leftJoin(plan, eq(plan.id, eventPlan.planId))
    .where(and(gte(event.startsAt, input.from), lt(event.startsAt, input.to)))
    .orderBy(asc(event.startsAt));

  const events: CostReportEvent[] = rows.map((r) => ({
    eventId: r.eventId,
    title: r.title,
    startsAt: r.startsAt,
    planKey: r.planKey,
    cardsPaid: Number(r.cardsPaid),
    ...finish(
      {
        revenue: Number(r.revenue),
        whatsappMessages: Number(r.whatsappMessages),
        whatsappCost: Number(r.whatsappCost),
        smsMessages: Number(r.smsMessages),
        smsCost: Number(r.smsCost),
        uncostedMessages: Number(r.uncostedMessages),
      },
      feePercent,
    ),
  }));
  const group = <K extends string>(key: (e: CostReportEvent) => K) => {
    const map = new Map<K, CostReportEvent[]>();
    for (const e of events) map.set(key(e), [...(map.get(key(e)) ?? []), e]);
    return [...map.entries()];
  };
  return {
    from: input.from,
    to: input.to,
    feePercent,
    events,
    byPlan: group((e) => e.planKey ?? "none").map(([planKey, list]) => ({ planKey, ...sum(list, feePercent) })),
    byMonth: group((e) => e.startsAt.toISOString().slice(0, 7)).map(([month, list]) => ({ month, ...sum(list, feePercent) })),
    total: sum(events, feePercent),
  };
}

import { event, eventMessageSetting, eventPlan, invitation, outbox, plan, pledge, type MessageSchedule } from "@dcard/db";
import { and, desc, eq, gt, inArray, like, ne, sql } from "drizzle-orm";
import type { DbExecutor } from "../db-types.js";
import { enqueueMessage } from "./outbox.js";
import { atLocalTime, inQuietHours, localDate } from "./time.js";
import { MESSAGE_DEFAULTS, type MessageType } from "./types.js";

// Scheduled guest messages (NTF-3, NTF-6, NTF-7, NTF-8; MSG-6, MSG-7, MSG-8, MSG-12).
// Runs every few minutes; idempotent because every occurrence has a fixed outbox key.

type Setting = { enabled: boolean; schedule: MessageSchedule };

async function settingsFor(db: DbExecutor, eventId: string): Promise<(type: MessageType) => Setting> {
  const rows = await db.select().from(eventMessageSetting).where(eq(eventMessageSetting.eventId, eventId));
  return (type) => {
    const row = rows.find((r) => r.messageType === type);
    const d = MESSAGE_DEFAULTS[type];
    return { enabled: row?.enabled ?? d.enabled, schedule: { ...d.schedule, ...(row?.schedule ?? {}) } };
  };
}

/** A late scheduled message is still worth sending within this window, not after. */
const LATE_WINDOW_MS = 24 * 60 * 60 * 1000;

export type ScheduleRun = { queued: number; byType: Partial<Record<MessageType, number>> };

export async function scheduleDueMessages(db: DbExecutor, now = new Date()): Promise<ScheduleRun> {
  const run: ScheduleRun = { queued: 0, byType: {} };
  const count = (t: MessageType, n: number) => {
    run.queued += n;
    run.byType[t] = (run.byType[t] ?? 0) + n;
  };
  const events = await db
    .select({ e: event, entitlements: plan.entitlements })
    .from(event)
    .innerJoin(eventPlan, eq(eventPlan.eventId, event.id))
    .innerJoin(plan, eq(plan.id, eventPlan.planId))
    .where(and(inArray(event.status, ["draft", "published"]), gt(event.startsAt, new Date(now.getTime() - 3 * LATE_WINDOW_MS))));

  for (const { e, entitlements } of events) {
    const tz = e.timeZone;
    // MSG-8: nothing new is queued during quiet hours (dispatch also holds anything already queued).
    if (inQuietHours(now, tz)) continue;
    const setting = await settingsFor(db, e.id);
    const startDay = localDate(e.startsAt, tz);
    const issued = () =>
      db
        .select({ id: invitation.id })
        .from(invitation)
        .where(and(eq(invitation.eventId, e.id), eq(invitation.status, "issued")));

    // One-off messages at "N days before/after the event, at HH:MM".
    const oneOff = async (type: MessageType, extra: (id: string) => boolean | Promise<boolean> = () => true) => {
      const s = setting(type);
      if (!s.enabled) return;
      const due = atLocalTime(startDay, s.schedule.timeOfDay ?? "10:00", tz, -(s.schedule.offsetDays ?? 0));
      if (now < due || now.getTime() - due.getTime() > LATE_WINDOW_MS) return;
      let n = 0;
      for (const { id } of await issued()) {
        if (!(await extra(id))) continue;
        await enqueueMessage(db, { key: `${type}:${id}`, eventId: e.id, invitationId: id, messageType: type });
        n++;
      }
      if (n) count(type, n);
    };

    if (e.confirmationEnabled && now < e.startsAt) {
      await oneOff("attendance_confirmation", async (id) => {
        const [inv] = await db.select({ c: invitation.confirmationStatus }).from(invitation).where(eq(invitation.id, id));
        return inv?.c === "none";
      });
    }
    if (now < e.startsAt) await oneOff("event_reminder");
    // NTF-8 is a marketing-category message: only plans that allow it (MSG-12).
    if (entitlements.marketingMessages && now > e.startsAt) await oneOff("post_event_thanks");

    // NTF-3: contribution reminders to contributors with a balance, every N days, up to the plan max.
    const r = setting("contribution_reminder");
    const planMax = entitlements.maxContributionReminders;
    if (r.enabled && planMax > 0) {
      const max = Math.min(planMax, r.schedule.maxCount ?? planMax);
      const every = Math.max(1, r.schedule.frequencyDays ?? 14);
      const stopAt = new Date(e.startsAt.getTime() - (r.schedule.stopOffsetDays ?? 0) * LATE_WINDOW_MS);
      if (now < stopAt) {
        const open = await db
          .select({ id: pledge.id, invitationId: pledge.invitationId, createdAt: pledge.createdAt })
          .from(pledge)
          .innerJoin(invitation, eq(invitation.id, pledge.invitationId))
          .where(and(eq(pledge.eventId, e.id), ne(invitation.status, "cancelled"), sql`${pledge.amountPaid} < ${pledge.amountPledged}`));
        let n = 0;
        for (const p of open) {
          const sent = await db
            .select({ createdAt: outbox.createdAt })
            .from(outbox)
            .where(like(outbox.key, `contribution_reminder:${p.id}:%`))
            .orderBy(desc(outbox.createdAt));
          if (sent.length >= max) continue;
          const last = sent[0]?.createdAt ?? p.createdAt;
          const due = atLocalTime(localDate(last, tz), r.schedule.timeOfDay ?? "10:00", tz, every);
          if (now < due) continue;
          await enqueueMessage(db, {
            key: `contribution_reminder:${p.id}:${sent.length + 1}`,
            eventId: e.id,
            invitationId: p.invitationId,
            messageType: "contribution_reminder",
          });
          n++;
        }
        if (n) count("contribution_reminder", n);
      }
    }
  }
  return run;
}

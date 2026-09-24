import { event, eventRole } from "@dcard/db";
import { and, eq, inArray } from "drizzle-orm";
import type { DbExecutor } from "../db-types.js";
import { ForbiddenError, NotFoundError } from "../errors.js";

export type EventRoleName = "treasurer" | "committee" | "door_staff" | "walkin_approver";
export type EventAccess = "host" | EventRoleName;

/**
 * Allows the event host, or a user holding one of `roles` for this event.
 * Returns how access was granted. Throws NotFoundError / ForbiddenError otherwise.
 */
export async function requireEventRole(
  db: DbExecutor,
  params: { userId: string; eventId: string; roles: readonly EventRoleName[] },
): Promise<EventAccess> {
  const [found] = await db
    .select({ hostUserId: event.hostUserId })
    .from(event)
    .where(eq(event.id, params.eventId));
  if (!found) {
    throw new NotFoundError("Event not found.");
  }
  if (found.hostUserId === params.userId) {
    return "host";
  }
  if (params.roles.length > 0) {
    const [held] = await db
      .select({ role: eventRole.role })
      .from(eventRole)
      .where(
        and(
          eq(eventRole.eventId, params.eventId),
          eq(eventRole.userId, params.userId),
          inArray(eventRole.role, [...params.roles]),
        ),
      )
      .limit(1);
    if (held) {
      return held.role;
    }
  }
  throw new ForbiddenError();
}

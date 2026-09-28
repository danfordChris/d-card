import { NotFoundError } from "@dcard/core";

const UUID = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** Treats malformed ids as not found (never reaches the database). */
export function eventIdFrom(id: string): string {
  if (!UUID.test(id)) throw new NotFoundError("Event not found.");
  return id;
}

export function guestIdFrom(id: string): string {
  if (!UUID.test(id)) throw new NotFoundError("Guest not found.");
  return id;
}

export function uuidFrom(id: string, what = "Resource"): string {
  if (!UUID.test(id)) throw new NotFoundError(`${what} not found.`);
  return id;
}

import { DomainError, getEvent, listEventTypes, listPlans, type EventView } from "@dcard/core";
import type { PlanEntitlements } from "@dcard/db";
import { notFound, redirect } from "next/navigation";
import type { EventTypeOption, PlanOption } from "../features/events/types";
import { getDb } from "./db";
import { getSessionAccount } from "./session";

export async function requireAccount() {
  const account = await getSessionAccount();
  if (!account) redirect("/login");
  return account;
}

export async function loadCatalogue(): Promise<{ plans: PlanOption[]; eventTypes: EventTypeOption[] }> {
  const db = getDb();
  const [plans, types] = await Promise.all([listPlans(db), listEventTypes(db)]);
  return {
    plans: plans.map((p) => ({
      key: p.key,
      name: p.name,
      pricePerGuest: p.pricePerGuest,
      autoUpgrade: (p.entitlements as PlanEntitlements).autoUpgrade,
    })),
    eventTypes: types.map((t) => ({ key: t.key, nameSw: t.nameSw, nameEn: t.nameEn })),
  };
}

/** Loads an event the account may see; unknown/forbidden events render the 404 page. */
export async function loadEventOr404(accountId: string, id: string): Promise<EventView> {
  if (!/^[0-9a-f-]{36}$/i.test(id)) notFound();
  try {
    return await getEvent(getDb(), accountId, id);
  } catch (err) {
    if (err instanceof DomainError && (err.code === "not_found" || err.code === "forbidden")) notFound();
    throw err;
  }
}

import { createEvent, grantGuestCards, type DbExecutor } from "../src/index.js";

/**
 * Creates an event that is already paid for `cards` guest cards (the payment gate refuses card
 * issue and holds guest messages until then). Billing itself is tested in billing.test.ts.
 */
export async function createPaidEvent(db: DbExecutor, hostId: string, input: Parameters<typeof createEvent>[2], cards = 500): Promise<string> {
  const id = await createEvent(db, hostId, input);
  await grantGuestCards(db, id, cards);
  return id;
}

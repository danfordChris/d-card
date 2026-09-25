import { outbox } from "@dcard/db";
import type { DbExecutor } from "../db-types.js";
import { ValidationError } from "../errors.js";
import type { ChannelChoice, MessageType } from "./types.js";

/**
 * Queues a guest message inside the caller's transaction (transactional outbox, ADR 0003).
 * `key` makes it idempotent: the same business action never queues the same message twice.
 */
export async function enqueueMessage(
  tx: DbExecutor,
  params: {
    key: string;
    eventId: string;
    invitationId: string | null;
    messageType: MessageType;
    payload?: Record<string, string | number | null>;
    channels?: ChannelChoice;
    toPhone?: string;
  },
): Promise<void> {
  if (!params.invitationId && !params.toPhone) {
    throw new ValidationError("A message destination is required.", [
      { path: "invitationId", message: "Provide an invitation or a direct phone number." },
    ]);
  }
  await tx
    .insert(outbox)
    .values({
      key: params.key,
      eventId: params.eventId,
      invitationId: params.invitationId,
      messageType: params.messageType,
      payload: params.payload ?? {},
      channels: params.channels ?? null,
      toPhone: params.toPhone ?? null,
    })
    .onConflictDoNothing({ target: outbox.key });
}

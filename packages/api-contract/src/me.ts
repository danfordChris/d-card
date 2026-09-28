import type { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { z } from "zod";
import { CardTypeSchema } from "./guests.js";
import { ErrorResponse } from "./schemas.js";

// Guest accounts (AUTH-3, AUTH-4): link a card to the signed-in account, list my cards.

export const LinkCardInput = z.object({ token: z.string().min(20).max(100) }).openapi("LinkCardInput");

export const LinkCardResultSchema = z.object({ linked: z.boolean() }).openapi("LinkCardResult");

export const MyCardSchema = z
  .object({
    eventTitle: z.string(),
    startsAt: z.iso.datetime(),
    endsAt: z.iso.datetime().nullable(),
    timeZone: z.string(),
    venueName: z.string().nullable(),
    guestName: z.string(),
    cardType: CardTypeSchema,
    cardNumber: z.string(),
    status: z.enum(["issued", "cancelled"]),
    rsvpStatus: z.enum(["none", "yes", "no"]),
    linkToken: z.string(),
  })
  .openapi("MyCard");

export const MyCardListSchema = z.object({ items: z.array(MyCardSchema) }).openapi("MyCardList");

export type LinkCardInput = z.infer<typeof LinkCardInput>;
export type MyCard = z.infer<typeof MyCardSchema>;

export function registerMePaths(registry: OpenAPIRegistry, secured: Record<string, string[]>[]): void {
  const error = (description: string) => ({ description, content: { "application/json": { schema: ErrorResponse } } });
  const json = (schema: z.ZodType, description: string) => ({ description, content: { "application/json": { schema } } });
  registry.registerPath({
    method: "post",
    path: "/api/v1/me/cards/link",
    operationId: "linkMyCard",
    summary: "Link a card (by its link token) to the signed-in guest account",
    security: secured,
    request: { body: { content: { "application/json": { schema: LinkCardInput } } } },
    responses: {
      200: json(LinkCardResultSchema, "Linked (or already linked)"),
      404: error("Card not found"),
      409: error("person_linked: the guest has another account; account_linked: this account belongs to another guest"),
    },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/me/cards",
    operationId: "listMyCards",
    summary: "The signed-in guest's cards across events",
    security: secured,
    responses: { 200: json(MyCardListSchema, "Cards") },
  });
}

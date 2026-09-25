import { z } from "zod";
import "./schemas.js";

// docs/design/features/auth.md › Team Invitation (AUTH-8)

export const TeamRoleSchema = z.enum(["treasurer", "committee", "door_staff", "walkin_approver"]).openapi("TeamRole");

export const InviteCreateInput = z
  .object({ role: TeamRoleSchema, email: z.email().max(200).nullable().optional() })
  .openapi("InviteCreateInput");

export const InviteSchema = z
  .object({
    id: z.uuid(),
    eventId: z.uuid(),
    role: TeamRoleSchema,
    email: z.string().nullable(),
    expiresAt: z.iso.datetime(),
    createdAt: z.iso.datetime(),
  })
  .openapi("Invite");

export const InviteCreateResponse = z
  .object({ invite: InviteSchema, link: z.url(), emailQueued: z.boolean() })
  .openapi("InviteCreateResponse");

export const TeamResponse = z
  .object({
    members: z.array(z.object({ userId: z.uuid(), email: z.string().nullable(), role: TeamRoleSchema, since: z.iso.datetime() })),
    invites: z.array(InviteSchema),
  })
  .openapi("Team");

export const InviteInfoResponse = z
  .object({ eventId: z.uuid(), eventTitle: z.string(), role: TeamRoleSchema, expiresAt: z.iso.datetime() })
  .openapi("InviteInfo");

export const InviteAcceptResponse = z.object({ eventId: z.uuid(), role: TeamRoleSchema }).openapi("InviteAccepted");

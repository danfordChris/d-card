import type { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { z } from "zod";
import { ErrorResponse } from "./schemas.js";

// Admin panel (T06-03, T06-05) and admin two-step sign-in (AUTH-7).

const page = z.coerce.number().int().min(1).max(1000).optional();
const Page = <T extends z.ZodType>(item: T) => z.object({ items: z.array(item), page: z.number().int(), pageSize: z.number().int(), hasMore: z.boolean() });

export const TotpCodeInput = z.object({ code: z.string().trim().min(6).max(20) }).openapi("TotpCodeInput");
export const TotpStatusSchema = z.object({ enrolled: z.boolean(), verified: z.boolean(), recoveryCodesLeft: z.number().int() }).openapi("TotpStatus");
export const TotpEnrolmentSchema = z.object({ secret: z.string(), otpauthUri: z.string() }).openapi("TotpEnrolment");
export const TotpRecoveryCodesSchema = z.object({ recoveryCodes: z.array(z.string()) }).openapi("TotpRecoveryCodes");

export const AdminUserQuery = z.object({ q: z.string().max(100).optional(), page });
export const AdminUserSchema = z
  .object({
    id: z.uuid(),
    email: z.string().nullable(),
    phone: z.string().nullable(),
    name: z.string().nullable(),
    authProvider: z.enum(["password", "google", "apple"]),
    isAdmin: z.boolean(),
    disabledAt: z.iso.datetime().nullable(),
    deletedAt: z.iso.datetime().nullable(),
    createdAt: z.iso.datetime(),
    eventsHosted: z.number().int(),
    teamRoles: z.number().int(),
  })
  .openapi("AdminUser");
export const AdminUserPageSchema = Page(AdminUserSchema).openapi("AdminUserPage");
export const AdminUserUpdateInput = z.object({ isAdmin: z.boolean().optional(), disabled: z.boolean().optional() }).openapi("AdminUserUpdateInput");

export const AdminEventQuery = z.object({ q: z.string().max(100).optional(), from: z.iso.datetime().optional(), to: z.iso.datetime().optional(), page });
export const AdminEventSchema = z
  .object({
    id: z.uuid(),
    title: z.string(),
    hostEmail: z.string().nullable(),
    startsAt: z.iso.datetime(),
    status: z.enum(["draft", "published", "completed", "cancelled"]),
    planKey: z.string().nullable(),
    guestLimit: z.number().int(),
    amountPaid: z.number().int(),
    guests: z.number().int(),
    cardsIssued: z.number().int(),
    messagesSent: z.number().int(),
    createdAt: z.iso.datetime(),
  })
  .openapi("AdminEvent");
export const AdminEventPageSchema = Page(AdminEventSchema).openapi("AdminEventPage");

export const AdminAuditQuery = z.object({
  eventId: z.uuid().optional(),
  actorUserId: z.uuid().optional(),
  action: z.string().max(60).optional(),
  from: z.iso.datetime().optional(),
  to: z.iso.datetime().optional(),
  page,
});
export const AdminAuditEntrySchema = z
  .object({
    id: z.uuid(),
    createdAt: z.iso.datetime(),
    actorType: z.enum(["user", "system"]),
    actorUserId: z.uuid().nullable(),
    actorEmail: z.string().nullable(),
    eventId: z.uuid().nullable(),
    action: z.string(),
    targetType: z.string(),
    targetId: z.string().nullable(),
    oldValue: z.unknown(),
    newValue: z.unknown(),
    ip: z.string().nullable(),
  })
  .openapi("AdminAuditEntry");
export const AdminAuditPageSchema = Page(AdminAuditEntrySchema).openapi("AdminAuditPage");

export const QueueStatsSchema = z
  .object({ name: z.string(), waiting: z.number().int(), active: z.number().int(), delayed: z.number().int(), failed: z.number().int(), completed: z.number().int() })
  .openapi("QueueStats");
export const QueueStatsListSchema = z.object({ queues: z.array(QueueStatsSchema) }).openapi("QueueStatsList");

export const CostReportQuery = z.object({ from: z.iso.datetime(), to: z.iso.datetime(), feePercent: z.coerce.number().min(0).max(50).optional() });
const costLine = {
  revenue: z.number(),
  whatsappMessages: z.number().int(),
  whatsappCost: z.number(),
  smsMessages: z.number().int(),
  smsCost: z.number(),
  uncostedMessages: z.number().int(),
  paymentFee: z.number(),
  margin: z.number(),
  marginPct: z.number().nullable(),
};
export const CostLineSchema = z.object(costLine).openapi("CostLine");
export const CostReportSchema = z
  .object({
    from: z.iso.datetime(),
    to: z.iso.datetime(),
    feePercent: z.number(),
    events: z.array(z.object({ eventId: z.uuid(), title: z.string(), startsAt: z.iso.datetime(), planKey: z.string().nullable(), cardsPaid: z.number().int(), ...costLine }).openapi("CostReportEvent")),
    byPlan: z.array(z.object({ planKey: z.string(), ...costLine }).openapi("CostReportPlan")),
    byMonth: z.array(z.object({ month: z.string(), ...costLine }).openapi("CostReportMonth")),
    total: CostLineSchema,
  })
  .openapi("CostReport");

export type AdminUser = z.infer<typeof AdminUserSchema>;
export type AdminEvent = z.infer<typeof AdminEventSchema>;
export type AdminAuditEntry = z.infer<typeof AdminAuditEntrySchema>;
export type QueueStats = z.infer<typeof QueueStatsSchema>;
export type CostReport = z.infer<typeof CostReportSchema>;
export type TotpStatus = z.infer<typeof TotpStatusSchema>;

export function registerAdminPlatformPaths(registry: OpenAPIRegistry, secured: Record<string, string[]>[]): void {
  const error = (description: string) => ({ description, content: { "application/json": { schema: ErrorResponse } } });
  const json = (schema: z.ZodType, description: string) => ({ description, content: { "application/json": { schema } } });
  const body = (schema: z.ZodType) => ({ body: { content: { "application/json": { schema } } } });
  const needs2fa = { 403: error("Admins only, or second_factor_required") };
  const code = (path: string, operationId: string, summary: string, ok: ReturnType<typeof json> | { description: string }) =>
    registry.registerPath({
      method: "post",
      path,
      operationId,
      summary,
      security: secured,
      request: body(TotpCodeInput),
      responses: { 200: ok, 403: error("Admins only"), 422: error("second_factor_invalid"), 429: error("second_factor_locked (15 minutes)") },
    });

  registry.registerPath({ method: "get", path: "/api/v1/admin/2fa", operationId: "getAdminTotp", summary: "Two-step sign-in status for this admin", security: secured, responses: { 200: json(TotpStatusSchema, "Status"), 403: error("Admins only") } });
  registry.registerPath({
    method: "post",
    path: "/api/v1/admin/2fa/enrol",
    operationId: "startAdminTotp",
    summary: "Start authenticator-app setup (secret + otpauth URI for a QR code)",
    security: secured,
    responses: { 200: json(TotpEnrolmentSchema, "Setup"), 403: error("Admins only"), 409: error("Already on") },
  });
  code("/api/v1/admin/2fa/confirm", "confirmAdminTotp", "Confirm setup with a first code; returns 10 one-time recovery codes and sets the admin session cookie", json(TotpRecoveryCodesSchema, "Recovery codes (shown once)"));
  code("/api/v1/admin/2fa/verify", "verifyAdminTotp", "Verify a code or recovery code; sets the admin session cookie (12 h)", { description: "Verified" });
  code("/api/v1/admin/2fa/disable", "disableAdminTotp", "Turn two-step sign-in off (needs a code)", { description: "Turned off" });

  registry.registerPath({ method: "get", path: "/api/v1/admin/users", operationId: "searchAdminUsers", summary: "Search accounts by email, name or phone", security: secured, request: { query: AdminUserQuery }, responses: { 200: json(AdminUserPageSchema, "Users"), ...needs2fa } });
  registry.registerPath({
    method: "patch",
    path: "/api/v1/admin/users/{userId}",
    operationId: "updateAdminUser",
    summary: "Grant/revoke admin, disable/enable an account (not yourself)",
    security: secured,
    request: { params: z.object({ userId: z.uuid() }), ...body(AdminUserUpdateInput) },
    responses: { 204: { description: "Updated" }, ...needs2fa, 404: error("Not found"), 409: error("Your own account") },
  });
  registry.registerPath({ method: "get", path: "/api/v1/admin/events", operationId: "searchAdminEvents", summary: "Search events by title or host email and date", security: secured, request: { query: AdminEventQuery }, responses: { 200: json(AdminEventPageSchema, "Events"), ...needs2fa } });
  registry.registerPath({ method: "get", path: "/api/v1/admin/audit", operationId: "searchAdminAudit", summary: "Search the audit log", security: secured, request: { query: AdminAuditQuery }, responses: { 200: json(AdminAuditPageSchema, "Entries"), ...needs2fa } });
  registry.registerPath({
    method: "get",
    path: "/api/v1/admin/audit/export",
    operationId: "exportAdminAudit",
    summary: "Audit search as CSV (up to 10,000 rows)",
    security: secured,
    request: { query: AdminAuditQuery },
    responses: { 200: { description: "CSV", content: { "text/csv": { schema: z.string() } } }, ...needs2fa },
  });
  registry.registerPath({ method: "get", path: "/api/v1/admin/queues", operationId: "getAdminQueues", summary: "Job counts per queue", security: secured, responses: { 200: json(QueueStatsListSchema, "Queues"), ...needs2fa } });
  registry.registerPath({
    method: "post",
    path: "/api/v1/admin/queues/{name}/retry",
    operationId: "retryAdminQueue",
    summary: "Retry the failed jobs of a queue",
    security: secured,
    request: { params: z.object({ name: z.string() }) },
    responses: { 200: json(z.object({ retried: z.number().int() }), "Retried"), ...needs2fa, 404: error("Unknown queue") },
  });
  registry.registerPath({ method: "get", path: "/api/v1/admin/cost-report", operationId: "getCostReport", summary: "Revenue, message cost, payment fee and margin per event, plan and month", security: secured, request: { query: CostReportQuery }, responses: { 200: json(CostReportSchema, "Report"), ...needs2fa } });
}

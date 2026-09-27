import type { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { z } from "zod";
import { ErrorResponse } from "./schemas.js";

// T06-04 host audit view and CSV exports (privacy-and-audit.md "Audited Actions", CON-10).
// Kept free of unions/literals so the generated Dart client (dcard_api) stays valid.

export const AuditChangeSchema = z
  .object({ field: z.string(), from: z.string().nullable(), to: z.string().nullable() })
  .openapi("AuditChange");

export const EventAuditEntrySchema = z
  .object({
    id: z.uuid(),
    createdAt: z.iso.datetime(),
    /** Dotted verb, e.g. "payment.recorded"; clients map it to a label and fall back to the raw value. */
    action: z.string(),
    actorType: z.enum(["user", "system"]),
    actorName: z.string().nullable(),
    targetType: z.string(),
    targetId: z.string().nullable(),
    changes: z.array(AuditChangeSchema),
  })
  .openapi("EventAuditEntry");

export const EventAuditPageSchema = z
  .object({ entries: z.array(EventAuditEntrySchema), nextCursor: z.string().nullable() })
  .openapi("EventAuditPage");

export const EventAuditQuery = z
  .object({
    action: z.string().max(80).optional().openapi({ description: 'Dotted prefix: "payment" matches payment.*; "card.issued" matches exactly.' }),
    limit: z.coerce.number().int().min(1).max(200).optional(),
    cursor: z.string().optional(),
  })
  .openapi("EventAuditQuery");

export const ExportKindSchema = z.enum(["guests", "contributions", "attendance"]).openapi("ExportKind");

export function registerAuditPaths(registry: OpenAPIRegistry, secured: Record<string, string[]>[]): void {
  const error = (description: string) => ({ description, content: { "application/json": { schema: ErrorResponse } } });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/audit",
    operationId: "listEventAudit",
    summary: "Event audit trail, newest first (host or treasurer)",
    security: secured,
    request: { params: z.object({ id: z.uuid() }), query: EventAuditQuery },
    responses: {
      200: { description: "Audit page", content: { "application/json": { schema: EventAuditPageSchema } } },
      403: error("No access"),
      404: error("Event not found"),
      422: error("Invalid filter or cursor"),
    },
  });
  registry.registerPath({
    method: "get",
    path: "/api/v1/events/{id}/exports/{kind}",
    operationId: "downloadEventExport",
    summary: "CSV export (UTF-8 with BOM): guests and attendance for the host, contributions for host or treasurer; audited",
    security: secured,
    request: {
      params: z.object({ id: z.uuid(), kind: ExportKindSchema }),
      query: z.object({ lang: z.enum(["sw", "en"]).optional() }),
    },
    responses: {
      200: { description: "CSV file (Content-Disposition: attachment)", content: { "text/csv": { schema: z.string() } } },
      403: error("No access"),
      404: error("Event or export not found"),
    },
  });
}

import { z } from "zod";
import "./schemas.js";

// docs/design/features/events.md (EVT-5): admin-managed event types.

export const AdminEventTypeSchema = z
  .object({ id: z.uuid(), key: z.string(), nameSw: z.string(), nameEn: z.string(), active: z.boolean() })
  .openapi("AdminEventType");

export const AdminEventTypeListResponse = z.object({ eventTypes: z.array(AdminEventTypeSchema) }).openapi("AdminEventTypeList");

export const AdminEventTypeCreateInput = z
  .object({
    key: z.string().regex(/^\s*[A-Za-z][A-Za-z0-9_]{1,39}\s*$/).openapi({ example: "kitchen_party" }),
    nameSw: z.string().trim().min(1).max(80),
    nameEn: z.string().trim().min(1).max(80),
  })
  .openapi("AdminEventTypeCreateInput");

export const AdminEventTypeUpdateInput = z
  .object({ nameSw: z.string().trim().min(1).max(80), nameEn: z.string().trim().min(1).max(80), active: z.boolean() })
  .partial()
  .openapi("AdminEventTypeUpdateInput");

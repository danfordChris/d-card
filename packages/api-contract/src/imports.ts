import { z } from "zod";
import "./schemas.js";

// docs/design/features/guests-and-cards.md (GST-5, GST-7)

export const ImportReportSchema = z
  .object({
    total: z.number().int(),
    valid: z.number().int(),
    invalid: z.array(z.object({ row: z.number().int(), phone: z.string(), reason: z.enum(["invalid_phone", "name_required", "invalid_card_type"]) })),
    duplicatesInFile: z.array(z.object({ row: z.number().int(), phone: z.string(), firstRow: z.number().int() })),
    existing: z.array(z.object({ row: z.number().int(), phone: z.string(), name: z.string() })),
  })
  .openapi("ImportReport");

export const ImportPreviewResponse = z.object({ jobId: z.uuid(), report: ImportReportSchema }).openapi("ImportPreview");
export const ImportCopyInput = z.object({ fromEventId: z.uuid() }).openapi("ImportCopyInput");
export const ImportConfirmInput = z.object({ consent: z.boolean() }).openapi("ImportConfirmInput");
export const ImportConfirmResponse = z
  .object({ imported: z.number().int(), existing: z.number().int(), invalid: z.number().int() })
  .openapi("ImportResult");

export type ImportReportDto = z.infer<typeof ImportReportSchema>;

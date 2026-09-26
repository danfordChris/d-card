import { z } from "zod";
import "./schemas.js";

// T04-03 confirmation recording (CNF-3) and expected headcount (GST-14).

export const ConfirmationStatusSchema = z.enum(["none", "yes", "no"]);
export const ConfirmationUpdateInput = z.object({ status: ConfirmationStatusSchema }).strict().openapi("ConfirmationUpdateInput");

export type ConfirmationUpdateInput = z.infer<typeof ConfirmationUpdateInput>;

import { extendZodWithOpenApi } from "@asteasolutions/zod-to-openapi";
import { z } from "zod";

extendZodWithOpenApi(z);

export const ErrorResponse = z
  .object({
    error: z.object({
      code: z.string().openapi({ example: "unauthorized" }),
      message: z.string(),
      issues: z.array(z.object({ path: z.string(), message: z.string() })).optional(),
    }),
  })
  .openapi("ErrorResponse");

export const HealthResponse = z
  .object({ status: z.literal("ok") })
  .openapi("HealthResponse");

export const AuthProvider = z.enum(["password", "google", "apple"]).openapi("AuthProvider");

export const Account = z
  .object({
    id: z.uuid(),
    firebaseUid: z.string(),
    email: z.email().nullable(),
    authProvider: AuthProvider,
    personId: z.uuid().nullable(),
    isAdmin: z.boolean(),
    emailVerified: z.boolean(),
    createdAt: z.iso.datetime(),
  })
  .openapi("Account");

export type ErrorResponse = z.infer<typeof ErrorResponse>;
export type HealthResponse = z.infer<typeof HealthResponse>;
export type Account = z.infer<typeof Account>;

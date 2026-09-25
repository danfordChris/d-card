import type { OpenAPIRegistry } from "@asteasolutions/zod-to-openapi";
import { z } from "zod";
import { ErrorResponse } from "./schemas.js";

// T03-08 push setup: docs/design/integrations/firebase.md › FCM/APNs

export const DevicePlatformSchema = z.enum(["android", "ios"]).openapi("DevicePlatform");
export const DeviceAppSchema = z.enum(["mobile", "door"]).openapi("DeviceApp");

export const DeviceRegisterInput = z
  .object({
    token: z.string().trim().min(1).max(4096),
    platform: DevicePlatformSchema,
    app: DeviceAppSchema,
  })
  .strict()
  .openapi("DeviceRegisterInput");

export const DeviceSchema = z
  .object({
    id: z.uuid(),
    platform: DevicePlatformSchema,
    app: DeviceAppSchema,
    createdAt: z.iso.datetime(),
    lastSeenAt: z.iso.datetime(),
  })
  .openapi("Device");

export type DevicePlatform = z.infer<typeof DevicePlatformSchema>;
export type DeviceApp = z.infer<typeof DeviceAppSchema>;
export type DeviceRegisterInput = z.infer<typeof DeviceRegisterInput>;
export type Device = z.infer<typeof DeviceSchema>;

/** Registers the /api/v1/me/devices paths; called from buildOpenApiDocument. */
export function registerDevicePaths(registry: OpenAPIRegistry, secured: Record<string, string[]>[]): void {
  const error = (description: string) => ({ description, content: { "application/json": { schema: ErrorResponse } } });
  registry.registerPath({
    method: "post",
    path: "/api/v1/me/devices",
    operationId: "registerDevice",
    summary: "Register (upsert) this device's push token for the signed-in user",
    security: secured,
    request: { body: { content: { "application/json": { schema: DeviceRegisterInput } } } },
    responses: {
      200: { description: "Token already known; refreshed", content: { "application/json": { schema: DeviceSchema } } },
      201: { description: "Token registered", content: { "application/json": { schema: DeviceSchema } } },
      401: error("Missing or invalid token"),
      403: error("Account not provisioned"),
      422: error("Validation error"),
    },
  });
  registry.registerPath({
    method: "delete",
    path: "/api/v1/me/devices/{token}",
    operationId: "unregisterDevice",
    summary: "Remove a push token of the signed-in user (idempotent; call on sign-out)",
    security: secured,
    request: { params: z.object({ token: z.string().min(1) }) },
    responses: {
      204: { description: "Removed (or was not registered)" },
      401: error("Missing or invalid token"),
      403: error("Account not provisioned"),
    },
  });
}

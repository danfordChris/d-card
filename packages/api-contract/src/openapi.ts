import { OpenAPIRegistry, OpenApiGeneratorV31 } from "@asteasolutions/zod-to-openapi";
import { Account, ErrorResponse, HealthResponse } from "./schemas.js";

// Contract source of truth: docs/design/integrations/firebase.md, docs/design/architecture/codebase.md

/** Plain JSON OpenAPI 3.1 document. */
export type OpenApiDocument = Record<string, unknown>;

export function buildOpenApiDocument(): OpenApiDocument {
  const registry = new OpenAPIRegistry();
  const bearer = registry.registerComponent("securitySchemes", "firebaseIdToken", {
    type: "http",
    scheme: "bearer",
    description: "Firebase ID token",
  });
  const error = (description: string) => ({
    description,
    content: { "application/json": { schema: ErrorResponse } },
  });

  registry.registerPath({
    method: "get",
    path: "/api/v1/health",
    operationId: "getHealth",
    summary: "Service health",
    responses: {
      200: { description: "Healthy", content: { "application/json": { schema: HealthResponse } } },
      503: error("Database unreachable"),
    },
  });

  registry.registerPath({
    method: "get",
    path: "/api/v1/me",
    operationId: "getMe",
    summary: "Current account",
    security: [{ [bearer.name]: [] }],
    responses: {
      200: { description: "Account", content: { "application/json": { schema: Account } } },
      401: error("Missing or invalid token"),
      404: error("Account not provisioned"),
    },
  });

  registry.registerPath({
    method: "post",
    path: "/api/v1/me",
    operationId: "provisionMe",
    summary: "Create the D-Card account for the signed-in Firebase user (idempotent)",
    security: [{ [bearer.name]: [] }],
    responses: {
      200: { description: "Account already existed", content: { "application/json": { schema: Account } } },
      201: { description: "Account created", content: { "application/json": { schema: Account } } },
      401: error("Missing or invalid token"),
    },
  });

  return new OpenApiGeneratorV31(registry.definitions).generateDocument({
    openapi: "3.1.0",
    info: { title: "D-Card API", version: "0.1.0" },
    servers: [{ url: "/" }],
  }) as unknown as OpenApiDocument;
}

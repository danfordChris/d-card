// JSON shapes of GET /api/v1/events/{id}/audit (dates as ISO strings).

export type AuditChange = { field: string; from: string | null; to: string | null };

export type AuditEntry = {
  id: string;
  createdAt: string;
  action: string;
  actorType: "user" | "system";
  actorName: string | null;
  targetType: string;
  targetId: string | null;
  changes: AuditChange[];
};

export type AuditPage = { entries: AuditEntry[]; nextCursor: string | null };

export type ExportKind = "guests" | "contributions" | "attendance";

/** Filter groups shown in the action filter; each is a dotted prefix understood by the API. */
export const AUDIT_GROUPS = [
  "event",
  "guest",
  "card",
  "pledge",
  "payment",
  "refund",
  "confirmation",
  "door",
  "walkin",
  "team",
  "message",
  "billing",
  "media",
  "export",
] as const;
export type AuditGroup = (typeof AUDIT_GROUPS)[number];

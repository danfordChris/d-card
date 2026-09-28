export const WALK_IN_STATUSES = ["pending", "approved", "refused", "admitted_offline", "accepted", "flagged"] as const;
export type WalkInStatus = (typeof WALK_IN_STATUSES)[number];
export type WalkInDecision = "approve" | "refuse" | "accept" | "flag";

// Mirrors GET /api/v1/events/{id}/walk-ins (dates as ISO strings).
export type WalkIn = {
  id: string;
  eventId: string;
  status: WalkInStatus;
  description: string;
  invitationId: string | null;
  guestName: string | null;
  admittedCount: number;
  source: "online" | "offline";
  offlineReason: string | null;
  requestedBy: string | null;
  deviceName: string | null;
  decidedBy: string | null;
  decidedAt: string | null;
  occurredAt: string;
};

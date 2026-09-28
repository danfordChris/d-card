// JSON shape of GET /api/v1/events/{id}/dashboard (core getEventDashboard; dates as ISO strings).

export type DashboardDevice = {
  id: string;
  name: string | null;
  staffName: string | null;
  lastSeenAt: string;
  lastSyncAt: string | null;
  pendingCount: number;
  revoked: boolean;
  stale: boolean;
};

export type OverUsedAlert = {
  invitationId: string;
  guestName: string;
  cardNumber: string | null;
  totalEntries: number;
  entriesUsed: number;
  at: string;
};

export type LockoutAlert = {
  id: string;
  deviceName: string | null;
  staffName: string | null;
  source: "online" | "offline";
  at: string;
};

export type Dashboard = {
  eventId: string;
  title: string;
  startsAt: string;
  access: "host" | "committee" | "treasurer" | "door_staff" | "walkin_approver";
  admitted: { total: number; cards: number; walkIns: number; online: number; offline: number };
  confirmations: {
    counts: { total: number; yes: number; no: number; none: number };
    totalEntries: number;
    expectedHeadcount: number;
    headcountPct: number;
  };
  cards: { issued: number; checkedIn: number; notArrived: number };
  walkIns: { pending: number; needsReview: number };
  devices: DashboardDevice[];
  alerts: { overUsed: OverUsedAlert[]; lockouts: LockoutAlert[] };
  version: string;
};

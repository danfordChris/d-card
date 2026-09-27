// Admin panel (T06-03) and cost report (T06-05) response shapes. They mirror
// packages/api-contract/src/admin-platform.ts; kept local so the admin bundle stays free of zod.

export type TotpStatus = { enrolled: boolean; verified: boolean; recoveryCodesLeft: number };
export type TotpEnrolment = { secret: string; otpauthUri: string };

export type Paged<T> = { items: T[]; page: number; pageSize: number; hasMore: boolean };

export type AdminUser = {
  id: string;
  email: string | null;
  phone: string | null;
  name: string | null;
  authProvider: "password" | "google" | "apple";
  isAdmin: boolean;
  disabledAt: string | null;
  deletedAt: string | null;
  createdAt: string;
  eventsHosted: number;
  teamRoles: number;
};

export type AdminEvent = {
  id: string;
  title: string;
  hostEmail: string | null;
  startsAt: string;
  status: "draft" | "published" | "completed" | "cancelled";
  planKey: string | null;
  guestLimit: number;
  amountPaid: number;
  guests: number;
  cardsIssued: number;
  messagesSent: number;
  createdAt: string;
};

export type AdminAuditEntry = {
  id: string;
  createdAt: string;
  actorType: "user" | "system";
  actorUserId: string | null;
  actorEmail: string | null;
  eventId: string | null;
  action: string;
  targetType: string;
  targetId: string | null;
  oldValue: unknown;
  newValue: unknown;
  ip: string | null;
};

export type QueueStats = { name: string; waiting: number; active: number; delayed: number; failed: number; completed: number };

export type CostLine = {
  revenue: number;
  whatsappMessages: number;
  whatsappCost: number;
  smsMessages: number;
  smsCost: number;
  uncostedMessages: number;
  paymentFee: number;
  margin: number;
  marginPct: number | null;
};

export type CostReport = {
  from: string;
  to: string;
  feePercent: number;
  events: (CostLine & { eventId: string; title: string; startsAt: string; planKey: string | null; cardsPaid: number })[];
  byPlan: (CostLine & { planKey: string })[];
  byMonth: (CostLine & { month: string })[];
  total: CostLine;
};

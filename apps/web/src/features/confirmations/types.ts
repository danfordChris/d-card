export type ConfirmationStatus = "none" | "yes" | "no";

export type ConfirmationGuest = {
  id: string;
  name: string;
  phone: string;
  partnerName: string | null;
  cardType: "single" | "double";
  totalEntries: number;
  confirmationStatus: ConfirmationStatus;
  confirmationAt: string | null;
  confirmationSource: string | null;
};

export type ConfirmationList = {
  guests: ConfirmationGuest[];
  counts: { total: number; yes: number; no: number; none: number };
  totalEntries: number;
  expectedHeadcount: number;
  headcountPct: number;
};

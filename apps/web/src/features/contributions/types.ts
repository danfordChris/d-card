export type PledgeStatus = "not_paid" | "part_paid" | "fully_paid";
export type StatusFilter = PledgeStatus | "cancelled";
export type PaymentMethod = "mpesa" | "mixx_by_yas" | "airtel_money" | "halopesa" | "bank" | "cash" | "other";
export const PAYMENT_METHODS: PaymentMethod[] = ["mpesa", "mixx_by_yas", "airtel_money", "halopesa", "bank", "cash", "other"];

export type Pledge = {
  id: string;
  guestId: string;
  name: string;
  phone: string;
  partnerName: string | null;
  cardType: "single" | "double";
  amountPledged: number;
  amountPaid: number;
  amountExtra: number;
  balance: number;
  status: PledgeStatus;
  upgradedAt: string | null;
  invitationStatus: "pending" | "issued" | "cancelled";
  cardNumber: string | null;
};

export type Payment = {
  id: string;
  kind: "payment" | "refund";
  amount: number;
  method: PaymentMethod;
  reference: string | null;
  paidOn: string;
};

export type Summary = {
  pledged: number;
  collected: number;
  outstanding: number;
  extras: number;
  refunds: number;
  budget: number | null;
  counts: Record<StatusFilter, number>;
};

export const rowStatus = (p: Pledge): StatusFilter => (p.invitationStatus === "cancelled" ? "cancelled" : p.status);

export function tsh(amount: number): string {
  return `Tsh ${amount.toLocaleString("en-US")}`;
}

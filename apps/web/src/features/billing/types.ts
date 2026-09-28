// Web-side shapes for host billing (T05-02). They mirror BillingSummary, BillingQuote,
// PaymentAttempt, HostPayment and BillingSettings in @dcard/api-contract (billing.ts).
// Money is whole TZS.

export type PlanKey = "msingi" | "kawaida" | "premium";
export type HostPaymentMethod = "mobile" | "session";
export type PaymentStatus = "pending" | "completed" | "failed" | "expired";

export interface BillingPlan {
  key: string;
  name: string;
  pricePerGuest: number;
}

export interface BillingQuoteLine {
  /** new_cards | extra_cards | upgrade | minimum_top_up */
  code: string;
  quantity: number;
  unitPrice: number;
  amount: number;
}

export interface BillingQuote {
  planKey: PlanKey;
  planName: string;
  pricePerGuest: number;
  currentGuestCards: number;
  guestCards: number;
  blockSize: number;
  minimumCharge: number;
  lines: BillingQuoteLine[];
  subtotal: number;
  discountPercent: number;
  discountAmount: number;
  total: number;
  payable: boolean;
}

export interface PaymentAttempt {
  id: string;
  status: PaymentStatus;
  method: HostPaymentMethod;
  amount: number;
  planKey: PlanKey;
  guestCards: number;
  phone: string | null;
  checkoutUrl: string | null;
  reference: string | null;
  failureReason: string | null;
  createdAt: string;
  completedAt: string | null;
}

export interface HostPayment {
  id: string;
  planKey: PlanKey;
  guestCards: number;
  amount: number;
  discountAmount: number;
  method: string;
  reference: string;
  paidAt: string;
}

export interface BillingSummary {
  planKey: PlanKey;
  planName: string;
  pricePerGuest: number;
  guestLimit: number;
  amountPaid: number;
  paid: boolean;
  issuedCards: number;
  guestCount: number;
  launchOfferPercent: number;
  launchOfferEligible: boolean;
  pendingAttempt: PaymentAttempt | null;
  payments: HostPayment[];
}

export interface BillingQuoteBody {
  planKey?: string | null;
  guestCards: number;
}

export interface CheckoutBody {
  planKey?: string | null;
  guestCards: number;
  method: HostPaymentMethod;
  phone?: string | null;
  expectedTotal: number;
}

export interface BillingSettings {
  launchOfferEnabled: boolean;
  launchOfferPercent: number;
}

/** Which entry point opened the checkout. */
export type CheckoutMode = "buy" | "add" | "upgrade";

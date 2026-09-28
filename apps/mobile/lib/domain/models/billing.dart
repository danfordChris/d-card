/// Plans and billing (docs/design/features/plans-and-billing.md). Money is whole TZS.
library;

/// A plan the host can choose (`GET /api/v1/plans`).
class PlanOption {
  const PlanOption({required this.key, required this.name, required this.pricePerGuest});

  final String key;
  final String name;
  final int pricePerGuest;
}

enum PaymentAttemptStatus { pending, completed, failed, expired }

/// How the host pays: USSD push to a mobile-money number, or a hosted payment page.
enum CheckoutMethod { mobile, session }

/// One checkout started with the payment provider.
class PaymentAttempt {
  const PaymentAttempt({
    required this.id,
    required this.status,
    required this.method,
    required this.amount,
    required this.planKey,
    required this.guestCards,
    required this.createdAt,
    this.phone,
    this.checkoutUrl,
    this.reference,
    this.failureReason,
    this.completedAt,
  });

  final String id;
  final PaymentAttemptStatus status;
  final CheckoutMethod method;
  final int amount;
  final String planKey;
  final int guestCards;
  final String? phone;
  final String? checkoutUrl;
  final String? reference;
  final String? failureReason;
  final DateTime createdAt;
  final DateTime? completedAt;

  bool get isPending => status == PaymentAttemptStatus.pending;
}

/// A completed host payment (receipt).
class HostPaymentReceipt {
  const HostPaymentReceipt({
    required this.id,
    required this.planKey,
    required this.guestCards,
    required this.amount,
    required this.discountAmount,
    required this.method,
    required this.reference,
    required this.paidAt,
  });

  final String id;
  final String planKey;
  final int guestCards;
  final int amount;
  final int discountAmount;
  final String method;
  final String reference;
  final DateTime paidAt;
}

/// What the event has paid for (`GET /api/v1/events/{id}/billing`).
class BillingSummary {
  const BillingSummary({
    required this.planKey,
    required this.planName,
    required this.pricePerGuest,
    required this.guestLimit,
    required this.amountPaid,
    required this.paid,
    required this.issuedCards,
    required this.guestCount,
    required this.launchOfferPercent,
    required this.launchOfferEligible,
    required this.payments,
    this.pendingAttempt,
  });

  final String planKey;
  final String planName;
  final int pricePerGuest;

  /// Guest cards paid for (0 before the first payment).
  final int guestLimit;
  final int amountPaid;
  final bool paid;
  final int issuedCards;
  final int guestCount;
  final int launchOfferPercent;
  final bool launchOfferEligible;
  final PaymentAttempt? pendingAttempt;
  final List<HostPaymentReceipt> payments;
}

enum QuoteLineKind { newCards, extraCards, upgrade, other }

class QuoteLine {
  const QuoteLine({required this.kind, required this.quantity, required this.unitPrice, required this.amount});

  final QuoteLineKind kind;
  final int quantity;
  final int unitPrice;
  final int amount;
}

/// The server's price for a plan and a number of cards (`POST .../billing/quote`).
class BillingQuote {
  const BillingQuote({
    required this.planKey,
    required this.planName,
    required this.pricePerGuest,
    required this.currentGuestCards,
    required this.guestCards,
    required this.blockSize,
    required this.minimumCharge,
    required this.lines,
    required this.subtotal,
    required this.discountPercent,
    required this.discountAmount,
    required this.total,
    required this.payable,
  });

  final String planKey;
  final String planName;
  final int pricePerGuest;
  final int currentGuestCards;

  /// Cards after the minimum charge and blocks of [blockSize] are applied.
  final int guestCards;
  final int blockSize;
  final int minimumCharge;
  final List<QuoteLine> lines;
  final int subtotal;
  final int discountPercent;
  final int discountAmount;
  final int total;
  final bool payable;
}

/// Why the server refused to start a checkout.
enum CheckoutRejection {
  quoteChanged,
  nothingToPay,
  paymentInProgress,
  providerUnavailable,
  eventClosed,
  invalid,
  forbidden,
}

class CheckoutRejectedException implements Exception {
  const CheckoutRejectedException(this.reason);

  final CheckoutRejection reason;

  @override
  String toString() => 'CheckoutRejectedException($reason)';
}

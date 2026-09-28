/// Pledge progress (docs/design/features/contributions.md › Pledge States).
enum PledgeStatus { notPaid, partPaid, fullyPaid }

/// One contributor's pledge as the treasurer sees it (CON-3).
class Contributor {
  const Contributor({
    required this.id,
    required this.name,
    required this.phone,
    required this.isDouble,
    required this.pledged,
    required this.paid,
    required this.balance,
    required this.extra,
    required this.status,
    required this.cancelled,
    this.cardNumber,
  });

  final String id;
  final String name;
  final String phone;
  final bool isDouble;
  final int pledged;
  final int paid;
  final int balance;
  final int extra;
  final PledgeStatus status;
  final bool cancelled;
  final String? cardNumber;
}

class ContributionTotals {
  const ContributionTotals({required this.pledged, required this.collected, required this.outstanding});

  final int pledged;
  final int collected;
  final int outstanding;
}

enum PaymentMethod { mpesa, mixxByYas, airtelMoney, halopesa, bank, cash, other }

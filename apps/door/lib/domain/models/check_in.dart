/// How the card was found at the door (sent with each entry).
enum CheckInMethod { qr, cardNumber, name }

enum CardType { single, double }

enum CardStatus { pending, issued, cancelled }

/// One past admission on a card (shown for "Card fully used").
class CardEntry {
  const CardEntry({
    required this.occurredAt,
    required this.admittedCount,
    required this.method,
    this.deviceName,
    this.staffName,
  });

  final DateTime occurredAt;
  final int admittedCount;
  final CheckInMethod method;
  final String? deviceName;
  final String? staffName;
}

/// A card as the door sees it (CHK-2).
class CheckInCard {
  const CheckInCard({
    required this.invitationId,
    required this.guestName,
    required this.cardType,
    required this.status,
    required this.totalEntries,
    required this.entriesUsed,
    required this.entriesLeft,
    this.partnerName,
    this.cardNumber,
    this.table,
    this.overUsed = false,
    this.entries = const [],
  });

  final String invitationId;
  final String guestName;
  final String? partnerName;
  final String? cardNumber;
  final CardType cardType;
  final CardStatus status;
  final int totalEntries;
  final int entriesUsed;
  final int entriesLeft;
  final String? table;
  final bool overUsed;
  final List<CardEntry> entries;

  /// The refusal this card would get if admitted now, or null when it can be admitted.
  RefusalReason? get refusal {
    if (status == CardStatus.cancelled) return RefusalReason.cancelled;
    if (status == CardStatus.pending) return RefusalReason.notIssued;
    if (entriesLeft <= 0) return RefusalReason.fullyUsed;
    return null;
  }
}

/// Why the door refused (CHK-4, CHK-5).
enum RefusalReason { notFound, fullyUsed, cancelled, notIssued, tooMany, locked }

/// The server refused a lookup or an entry; [card] is set when the card is known.
class DoorRefusedException implements Exception {
  const DoorRefusedException(this.reason, {this.card, this.lockedUntil});

  final RefusalReason reason;
  final CheckInCard? card;

  /// For [RefusalReason.locked]: when card-number entry opens again.
  final DateTime? lockedUntil;

  @override
  String toString() => 'DoorRefusedException($reason)';
}

/// Turns a scanned QR value into the card link token the API expects.
///
/// Cards encode the raw token; if a scanner returns a card URL instead
/// (`https://…/c/<token>`), the last path segment is the token.
String qrTokenFrom(String scanned) {
  final value = scanned.trim();
  if (!value.toLowerCase().startsWith('http')) return value;
  final uri = Uri.tryParse(value);
  final segments = uri?.pathSegments.where((s) => s.isNotEmpty).toList() ?? const [];
  return segments.isEmpty ? value : segments.last;
}

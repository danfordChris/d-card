/// A guest's card as shown in "My cards" and on the card view (AUTH-4, AUTH-5, GST-12).
enum CardStatus { issued, cancelled }

enum RsvpAnswer { none, yes, no }

/// One row of `GET /api/v1/me/cards`.
class MyCard {
  const MyCard({
    required this.eventTitle,
    required this.startsAt,
    required this.timeZone,
    required this.guestName,
    required this.isDouble,
    required this.cardNumber,
    required this.status,
    required this.rsvp,
    required this.linkToken,
    this.endsAt,
    this.venueName,
  });

  final String eventTitle;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String timeZone;
  final String? venueName;
  final String guestName;
  final bool isDouble;
  final String cardNumber;
  final CardStatus status;
  final RsvpAnswer rsvp;
  final String linkToken;
}

/// The guest's RSVP on a card; [open] is false once the event has started.
class RsvpState {
  const RsvpState({required this.answer, required this.open, this.dietaryNotes});

  final RsvpAnswer answer;
  final bool open;
  final String? dietaryNotes;
}

/// The public card by link token (`GET /api/v1/cards/{token}`), viewable without login.
class GuestCard {
  const GuestCard({
    required this.status,
    required this.guestName,
    required this.isDouble,
    required this.cardNumber,
    required this.rsvp,
    required this.eventTitle,
    required this.eventTypeSw,
    required this.eventTypeEn,
    required this.startsAt,
    required this.contactName,
    required this.contactPhone,
    this.partnerName,
    this.qrToken,
    this.endsAt,
    this.venueName,
    this.venueAddress,
    this.venueMapUrl,
    this.eventCancelled = false,
  });

  final CardStatus status;
  final String guestName;
  final String? partnerName;
  final bool isDouble;
  final String cardNumber;

  /// What the door scans; null when the card is cancelled.
  final String? qrToken;
  final RsvpState rsvp;
  final String eventTitle;
  final String eventTypeSw;
  final String eventTypeEn;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? venueName;
  final String? venueAddress;
  final String? venueMapUrl;
  final String contactName;
  final String contactPhone;
  final bool eventCancelled;

  String eventType(String languageCode) => languageCode == 'sw' ? eventTypeSw : eventTypeEn;

  GuestCard withRsvp(RsvpState next) => GuestCard(
    status: status,
    guestName: guestName,
    partnerName: partnerName,
    isDouble: isDouble,
    cardNumber: cardNumber,
    qrToken: qrToken,
    rsvp: next,
    eventTitle: eventTitle,
    eventTypeSw: eventTypeSw,
    eventTypeEn: eventTypeEn,
    startsAt: startsAt,
    endsAt: endsAt,
    venueName: venueName,
    venueAddress: venueAddress,
    venueMapUrl: venueMapUrl,
    contactName: contactName,
    contactPhone: contactPhone,
    eventCancelled: eventCancelled,
  );
}

/// Why linking a card was refused (`POST /api/v1/me/cards/link`).
enum LinkRefusal {
  /// The text is not a card link or token.
  invalidLink,

  /// No card has this link.
  notFound,

  /// The guest on this card already uses another D-Card account (409 `person_linked`).
  personLinked,

  /// This account already belongs to a different guest (409 `account_linked`).
  accountLinked,
}

class LinkRefusedException implements Exception {
  const LinkRefusedException(this.refusal);

  final LinkRefusal refusal;

  @override
  String toString() => 'LinkRefusedException($refusal)';
}

/// Why an RSVP was refused (`POST /api/v1/cards/{token}/rsvp`).
enum RsvpRefusal { closed, tooMany }

class RsvpRefusedException implements Exception {
  const RsvpRefusedException(this.refusal);

  final RsvpRefusal refusal;
}

/// Pulls the link token out of a pasted card link (`https://…/c/<token>`) or a bare token.
/// Returns null when the text is neither.
String? parseCardToken(String input) {
  final text = input.trim();
  if (text.isEmpty) return null;
  final token = RegExp(r'^[A-Za-z0-9_-]{20,100}$');
  if (token.hasMatch(text)) return text;
  final uri = Uri.tryParse(text.contains('://') ? text : 'https://$text');
  if (uri == null) return null;
  final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
  final i = segments.indexOf('c');
  if (i < 0 || i + 1 >= segments.length) return null;
  final candidate = segments[i + 1];
  return token.hasMatch(candidate) ? candidate : null;
}

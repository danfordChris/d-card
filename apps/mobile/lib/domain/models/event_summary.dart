/// Event lifecycle states (docs/design/features/events.md).
enum EventStatus { draft, published, completed, cancelled }

/// What the host sees about an event in the list and summary screens.
class EventSummary {
  const EventSummary({
    required this.id,
    required this.title,
    required this.status,
    required this.typeNameSw,
    required this.typeNameEn,
    required this.planName,
    required this.startsAt,
    required this.contactName,
    required this.contactPhone,
    this.canManageGuests = false,
    this.canViewContributions = false,
    this.canRecordPayments = false,
    this.canViewWalkIns = false,
    this.canDecideWalkIns = false,
    this.isHost = false,
    this.planPaid = false,
    this.venueName,
    this.venueAddress,
    this.contact2Name,
    this.contact2Phone,
  });

  final String id;
  final String title;
  final EventStatus status;
  final String typeNameSw;
  final String typeNameEn;
  final String planName;
  final DateTime startsAt;
  final String? venueName;
  final String? venueAddress;
  final String contactName;
  final String contactPhone;
  final String? contact2Name;
  final String? contact2Phone;

  /// Host or committee on a draft/published event (GST-1, Access).
  final bool canManageGuests;

  /// Host, committee and treasurers see contribution amounts (CON-12).
  final bool canViewContributions;

  /// Host and treasurers record payments (CON-2).
  final bool canRecordPayments;

  /// Host, committee and walk-in approvers see walk-in requests (CHK-8).
  final bool canViewWalkIns;

  /// Host and walk-in approvers approve/refuse and review offline walk-ins; committee is read-only.
  final bool canDecideWalkIns;

  /// Only the host pays for the event (T05-03).
  final bool isHost;

  /// Guest cards have been paid for at least once.
  final bool planPaid;

  String typeName(String languageCode) => languageCode == 'sw' ? typeNameSw : typeNameEn;
}

/// Walk-in request states (docs/design/features/check-in.md › Walk-in Request States).
///
/// Online: `pending → approved | refused` (first approver to answer).
/// Offline: `admittedOffline → accepted | flagged` (reviewed after sync).
enum WalkInStatus { pending, approved, refused, admittedOffline, accepted, flagged }

/// Answers an approver can give: approve/refuse a pending request, accept/flag an offline one.
enum WalkInDecision { approve, refuse, accept, flag }

/// A person at the door without a valid card (or beyond their card's entries) (CHK-8, CHK-8a).
class WalkIn {
  const WalkIn({
    required this.id,
    required this.eventId,
    required this.status,
    required this.description,
    required this.admittedCount,
    required this.offline,
    required this.occurredAt,
    this.invitationId,
    this.guestName,
    this.offlineReason,
    this.requestedBy,
    this.deviceName,
    this.decidedBy,
    this.decidedAt,
  });

  final String id;
  final String eventId;
  final WalkInStatus status;
  final String description;

  /// 1 or 2 people.
  final int admittedCount;

  /// Admitted by the door while offline; synced for review.
  final bool offline;
  final DateTime occurredAt;
  final String? invitationId;

  /// Guest on the linked card, if any.
  final String? guestName;

  /// Staff's mandatory reason for an offline admission.
  final String? offlineReason;
  final String? requestedBy;
  final String? deviceName;
  final String? decidedBy;
  final DateTime? decidedAt;

  bool get isPending => status == WalkInStatus.pending;
  bool get needsReview => status == WalkInStatus.admittedOffline;
  bool get isOpen => isPending || needsReview;
}

/// Someone else answered first (409); carries the walk-in as they decided it.
class WalkInAlreadyDecided implements Exception {
  const WalkInAlreadyDecided(this.walkIn);

  final WalkIn walkIn;

  @override
  String toString() => 'WalkInAlreadyDecided(${walkIn.id}, ${walkIn.status})';
}

/// A walk-in push (FCM data `{type: "walk_in", eventId, walkInId, status}`).
class WalkInAlert {
  const WalkInAlert({required this.eventId, required this.walkInId, required this.status, required this.opened});

  final String eventId;
  final String walkInId;

  /// Null when the push carried an unknown status.
  final WalkInStatus? status;

  /// True when the user tapped the notification (app opened from it); false for a foreground message.
  final bool opened;
}

/// Walk-in states (check-in.md): online `pending → approved | refused`,
/// offline `admittedOffline → accepted | flagged`.
enum WalkInStatus { pending, approved, refused, admittedOffline, accepted, flagged }

WalkInStatus walkInStatusOf(Object? value) => switch (value) {
  'approved' => WalkInStatus.approved,
  'refused' => WalkInStatus.refused,
  'admitted_offline' => WalkInStatus.admittedOffline,
  'accepted' => WalkInStatus.accepted,
  'flagged' => WalkInStatus.flagged,
  _ => WalkInStatus.pending,
};

/// A walk-in request as the door sees it (CHK-8).
class WalkInRequest {
  const WalkInRequest({
    required this.id,
    required this.status,
    required this.description,
    required this.admittedCount,
    this.guestName,
    this.decidedBy,
  });

  factory WalkInRequest.fromJson(Map<String, dynamic> j) => WalkInRequest(
    id: j['id'] as String,
    status: walkInStatusOf(j['status']),
    description: (j['description'] as String?) ?? '',
    admittedCount: (j['admittedCount'] as num? ?? 1).toInt(),
    guestName: j['guestName'] as String?,
    decidedBy: j['decidedBy'] as String?,
  );

  final String id;
  final WalkInStatus status;
  final String description;
  final int admittedCount;
  final String? guestName;

  /// Who approved or refused (the first approver to answer).
  final String? decidedBy;

  bool get isDecided => status != WalkInStatus.pending;
}

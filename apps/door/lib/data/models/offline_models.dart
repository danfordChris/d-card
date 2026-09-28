import '../../domain/models/check_in.dart';
import '../../domain/models/door_event.dart';

/// A card in the offline cache (`DoorSyncCard` from `GET /api/v1/door/sync`, offline-sync 9.1).
///
/// [entriesUsed] is the server's count; [localUsed] adds this phone's entries the server
/// has not reflected yet, so offline decisions never re-admit a guest this phone let in.
class CachedCard {
  const CachedCard({
    required this.invitationId,
    required this.guestName,
    required this.cardType,
    required this.status,
    required this.totalEntries,
    required this.entriesUsed,
    this.partnerName,
    this.cardNumber,
    this.qrTokenDigest,
    this.table,
    this.overUsed = false,
    this.localUsed = 0,
    this.updatedAt,
  });

  factory CachedCard.fromJson(Map<String, dynamic> c) => CachedCard(
    invitationId: c['invitationId'] as String,
    guestName: c['guestName'] as String,
    partnerName: _blankToNull(c['partnerName']),
    cardNumber: _blankToNull(c['cardNumber']),
    qrTokenDigest: _blankToNull(c['qrTokenDigest'])?.toLowerCase(),
    cardType: c['cardType'] == 'double' ? CardType.double : CardType.single,
    status: cardStatusOf(c['status']),
    totalEntries: (c['totalEntries'] as num).toInt(),
    entriesUsed: (c['entriesUsed'] as num).toInt(),
    table: _blankToNull(c['table']),
    overUsed: c['overUsed'] == true,
    updatedAt: c['updatedAt'] as String?,
  );

  final String invitationId;
  final String guestName;
  final String? partnerName;
  final String? cardNumber;

  /// Lowercase hex SHA-256 of the raw QR token; null while the card is not issued.
  final String? qrTokenDigest;
  final CardType cardType;
  final CardStatus status;
  final int totalEntries;
  final int entriesUsed;
  final int localUsed;
  final String? table;
  final bool overUsed;
  final String? updatedAt;

  int get used => entriesUsed + localUsed;

  CheckInCard toCheckInCard() {
    final left = totalEntries - used;
    return CheckInCard(
      invitationId: invitationId,
      guestName: guestName,
      partnerName: partnerName,
      cardNumber: cardNumber,
      cardType: cardType,
      status: status,
      totalEntries: totalEntries,
      entriesUsed: used,
      entriesLeft: left < 0 ? 0 : left,
      table: table,
      overUsed: overUsed || used > totalEntries,
    );
  }
}

CardStatus cardStatusOf(Object? value) => switch (value) {
  'issued' => CardStatus.issued,
  'cancelled' => CardStatus.cancelled,
  _ => CardStatus.pending,
};

String cardStatusName(CardStatus s) => switch (s) {
  CardStatus.issued => 'issued',
  CardStatus.cancelled => 'cancelled',
  CardStatus.pending => 'pending',
};

String methodName(CheckInMethod m) => switch (m) {
  CheckInMethod.qr => 'qr',
  CheckInMethod.cardNumber => 'card_number',
  CheckInMethod.name => 'name',
};

CheckInMethod methodOf(Object? value) => switch (value) {
  'qr' => CheckInMethod.qr,
  'card_number' => CheckInMethod.cardNumber,
  _ => CheckInMethod.name,
};

/// Attempt outcomes the sync API accepts (`DoorSyncAttemptInput.outcome`).
String outcomeName(RefusalReason r) => switch (r) {
  RefusalReason.fullyUsed => 'fully_used',
  RefusalReason.cancelled => 'cancelled',
  RefusalReason.notIssued => 'not_issued',
  RefusalReason.tooMany => 'too_many',
  RefusalReason.notFound => 'not_found',
  RefusalReason.locked => 'locked',
};

/// An entry admitted offline, waiting to upload (immutable, device UUID; offline-sync 9.2).
class PendingEntry {
  const PendingEntry({
    required this.id,
    required this.deviceId,
    required this.invitationId,
    required this.admittedCount,
    required this.method,
    required this.occurredAt,
  });

  final String id;
  final String deviceId;
  final String invitationId;
  final int admittedCount;
  final CheckInMethod method;
  final DateTime occurredAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'invitationId': invitationId,
    'admittedCount': admittedCount,
    'method': methodName(method),
    'occurredAt': occurredAt.toUtc().toIso8601String(),
  };
}

/// A refusal or lockout decided offline, reported on sync.
class PendingAttempt {
  const PendingAttempt({
    required this.id,
    required this.deviceId,
    required this.method,
    required this.outcome,
    required this.occurredAt,
    this.invitationId,
    this.query,
  });

  final String id;
  final String deviceId;
  final String? invitationId;
  final CheckInMethod method;

  /// What staff typed (card number or name); never the QR token.
  final String? query;
  final RefusalReason outcome;
  final DateTime occurredAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'invitationId': ?invitationId,
    'method': methodName(method),
    'query': ?query,
    'outcome': outcomeName(outcome),
    'occurredAt': occurredAt.toUtc().toIso8601String(),
  };
}

/// A walk-in admitted without network, with the mandatory reason (CHK-8a).
class PendingWalkIn {
  const PendingWalkIn({
    required this.id,
    required this.deviceId,
    required this.description,
    required this.admittedCount,
    required this.offlineReason,
    required this.occurredAt,
    this.invitationId,
  });

  final String id;
  final String deviceId;
  final String description;
  final String? invitationId;
  final int admittedCount;
  final String offlineReason;
  final DateTime occurredAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'description': description,
    'invitationId': ?invitationId,
    'admittedCount': admittedCount,
    'offlineReason': offlineReason,
    'occurredAt': occurredAt.toUtc().toIso8601String(),
  };
}

/// One upload for one device ID.
class PendingBatch {
  const PendingBatch({required this.deviceId, this.entries = const [], this.attempts = const [], this.walkIns = const []});

  final String deviceId;
  final List<PendingEntry> entries;
  final List<PendingAttempt> attempts;
  final List<PendingWalkIn> walkIns;

  bool get isEmpty => entries.isEmpty && attempts.isEmpty && walkIns.isEmpty;
}

/// Someone who can approve walk-ins (the host first).
class Approver {
  const Approver({required this.userId, required this.name});

  final String userId;
  final String name;
}

/// `GET /api/v1/door/sync`.
class SyncSnapshot {
  const SyncSnapshot({
    required this.eventId,
    required this.full,
    required this.cards,
    required this.approvers,
    required this.cursor,
    required this.wipeAfter,
  });

  factory SyncSnapshot.fromJson(Map<String, dynamic> j) => SyncSnapshot(
    eventId: j['eventId'] as String,
    full: j['full'] == true,
    cards: [for (final c in (j['cards'] as List? ?? const []).cast<Map<String, dynamic>>()) CachedCard.fromJson(c)],
    approvers: [
      for (final a in (j['approvers'] as List? ?? const []).cast<Map<String, dynamic>>())
        Approver(userId: a['userId'] as String, name: (a['name'] as String?) ?? ''),
    ],
    cursor: j['cursor'] as String,
    wipeAfter: DateTime.parse(j['wipeAfter'] as String),
  );

  final String eventId;
  final bool full;
  final List<CachedCard> cards;
  final List<Approver> approvers;
  final String cursor;
  final DateTime wipeAfter;
}

/// `POST /api/v1/door/sync` result.
class SyncUploadResult {
  const SyncUploadResult({
    this.entriesAccepted = 0,
    this.entriesDuplicate = 0,
    this.entriesRejected = const [],
    this.attemptsAccepted = 0,
    this.walkInsAccepted = 0,
    this.overUsed = const [],
  });

  factory SyncUploadResult.fromJson(Map<String, dynamic> j) => SyncUploadResult(
    entriesAccepted: (j['entriesAccepted'] as num? ?? 0).toInt(),
    entriesDuplicate: (j['entriesDuplicate'] as num? ?? 0).toInt(),
    entriesRejected: (j['entriesRejected'] as List? ?? const []).cast<String>(),
    attemptsAccepted: (j['attemptsAccepted'] as num? ?? 0).toInt(),
    walkInsAccepted: (j['walkInsAccepted'] as num? ?? 0).toInt(),
    overUsed: (j['overUsed'] as List? ?? const []).cast<String>(),
  );

  final int entriesAccepted;
  final int entriesDuplicate;
  final List<String> entriesRejected;
  final int attemptsAccepted;
  final int walkInsAccepted;
  final List<String> overUsed;
}

/// What the cache remembers about the event it holds (so the door can reopen it offline).
class CacheState {
  const CacheState({
    required this.event,
    required this.deviceId,
    this.deviceName,
    this.cursor,
    this.wipeAfter,
    this.lastSyncAt,
    this.approvers = const [],
  });

  final DoorEvent event;
  final String deviceId;
  final String? deviceName;
  final String? cursor;
  final DateTime? wipeAfter;
  final DateTime? lastSyncAt;
  final List<Approver> approvers;

  DoorSession get session => DoorSession(event: event, deviceId: deviceId, deviceName: deviceName);
}

String? _blankToNull(Object? v) => v is String && v.trim().isNotEmpty ? v : null;

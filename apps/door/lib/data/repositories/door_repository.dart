import 'dart:convert';
import 'dart:io';

import 'package:dcard_api/api.dart' as api;
import 'package:http/http.dart' as http;

import '../../domain/models/app_failure.dart';
import '../../domain/models/check_in.dart';
import '../../domain/models/door_event.dart';
import '../../domain/models/walk_in.dart';
import '../models/offline_models.dart';
import '../services/door_device_store.dart';
import '../services/uuid.dart';
import 'api_errors.dart';

/// What to look a card up by (exactly one per request).
sealed class CardQuery {
  const CardQuery();

  CheckInMethod get method;
}

class QrQuery extends CardQuery {
  const QrQuery(this.scanned);

  /// The raw scanned value; see [qrTokenFrom].
  final String scanned;

  @override
  CheckInMethod get method => CheckInMethod.qr;
}

class CardNumberQuery extends CardQuery {
  const CardNumberQuery(this.cardNumber);

  final String cardNumber;

  @override
  CheckInMethod get method => CheckInMethod.cardNumber;
}

class NameQuery extends CardQuery {
  const NameQuery(this.name);

  final String name;

  @override
  CheckInMethod get method => CheckInMethod.name;
}

/// Online door check-in (`/api/v1/door/*`, CHK-1…CHK-5, AUTH-9).
///
/// Responses are decoded here rather than by the generated models so that refusal bodies
/// (404/409/423 with the card) and nullable fields map cleanly to domain models.
/// Failures surface as [DoorRefusedException] (the card was refused) or [AppException]
/// ([AppFailure.doorAccessDenied] on 403: device revoked or no door access).
class DoorRepository {
  DoorRepository(this._api, this._devices, {String Function()? newEntryId, DateTime Function()? clock})
    : _newEntryId = newEntryId ?? uuidV4,
      _now = clock ?? DateTime.now;

  final api.DefaultApi _api;
  final DoorDeviceStore _devices;
  final String Function() _newEntryId;
  final DateTime Function() _now;

  /// Server time minus this phone's time, from the `Date` header of the last API response;
  /// null until a response carried one. Offline entry times and the lockout rely on the
  /// phone's clock, so the door warns when this drifts (see [clockSkewed]).
  Duration? clockSkew;

  /// Beyond this the phone's clock is treated as wrong (the header has 1 s resolution).
  static const clockSkewTolerance = Duration(minutes: 5);

  bool get clockSkewed => clockSkew != null && clockSkew!.abs() > clockSkewTolerance;

  /// A server timestamp (e.g. `lockedUntil`) on this phone's clock.
  DateTime toLocalClock(DateTime serverTime) => clockSkew == null ? serverTime : serverTime.subtract(clockSkew!);

  String? get deviceName => _devices.deviceName;

  Future<void> setDeviceName(String? name) => _devices.setDeviceName(name);

  /// Events the user may check guests in for.
  Future<List<DoorEvent>> listEvents() async {
    final body = await _send(_api.listDoorEventsWithHttpInfo);
    final events = (body['events'] as List? ?? const []).cast<Map<String, dynamic>>();
    return events.map(_toEvent).toList();
  }

  /// Registers this phone for [event] (idempotent per device ID) and returns the door session.
  Future<DoorSession> openEvent(DoorEvent event) async {
    final deviceId = await _devices.deviceIdFor(event.id);
    final name = _devices.deviceName;
    await _send(
      () => _api.registerDoorDeviceWithHttpInfo(
        doorDeviceRegisterInput: _CompactDeviceInput(eventId: event.id, deviceId: deviceId, name: name),
      ),
    );
    return DoorSession(event: event, deviceId: deviceId, deviceName: name);
  }

  /// Finds cards; QR and card number return at most one, name search may return several.
  Future<List<CheckInCard>> lookup(DoorSession session, CardQuery query) async {
    final input = _CompactLookupInput(
      deviceId: session.deviceId,
      qrToken: query is QrQuery ? qrTokenFrom(query.scanned) : null,
      cardNumber: query is CardNumberQuery ? query.cardNumber.trim() : null,
      name: query is NameQuery ? query.name.trim() : null,
    );
    final body = await _send(() => _api.doorLookupWithHttpInfo(doorLookupInput: input));
    return (body['cards'] as List? ?? const []).cast<Map<String, dynamic>>().map(cardFromJson).toList();
  }

  /// A new entry ID for one Admit tap; reuse it when retrying the same tap after a network error.
  String newEntryId() => _newEntryId();

  /// Admits [count] (1 or 2) on a card and returns the updated card.
  Future<CheckInCard> admit(
    DoorSession session, {
    required String entryId,
    required String invitationId,
    required int count,
    required CheckInMethod method,
  }) async {
    final body = await _send(
      () => _api.doorAdmitWithHttpInfo(
        doorEntryInput: api.DoorEntryInput(
          id: entryId,
          deviceId: session.deviceId,
          invitationId: invitationId,
          admittedCount: count,
          method: _methodToApi(method),
        ),
      ),
    );
    return cardFromJson((body['card'] as Map).cast<String, dynamic>());
  }

  /// The offline cache for [deviceId]'s event: full without [since], changes only with it.
  Future<SyncSnapshot> syncDownload(String deviceId, {String? since, int? pending}) async {
    final body = await _send(() => _api.doorSyncDownloadWithHttpInfo(deviceId, since: since, pending: pending));
    return SyncSnapshot.fromJson(body);
  }

  /// Uploads offline entries, attempts and walk-ins (idempotent: resending the same IDs is safe).
  Future<SyncUploadResult> syncUpload(PendingBatch batch, {required int pending}) async {
    final body = await _send(
      () => _api.doorSyncUploadWithHttpInfo(
        doorSyncUpload: _RawSyncUpload({
          'deviceId': batch.deviceId,
          'entries': [for (final e in batch.entries) e.toJson()],
          'attempts': [for (final a in batch.attempts) a.toJson()],
          'walkIns': [for (final w in batch.walkIns) w.toJson()],
          'pending': pending,
        }),
      ),
    );
    return SyncUploadResult.fromJson(body);
  }

  /// Asks the host and walk-in approvers (CHK-8); resending the same [id] returns the same request.
  Future<WalkInRequest> requestWalkIn(
    DoorSession session, {
    required String id,
    required String description,
    required int count,
    String? invitationId,
  }) async {
    final body = await _send(
      () => _api.doorRequestWalkInWithHttpInfo(
        walkInCreateInput: _CompactWalkInInput(
          id: id,
          deviceId: session.deviceId,
          description: description.trim(),
          invitationId: invitationId,
          admittedCount: count,
        ),
      ),
    );
    return WalkInRequest.fromJson(body);
  }

  /// The current state of a walk-in this device asked for.
  Future<WalkInRequest> getWalkIn(DoorSession session, String id) async =>
      WalkInRequest.fromJson(await _send(() => _api.doorGetWalkInWithHttpInfo(id, session.deviceId)));

  Future<Map<String, dynamic>> _send(Future<http.Response> Function() call) async {
    final http.Response response;
    try {
      response = await call();
    } on api.ApiException catch (e) {
      throw AppException(failureOf(e));
    } on SocketException {
      throw const AppException(AppFailure.network);
    } on HttpException {
      throw const AppException(AppFailure.network);
    }
    _recordServerTime(response.headers['date']);
    final Object? decoded;
    try {
      decoded = response.bodyBytes.isEmpty ? null : jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const AppException(AppFailure.unknown);
    }
    final body = decoded is Map ? decoded.cast<String, dynamic>() : <String, dynamic>{};
    final status = response.statusCode;
    if (status < 400) return body;
    if (status == 401) throw const AppException(AppFailure.unauthorized);
    if (status == 403) throw const AppException(AppFailure.doorAccessDenied);
    final code = (body['error'] as Map?)?['code'];
    if (status == 409 && code == 'plan_limit') throw const AppException(AppFailure.doorPlanLimit);
    final reason = switch (code) {
      'not_found' => RefusalReason.notFound,
      'fully_used' => RefusalReason.fullyUsed,
      'cancelled' => RefusalReason.cancelled,
      'not_issued' => RefusalReason.notIssued,
      'too_many' => RefusalReason.tooMany,
      'locked' => RefusalReason.locked,
      _ => null,
    };
    if (reason == null) throw const AppException(AppFailure.unknown);
    final card = body['card'];
    final lockedUntil = body['lockedUntil'];
    throw DoorRefusedException(
      reason,
      card: card is Map ? cardFromJson(card.cast<String, dynamic>()) : null,
      lockedUntil: lockedUntil is String ? DateTime.tryParse(lockedUntil) : null,
    );
  }

  void _recordServerTime(String? header) {
    if (header == null || header.isEmpty) return;
    try {
      clockSkew = HttpDate.parse(header).difference(_now());
    } on FormatException {
      // Not an HTTP date: keep the last known skew.
    } on HttpException {
      // Same.
    }
  }

  static DoorEvent _toEvent(Map<String, dynamic> e) => DoorEvent(
    id: e['id'] as String,
    title: e['title'] as String,
    startsAt: DateTime.parse(e['startsAt'] as String),
    endsAt: e['endsAt'] == null ? null : DateTime.parse(e['endsAt'] as String),
    venueName: e['venueName'] as String?,
    role: switch (e['role']) {
      'host' => DoorRole.host,
      'committee' => DoorRole.committee,
      _ => DoorRole.doorStaff,
    },
  );

  static api.CheckInMethod _methodToApi(CheckInMethod m) => switch (m) {
    CheckInMethod.qr => api.CheckInMethod.qr,
    CheckInMethod.cardNumber => api.CheckInMethod.cardNumber,
    CheckInMethod.name => api.CheckInMethod.name,
  };
}

/// Maps a `DoorCard` JSON object to the domain card.
CheckInCard cardFromJson(Map<String, dynamic> c) => CheckInCard(
  invitationId: c['invitationId'] as String,
  guestName: c['guestName'] as String,
  partnerName: _blankToNull(c['partnerName']),
  cardNumber: _blankToNull(c['cardNumber']),
  cardType: c['cardType'] == 'double' ? CardType.double : CardType.single,
  status: switch (c['status']) {
    'issued' => CardStatus.issued,
    'cancelled' => CardStatus.cancelled,
    _ => CardStatus.pending,
  },
  totalEntries: (c['totalEntries'] as num).toInt(),
  entriesUsed: (c['entriesUsed'] as num).toInt(),
  entriesLeft: (c['entriesLeft'] as num).toInt(),
  table: _blankToNull(c['table']),
  overUsed: c['overUsed'] == true,
  entries: [
    for (final e in (c['entries'] as List? ?? const []).cast<Map<String, dynamic>>())
      CardEntry(
        occurredAt: DateTime.parse(e['occurredAt'] as String),
        admittedCount: (e['admittedCount'] as num).toInt(),
        method: switch (e['method']) {
          'qr' => CheckInMethod.qr,
          'card_number' => CheckInMethod.cardNumber,
          _ => CheckInMethod.name,
        },
        deviceName: e['deviceName'] as String?,
        staffName: e['staffName'] as String?,
      ),
  ]..sort((a, b) => a.occurredAt.compareTo(b.occurredAt)),
);

String? _blankToNull(Object? v) => v is String && v.trim().isNotEmpty ? v : null;

/// The generated models serialise absent optional fields as `null`; the API wants them left out.
class _CompactLookupInput extends api.DoorLookupInput {
  _CompactLookupInput({required super.deviceId, super.qrToken, super.cardNumber, super.name});

  @override
  Map<String, dynamic> toJson() => super.toJson()..removeWhere((_, v) => v == null);
}

class _CompactDeviceInput extends api.DoorDeviceRegisterInput {
  _CompactDeviceInput({required super.eventId, required super.deviceId, super.name});

  @override
  Map<String, dynamic> toJson() => super.toJson()..removeWhere((_, v) => v == null);
}

class _CompactWalkInInput extends api.WalkInCreateInput {
  _CompactWalkInInput({
    required super.id,
    required super.deviceId,
    required super.description,
    required super.admittedCount,
    super.invitationId,
  });

  @override
  Map<String, dynamic> toJson() => super.toJson()..removeWhere((_, v) => v == null);
}

/// The sync body as plain JSON (the generated models would send `null` for absent optionals).
class _RawSyncUpload extends api.DoorSyncUpload {
  _RawSyncUpload(this._json) : super(deviceId: _json['deviceId'] as String, pending: _json['pending'] as int);

  final Map<String, dynamic> _json;

  @override
  Map<String, dynamic> toJson() => _json;
}

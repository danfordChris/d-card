import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dcard_api/api.dart';
import 'package:dcard_door/data/services/connectivity_source.dart';
import 'package:dcard_door/data/services/door_cache.dart';
import 'package:dcard_door/data/services/door_cache_store.dart';
import 'package:dcard_door/data/services/auth_service.dart';
import 'package:dcard_door/data/services/push_token_source.dart';
import 'package:dcard_door/domain/models/app_failure.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({this.failure});

  AppFailure? failure;
  AuthUser? _user;
  final signIns = <String>[];

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    signIns.add(email);
    if (failure != null) throw AppException(failure!);
    return _user = AuthUser(uid: 'uid-$email', email: email);
  }

  @override
  Future<void> signOut() async => _user = null;

  @override
  Future<String?> idToken() async => _user == null ? null : 'token';
}

class FakePushTokenSource implements PushTokenSource {
  FakePushTokenSource({this.current = 'door-token-1'});

  String? current;
  final refreshes = StreamController<String>.broadcast();

  @override
  DevicePlatform get platform => DevicePlatform.android;

  @override
  Future<String?> token() async => current;

  @override
  Stream<String> get tokenRefreshes => refreshes.stream;
}

http.Response jsonResponse(Object? body, int status) => http.Response.bytes(
  body == null ? const [] : utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json'},
);

Map<String, dynamic> _sent(Object? input) => (jsonDecode(jsonEncode(input)) as Map).cast<String, dynamic>();

Map<String, dynamic> eventJson({String id = 'e1', String title = 'Harusi ya Asha', String role = 'door_staff'}) => {
  'id': id,
  'title': title,
  'startsAt': '2026-12-12T12:00:00.000Z',
  'endsAt': null,
  'timeZone': 'Africa/Dar_es_Salaam',
  'venueName': 'Diamond Jubilee',
  'role': role,
};

Map<String, dynamic> cardJson({
  String id = 'inv-1',
  String guestName = 'Asha Juma',
  String? partnerName,
  String? cardNumber = '007-1234',
  String cardType = 'single',
  String status = 'issued',
  int? total,
  int used = 0,
  String? table = '12',
  bool overUsed = false,
  List<Map<String, dynamic>> entries = const [],
}) {
  final totalEntries = total ?? (cardType == 'double' ? 2 : 1);
  return {
    'invitationId': id,
    'guestName': guestName,
    'partnerName': partnerName,
    'cardNumber': cardNumber,
    'cardType': cardType,
    'status': status,
    'totalEntries': totalEntries,
    'entriesUsed': used,
    'entriesLeft': totalEntries - used < 0 ? 0 : totalEntries - used,
    'table': table,
    'overUsed': overUsed,
    'entries': entries,
  };
}

Map<String, dynamic> entryJson({
  String id = 'en-1',
  int count = 1,
  String method = 'qr',
  String occurredAt = '2026-12-12T15:05:00.000Z',
  String? deviceName = 'Gate 1',
  String? staffName = 'Juma',
}) => {
  'id': id,
  'admittedCount': count,
  'method': method,
  'occurredAt': occurredAt,
  'deviceName': deviceName,
  'staffName': staffName,
};

Map<String, dynamic> refusal(String code, {Map<String, dynamic>? card, String? lockedUntil}) => {
  'error': {'code': code, 'message': code},
  'card': card,
  'lockedUntil': lockedUntil,
};

/// An in-memory door API that behaves like the server contract (`/api/v1/door/*`, `/me`, push devices).
class FakeDoorApi extends DefaultApi {
  FakeDoorApi({List<Map<String, dynamic>>? events, List<Map<String, dynamic>>? cards, DateTime Function()? clock})
    : events = events ?? [eventJson()],
      _now = clock ?? DateTime.now {
    for (final c in cards ?? [cardJson()]) {
      this.cards[c['invitationId'] as String] = c;
    }
  }

  final DateTime Function() _now;
  List<Map<String, dynamic>> events;
  final cards = <String, Map<String, dynamic>>{};

  /// The QR token of a card: `qr-` + its invitation ID.
  String qrFor(String invitationId) => 'qr-$invitationId';

  bool revoked = false;

  /// Throws a network error on the next door call.
  bool offlineOnce = false;

  /// Every door call fails with a network error while true.
  bool offline = false;

  /// The next [loseUploadResponses] uploads are applied but their responses are lost.
  int loseUploadResponses = 0;

  /// Event window end + 24 h, as the sync API reports it.
  DateTime wipeAfter = DateTime.utc(2026, 12, 14);

  final syncDownloads = <Map<String, Object?>>[];
  final uploads = <Map<String, dynamic>>[];
  final walkIns = <String, Map<String, dynamic>>{};
  final walkInRequests = <Map<String, dynamic>>[];
  final walkInPolls = <String>[];

  /// Offline entries merged by the server (G-Set keyed by ID).
  final syncedEntries = <String, Map<String, dynamic>>{};
  final syncedAttempts = <String, Map<String, dynamic>>{};
  final syncedWalkIns = <String, Map<String, dynamic>>{};

  int _version = 0;
  final _cardVersion = <String, int>{};

  /// Marks a card changed so the next delta download includes it.
  void touch(String invitationId) => _cardVersion[invitationId] = ++_version;

  static String digest(String token) => sha256.convert(utf8.encode(token)).toString();

  Map<String, dynamic> syncCard(Map<String, dynamic> c) => {
    'invitationId': c['invitationId'],
    'guestName': c['guestName'],
    'partnerName': c['partnerName'],
    'cardNumber': c['cardNumber'],
    'qrTokenDigest': c['status'] == 'issued' ? digest(qrFor(c['invitationId'] as String)) : null,
    'cardType': c['cardType'],
    'status': c['status'],
    'totalEntries': c['totalEntries'],
    'entriesUsed': c['entriesUsed'],
    'table': null,
    'overUsed': (c['entriesUsed'] as int) > (c['totalEntries'] as int),
    'updatedAt': '2026-12-12T10:00:00.000Z',
  };

  void _count(Map<String, dynamic> card, int n) {
    card['entriesUsed'] = (card['entriesUsed'] as int) + n;
    final left = (card['totalEntries'] as int) - (card['entriesUsed'] as int);
    card['entriesLeft'] = left < 0 ? 0 : left;
    card['overUsed'] = (card['entriesUsed'] as int) > (card['totalEntries'] as int);
    touch(card['invitationId'] as String);
  }

  @override
  Future<http.Response> doorSyncDownloadWithHttpInfo(String deviceId, {String? since, int? pending}) async {
    _network();
    syncDownloads.add({'deviceId': deviceId, 'since': since, 'pending': pending});
    final denied = _denied();
    if (denied != null) return denied;
    final from = since == null ? null : int.parse(since);
    final changed = cards.values.where((c) => from == null || (_cardVersion[c['invitationId']] ?? 0) > from);
    return jsonResponse({
      'eventId': events.first['id'],
      'full': since == null,
      'cards': [for (final c in changed) syncCard(c)],
      'approvers': [
        {'userId': 'u-host', 'name': 'host@example.com'},
      ],
      'cursor': '$_version',
      'wipeAfter': wipeAfter.toUtc().toIso8601String(),
    }, 200);
  }

  @override
  Future<http.Response> doorSyncUploadWithHttpInfo({DoorSyncUpload? doorSyncUpload}) async {
    _network();
    final body = _sent(doorSyncUpload);
    uploads.add(body);
    final denied = _denied();
    if (denied != null) return denied;
    var accepted = 0;
    var duplicate = 0;
    final rejected = <String>[];
    final touched = <String>{};
    for (final e in (body['entries'] as List).cast<Map<String, dynamic>>()) {
      final card = cards[e['invitationId']];
      if (card == null) {
        rejected.add(e['id'] as String);
        continue;
      }
      if (syncedEntries.containsKey(e['id']) || _applied.contains(e['id'])) {
        duplicate++;
        continue;
      }
      syncedEntries[e['id'] as String] = e;
      accepted++;
      touched.add(card['invitationId'] as String);
      _count(card, e['admittedCount'] as int);
    }
    var attempts = 0;
    for (final a in (body['attempts'] as List).cast<Map<String, dynamic>>()) {
      if (syncedAttempts.putIfAbsent(a['id'] as String, () => a) == a) attempts++;
    }
    var walkInCount = 0;
    for (final w in ((body['walkIns'] as List?) ?? const []).cast<Map<String, dynamic>>()) {
      if (syncedWalkIns.putIfAbsent(w['id'] as String, () => w) == w) walkInCount++;
    }
    final overUsed = [
      for (final id in touched)
        if (cards[id]!['overUsed'] == true) id,
    ];
    if (loseUploadResponses > 0) {
      loseUploadResponses--;
      throw ApiException.withInner(400, 'Socket operation failed', const SocketException('down'), null);
    }
    return jsonResponse({
      'entriesAccepted': accepted,
      'entriesDuplicate': duplicate,
      'entriesRejected': rejected,
      'attemptsAccepted': attempts,
      'walkInsAccepted': walkInCount,
      'overUsed': overUsed,
    }, 200);
  }

  @override
  Future<http.Response> doorRequestWalkInWithHttpInfo({WalkInCreateInput? walkInCreateInput}) async {
    _network();
    final body = _sent(walkInCreateInput);
    walkInRequests.add(body);
    final denied = _denied();
    if (denied != null) return denied;
    final id = body['id'] as String;
    final existing = walkIns[id];
    if (existing != null) return jsonResponse(existing, 200);
    final created = walkIns[id] = {
      'id': id,
      'eventId': events.first['id'],
      'status': 'pending',
      'description': body['description'],
      'invitationId': body['invitationId'],
      'guestName': null,
      'admittedCount': body['admittedCount'],
      'source': 'online',
      'offlineReason': null,
      'requestedBy': 'door@example.com',
      'deviceName': null,
      'decidedBy': null,
      'decidedAt': null,
      'occurredAt': _now().toUtc().toIso8601String(),
    };
    return jsonResponse(created, 201);
  }

  @override
  Future<http.Response> doorGetWalkInWithHttpInfo(String walkInId, String deviceId) async {
    _network();
    walkInPolls.add(walkInId);
    final denied = _denied();
    if (denied != null) return denied;
    final w = walkIns[walkInId];
    return w == null ? jsonResponse(refusal('not_found'), 404) : jsonResponse(w, 200);
  }

  /// The host or an approver answers a walk-in (the first answer decides).
  void answerWalkIn(String id, {required bool approve, String by = 'host@example.com'}) {
    final w = walkIns[id]!;
    if (w['status'] != 'pending') return;
    w
      ..['status'] = approve ? 'approved' : 'refused'
      ..['decidedBy'] = by
      ..['decidedAt'] = _now().toUtc().toIso8601String();
  }

  /// Makes the next admit fail with a network error after the server applied it (lost response).
  bool loseNextAdmitResponse = false;

  int provisionCalls = 0;
  final registrations = <Map<String, dynamic>>[];
  final lookups = <Map<String, dynamic>>[];
  final admits = <Map<String, dynamic>>[];
  final pushRegistered = <String>[];
  final pushUnregistered = <String>[];
  final _applied = <String>{};
  int _wrongNumbers = 0;
  DateTime? _lockedUntil;

  @override
  Future<Account?> provisionMe() async {
    provisionCalls++;
    return Account(
      id: 'a1',
      firebaseUid: 'uid',
      email: 'door@example.com',
      authProvider: AuthProvider.password,
      personId: null,
      isAdmin: false,
      emailVerified: true,
      createdAt: DateTime.utc(2026),
    );
  }

  @override
  Future<Device?> registerDevice({DeviceRegisterInput? deviceRegisterInput}) async {
    pushRegistered.add(deviceRegisterInput!.token);
    return null;
  }

  @override
  Future<void> unregisterDevice(String token) async => pushUnregistered.add(token);

  void _network() {
    if (offline) {
      throw ApiException.withInner(400, 'Socket operation failed', const SocketException('down'), null);
    }
    if (offlineOnce) {
      offlineOnce = false;
      throw ApiException.withInner(400, 'Socket operation failed', const SocketException('down'), null);
    }
  }

  http.Response? _denied() =>
      revoked ? jsonResponse({'error': {'code': 'forbidden', 'message': 'Device revoked'}}, 403) : null;

  @override
  Future<http.Response> listDoorEventsWithHttpInfo() async {
    _network();
    return jsonResponse({'events': events}, 200);
  }

  @override
  Future<http.Response> registerDoorDeviceWithHttpInfo({DoorDeviceRegisterInput? doorDeviceRegisterInput}) async {
    _network();
    final body = _sent(doorDeviceRegisterInput);
    registrations.add(body);
    final denied = _denied();
    if (denied != null) return denied;
    return jsonResponse({
      'id': body['deviceId'],
      'eventId': body['eventId'],
      'name': body['name'],
      'staffName': 'Juma',
      'createdAt': '2026-12-12T10:00:00.000Z',
      'lastSyncAt': null,
      'revokedAt': null,
    }, registrations.length == 1 ? 201 : 200);
  }

  @override
  Future<http.Response> doorLookupWithHttpInfo({DoorLookupInput? doorLookupInput}) async {
    _network();
    final body = _sent(doorLookupInput);
    lookups.add(body);
    final denied = _denied();
    if (denied != null) return denied;
    if (body['qrToken'] != null) {
      final match = cards.values.where((c) => qrFor(c['invitationId'] as String) == body['qrToken']);
      return match.isEmpty ? jsonResponse(refusal('not_found'), 404) : jsonResponse({'cards': match.toList()}, 200);
    }
    if (body['cardNumber'] != null) {
      if (_lockedUntil != null && _now().isBefore(_lockedUntil!)) {
        return jsonResponse(refusal('locked', lockedUntil: _lockedUntil!.toUtc().toIso8601String()), 423);
      }
      final match = cards.values.where((c) => c['cardNumber'] == body['cardNumber']);
      if (match.isEmpty) {
        _wrongNumbers++;
        if (_wrongNumbers >= 3) {
          _wrongNumbers = 0;
          _lockedUntil = _now().add(const Duration(minutes: 5));
          return jsonResponse(refusal('locked', lockedUntil: _lockedUntil!.toUtc().toIso8601String()), 423);
        }
        return jsonResponse(refusal('not_found'), 404);
      }
      _wrongNumbers = 0;
      return jsonResponse({'cards': match.toList()}, 200);
    }
    final q = (body['name'] as String).toLowerCase();
    final match = cards.values.where(
      (c) => '${c['guestName']} ${c['partnerName'] ?? ''}'.toLowerCase().contains(q),
    );
    return jsonResponse({'cards': match.toList()}, 200);
  }

  @override
  Future<http.Response> doorAdmitWithHttpInfo({DoorEntryInput? doorEntryInput}) async {
    _network();
    final body = _sent(doorEntryInput);
    admits.add(body);
    final denied = _denied();
    if (denied != null) return denied;
    final card = cards[body['invitationId']];
    if (card == null) return jsonResponse(refusal('not_found'), 404);
    final count = body['admittedCount'] as int;
    if (_applied.contains(body['id'])) return jsonResponse({'entry': entryJson(id: body['id'] as String), 'card': card}, 200);
    final code = switch (card) {
      {'status': 'cancelled'} => 'cancelled',
      {'status': 'pending'} => 'not_issued',
      {'entriesLeft': 0} => 'fully_used',
      {'entriesLeft': final int left} when count > left => 'too_many',
      _ => null,
    };
    if (code != null) return jsonResponse(refusal(code, card: card), 409);
    final entry = entryJson(
      id: body['id'] as String,
      count: count,
      method: body['method'] as String,
      occurredAt: _now().toUtc().toIso8601String(),
    );
    _count(card, count);
    card['entries'] = [...(card['entries'] as List), entry];
    _applied.add(body['id'] as String);
    if (loseNextAdmitResponse) {
      loseNextAdmitResponse = false;
      throw ApiException.withInner(400, 'Socket operation failed', const SocketException('down'), null);
    }
    return jsonResponse({'entry': entry, 'card': card}, 201);
  }
}


/// Keeps the cache key in memory instead of the platform keystore.
class MemoryKeyStore implements CacheKeyStore {
  String? key;
  int deletes = 0;

  @override
  Future<String?> read() async => key;

  @override
  Future<void> write(String value) async => key = value;

  @override
  Future<void> delete() async {
    deletes++;
    key = null;
  }
}

/// In-memory SQLite (sqflite FFI, no isolate) standing in for the SQLCipher file.
class MemoryDbOpener implements CacheDatabaseOpener {
  final passwords = <String>[];
  int deletes = 0;
  Database? current;

  static bool _ready = false;

  @override
  Future<Database> open(String password) async {
    if (!_ready) {
      sqfliteFfiInit();
      _ready = true;
    }
    passwords.add(password);
    return current = await databaseFactoryFfiNoIsolate.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: DoorCache.schemaVersion,
        onCreate: DoorCache.createSchema,
        singleInstance: false,
      ),
    );
  }

  @override
  Future<void> delete() async {
    deletes++;
    final db = current;
    current = null;
    if (db != null && db.isOpen) await db.close();
  }
}

DoorCacheStore memoryCacheStore({MemoryKeyStore? keys, MemoryDbOpener? opener}) =>
    DoorCacheStore(keys: keys ?? MemoryKeyStore(), opener: opener ?? MemoryDbOpener());

/// Connectivity the test switches by hand.
class FakeConnectivity implements ConnectivitySource {
  FakeConnectivity({this.up = true});

  bool up;
  final _changes = StreamController<bool>.broadcast();

  void set(bool value) {
    up = value;
    _changes.add(value);
  }

  @override
  Future<bool> hasNetwork() async => up;

  @override
  Stream<bool> get changes => _changes.stream;
}

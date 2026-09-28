import 'dart:convert';

import 'package:sqflite_sqlcipher/sqlite_api.dart';

import '../../domain/models/check_in.dart';
import '../../domain/models/door_event.dart';
import '../models/offline_models.dart';

/// The offline cache for one event: cards, pending uploads and sync state (offline-sync 9.1).
///
/// Works on any sqflite [Database]; the app opens it with SQLCipher ([DoorCacheStore]),
/// tests with an in-memory FFI database.
class DoorCache {
  DoorCache(this._db);

  final Database _db;

  static const schemaVersion = 1;

  static Future<void> createSchema(Database db, int version) async {
    final batch = db.batch()
      ..execute('''
        CREATE TABLE cards (
          invitation_id TEXT PRIMARY KEY,
          guest_name TEXT NOT NULL,
          partner_name TEXT,
          card_number TEXT,
          card_digits TEXT,
          qr_digest TEXT,
          card_type TEXT NOT NULL,
          status TEXT NOT NULL,
          total_entries INTEGER NOT NULL,
          entries_used INTEGER NOT NULL,
          local_used INTEGER NOT NULL DEFAULT 0,
          table_name TEXT,
          over_used INTEGER NOT NULL DEFAULT 0,
          updated_at TEXT
        )''')
      ..execute('CREATE INDEX cards_qr ON cards (qr_digest)')
      ..execute('CREATE INDEX cards_number ON cards (card_digits)')
      ..execute('''
        CREATE TABLE pending_entries (
          id TEXT PRIMARY KEY,
          device_id TEXT NOT NULL,
          invitation_id TEXT NOT NULL,
          admitted_count INTEGER NOT NULL,
          method TEXT NOT NULL,
          occurred_at TEXT NOT NULL
        )''')
      ..execute('''
        CREATE TABLE pending_attempts (
          id TEXT PRIMARY KEY,
          device_id TEXT NOT NULL,
          invitation_id TEXT,
          method TEXT NOT NULL,
          query TEXT,
          outcome TEXT NOT NULL,
          occurred_at TEXT NOT NULL
        )''')
      ..execute('''
        CREATE TABLE pending_walk_ins (
          id TEXT PRIMARY KEY,
          device_id TEXT NOT NULL,
          description TEXT NOT NULL,
          invitation_id TEXT,
          admitted_count INTEGER NOT NULL,
          offline_reason TEXT NOT NULL,
          occurred_at TEXT NOT NULL
        )''')
      ..execute('CREATE TABLE sync_state (key TEXT PRIMARY KEY, value TEXT)');
    await batch.commit(noResult: true);
  }

  Future<void> close() => _db.close();

  // ── cards ──

  /// A full snapshot: the cache now holds exactly [cards].
  Future<void> replaceCards(List<CachedCard> cards) => _db.transaction((tx) async {
    await tx.delete('cards');
    await _insertCards(tx, cards);
    await _recountLocal(tx, null);
  });

  /// A delta: changed cards replace their rows.
  Future<void> upsertCards(List<CachedCard> cards) => _db.transaction((tx) async {
    if (cards.isEmpty) return;
    await _insertCards(tx, cards);
    await _recountLocal(tx, [for (final c in cards) c.invitationId]);
  });

  /// Refreshes a cached card from an online lookup/admit so going offline right after
  /// cannot re-admit what the server just counted.
  Future<void> updateFromOnline(CheckInCard card) => _db.transaction((tx) async {
    await tx.update(
      'cards',
      {
        'status': cardStatusName(card.status),
        'total_entries': card.totalEntries,
        'entries_used': card.entriesUsed,
        'over_used': card.overUsed ? 1 : 0,
      },
      where: 'invitation_id = ?',
      whereArgs: [card.invitationId],
    );
    await _recountLocal(tx, [card.invitationId]);
  });

  Future<void> markOverUsed(List<String> invitationIds) async {
    if (invitationIds.isEmpty) return;
    await _db.update(
      'cards',
      {'over_used': 1},
      where: 'invitation_id IN (${_marks(invitationIds.length)})',
      whereArgs: invitationIds,
    );
  }

  Future<CachedCard?> cardById(String invitationId) =>
      _one('SELECT * FROM cards WHERE invitation_id = ?', [invitationId]);

  Future<CachedCard?> cardByDigest(String digest) =>
      _one('SELECT * FROM cards WHERE qr_digest = ?', [digest.toLowerCase()]);

  /// Card numbers match on their digits ("007-1234" = "0071234").
  Future<CachedCard?> cardByNumber(String cardNumber) {
    final digits = digitsOf(cardNumber);
    return digits.isEmpty ? Future.value() : _one('SELECT * FROM cards WHERE card_digits = ?', [digits]);
  }

  /// Guests whose name or partner's name contains [query] (case-insensitive), by name.
  Future<List<CachedCard>> searchName(String query, {int limit = 30}) async {
    final like = '%${query.trim().toLowerCase().replaceAll(RegExp(r'[%_\\]'), '')}%';
    final rows = await _db.rawQuery(
      "SELECT * FROM cards WHERE lower(guest_name || ' ' || coalesce(partner_name, '')) LIKE ? "
      'ORDER BY guest_name LIMIT ?',
      [like, limit],
    );
    return rows.map(_cardFromRow).toList();
  }

  Future<int> cardCount() async =>
      (await _db.rawQuery('SELECT count(*) AS n FROM cards')).first['n'] as int;

  // ── pending uploads ──

  /// Records an offline entry and counts it on its card, atomically.
  /// Re-adding the same entry ID (a retried tap) changes nothing.
  Future<void> addEntry(PendingEntry e) => _db.transaction((tx) async {
    final existing = await tx.query('pending_entries', columns: ['id'], where: 'id = ?', whereArgs: [e.id]);
    if (existing.isNotEmpty) return;
    await tx.insert('pending_entries', {
      'id': e.id,
      'device_id': e.deviceId,
      'invitation_id': e.invitationId,
      'admitted_count': e.admittedCount,
      'method': methodName(e.method),
      'occurred_at': e.occurredAt.toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
    await tx.rawUpdate(
      'UPDATE cards SET local_used = local_used + ? WHERE invitation_id = ?',
      [e.admittedCount, e.invitationId],
    );
  });

  Future<void> addAttempt(PendingAttempt a) => _db.insert('pending_attempts', {
    'id': a.id,
    'device_id': a.deviceId,
    'invitation_id': a.invitationId,
    'method': methodName(a.method),
    'query': a.query,
    'outcome': outcomeName(a.outcome),
    'occurred_at': a.occurredAt.toUtc().toIso8601String(),
  }, conflictAlgorithm: ConflictAlgorithm.ignore);

  Future<void> addWalkIn(PendingWalkIn w) => _db.insert('pending_walk_ins', {
    'id': w.id,
    'device_id': w.deviceId,
    'description': w.description,
    'invitation_id': w.invitationId,
    'admitted_count': w.admittedCount,
    'offline_reason': w.offlineReason,
    'occurred_at': w.occurredAt.toUtc().toIso8601String(),
  }, conflictAlgorithm: ConflictAlgorithm.ignore);

  /// Entries and walk-ins still on the phone (what staff see as "waiting to sync").
  Future<int> pendingCount({String? deviceId}) async {
    final where = deviceId == null ? '' : ' WHERE device_id = ?';
    final rows = await _db.rawQuery(
      'SELECT (SELECT count(*) FROM pending_entries$where) + (SELECT count(*) FROM pending_walk_ins$where) AS n',
      [?deviceId, ?deviceId],
    );
    return rows.first['n'] as int;
  }

  /// Whether anything (including attempts) still has to upload.
  Future<bool> hasPending() async {
    final rows = await _db.rawQuery(
      'SELECT (SELECT count(*) FROM pending_entries) + (SELECT count(*) FROM pending_walk_ins) + '
      '(SELECT count(*) FROM pending_attempts) AS n',
    );
    return (rows.first['n'] as int) > 0;
  }

  /// Device IDs with something to upload (an event switch can leave another event's items).
  Future<List<String>> pendingDevices() async {
    final rows = await _db.rawQuery(
      'SELECT device_id FROM pending_entries UNION SELECT device_id FROM pending_attempts '
      'UNION SELECT device_id FROM pending_walk_ins',
    );
    return [for (final r in rows) r['device_id'] as String];
  }

  /// The oldest pending items of [deviceId], at most [limit] of each kind.
  Future<PendingBatch> pendingFor(String deviceId, {int limit = 500}) async {
    final entries = await _db.query(
      'pending_entries',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      orderBy: 'occurred_at',
      limit: limit,
    );
    final attempts = await _db.query(
      'pending_attempts',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      orderBy: 'occurred_at',
      limit: limit,
    );
    final walkIns = await _db.query(
      'pending_walk_ins',
      where: 'device_id = ?',
      whereArgs: [deviceId],
      orderBy: 'occurred_at',
      limit: limit < 100 ? limit : 100,
    );
    return PendingBatch(
      deviceId: deviceId,
      entries: [
        for (final r in entries)
          PendingEntry(
            id: r['id'] as String,
            deviceId: deviceId,
            invitationId: r['invitation_id'] as String,
            admittedCount: r['admitted_count'] as int,
            method: methodOf(r['method']),
            occurredAt: DateTime.parse(r['occurred_at'] as String),
          ),
      ],
      attempts: [
        for (final r in attempts)
          PendingAttempt(
            id: r['id'] as String,
            deviceId: deviceId,
            invitationId: r['invitation_id'] as String?,
            method: methodOf(r['method']),
            query: r['query'] as String?,
            outcome: RefusalReason.values.firstWhere(
              (o) => outcomeName(o) == r['outcome'],
              orElse: () => RefusalReason.notFound,
            ),
            occurredAt: DateTime.parse(r['occurred_at'] as String),
          ),
      ],
      walkIns: [
        for (final r in walkIns)
          PendingWalkIn(
            id: r['id'] as String,
            deviceId: deviceId,
            description: r['description'] as String,
            invitationId: r['invitation_id'] as String?,
            admittedCount: r['admitted_count'] as int,
            offlineReason: r['offline_reason'] as String,
            occurredAt: DateTime.parse(r['occurred_at'] as String),
          ),
      ],
    );
  }

  /// Drops what the server has merged (accepted, duplicate or rejected).
  ///
  /// Cards keep their `local_used` until the next download reports the server count.
  Future<void> removeSent(PendingBatch batch) => _db.transaction((tx) async {
    Future<void> drop(String table, List<String> ids) async {
      if (ids.isEmpty) return;
      await tx.delete(table, where: 'id IN (${_marks(ids.length)})', whereArgs: ids);
    }

    await drop('pending_entries', [for (final e in batch.entries) e.id]);
    await drop('pending_attempts', [for (final a in batch.attempts) a.id]);
    await drop('pending_walk_ins', [for (final w in batch.walkIns) w.id]);
  });

  /// Everything queued by a device that can no longer upload (revoked for its event).
  Future<void> dropDevice(String deviceId) => _db.transaction((tx) async {
    for (final table in ['pending_entries', 'pending_attempts', 'pending_walk_ins']) {
      await tx.delete(table, where: 'device_id = ?', whereArgs: [deviceId]);
    }
  });

  // ── sync state ──

  Future<CacheState?> readState() async {
    final rows = await _db.query('sync_state');
    final m = {for (final r in rows) r['key'] as String: r['value'] as String?};
    final eventJson = m['event'];
    final deviceId = m['device_id'];
    if (eventJson == null || deviceId == null) return null;
    final e = (jsonDecode(eventJson) as Map).cast<String, dynamic>();
    return CacheState(
      event: DoorEvent(
        id: e['id'] as String,
        title: e['title'] as String,
        startsAt: DateTime.parse(e['startsAt'] as String),
        endsAt: e['endsAt'] == null ? null : DateTime.parse(e['endsAt'] as String),
        venueName: e['venueName'] as String?,
        role: DoorRole.values.byName(e['role'] as String),
      ),
      deviceId: deviceId,
      deviceName: m['device_name'],
      cursor: m['cursor'],
      wipeAfter: _date(m['wipe_after']),
      lastSyncAt: _date(m['last_sync_at']),
      approvers: [
        for (final a in (jsonDecode(m['approvers'] ?? '[]') as List).cast<Map<String, dynamic>>())
          Approver(userId: a['userId'] as String, name: a['name'] as String),
      ],
    );
  }

  /// Starts holding [session]'s event: a different event clears the cards and state.
  Future<void> bindSession(DoorSession session) => _db.transaction((tx) async {
    final current = await tx.query('sync_state', where: 'key = ?', whereArgs: ['event']);
    final currentId = current.isEmpty
        ? null
        : ((jsonDecode(current.first['value'] as String) as Map)['id'] as String?);
    if (currentId != session.event.id) {
      await tx.delete('cards');
      await tx.delete('sync_state');
    }
    final e = session.event;
    await _put(tx, {
      'event': jsonEncode({
        'id': e.id,
        'title': e.title,
        'startsAt': e.startsAt.toUtc().toIso8601String(),
        'endsAt': e.endsAt?.toUtc().toIso8601String(),
        'venueName': e.venueName,
        'role': e.role.name,
      }),
      'device_id': session.deviceId,
      'device_name': session.deviceName,
    });
  });

  Future<void> saveSync({required String cursor, required DateTime wipeAfter, required DateTime at, required List<Approver> approvers}) =>
      _db.transaction(
        (tx) => _put(tx, {
          'cursor': cursor,
          'wipe_after': wipeAfter.toUtc().toIso8601String(),
          'last_sync_at': at.toUtc().toIso8601String(),
          'approvers': jsonEncode([for (final a in approvers) {'userId': a.userId, 'name': a.name}]),
        }),
      );

  /// CHK-5 offline: wrong card numbers in a row and the lock expiry survive a restart.
  Future<(int, DateTime?)> readLockout() async {
    final rows = await _db.query('sync_state', where: "key IN ('wrong_numbers', 'locked_until')");
    final m = {for (final r in rows) r['key'] as String: r['value'] as String?};
    return (int.tryParse(m['wrong_numbers'] ?? '') ?? 0, _date(m['locked_until']));
  }

  Future<void> writeLockout(int wrongNumbers, DateTime? lockedUntil) => _db.transaction(
    (tx) => _put(tx, {'wrong_numbers': '$wrongNumbers', 'locked_until': lockedUntil?.toUtc().toIso8601String()}),
  );

  // ── helpers ──

  Future<void> _put(DatabaseExecutor tx, Map<String, String?> values) async {
    for (final MapEntry(:key, :value) in values.entries) {
      await tx.insert('sync_state', {'key': key, 'value': value}, conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<void> _insertCards(DatabaseExecutor tx, List<CachedCard> cards) async {
    final batch = tx.batch();
    for (final c in cards) {
      batch.insert('cards', {
        'invitation_id': c.invitationId,
        'guest_name': c.guestName,
        'partner_name': c.partnerName,
        'card_number': c.cardNumber,
        'card_digits': c.cardNumber == null ? null : digitsOf(c.cardNumber!),
        'qr_digest': c.qrTokenDigest?.toLowerCase(),
        'card_type': c.cardType.name,
        'status': cardStatusName(c.status),
        'total_entries': c.totalEntries,
        'entries_used': c.entriesUsed,
        'local_used': 0,
        'table_name': c.table,
        'over_used': c.overUsed ? 1 : 0,
        'updated_at': c.updatedAt,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  /// Local count = this phone's entries still waiting to upload (the server count has the rest).
  Future<void> _recountLocal(DatabaseExecutor tx, List<String>? ids) => tx.rawUpdate(
    'UPDATE cards SET local_used = coalesce((SELECT sum(p.admitted_count) FROM pending_entries p '
    'WHERE p.invitation_id = cards.invitation_id), 0)'
    '${ids == null ? '' : ' WHERE invitation_id IN (${_marks(ids.length)})'}',
    ids ?? const [],
  );

  Future<CachedCard?> _one(String sql, List<Object?> args) async {
    final rows = await _db.rawQuery(sql, args);
    return rows.isEmpty ? null : _cardFromRow(rows.first);
  }

  static CachedCard _cardFromRow(Map<String, Object?> r) => CachedCard(
    invitationId: r['invitation_id'] as String,
    guestName: r['guest_name'] as String,
    partnerName: r['partner_name'] as String?,
    cardNumber: r['card_number'] as String?,
    qrTokenDigest: r['qr_digest'] as String?,
    cardType: r['card_type'] == 'double' ? CardType.double : CardType.single,
    status: cardStatusOf(r['status']),
    totalEntries: r['total_entries'] as int,
    entriesUsed: r['entries_used'] as int,
    localUsed: r['local_used'] as int,
    table: r['table_name'] as String?,
    overUsed: r['over_used'] == 1,
    updatedAt: r['updated_at'] as String?,
  );

  static String _marks(int n) => List.filled(n, '?').join(', ');

  static DateTime? _date(String? v) => v == null ? null : DateTime.tryParse(v);
}

String digitsOf(String value) => value.replaceAll(RegExp(r'\D'), '');

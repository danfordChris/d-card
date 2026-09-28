import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../../domain/models/check_in.dart';
import '../../domain/models/door_event.dart';
import '../models/offline_models.dart';
import '../services/door_cache.dart';
import '../services/door_cache_store.dart';
import '../services/uuid.dart';
import 'door_repository.dart';
import 'door_sync_repository.dart';

/// Lowercase hex SHA-256 of the card token in a scanned QR value (matches `qrTokenDigest`).
String qrDigestOf(String scanned) => sha256.convert(utf8.encode(qrTokenFrom(scanned))).toString();

/// Check-in decided on the phone from the encrypted cache when the API cannot be reached
/// (CHK-6). Same rules as the server; the server stays the authority after sync.
///
/// Admits become immutable pending entries (device UUID, time now); refusals and lockouts
/// become pending attempts. CHK-5 is enforced locally: 3 wrong card numbers in a row lock
/// card-number entry for 5 minutes, recorded as a `locked` attempt.
class OfflineCheckInRepository {
  OfflineCheckInRepository({
    required this._store,
    required this._sync,
    DateTime Function()? clock,
    String Function()? newId,
  }) : _now = clock ?? DateTime.now,
       _newId = newId ?? uuidV4;

  final DoorCacheStore _store;
  final DoorSyncRepository _sync;
  final DateTime Function() _now;
  final String Function() _newId;

  static const maxWrongNumbers = 3;
  static const lockDuration = Duration(minutes: 5);

  /// Whether the cache holds [session]'s event.
  bool isAvailable(DoorSession session) => _sync.isReadyFor(session);

  /// Finds cards like `POST /door/lookup`: QR and card number return one card or throw
  /// [DoorRefusedException] (`notFound`, `locked`); names return the matches.
  Future<List<CheckInCard>> lookup(DoorSession session, CardQuery query) async {
    final cache = await _store.open();
    switch (query) {
      case QrQuery(:final scanned):
        final card = await cache.cardByDigest(qrDigestOf(scanned));
        if (card == null) {
          await _attempt(cache, session, CheckInMethod.qr, RefusalReason.notFound);
          throw const DoorRefusedException(RefusalReason.notFound);
        }
        return [await _found(cache, session, card, CheckInMethod.qr)];
      case CardNumberQuery(:final cardNumber):
        final (wrong, lockedUntil) = await cache.readLockout();
        if (lockedUntil != null && _now().isBefore(lockedUntil)) {
          throw DoorRefusedException(RefusalReason.locked, lockedUntil: lockedUntil);
        }
        final number = cardNumber.trim();
        final card = await cache.cardByNumber(number);
        if (card == null) {
          final count = wrong + 1;
          if (count >= maxWrongNumbers) {
            final until = _now().add(lockDuration);
            await cache.writeLockout(0, until);
            await _attempt(cache, session, CheckInMethod.cardNumber, RefusalReason.locked, query: number);
            throw DoorRefusedException(RefusalReason.locked, lockedUntil: until);
          }
          await cache.writeLockout(count, null);
          await _attempt(cache, session, CheckInMethod.cardNumber, RefusalReason.notFound, query: number);
          throw const DoorRefusedException(RefusalReason.notFound);
        }
        if (wrong != 0 || lockedUntil != null) await cache.writeLockout(0, null);
        return [await _found(cache, session, card, CheckInMethod.cardNumber)];
      case NameQuery(:final name):
        return [for (final c in await cache.searchName(name)) c.toCheckInCard()];
    }
  }

  /// When card-number entry opens again on this phone (online or offline lock), or null.
  Future<DateTime?> lockedUntil() async {
    try {
      final (_, until) = await (await _store.open()).readLockout();
      return until != null && _now().isBefore(until) ? until : null;
    } catch (_) {
      return null;
    }
  }

  /// Keeps a lock the server reported (423), so it holds after reopening the event and offline.
  Future<void> rememberLock(DateTime until) async {
    try {
      await (await _store.open()).writeLockout(0, until);
    } catch (_) {}
  }

  /// Admits [count] on a cached card and queues the entry under [entryId].
  Future<CheckInCard> admit(
    DoorSession session, {
    required String entryId,
    required String invitationId,
    required int count,
    required CheckInMethod method,
  }) async {
    final cache = await _store.open();
    final cached = await cache.cardById(invitationId);
    if (cached == null) {
      await _attempt(cache, session, method, RefusalReason.notFound);
      throw const DoorRefusedException(RefusalReason.notFound);
    }
    final card = cached.toCheckInCard();
    final refusal = card.refusal ?? (count > card.entriesLeft ? RefusalReason.tooMany : null);
    if (refusal != null) {
      await _attempt(cache, session, method, refusal, invitationId: invitationId);
      throw DoorRefusedException(refusal, card: card);
    }
    await cache.addEntry(
      PendingEntry(
        id: entryId,
        deviceId: session.deviceId,
        invitationId: invitationId,
        admittedCount: count,
        method: method,
        occurredAt: _now(),
      ),
    );
    await _sync.localChanged();
    return (await cache.cardById(invitationId))!.toCheckInCard();
  }

  /// A walk-in admitted without network, with the mandatory reason (CHK-8a).
  Future<void> admitWalkIn(
    DoorSession session, {
    required String id,
    required String description,
    required int count,
    required String reason,
    String? invitationId,
  }) async {
    final cache = await _store.open();
    await cache.addWalkIn(
      PendingWalkIn(
        id: id,
        deviceId: session.deviceId,
        description: description.trim(),
        invitationId: invitationId,
        admittedCount: count,
        offlineReason: reason.trim(),
        occurredAt: _now(),
      ),
    );
    await _sync.localChanged();
  }

  /// Keeps the cached copy of a card the server just returned (online lookup or admit).
  Future<void> remember(DoorSession session, CheckInCard card) async {
    if (!isAvailable(session)) return;
    await (await _store.open()).updateFromOnline(card);
  }

  Future<CheckInCard> _found(DoorCache cache, DoorSession session, CachedCard cached, CheckInMethod method) async {
    final card = cached.toCheckInCard();
    final refusal = card.refusal;
    if (refusal != null) await _attempt(cache, session, method, refusal, invitationId: card.invitationId);
    return card;
  }

  Future<void> _attempt(
    DoorCache cache,
    DoorSession session,
    CheckInMethod method,
    RefusalReason outcome, {
    String? invitationId,
    String? query,
  }) async {
    await cache.addAttempt(
      PendingAttempt(
        id: _newId(),
        deviceId: session.deviceId,
        invitationId: invitationId,
        method: method,
        query: query == null || query.isEmpty ? null : (query.length > 80 ? query.substring(0, 80) : query),
        outcome: outcome,
        occurredAt: _now(),
      ),
    );
    await _sync.localChanged();
  }
}

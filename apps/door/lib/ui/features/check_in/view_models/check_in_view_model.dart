import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/door_repository.dart';
import '../../../../data/repositories/door_sync_repository.dart';
import '../../../../data/repositories/offline_check_in_repository.dart';
import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/check_in.dart';
import '../../../../domain/models/door_event.dart';

enum CheckInMode { scan, number, name }

/// What the door screen shows after a lookup or an Admit tap.
sealed class CheckInResult {
  const CheckInResult();
}

/// A card that was found; [CheckInCard.refusal] tells whether it can be admitted.
class CardFound extends CheckInResult {
  const CardFound(this.card, this.method, {this.offline = false});

  final CheckInCard card;
  final CheckInMethod method;

  /// Decided from the phone's cache (no network).
  final bool offline;
}

/// Entry recorded: [card] is the card after the entry.
class Admitted extends CheckInResult {
  const Admitted(this.card, this.count, {this.offline = false});

  final CheckInCard card;
  final int count;

  /// Saved on the phone; uploads when the network is back.
  final bool offline;
}

class Refused extends CheckInResult {
  const Refused(this.reason, {this.card, this.offline = false});

  final RefusalReason reason;
  final CheckInCard? card;
  final bool offline;
}

/// Door check-in for one event and device: lookup by QR, card number or name,
/// Admit 1 / Admit 2, refusals and the card-number lockout (CHK-1…CHK-5).
///
/// Online is the default. When a call fails with a network error, or [DoorSyncRepository]
/// already knows the phone is offline, the same action is decided from the encrypted cache
/// ([OfflineCheckInRepository], CHK-6) and uploaded later.
class CheckInViewModel extends ChangeNotifier {
  CheckInViewModel({
    required this._door,
    required this.session,
    required this._onAccessDenied,
    this._offline,
    this._sync,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now {
    _sync?.addListener(_syncChanged);
    unawaited(_restoreLock());
  }

  final DoorRepository _door;
  final OfflineCheckInRepository? _offline;
  final DoorSyncRepository? _sync;
  final DoorSession session;
  /// Called when the server refuses this device or session (403 revoked / no access, 401);
  /// the app shows why: the revoked screen, or sign-in after a 401 (AUTH-9).
  final Future<void> Function(AppFailure because) _onAccessDenied;
  final DateTime Function() _now;

  /// Used when a 423 carries no `lockedUntil` (CHK-5: 5 minutes).
  static const lockDuration = Duration(minutes: 5);

  CheckInMode mode = CheckInMode.scan;
  bool busy = false;
  CheckInResult? result;

  /// Network or unexpected error from the last action (the screen offers to retry).
  AppFailure? failure;

  /// Name search results; null until a search ran.
  List<CheckInCard>? nameMatches;
  bool nameTooShort = false;

  /// The name matches came from the phone's cache.
  bool nameMatchesOffline = false;

  DateTime? _lockedUntil;
  Timer? _ticker;
  _PendingEntry? _pending;
  bool _disposed = false;

  /// The current action was decided locally.
  bool _local = false;

  /// Sync status for the screen (null-safe when the app runs without the offline cache).
  bool get hasSync => _sync != null;
  bool get isOffline => _sync != null && !_sync.online;
  bool get syncing => _sync?.syncing ?? false;
  int get pendingCount => _sync?.pendingCount ?? 0;
  DateTime? get lastSyncAt => _sync?.lastSyncAt;

  /// Whether offline check-in is possible now (the event cache is on the phone).
  bool get offlineReady => _offline?.isAvailable(session) ?? false;

  Future<void> syncNow() async => _sync?.syncNow();

  /// Whether the event is before its door window or over, on this phone's clock.
  EventTiming get timing => session.event.timingAt(_now());

  /// Staff chose to check in although the event has not started or has ended.
  bool timingAcknowledged = false;

  /// Show the "not started" / "ended" screen instead of scanning.
  bool get showTimingNotice => timing != EventTiming.open && !timingAcknowledged;

  void acknowledgeTiming() {
    timingAcknowledged = true;
    notifyListeners();
  }

  /// The event window is 24 h past and the offline copy was wiped.
  bool get cacheExpired => _sync?.expired ?? false;

  /// No network and no offline copy of this event: nothing can be checked (retry or wait).
  bool get offlineWithoutCache => isOffline && !offlineReady && !cacheExpired;

  /// This phone's clock differs from the server's by more than [DoorRepository.clockSkewTolerance].
  bool get clockSkewed => _door.clockSkewed;

  /// Server time minus phone time (see [DoorRepository.clockSkew]).
  Duration? get clockSkew => _door.clockSkew;

  bool get isLocked => _lockedUntil != null && _now().isBefore(_lockedUntil!);

  /// Time left on the card-number lock (zero when not locked).
  Duration get lockRemaining => isLocked ? _lockedUntil!.difference(_now()) : Duration.zero;

  void setMode(CheckInMode value) {
    if (mode == value) return;
    mode = value;
    failure = null;
    notifyListeners();
  }

  /// A QR code was read. Ignored while a lookup runs or a result is on screen.
  Future<void> scanned(String raw) async {
    if (busy || result != null || raw.trim().isEmpty) return;
    await _lookupOne(QrQuery(raw));
  }

  Future<void> lookupCardNumber(String cardNumber) async {
    if (busy || isLocked || cardNumber.trim().isEmpty) return;
    await _lookupOne(CardNumberQuery(cardNumber));
  }

  Future<void> searchName(String name) async {
    if (busy) return;
    nameTooShort = name.trim().length < 2;
    if (nameTooShort) {
      notifyListeners();
      return;
    }
    await _run(() async {
      nameMatches = await _either(
        () async {
          try {
            return await _door.lookup(session, NameQuery(name));
          } on DoorRefusedException catch (e) {
            if (e.reason != RefusalReason.notFound) rethrow;
            return const <CheckInCard>[];
          }
        },
        () => _offline!.lookup(session, NameQuery(name)),
      );
      nameMatchesOffline = _local;
    });
  }

  /// Staff picked a card from the name search results.
  void selectMatch(CheckInCard card) {
    result = CardFound(card, CheckInMethod.name, offline: nameMatchesOffline);
    failure = null;
    notifyListeners();
  }

  /// Admit [count] (1 or 2) on the card on screen.
  Future<void> admit(int count) async {
    final found = result;
    if (busy || found is! CardFound || found.card.refusal != null) return;
    if (count < 1 || count > 2 || count > found.card.entriesLeft) return;
    final card = found.card;
    // One ID per tap; a retry after a network error reuses it so the server can't count it twice.
    final pending = _pending != null && _pending!.invitationId == card.invitationId && _pending!.count == count
        ? _pending!
        : _pending = _PendingEntry(_door.newEntryId(), card.invitationId, count);
    await _run(() async {
      try {
        final updated = await _either(
          () async {
            final c = await _door.admit(
              session,
              entryId: pending.id,
              invitationId: card.invitationId,
              count: count,
              method: found.method,
            );
            await _remember(c);
            return c;
          },
          // Same entry ID: if the server did apply a lost request, the upload is a duplicate.
          () => _offline!.admit(
            session,
            entryId: pending.id,
            invitationId: card.invitationId,
            count: count,
            method: found.method,
          ),
        );
        _pending = null;
        result = Admitted(updated, count, offline: _local);
      } on DoorRefusedException {
        _pending = null;
        rethrow;
      }
    }, fallbackCard: card);
  }

  /// Back to scanning for the next guest.
  void next() {
    result = null;
    failure = null;
    _pending = null;
    notifyListeners();
  }

  Future<void> _lookupOne(CardQuery query) => _run(() async {
    final cards = await _either(() async {
      final c = await _door.lookup(session, query);
      if (c.length == 1) await _remember(c.single);
      return c;
    }, () => _offline!.lookup(session, query));
    result = cards.isEmpty
        ? Refused(RefusalReason.notFound, offline: _local)
        : CardFound(cards.first, query.method, offline: _local);
  });

  bool get _canDecideLocally => _offline != null && _offline.isAvailable(session);

  /// Runs [online]; decides with [local] instead when the phone is known to be offline or
  /// the call fails with a network error and the event cache is on the phone.
  Future<T> _either<T>(Future<T> Function() online, Future<T> Function() local) async {
    if (isOffline && _canDecideLocally) {
      _local = true;
      return local();
    }
    try {
      final value = await online();
      _sync?.markOnline();
      return value;
    } on DoorRefusedException {
      _sync?.markOnline();
      rethrow;
    } on AppException catch (e) {
      if (e.failure != AppFailure.network || !_canDecideLocally) rethrow;
      _sync?.markOffline();
      _local = true;
      return local();
    }
  }

  Future<void> _remember(CheckInCard card) async {
    try {
      await _offline?.remember(session, card);
    } catch (_) {}
  }

  void _syncChanged() {
    if (!_disposed) notifyListeners();
  }

  Future<void> _run(Future<void> Function() action, {CheckInCard? fallbackCard}) async {
    busy = true;
    failure = null;
    _local = false;
    notifyListeners();
    try {
      await action();
    } on DoorRefusedException catch (e) {
      if (e.reason == RefusalReason.locked) {
        final until = e.lockedUntil;
        if (_local) {
          _lock(until ?? _now().add(lockDuration));
        } else {
          // The server's expiry, on this phone's clock; kept so it holds offline and on reopen.
          final local = until == null ? _now().add(lockDuration) : _door.toLocalClock(until);
          _lock(local);
          unawaited(_offline?.rememberLock(local));
        }
      } else {
        result = Refused(e.reason, card: e.card ?? fallbackCard, offline: _local);
      }
    } on AppException catch (e) {
      if (e.failure == AppFailure.doorAccessDenied || e.failure == AppFailure.unauthorized) {
        busy = false;
        await _onAccessDenied(e.failure);
        return;
      }
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> _restoreLock() async {
    final until = await _offline?.lockedUntil();
    if (until == null || _disposed || !_now().isBefore(until)) return;
    _lock(until);
    notifyListeners();
  }

  void _lock(DateTime until) {
    _lockedUntil = until;
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!isLocked) {
        t.cancel();
        _ticker = null;
        _lockedUntil = null;
      }
      if (!_disposed) notifyListeners();
    });
  }

  @override
  void dispose() {
    _disposed = true;
    _sync?.removeListener(_syncChanged);
    _ticker?.cancel();
    super.dispose();
  }
}

class _PendingEntry {
  const _PendingEntry(this.id, this.invitationId, this.count);

  final String id;
  final String invitationId;
  final int count;
}

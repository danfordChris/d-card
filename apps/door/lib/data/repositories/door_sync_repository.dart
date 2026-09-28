import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';

import '../../domain/models/app_failure.dart';
import '../../domain/models/check_in.dart';
import '../../domain/models/door_event.dart';
import '../models/offline_models.dart';
import '../services/connectivity_source.dart';
import '../services/door_cache.dart';
import '../services/door_cache_store.dart';
import 'door_repository.dart';

/// Keeps the encrypted event cache in step with the server and uploads what the door
/// decided offline (offline-sync 9.1–9.4).
///
/// - Opening an event downloads the full cache; while open, a delta runs every [interval]
///   and as soon as the network comes back. Failures back off ([minBackoff] doubling up to
///   [maxBackoff]).
/// - Each cycle uploads first (entries, attempts, walk-ins; idempotent by ID), applies the
///   returned `overUsed` flags, then downloads.
/// - The cache is wiped after the event window (`wipeAfter`), when the device is revoked
///   (403, after one last upload try: [deviceRevoked]) and on sign-out.
///
/// [online] is the last known reachability of the API: false after a network failure,
/// true after any successful call. Check-in decides locally while it is false.
class DoorSyncRepository extends ChangeNotifier {
  DoorSyncRepository({
    required this._door,
    required this._store,
    this._connectivity = const NoConnectivitySource(),
    DateTime Function()? clock,
    this.interval = const Duration(seconds: 30),
    this.minBackoff = const Duration(seconds: 5),
    this.maxBackoff = const Duration(minutes: 1),
    this.batchSize = 500,
    this.autoSchedule = true,
  }) : _now = clock ?? DateTime.now;

  final DoorRepository _door;
  final DoorCacheStore _store;
  final ConnectivitySource _connectivity;
  final DateTime Function() _now;
  final Duration interval;
  final Duration minBackoff;
  final Duration maxBackoff;
  final int batchSize;

  /// False in tests that drive [syncNow] by hand.
  final bool autoSchedule;

  /// Called when the server refuses this device (403 revoked) or the session (401).
  Future<void> Function(AppFailure because)? onAccessDenied;

  DoorSession? _session;
  bool online = true;
  bool syncing = false;

  /// The cache holds a downloaded copy of the open event.
  bool cacheReady = false;

  /// The event window has passed and the cache was wiped.
  bool expired = false;

  /// The server refused this device (403: revoked by the host, or door access removed).
  /// Syncing stopped, what was waiting got one upload try and the cache was wiped.
  bool revoked = false;

  /// Entries and walk-ins that could not be uploaded before the revoke wipe (lost on this phone).
  int lostOnRevoke = 0;

  /// Entries and walk-ins waiting to upload.
  int pendingCount = 0;
  DateTime? lastSyncAt;
  List<Approver> approvers = const [];

  int _failures = 0;
  Timer? _timer;
  StreamSubscription<bool>? _connectivitySub;
  Future<bool>? _running;
  Future<int>? _revoking;
  bool _disposed = false;

  DoorSession? get session => _session;

  /// Whether offline decisions can be made for [session].
  bool isReadyFor(DoorSession session) => cacheReady && _session?.deviceId == session.deviceId;

  /// The event cached on this phone, to reopen it without network; null when there is none.
  Future<DoorSession?> cachedSession() async {
    try {
      final cache = await _store.open();
      final state = await cache.readState();
      if (state == null || state.cursor == null) return null;
      if (_isPast(state.wipeAfter)) {
        await _wipeExpired(cache);
        return null;
      }
      return state.session;
    } catch (_) {
      return null;
    }
  }

  /// Opens [session]'s event: binds the cache to it and downloads the full snapshot.
  Future<void> start(DoorSession session) async {
    _stopTimers();
    _session = session;
    expired = false;
    revoked = false;
    lostOnRevoke = 0;
    _revoking = null;
    _failures = 0;
    final cache = await _store.open();
    await cache.bindSession(session);
    final state = await cache.readState();
    lastSyncAt = state?.lastSyncAt;
    approvers = state?.approvers ?? const [];
    cacheReady = state?.cursor != null;
    pendingCount = await cache.pendingCount();
    _notify();
    if (_isPast(state?.wipeAfter)) {
      await _wipeExpired(cache);
      return;
    }
    _connectivitySub = _connectivity.changes.listen(_connectivityChanged);
    if (!await _connectivity.hasNetwork()) {
      _wentOffline();
      return;
    }
    await syncNow(full: true);
  }

  /// Leaves the event (the cache and its pending items stay until uploaded or wiped).
  void stop() {
    _stopTimers();
    _session = null;
    cacheReady = false;
    _notify();
  }

  /// Upload then download now; concurrent calls share one run. Returns true on success.
  Future<bool> syncNow({bool full = false}) =>
      _running ??= _cycle(full).whenComplete(() => _running = null);

  /// Check-in hit a network error: decide locally and probe again soon.
  void markOffline() {
    if (!online) return;
    _wentOffline();
  }

  /// A check-in call reached the server: upload what is waiting.
  void markOnline() {
    if (online) return;
    online = true;
    _failures = 0;
    _notify();
    if (_session != null) unawaited(syncNow());
  }

  /// Something was queued locally (entry, attempt, walk-in).
  Future<void> localChanged() async {
    try {
      pendingCount = await (await _store.open()).pendingCount();
    } catch (_) {}
    _notify();
  }

  /// Uploads everything waiting (all device IDs); true when nothing is left.
  Future<bool> uploadPending() async {
    try {
      final cache = await _store.open();
      await _uploadAll(cache, _session?.deviceId);
      pendingCount = await cache.pendingCount();
      _notify();
      return !await cache.hasPending();
    } catch (_) {
      return false;
    }
  }

  /// Deletes the cache and its key.
  Future<void> wipe() async {
    _stopTimers();
    await _running?.catchError((_) => false);
    await _wipeNow();
  }

  Future<void> _wipeNow() async {
    _stopTimers();
    await _store.wipe();
    cacheReady = false;
    pendingCount = 0;
    lastSyncAt = null;
    approvers = const [];
    _notify();
  }

  /// The server refused this device (403 from any door call; AUTH-9): stop syncing, try once
  /// to upload what is waiting (the server decides whether it still accepts it), then wipe the
  /// cache and its key. Returns how many waiting items could not be sent. Safe to call twice.
  Future<int> deviceRevoked() async {
    if (_revoking case final running?) return running;
    _stopTimers();
    _session = null;
    await _running?.catchError((_) => false);
    return _revoking ??= _afterRevoked();
  }

  Future<int> _afterRevoked({Duration timeout = const Duration(seconds: 10)}) async {
    revoked = true;
    var lost = 0;
    try {
      final cache = await _store.open();
      if (await cache.hasPending()) {
        try {
          await _uploadEachQuietly(cache).timeout(timeout);
        } catch (_) {}
      }
      lost = await cache.pendingCount();
    } catch (_) {
      lost = pendingCount;
    }
    await _wipeNow();
    lostOnRevoke = lost;
    _notify();
    return lost;
  }

  /// One upload try per device queue; a refused queue is left in place (and counted as lost).
  Future<void> _uploadEachQuietly(DoorCache cache) async {
    for (final deviceId in await cache.pendingDevices()) {
      try {
        while (true) {
          final batch = await cache.pendingFor(deviceId, limit: batchSize);
          if (batch.isEmpty) break;
          final left = await cache.pendingCount(deviceId: deviceId) - batch.entries.length - batch.walkIns.length;
          final result = await _door.syncUpload(batch, pending: max(0, left));
          await cache.removeSent(batch);
          await cache.markOverUsed(result.overUsed);
          final full = batch.entries.length >= batchSize || batch.attempts.length >= batchSize || batch.walkIns.length >= 100;
          if (!full) break;
        }
      } catch (_) {
        // Refused (revoked) or unreachable: move on to the next device's queue.
      }
    }
  }

  /// On sign-out: try to upload what is waiting (unless the server refused us), then wipe.
  Future<void> signOut({bool upload = true, Duration timeout = const Duration(seconds: 10)}) async {
    _stopTimers();
    _session = null;
    if (upload && pendingCount > 0) {
      try {
        await uploadPending().timeout(timeout);
      } catch (_) {}
    }
    await wipe();
  }

  Future<bool> _cycle(bool full) async {
    final session = _session;
    if (session == null || expired || revoked) return false;
    _timer?.cancel();
    syncing = true;
    _notify();
    var ok = false;
    try {
      final cache = await _store.open();
      final state = await cache.readState();
      if (_isPast(state?.wipeAfter)) {
        await _wipeExpired(cache);
        return false;
      }
      await _uploadAll(cache, session.deviceId);
      final pending = await cache.pendingCount(deviceId: session.deviceId);
      final since = full ? null : state?.cursor;
      final snapshot = await _door.syncDownload(session.deviceId, since: since, pending: pending);
      if (_session?.deviceId != session.deviceId) return false;
      if (snapshot.full) {
        await cache.replaceCards(snapshot.cards);
      } else {
        await cache.upsertCards(snapshot.cards);
      }
      final at = _now();
      await cache.saveSync(cursor: snapshot.cursor, wipeAfter: snapshot.wipeAfter, at: at, approvers: snapshot.approvers);
      lastSyncAt = at;
      approvers = snapshot.approvers;
      cacheReady = true;
      online = true;
      _failures = 0;
      pendingCount = await cache.pendingCount();
      ok = true;
      if (_isPast(snapshot.wipeAfter)) await _wipeExpired(cache);
      return true;
    } on AppException catch (e) {
      if (e.failure == AppFailure.doorAccessDenied || e.failure == AppFailure.unauthorized) {
        await _denied(e.failure);
        return false;
      }
      if (e.failure == AppFailure.network) online = false;
      _failures++;
      return false;
    } catch (_) {
      _failures++;
      return false;
    } finally {
      syncing = false;
      if (!ok && _session != null && !expired) await _refreshPendingQuietly();
      _schedule();
      _notify();
    }
  }

  /// Uploads each device's queue in batches; drops the queue of another event's device the
  /// server no longer knows or accepts. Stops at the first failure for [currentDeviceId].
  Future<void> _uploadAll(DoorCache cache, String? currentDeviceId) async {
    for (final deviceId in await cache.pendingDevices()) {
      while (true) {
        final batch = await cache.pendingFor(deviceId, limit: batchSize);
        if (batch.isEmpty) break;
        final left = await cache.pendingCount(deviceId: deviceId) - batch.entries.length - batch.walkIns.length;
        final SyncUploadResult result;
        try {
          result = await _door.syncUpload(batch, pending: max(0, left));
        } on DoorRefusedException {
          if (deviceId == currentDeviceId) throw const AppException(AppFailure.unknown);
          await cache.dropDevice(deviceId);
          break;
        } on AppException catch (e) {
          if (e.failure == AppFailure.doorAccessDenied && deviceId != currentDeviceId) {
            await cache.dropDevice(deviceId);
            break;
          }
          rethrow;
        }
        await cache.removeSent(batch);
        await cache.markOverUsed(result.overUsed);
        online = true;
        final full = batch.entries.length >= batchSize || batch.attempts.length >= batchSize || batch.walkIns.length >= 100;
        if (!full) break;
      }
    }
  }

  Future<void> _denied(AppFailure because) async {
    _stopTimers();
    _session = null;
    // Runs inside the sync cycle, so it must not wait for the cycle (see [deviceRevoked]).
    if (because == AppFailure.doorAccessDenied && _revoking == null) await (_revoking = _afterRevoked());
    // Not awaited: signing out waits for this sync run to finish.
    unawaited(onAccessDenied?.call(because));
  }

  Future<void> _wipeExpired(DoorCache cache) async {
    // Last chance to report what is waiting; the data must not outlive the window.
    if (await cache.hasPending()) {
      try {
        await _uploadAll(cache, _session?.deviceId).timeout(const Duration(seconds: 10));
      } catch (_) {}
    }
    expired = true;
    await _wipeNow();
  }

  void _connectivityChanged(bool up) {
    if (!up) {
      _wentOffline();
    } else if (_session != null) {
      _failures = 0;
      unawaited(syncNow());
    }
  }

  void _wentOffline() {
    online = false;
    if (_failures == 0) _failures = 1;
    _schedule();
    _notify();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = null;
    if (!autoSchedule || _session == null || expired || revoked || _disposed) return;
    final delay = _failures == 0 ? interval : _backoff(_failures);
    _timer = Timer(delay, () => unawaited(syncNow()));
  }

  Duration _backoff(int failures) {
    final ms = minBackoff.inMilliseconds * pow(2, min(failures - 1, 16));
    return Duration(milliseconds: min(ms.toInt(), maxBackoff.inMilliseconds));
  }

  /// The delay before the next try after [failures] failures in a row (for tests).
  @visibleForTesting
  Duration backoffFor(int failures) => failures == 0 ? interval : _backoff(failures);

  Future<void> _refreshPendingQuietly() async {
    try {
      pendingCount = await (await _store.open()).pendingCount();
    } catch (_) {}
  }

  bool _isPast(DateTime? t) => t != null && _now().isAfter(t);

  void _stopTimers() {
    _timer?.cancel();
    _timer = null;
    unawaited(_connectivitySub?.cancel());
    _connectivitySub = null;
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _stopTimers();
    super.dispose();
  }
}

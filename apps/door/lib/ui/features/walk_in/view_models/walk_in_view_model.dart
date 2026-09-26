import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/door_repository.dart';
import '../../../../data/repositories/door_sync_repository.dart';
import '../../../../data/repositories/offline_check_in_repository.dart';
import '../../../../data/services/uuid.dart';
import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/check_in.dart';
import '../../../../domain/models/door_event.dart';
import '../../../../domain/models/walk_in.dart';

enum WalkInStep {
  /// Filling in the request.
  form,

  /// Sent; waiting for the host or an approver (online).
  waiting,
  approved,
  refused,

  /// Let in without network, with a reason; uploads on sync (CHK-8a).
  admittedOffline,
}

/// A guest without a valid card (CHK-8, CHK-8a).
///
/// Online: the request goes to the host and walk-in approvers and the screen polls until the
/// first answer. Offline (known offline, or the request fails with a network error): staff
/// may admit with a mandatory reason, e.g. "host approved by phone call".
class WalkInViewModel extends ChangeNotifier {
  WalkInViewModel({
    required this._door,
    required this.session,
    required this._onAccessDenied,
    this._offline,
    this._sync,
    this.linkedCard,
    this.pollInterval = const Duration(seconds: 3),
    String Function()? newId,
  }) : _newId = newId ?? uuidV4 {
    offlineMode = _sync != null && !_sync.online && _offlinePossible;
  }

  final DoorRepository _door;
  final DoorSession session;
  final Future<void> Function(AppFailure because) _onAccessDenied;
  final OfflineCheckInRepository? _offline;
  final DoorSyncRepository? _sync;
  final String Function() _newId;

  /// How often to ask for the decision while waiting.
  final Duration pollInterval;

  static const minDescription = 2;
  static const maxDescription = 200;
  static const minReason = 3;

  /// The card this walk-in relates to (e.g. a fully used card), if any.
  CheckInCard? linkedCard;
  String description = '';
  int count = 1;

  /// Offline admission instead of a request: needs [reason].
  bool offlineMode = false;
  String reason = '';

  WalkInStep step = WalkInStep.form;
  bool busy = false;
  AppFailure? failure;

  /// Validation messages are shown after the first submit.
  bool showErrors = false;
  WalkInRequest? request;

  String? _requestId;
  Timer? _poll;
  bool _disposed = false;

  bool get _offlinePossible => _offline != null && _offline.isAvailable(session);

  /// Whether this phone can admit offline (the event cache is on it).
  bool get canAdmitOffline => _offlinePossible;

  /// The network is down (known offline, or the last request failed to connect).
  bool get networkDown => (_sync != null && !_sync.online) || failure == AppFailure.network;

  bool get descriptionValid {
    final n = description.trim().length;
    return n >= minDescription && n <= maxDescription;
  }

  bool get reasonValid => reason.trim().length >= minReason && reason.trim().length <= 200;

  void setDescription(String value) {
    description = value;
    notifyListeners();
  }

  void setReason(String value) {
    reason = value;
    notifyListeners();
  }

  void setCount(int value) {
    if (value < 1 || value > 2 || step != WalkInStep.form) return;
    count = value;
    _requestId = null;
    notifyListeners();
  }

  void unlinkCard() {
    if (step != WalkInStep.form) return;
    linkedCard = null;
    _requestId = null;
    notifyListeners();
  }

  /// Switches between asking (online) and admitting with a reason (offline only).
  void setOfflineMode(bool value) {
    if (step != WalkInStep.form || (value && !_offlinePossible)) return;
    offlineMode = value;
    failure = null;
    notifyListeners();
  }

  Future<void> submit() async {
    if (busy || step != WalkInStep.form) return;
    showErrors = true;
    if (!descriptionValid || (offlineMode && !reasonValid)) {
      notifyListeners();
      return;
    }
    if (offlineMode) {
      await _admitOffline();
    } else {
      await _request();
    }
  }

  Future<void> _request() async {
    // One ID per request; a retry after a network error resends it (idempotent on the server).
    final id = _requestId ??= _newId();
    await _guard(() async {
      try {
        request = await _door.requestWalkIn(
          session,
          id: id,
          description: description,
          count: count,
          invitationId: linkedCard?.invitationId,
        );
        _sync?.markOnline();
      } on AppException catch (e) {
        if (e.failure == AppFailure.network && _offlinePossible) {
          _sync?.markOffline();
          offlineMode = true;
        }
        rethrow;
      }
      _applyRequest();
    });
  }

  Future<void> _admitOffline() => _guard(() async {
    await _offline!.admitWalkIn(
      session,
      id: _newId(),
      description: description,
      count: count,
      reason: reason,
      invitationId: linkedCard?.invitationId,
    );
    step = WalkInStep.admittedOffline;
  });

  /// Asks for the decision now (the timer does this every [pollInterval]).
  Future<void> refresh() async {
    final current = request;
    if (current == null || step != WalkInStep.waiting || _disposed) return;
    try {
      request = await _door.getWalkIn(session, current.id);
      failure = null;
      _applyRequest();
    } on AppException catch (e) {
      if (e.failure == AppFailure.doorAccessDenied || e.failure == AppFailure.unauthorized) {
        _stopPolling();
        await _onAccessDenied(e.failure);
        return;
      }
      // Keep waiting; the decision is kept on the server.
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    }
    if (!_disposed) notifyListeners();
  }

  void _applyRequest() {
    final r = request!;
    switch (r.status) {
      case WalkInStatus.pending:
        step = WalkInStep.waiting;
        _poll ??= Timer.periodic(pollInterval, (_) => unawaited(refresh()));
      case WalkInStatus.approved || WalkInStatus.accepted:
        step = WalkInStep.approved;
        _stopPolling();
      case WalkInStatus.refused || WalkInStatus.flagged:
        step = WalkInStep.refused;
        _stopPolling();
      case WalkInStatus.admittedOffline:
        step = WalkInStep.admittedOffline;
        _stopPolling();
    }
  }

  Future<void> _guard(Future<void> Function() action) async {
    busy = true;
    failure = null;
    notifyListeners();
    try {
      await action();
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

  void _stopPolling() {
    _poll?.cancel();
    _poll = null;
  }

  @override
  void dispose() {
    _disposed = true;
    _stopPolling();
    super.dispose();
  }
}

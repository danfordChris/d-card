import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/walk_in_alerts_repository.dart';
import '../../../../data/repositories/walk_ins_repository.dart';
import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/walk_in.dart';

/// Outcome of an approve/refuse/accept/flag tap, for the screen's message.
sealed class WalkInDecisionResult {
  const WalkInDecisionResult();
}

class WalkInDecided extends WalkInDecisionResult {
  const WalkInDecided(this.walkIn);
  final WalkIn walkIn;
}

/// Another approver answered first; [walkIn] shows who and what.
class WalkInDecidedElsewhere extends WalkInDecisionResult {
  const WalkInDecidedElsewhere(this.walkIn);
  final WalkIn walkIn;
}

class WalkInDecisionFailed extends WalkInDecisionResult {
  const WalkInDecisionFailed(this.failure);
  final AppFailure failure;
}

/// Walk-in requests of one event (CHK-8, CHK-8a): pending first, then offline admissions
/// needing review, then decided history. Refreshes on pull, on a timer while open, and on
/// walk-in pushes for this event.
class WalkInsViewModel extends ChangeNotifier {
  WalkInsViewModel({
    required this.eventId,
    required this._repository,
    required this._canDecide,
    WalkInAlertsRepository? alerts,
    this.pollInterval = const Duration(seconds: 10),
  }) {
    _alerts = alerts?.alerts.listen((a) {
      if (a.eventId == eventId) unawaited(load(silent: true));
    });
  }

  final String eventId;
  final WalkInsRepository _repository;
  final Duration pollInterval;

  StreamSubscription<WalkInAlert>? _alerts;
  Timer? _timer;
  bool _disposed = false;
  bool _inFlight = false;

  List<WalkIn> _all = const [];
  bool loaded = false;
  bool loading = false;
  AppFailure? failure;

  /// Walk-ins with a decision in progress.
  final Set<String> busy = {};

  bool _canDecide;

  /// Host and walk-in approvers decide; committee sees the list read-only.
  bool get canDecide => _canDecide;

  List<WalkIn> get pending => [
    for (final w in _all)
      if (w.isPending) w,
  ];
  List<WalkIn> get needsReview => [
    for (final w in _all)
      if (w.needsReview) w,
  ];
  List<WalkIn> get history => [
    for (final w in _all)
      if (!w.isOpen) w,
  ]..sort((a, b) => (b.decidedAt ?? b.occurredAt).compareTo(a.decidedAt ?? a.occurredAt));
  bool get isEmpty => _all.isEmpty;

  /// Loads the list. [silent] refreshes (polling, pushes) keep the current list on screen and
  /// only surface errors when nothing has loaded yet.
  Future<void> load({bool silent = false}) async {
    if (_inFlight) return;
    _inFlight = true;
    if (!silent) {
      loading = true;
      failure = null;
      _notify();
    }
    try {
      _all = await _repository.list(eventId);
      loaded = true;
      failure = null;
    } on AppException catch (e) {
      if (!silent || !loaded) failure = e.failure;
    } catch (_) {
      if (!silent || !loaded) failure = AppFailure.unknown;
    } finally {
      _inFlight = false;
      loading = false;
      _notify();
    }
  }

  /// Polls every [pollInterval] while the screen is visible.
  void startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(pollInterval, (_) => unawaited(load(silent: true)));
  }

  void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }

  bool get polling => _timer != null;

  Future<WalkInDecisionResult> decide(WalkIn walkIn, WalkInDecision decision) async {
    if (!_canDecide || busy.contains(walkIn.id)) return const WalkInDecisionFailed(AppFailure.unauthorized);
    busy.add(walkIn.id);
    _notify();
    try {
      final updated = await _repository.decide(eventId, walkIn.id, decision);
      _replace(updated);
      return WalkInDecided(updated);
    } on WalkInAlreadyDecided catch (e) {
      _replace(e.walkIn);
      return WalkInDecidedElsewhere(e.walkIn);
    } on AppException catch (e) {
      // The server says this user may not decide (e.g. committee): switch to read-only.
      if (e.failure == AppFailure.unauthorized) _canDecide = false;
      return WalkInDecisionFailed(e.failure);
    } catch (_) {
      return const WalkInDecisionFailed(AppFailure.unknown);
    } finally {
      busy.remove(walkIn.id);
      _notify();
    }
  }

  void _replace(WalkIn updated) {
    _all = [for (final w in _all) w.id == updated.id ? updated : w];
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    stopPolling();
    unawaited(_alerts?.cancel());
    super.dispose();
  }
}

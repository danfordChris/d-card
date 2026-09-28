import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models/walk_in.dart';
import '../services/push_message_source.dart';
import 'walk_ins_repository.dart';

/// Walk-in pushes (`{type: "walk_in", eventId, walkInId, status}`) sent by the worker to the host
/// and every walk-in approver, as [WalkInAlert]s. Other push types are ignored.
class WalkInAlertsRepository {
  WalkInAlertsRepository(this._source);

  final PushMessageSource _source;
  final _subscriptions = <StreamSubscription<Map<String, Object?>>>[];
  bool _initialTaken = false;

  late final StreamController<WalkInAlert> _controller = StreamController.broadcast(onListen: _start, onCancel: _stop);

  /// Foreground messages (`opened: false`) and tapped notifications (`opened: true`).
  Stream<WalkInAlert> get alerts => _controller.stream;

  /// The walk-in notification that launched the app, returned once.
  Future<WalkInAlert?> takeInitialAlert() async {
    if (_initialTaken) return null;
    _initialTaken = true;
    try {
      final data = await _source.initial();
      return data == null ? null : parse(data, opened: true);
    } catch (e) {
      debugPrint('Reading the initial push failed: $e');
      return null;
    }
  }

  void _start() {
    _subscriptions
      ..add(_source.foreground.listen((data) => _emit(data, opened: false)))
      ..add(_source.opened.listen((data) => _emit(data, opened: true)));
  }

  void _stop() {
    for (final s in _subscriptions) {
      unawaited(s.cancel());
    }
    _subscriptions.clear();
  }

  void _emit(Map<String, Object?> data, {required bool opened}) {
    final alert = parse(data, opened: opened);
    if (alert != null) _controller.add(alert);
  }

  static WalkInAlert? parse(Map<String, Object?> data, {required bool opened}) {
    final eventId = data['eventId'];
    final walkInId = data['walkInId'];
    if (data['type'] != 'walk_in' || eventId is! String || eventId.isEmpty || walkInId is! String) return null;
    final status = data['status'];
    return WalkInAlert(
      eventId: eventId,
      walkInId: walkInId,
      status: WalkInsRepository.statusFromWire(status is String ? status : null),
      opened: opened,
    );
  }
}

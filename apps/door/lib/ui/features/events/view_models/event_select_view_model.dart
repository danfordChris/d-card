import 'package:flutter/foundation.dart';

import '../../../../data/repositories/door_repository.dart';
import '../../../../data/repositories/door_sync_repository.dart';
import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/door_event.dart';

/// Lists the events this account can check guests in for, and registers the phone
/// for the chosen one (AUTH-9).
class EventSelectViewModel extends ChangeNotifier {
  EventSelectViewModel(this._door, {this.notice, this._sync});

  final DoorRepository _door;
  final DoorSyncRepository? _sync;

  /// The event cached on this phone, offered when the event list cannot load (no network).
  DoorSession? offlineSession;

  List<DoorEvent> events = const [];
  bool loading = false;
  AppFailure? failure;

  /// The event being registered, while the request runs.
  String? openingEventId;

  /// Why the last event could not be opened, or why the app came back here.
  AppFailure? notice;

  String? get deviceName => _door.deviceName;

  Future<void> load() async {
    loading = true;
    failure = null;
    notifyListeners();
    try {
      events = await _door.listEvents();
      offlineSession = null;
    } on AppException catch (e) {
      failure = e.failure;
      if (e.failure == AppFailure.network) offlineSession = await _sync?.cachedSession();
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> setDeviceName(String name) => _door.setDeviceName(name);

  /// Registers this device for [event]; returns the session, or null with [notice] set.
  Future<DoorSession?> open(DoorEvent event) async {
    if (openingEventId != null) return null;
    openingEventId = event.id;
    notice = null;
    notifyListeners();
    try {
      return await _door.openEvent(event);
    } on AppException catch (e) {
      if (e.failure == AppFailure.network) {
        // Registered before and cached: keep checking guests in without network (CHK-6).
        final cached = await _sync?.cachedSession();
        if (cached != null && cached.event.id == event.id) return cached;
      }
      notice = e.failure;
    } catch (_) {
      notice = AppFailure.unknown;
    } finally {
      openingEventId = null;
      notifyListeners();
    }
    return null;
  }
}

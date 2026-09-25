import 'package:flutter/foundation.dart';

import '../../../../data/repositories/events_repository.dart';
import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/event_summary.dart';

/// Loads the host's events list.
class EventsViewModel extends ChangeNotifier {
  EventsViewModel(this._events);

  final EventsRepository _events;

  List<EventSummary> events = const [];
  AppFailure? failure;
  bool loading = false;

  Future<void> load() async {
    loading = true;
    failure = null;
    notifyListeners();
    try {
      events = await _events.listEvents();
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

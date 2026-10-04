import 'package:dcard_api/api.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/repositories/events_repository.dart';
import '../../../../domain/models/app_failure.dart';

class CreateEventViewModel extends ChangeNotifier {
  CreateEventViewModel(this._events);

  final EventsRepository _events;

  List<EventType> eventTypes = const [];
  List<Plan> plans = const [];
  bool loading = false;
  bool submitting = false;
  AppFailure? failure;
  bool created = false;

  EventType? selectedType;
  Plan? selectedPlan;
  String title = '';
  DateTime? startsAt;
  String contactName = '';
  String contactPhone = '';
  String venueName = '';
  String venueAddress = '';

  bool get canSubmit =>
      !submitting &&
      selectedType != null &&
      selectedPlan != null &&
      title.trim().isNotEmpty &&
      startsAt != null &&
      contactName.trim().isNotEmpty &&
      contactPhone.trim().length >= 9;

  Future<void> loadOptions() async {
    loading = true;
    failure = null;
    notifyListeners();
    try {
      final results = await Future.wait([_events.listEventTypes(), _events.listPlans()]);
      eventTypes = results[0] as List<EventType>;
      plans = results[1] as List<Plan>;
      if (plans.length == 1) selectedPlan = plans.first;
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setType(EventType? type) {
    selectedType = type;
    notifyListeners();
  }

  void setPlan(Plan? plan) {
    selectedPlan = plan;
    notifyListeners();
  }

  void setTitle(String value) {
    title = value;
    notifyListeners();
  }

  void setDate(DateTime value) {
    startsAt = value;
    notifyListeners();
  }

  void setContactName(String value) {
    contactName = value;
    notifyListeners();
  }

  void setContactPhone(String value) {
    contactPhone = value;
    notifyListeners();
  }

  void setVenueName(String value) => venueName = value;
  void setVenueAddress(String value) => venueAddress = value;

  Future<void> submit() async {
    if (!canSubmit) return;
    submitting = true;
    failure = null;
    notifyListeners();
    try {
      final phone = contactPhone.trim().replaceFirst(RegExp(r'^0'), '255');
      await _events.createEvent(EventCreateInput(
        planKey: selectedPlan!.key,
        eventTypeKey: selectedType!.key,
        title: title.trim(),
        startsAt: startsAt!,
        contactName: contactName.trim(),
        contactPhone: phone,
        venueName: venueName.trim().isEmpty ? null : venueName.trim(),
        venueAddress: venueAddress.trim().isEmpty ? null : venueAddress.trim(),
      ));
      created = true;
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}

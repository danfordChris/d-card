import 'package:dcard_api/api.dart';

import '../../domain/models/event_summary.dart';
import 'api_errors.dart';

/// Events the signed-in user can see (`GET /api/v1/events`).
class EventsRepository {
  EventsRepository(this._api);

  final DefaultApi _api;

  Future<List<EventSummary>> listEvents() async {
    final list = await guardApi(_api.listEvents);
    return list.events.map(_toSummary).toList();
  }

  static EventSummary _toSummary(Event e) => EventSummary(
    id: e.id,
    title: e.title,
    status: EventStatus.values.byName(e.status.value),
    typeNameSw: e.eventType.nameSw,
    typeNameEn: e.eventType.nameEn,
    planName: e.plan.name,
    startsAt: e.startsAt,
    venueName: e.venueName,
    venueAddress: e.venueAddress,
    contactName: e.contactName,
    contactPhone: e.contactPhone,
    contact2Name: e.contact2Name,
    contact2Phone: e.contact2Phone,
    canManageGuests:
        (e.access == EventAccessEnum.host || e.access == EventAccessEnum.committee) &&
        (e.status == EventStatusEnum.draft || e.status == EventStatusEnum.published),
  );
}

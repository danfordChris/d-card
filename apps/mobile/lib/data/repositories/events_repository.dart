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

  /// One event (`GET /api/v1/events/{id}`), e.g. when a push opens it.
  Future<EventSummary> getEvent(String id) async => _toSummary(await guardApi(() => _api.getEvent(id)));

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
    canViewContributions: const [
      EventAccessEnum.host,
      EventAccessEnum.committee,
      EventAccessEnum.treasurer,
    ].contains(e.access),
    canRecordPayments: e.access == EventAccessEnum.host || e.access == EventAccessEnum.treasurer,
    // `roles` lists every role held here (e.g. committee + walk-in approver); `access` is only one.
    canViewWalkIns: e.roles.any((r) => const [
          EventRolesEnum.host,
          EventRolesEnum.committee,
          EventRolesEnum.walkinApprover,
        ].contains(r)) ||
        const [EventAccessEnum.host, EventAccessEnum.committee, EventAccessEnum.walkinApprover].contains(e.access),
    isHost: e.access == EventAccessEnum.host || e.roles.contains(EventRolesEnum.host),
    planPaid: e.plan.paid,
    canDecideWalkIns: e.roles.contains(EventRolesEnum.host) ||
        e.roles.contains(EventRolesEnum.walkinApprover) ||
        e.access == EventAccessEnum.host ||
        e.access == EventAccessEnum.walkinApprover,
  );
}

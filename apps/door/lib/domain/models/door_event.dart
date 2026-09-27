enum DoorRole { host, committee, doorStaff }

/// An event the signed-in user may check guests in for.
class DoorEvent {
  const DoorEvent({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.role,
    this.endsAt,
    this.venueName,
  });

  final String id;
  final String title;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? venueName;
  final DoorRole role;
}

/// This phone registered for one event (AUTH-9): all door calls carry [deviceId].
class DoorSession {
  const DoorSession({required this.event, required this.deviceId, this.deviceName});

  final DoorEvent event;
  final String deviceId;
  final String? deviceName;
}

/// Where [DoorEvent] stands against the phone's clock, for the door's "not started" and
/// "ended" screens. The server does not refuse check-in by time, so these only warn.
enum EventTiming { upcoming, open, ended }

extension DoorEventTiming on DoorEvent {
  /// Doors usually open before the start time; earlier than this the door warns.
  static const earlyWindow = Duration(hours: 3);

  /// Without an end time the event counts as running this long (the server's default).
  static const defaultLength = Duration(hours: 12);

  DateTime get effectiveEndsAt => endsAt ?? startsAt.add(defaultLength);

  EventTiming timingAt(DateTime now) {
    if (now.isBefore(startsAt.subtract(earlyWindow))) return EventTiming.upcoming;
    if (now.isAfter(effectiveEndsAt)) return EventTiming.ended;
    return EventTiming.open;
  }
}

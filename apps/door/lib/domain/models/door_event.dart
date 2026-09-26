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

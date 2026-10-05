import 'package:dcard_api/api.dart';

sealed class GuestResult {}

class GuestUpdated extends GuestResult {
  GuestUpdated(this.guest);
  final Guest guest;
}

class GuestRemoved extends GuestResult {
  GuestRemoved(this.guestId);
  final String guestId;
}

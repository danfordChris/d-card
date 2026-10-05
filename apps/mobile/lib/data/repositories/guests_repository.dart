import 'package:dcard_api/api.dart';

import 'api_errors.dart';

class BulkAddResult {
  const BulkAddResult({required this.added, required this.existing, required this.invalid});

  final int added;
  final int existing;
  final int invalid;
}

class GuestsRepository {
  GuestsRepository(this._api);

  final DefaultApi _api;

  Future<GuestPage> list(String eventId, {String? query, int? limit, String? cursor}) async {
    return guardApi(() => _api.listGuests(eventId, q: query, limit: limit, cursor: cursor));
  }

  Future<BulkAddResult> addFromContacts(String eventId, List<({String name, String phone})> guests) async {
    final input = GuestBulkInput(
      guests: [for (final g in guests) GuestBulkInputGuestsInner(name: g.name, phone: g.phone)],
      consent: true,
    );
    final result = await guardApi(() => _api.addGuestsBulk(eventId, guestBulkInput: input));
    return BulkAddResult(added: result.added.length, existing: result.existing.length, invalid: result.invalid.length);
  }

  Future<void> remove(String eventId, String guestId) async {
    await _api.removeGuest(eventId, guestId);
  }

  Future<Card> issueCard(String eventId, String guestId) async {
    return guardApi(() => _api.issueCard(eventId, guestId));
  }

  Future<Card> cancelCard(String eventId, String guestId) async {
    return guardApi(() => _api.cancelCard(eventId, guestId));
  }

  Future<Card> reinstateCard(String eventId, String guestId) async {
    return guardApi(() => _api.reinstateCard(eventId, guestId));
  }

  Future<CardLink> getCardLink(String eventId, String guestId) async {
    return guardApi(() => _api.getCardLink(eventId, guestId));
  }
}

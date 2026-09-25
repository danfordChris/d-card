import 'package:dcard_api/api.dart';

import 'api_errors.dart';

/// Outcome of adding several guests at once.
class BulkAddResult {
  const BulkAddResult({required this.added, required this.existing, required this.invalid});

  final int added;
  final int existing;
  final int invalid;
}

class GuestsRepository {
  GuestsRepository(this._api);

  final DefaultApi _api;

  /// `POST /api/v1/events/{id}/guests/bulk` with the host's consent confirmation.
  Future<BulkAddResult> addFromContacts(String eventId, List<({String name, String phone})> guests) async {
    final input = GuestBulkInput(
      guests: [for (final g in guests) GuestBulkInputGuestsInner(name: g.name, phone: g.phone)],
      consent: true,
    );
    final result = await guardApi(() => _api.addGuestsBulk(eventId, guestBulkInput: input));
    return BulkAddResult(added: result.added.length, existing: result.existing.length, invalid: result.invalid.length);
  }
}

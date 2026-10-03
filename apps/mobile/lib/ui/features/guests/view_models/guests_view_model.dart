import 'package:dcard_api/api.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/repositories/guests_repository.dart';
import '../../../../domain/models/app_failure.dart';

enum GuestFilter { all, pending, issued, cancelled }

class GuestsViewModel extends ChangeNotifier {
  GuestsViewModel({required this.eventId, required this.repository});

  final String eventId;
  final GuestsRepository repository;

  List<Guest> _all = const [];
  GuestFilter filter = GuestFilter.all;
  String query = '';
  bool loading = false;
  AppFailure? failure;

  int get totalCount => _all.length;
  int get issuedCount => _all.where((g) => g.status == GuestStatusEnum.issued).length;
  int get pendingCount => _all.where((g) => g.status == GuestStatusEnum.pending).length;
  int get cancelledCount => _all.where((g) => g.status == GuestStatusEnum.cancelled).length;

  List<Guest> get visible {
    final q = query.trim().toLowerCase();
    final digits = q.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp('^0'), '');
    return [
      for (final g in _all)
        if (_matchesFilter(g) &&
            (q.isEmpty || g.name.toLowerCase().contains(q) || (digits.length >= 3 && g.phone.contains(digits))))
          g,
    ];
  }

  bool _matchesFilter(Guest g) => switch (filter) {
    GuestFilter.all => true,
    GuestFilter.pending => g.status == GuestStatusEnum.pending,
    GuestFilter.issued => g.status == GuestStatusEnum.issued,
    GuestFilter.cancelled => g.status == GuestStatusEnum.cancelled,
  };

  Future<void> load() async {
    loading = true;
    failure = null;
    notifyListeners();
    try {
      final List<Guest> all = [];
      String? cursor;
      do {
        final page = await repository.list(eventId, limit: 200, cursor: cursor);
        all.addAll(page.guests);
        cursor = page.nextCursor;
      } while (cursor != null);
      _all = all;
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setFilter(GuestFilter value) {
    filter = value;
    notifyListeners();
  }

  void search(String value) {
    query = value;
    notifyListeners();
  }

  void replaceGuest(Guest updated) {
    _all = [for (final g in _all) g.id == updated.id ? updated : g];
    notifyListeners();
  }

  void removeGuest(String guestId) {
    _all = [for (final g in _all) if (g.id != guestId) g];
    notifyListeners();
  }
}

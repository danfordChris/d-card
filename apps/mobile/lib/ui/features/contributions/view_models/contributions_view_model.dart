import 'package:flutter/foundation.dart';

import '../../../../data/repositories/contributions_repository.dart';
import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/contributor.dart';

enum ContributorFilter { all, notPaid, partPaid, fullyPaid }

/// Contributor list with search and status filter (CON-3).
class ContributionsViewModel extends ChangeNotifier {
  ContributionsViewModel({required this.eventId, required this._repository});

  final String eventId;
  final ContributionsRepository _repository;

  ContributionTotals? totals;
  List<Contributor> _all = const [];
  ContributorFilter filter = ContributorFilter.all;
  String query = '';
  bool loading = false;
  AppFailure? failure;

  List<Contributor> get visible {
    final q = query.trim().toLowerCase();
    final digits = q.replaceAll(RegExp(r'\D'), '').replaceFirst(RegExp('^0'), '');
    return [
      for (final c in _all)
        if (_matchesFilter(c) &&
            (q.isEmpty || c.name.toLowerCase().contains(q) || (digits.length >= 3 && c.phone.contains(digits))))
          c,
    ];
  }

  bool _matchesFilter(Contributor c) => switch (filter) {
    ContributorFilter.all => true,
    ContributorFilter.notPaid => !c.cancelled && c.status == PledgeStatus.notPaid,
    ContributorFilter.partPaid => !c.cancelled && c.status == PledgeStatus.partPaid,
    ContributorFilter.fullyPaid => !c.cancelled && c.status == PledgeStatus.fullyPaid,
  };

  Future<void> load() async {
    loading = true;
    failure = null;
    notifyListeners();
    try {
      final (t, list) = await _repository.list(eventId);
      totals = t;
      _all = list;
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void setFilter(ContributorFilter value) {
    filter = value;
    notifyListeners();
  }

  void search(String value) {
    query = value;
    notifyListeners();
  }

  /// Applies a payment result and refreshes totals from the server.
  Future<void> updated(Contributor c) async {
    _all = [for (final x in _all) x.id == c.id ? c : x];
    notifyListeners();
    await load();
  }
}

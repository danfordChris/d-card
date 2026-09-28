import 'package:flutter/foundation.dart';

import '../../../../data/repositories/billing_repository.dart';
import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/billing.dart';

/// The event's plan, paid cards, a waiting payment and receipts (host only).
class BillingViewModel extends ChangeNotifier {
  BillingViewModel({required this.eventId, required this._repository});

  final String eventId;
  final BillingRepository _repository;

  BillingSummary? summary;

  /// Active plans (cheapest first); empty when they could not be loaded.
  List<PlanOption> plans = const [];
  AppFailure? failure;
  bool loading = false;

  BillingRepository get repository => _repository;

  /// A plan priced above the current one exists (or plans are unknown).
  bool get canUpgrade {
    final s = summary;
    if (s == null) return false;
    return plans.isEmpty || plans.any((p) => p.pricePerGuest > s.pricePerGuest);
  }

  String planName(String key) =>
      plans.where((p) => p.key == key).firstOrNull?.name ?? (key == summary?.planKey ? summary!.planName : key);

  Future<void> load() async {
    loading = true;
    failure = null;
    notifyListeners();
    try {
      summary = await _repository.summary(eventId);
      if (plans.isEmpty) {
        try {
          plans = await _repository.plans();
        } catch (_) {
          // Optional: without plans the upgrade button stays visible and the checkout lists them.
        }
      }
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}

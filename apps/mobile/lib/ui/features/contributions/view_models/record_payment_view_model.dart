import 'package:flutter/foundation.dart';

import '../../../../data/repositories/contributions_repository.dart';
import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/contributor.dart';

enum AmountError { required, invalid }

/// CON-2: record a payment made outside D-Card (amount, method, reference, date).
class RecordPaymentViewModel extends ChangeNotifier {
  RecordPaymentViewModel({required this.eventId, required this.contributor, required this._repository, DateTime? today})
    : paidOn = today ?? _todayInTanzania();

  final String eventId;
  Contributor contributor;
  final ContributionsRepository _repository;

  PaymentMethod method = PaymentMethod.mpesa;
  DateTime paidOn;
  AmountError? amountError;
  AppFailure? failure;
  bool busy = false;

  /// Set after a successful save; true when this payment issued the card.
  bool? issuedNow;

  static DateTime _todayInTanzania() {
    final eat = DateTime.now().toUtc().add(const Duration(hours: 3));
    return DateTime(eat.year, eat.month, eat.day);
  }

  static int? parseAmount(String value) {
    final clean = value.replaceAll(RegExp(r'[,\s]'), '');
    if (!RegExp(r'^\d+$').hasMatch(clean)) return null;
    final n = int.parse(clean);
    return n >= 1 && n <= 100000000 ? n : null;
  }

  void setMethod(PaymentMethod value) {
    method = value;
    notifyListeners();
  }

  void setDate(DateTime value) {
    paidOn = value;
    notifyListeners();
  }

  Future<bool> submit(String amountText, String reference) async {
    final amount = parseAmount(amountText);
    amountError = amountText.trim().isEmpty ? AmountError.required : (amount == null ? AmountError.invalid : null);
    failure = null;
    if (amountError != null) {
      notifyListeners();
      return false;
    }
    busy = true;
    notifyListeners();
    try {
      final before = contributor.cardNumber;
      contributor = await _repository.recordPayment(
        eventId,
        contributor.id,
        amount: amount!,
        method: method,
        reference: reference.trim().isEmpty ? null : reference.trim(),
        paidOn: paidOn,
      );
      issuedNow = before == null && contributor.cardNumber != null;
      return true;
    } on AppException catch (e) {
      failure = e.failure;
      return false;
    } catch (_) {
      failure = AppFailure.unknown;
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}

import 'dart:convert';
import 'dart:io';

import 'package:dcard_api/api.dart' as api;
import 'package:http/http.dart' as http;

import '../../domain/models/app_failure.dart';
import '../../domain/models/billing.dart';

/// Host billing for one event: summary, live quote, checkout and attempt status
/// (`/api/v1/events/{id}/billing`, `.../billing/quote`, `.../checkout`, `.../checkout/{attemptId}`).
///
/// Reads raw JSON: `pendingAttempt` is null when nothing is waiting, which the generated
/// model does not allow.
class BillingRepository {
  BillingRepository(this._api);

  final api.DefaultApi _api;

  Future<BillingSummary> summary(String eventId) async =>
      summaryFromJson(await _send(() => _api.getBillingWithHttpInfo(eventId)));

  /// Active plans, cheapest first.
  Future<List<PlanOption>> plans() async {
    final body = await _send(_api.listPlansWithHttpInfo);
    final plans = [
      for (final p in (body['plans'] as List? ?? const []).cast<Map<String, dynamic>>())
        PlanOption(key: p['key'] as String, name: p['name'] as String, pricePerGuest: _int(p['pricePerGuest'])),
    ]..sort((a, b) => a.pricePerGuest.compareTo(b.pricePerGuest));
    return plans;
  }

  Future<BillingQuote> quote(String eventId, {required String planKey, required int guestCards}) async {
    final input = api.BillingQuoteInput(planKey: api.PlanKey.fromJson(planKey), guestCards: guestCards);
    return quoteFromJson(await _send(() => _api.quoteBillingWithHttpInfo(eventId, billingQuoteInput: input)));
  }

  /// Starts a payment. [phone] is `255` + 9 digits for [CheckoutMethod.mobile].
  /// Throws [CheckoutRejectedException] for the documented refusals.
  Future<PaymentAttempt> checkout(
    String eventId, {
    required String planKey,
    required int guestCards,
    required CheckoutMethod method,
    String? phone,
    required int expectedTotal,
  }) async {
    final input = api.CheckoutInput(
      planKey: api.PlanKey.fromJson(planKey),
      guestCards: guestCards,
      method: method == CheckoutMethod.mobile ? api.HostPaymentMethod.mobile : api.HostPaymentMethod.session,
      phone: phone,
      expectedTotal: expectedTotal,
    );
    return attemptFromJson(await _send(() => _api.startCheckoutWithHttpInfo(eventId, checkoutInput: input)));
  }

  Future<PaymentAttempt> attempt(String eventId, String attemptId) async =>
      attemptFromJson(await _send(() => _api.getCheckoutWithHttpInfo(eventId, attemptId)));

  Future<Map<String, dynamic>> _send(Future<http.Response> Function() call) async {
    final http.Response response;
    try {
      response = await call();
    } on api.ApiException catch (e) {
      if (e.innerException is SocketException || e.innerException is HttpException) {
        throw const AppException(AppFailure.network);
      }
      throw const AppException(AppFailure.unknown);
    } on SocketException {
      throw const AppException(AppFailure.network);
    } on HttpException {
      throw const AppException(AppFailure.network);
    }
    Object? decoded;
    try {
      decoded = response.bodyBytes.isEmpty ? null : jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      decoded = null;
    }
    final body = decoded is Map ? decoded.cast<String, dynamic>() : <String, dynamic>{};
    final status = response.statusCode;
    if (status < 400) {
      if (decoded is! Map) throw const AppException(AppFailure.unknown);
      return body;
    }
    if (status == 401) throw const AppException(AppFailure.unauthorized);
    final code = (body['error'] as Map?)?['code'];
    final rejection = switch (code) {
      'quote_changed' => CheckoutRejection.quoteChanged,
      'nothing_to_pay' => CheckoutRejection.nothingToPay,
      'payment_in_progress' => CheckoutRejection.paymentInProgress,
      'provider_unavailable' => CheckoutRejection.providerUnavailable,
      'event_closed' => CheckoutRejection.eventClosed,
      _ when status == 502 => CheckoutRejection.providerUnavailable,
      _ when status == 400 || status == 422 => CheckoutRejection.invalid,
      _ when status == 403 => CheckoutRejection.forbidden,
      _ => null,
    };
    if (rejection != null) throw CheckoutRejectedException(rejection);
    throw const AppException(AppFailure.unknown);
  }

  static int _int(Object? v) => v is num ? v.toInt() : 0;

  static DateTime? _date(Object? v) => v is String ? DateTime.tryParse(v) : null;

  static BillingSummary summaryFromJson(Map<String, dynamic> j) {
    final pending = j['pendingAttempt'];
    return BillingSummary(
      planKey: j['planKey'] as String,
      planName: j['planName'] as String,
      pricePerGuest: _int(j['pricePerGuest']),
      guestLimit: _int(j['guestLimit']),
      amountPaid: _int(j['amountPaid']),
      paid: j['paid'] == true,
      issuedCards: _int(j['issuedCards']),
      guestCount: _int(j['guestCount']),
      launchOfferPercent: _int(j['launchOfferPercent']),
      launchOfferEligible: j['launchOfferEligible'] == true,
      pendingAttempt: pending is Map ? attemptFromJson(pending.cast<String, dynamic>()) : null,
      payments: [
        for (final p in (j['payments'] as List? ?? const []).cast<Map<String, dynamic>>())
          HostPaymentReceipt(
            id: p['id'] as String,
            planKey: p['planKey'] as String,
            guestCards: _int(p['guestCards']),
            amount: _int(p['amount']),
            discountAmount: _int(p['discountAmount']),
            method: p['method'] as String? ?? '',
            reference: p['reference'] as String? ?? '',
            paidAt: _date(p['paidAt']) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
          ),
      ],
    );
  }

  static BillingQuote quoteFromJson(Map<String, dynamic> j) => BillingQuote(
    planKey: j['planKey'] as String,
    planName: j['planName'] as String,
    pricePerGuest: _int(j['pricePerGuest']),
    currentGuestCards: _int(j['currentGuestCards']),
    guestCards: _int(j['guestCards']),
    blockSize: _int(j['blockSize']),
    minimumCharge: _int(j['minimumCharge']),
    lines: [
      for (final l in (j['lines'] as List? ?? const []).cast<Map<String, dynamic>>())
        QuoteLine(
          kind: switch (l['code']) {
            'new_cards' => QuoteLineKind.newCards,
            'extra_cards' => QuoteLineKind.extraCards,
            'upgrade' => QuoteLineKind.upgrade,
            _ => QuoteLineKind.other,
          },
          quantity: _int(l['quantity']),
          unitPrice: _int(l['unitPrice']),
          amount: _int(l['amount']),
        ),
    ],
    subtotal: _int(j['subtotal']),
    discountPercent: _int(j['discountPercent']),
    discountAmount: _int(j['discountAmount']),
    total: _int(j['total']),
    payable: j['payable'] == true,
  );

  static PaymentAttempt attemptFromJson(Map<String, dynamic> j) => PaymentAttempt(
    id: j['id'] as String,
    status: switch (j['status']) {
      'completed' => PaymentAttemptStatus.completed,
      'failed' => PaymentAttemptStatus.failed,
      'expired' => PaymentAttemptStatus.expired,
      _ => PaymentAttemptStatus.pending,
    },
    method: j['method'] == 'session' ? CheckoutMethod.session : CheckoutMethod.mobile,
    amount: _int(j['amount']),
    planKey: j['planKey'] as String? ?? '',
    guestCards: _int(j['guestCards']),
    phone: j['phone'] as String?,
    checkoutUrl: j['checkoutUrl'] as String?,
    reference: j['reference'] as String?,
    failureReason: j['failureReason'] as String?,
    createdAt: _date(j['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    completedAt: _date(j['completedAt']),
  );
}

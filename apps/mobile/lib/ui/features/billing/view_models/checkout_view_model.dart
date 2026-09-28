import 'dart:async';

import 'package:dcard_core/dcard_core.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/repositories/billing_repository.dart';
import '../../../../data/services/link_opener.dart';
import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/billing.dart';

/// Where the host started: first purchase, one more block, a higher plan, or a waiting payment.
enum CheckoutMode { buy, addBlock, upgrade, resume }

/// Solomon money flow: choose (live server quote) → review → waiting (poll) → receipt or failure.
enum CheckoutStep { choose, review, waiting, success, failure }

enum QuoteState { loading, ready, error }

enum PhoneError { required, invalid }

/// Host checkout for one event (T05-03). The price always comes from the server quote; the
/// checkout sends the quoted total as `expectedTotal` so a changed price is never charged silently.
class CheckoutViewModel extends ChangeNotifier {
  CheckoutViewModel({
    required this.eventId,
    required this._repository,
    required this._links,
    required BillingSummary summary,
    required this.mode,
    this.defaultPhone,
    this.quoteDelay = const Duration(milliseconds: 400),
    this.pollInterval = const Duration(seconds: 3),
  }) : _summary = summary,
       planKey = mode == CheckoutMode.resume ? summary.pendingAttempt!.planKey : summary.planKey,
       cards = _initialCards(summary, mode),
       plans = [PlanOption(key: summary.planKey, name: summary.planName, pricePerGuest: summary.pricePerGuest)],
       step = mode == CheckoutMode.resume ? CheckoutStep.waiting : CheckoutStep.choose,
       attempt = mode == CheckoutMode.resume ? summary.pendingAttempt : null;

  static const defaultBlockSize = 10;

  final String eventId;
  final CheckoutMode mode;

  /// Mobile-money number to prefill (stored form, `255` + 9 digits), when the app knows one.
  final String? defaultPhone;
  final Duration quoteDelay;
  final Duration pollInterval;
  final BillingRepository _repository;
  final LinkOpener _links;
  BillingSummary _summary;

  /// The current plan and the higher ones, cheapest first.
  List<PlanOption> plans;
  String planKey;
  int cards;
  CheckoutStep step;
  CheckoutMethod method = CheckoutMethod.mobile;

  BillingQuote? quote;
  QuoteState quoteState = QuoteState.loading;
  String? _quoteKey;

  PaymentAttempt? attempt;
  PhoneError? phoneError;

  /// Refusal from the server on the last pay (shown as a notice).
  CheckoutRejection? rejection;
  AppFailure? failure;
  bool busy = false;

  /// Billing changed (paid, or another payment found): the billing screen should reload.
  bool changed = false;

  Timer? _quoteTimer;
  Timer? _pollTimer;
  int _quoteSeq = 0;
  bool _disposed = false;

  BillingSummary get summary => _summary;
  int get blockSize => quote?.blockSize ?? defaultBlockSize;
  int get minCards => _summary.paid ? _summary.guestLimit : 1;
  String get _currentKey => '$planKey|$cards';

  /// The quote matches the plan and cards on screen.
  bool get quoteFresh => quoteState == QuoteState.ready && _quoteKey == _currentKey && quote != null;
  bool get canReview => quoteFresh && quote!.payable;

  /// The minimum charge raised the cards above what the host chose.
  bool get minimumApplied => quoteFresh && !_summary.paid && quote!.guestCards > cards;

  String planName(String key) =>
      plans.where((p) => p.key == key).firstOrNull?.name ?? (key == _summary.planKey ? _summary.planName : key);

  static int _initialCards(BillingSummary s, CheckoutMode mode) => switch (mode) {
    CheckoutMode.resume => s.pendingAttempt!.guestCards,
    CheckoutMode.addBlock => s.guestLimit + defaultBlockSize,
    CheckoutMode.upgrade => s.guestLimit > 0 ? s.guestLimit : (s.guestCount > 0 ? s.guestCount : 1),
    CheckoutMode.buy => _roundUpToBlock(s, s.guestCount > s.guestLimit ? s.guestCount : s.guestLimit),
  };

  static int _roundUpToBlock(BillingSummary s, int wanted) {
    if (wanted < 1) return 1;
    if (!s.paid || wanted <= s.guestLimit) return wanted;
    final extra = wanted - s.guestLimit;
    return s.guestLimit + ((extra + defaultBlockSize - 1) ~/ defaultBlockSize) * defaultBlockSize;
  }

  /// Loads the plan choices and the first quote, or starts polling a waiting payment.
  Future<void> start() async {
    if (step == CheckoutStep.waiting) {
      _schedulePoll();
      return;
    }
    _requestQuote(immediate: true);
    try {
      final all = await _repository.plans();
      final upward = all
          .where((p) => p.key == _summary.planKey || p.pricePerGuest > _summary.pricePerGuest)
          .toList();
      if (upward.isNotEmpty) plans = upward;
      if (mode == CheckoutMode.upgrade && planKey == _summary.planKey) {
        final higher = plans.where((p) => p.key != _summary.planKey).firstOrNull;
        if (higher != null) {
          planKey = higher.key;
          _requestQuote(immediate: true);
        }
      }
    } catch (_) {
      // Keep the current plan only; the checkout still works.
    }
    _notify();
  }

  void setCards(int value) {
    final next = value < minCards ? minCards : value;
    if (next == cards) return;
    cards = next;
    _changedInput();
  }

  void increaseCards() => setCards(_summary.paid ? _nextBlock(cards) : cards + blockSize);

  void decreaseCards() => setCards(_summary.paid ? _previousBlock(cards) : cards - blockSize);

  int _nextBlock(int n) {
    final extra = n - _summary.guestLimit;
    return _summary.guestLimit + ((extra ~/ blockSize) + 1) * blockSize;
  }

  int _previousBlock(int n) {
    final extra = n - _summary.guestLimit;
    final blocks = (extra + blockSize - 1) ~/ blockSize;
    return _summary.guestLimit + (blocks > 0 ? blocks - 1 : 0) * blockSize;
  }

  bool get canDecrease => cards > minCards;

  void setPlan(String key) {
    if (key == planKey) return;
    planKey = key;
    _changedInput();
  }

  void setMethod(CheckoutMethod value) {
    method = value;
    phoneError = null;
    _notify();
  }

  void _changedInput() {
    rejection = null;
    failure = null;
    _requestQuote();
    _notify();
  }

  void retryQuote() => _requestQuote(immediate: true);

  void _requestQuote({bool immediate = false}) {
    _quoteTimer?.cancel();
    quoteState = QuoteState.loading;
    final seq = ++_quoteSeq;
    final key = _currentKey;
    final plan = planKey;
    final count = cards;
    Future<void> run() async {
      try {
        final q = await _repository.quote(eventId, planKey: plan, guestCards: count);
        if (_disposed || seq != _quoteSeq) return;
        quote = q;
        _quoteKey = key;
        quoteState = QuoteState.ready;
      } catch (_) {
        if (_disposed || seq != _quoteSeq) return;
        quoteState = QuoteState.error;
      }
      _notify();
    }

    if (immediate) {
      unawaited(run());
    } else {
      _quoteTimer = Timer(quoteDelay, run);
    }
    _notify();
  }

  void review() {
    if (!canReview) return;
    rejection = null;
    failure = null;
    step = CheckoutStep.review;
    _notify();
  }

  void backToChoose() {
    rejection = null;
    failure = null;
    phoneError = null;
    step = CheckoutStep.choose;
    _notify();
  }

  /// Starts the payment with the quoted total. [phoneText] is what the host typed.
  Future<void> pay(String phoneText) async {
    if (busy || !quoteFresh) return;
    rejection = null;
    failure = null;
    String? phone;
    if (method == CheckoutMethod.mobile) {
      if (phoneText.trim().isEmpty) {
        phoneError = PhoneError.required;
      } else if (!isValidPhone(phoneText)) {
        phoneError = PhoneError.invalid;
      } else {
        phoneError = null;
        phone = normalisePhone(phoneText);
      }
      if (phoneError != null) {
        _notify();
        return;
      }
    }
    busy = true;
    _notify();
    try {
      final started = await _repository.checkout(
        eventId,
        planKey: planKey,
        guestCards: cards,
        method: method,
        phone: phone,
        expectedTotal: quote!.total,
      );
      attempt = started;
      if (started.method == CheckoutMethod.session && started.checkoutUrl != null) {
        unawaited(_links.open(Uri.parse(started.checkoutUrl!)));
      }
      if (started.isPending) {
        step = CheckoutStep.waiting;
        _schedulePoll();
      } else {
        _finish(started);
      }
    } on CheckoutRejectedException catch (e) {
      rejection = e.reason;
      await _handleRejection(e.reason);
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      busy = false;
      _notify();
    }
  }

  Future<void> _handleRejection(CheckoutRejection reason) async {
    switch (reason) {
      case CheckoutRejection.quoteChanged:
        // Show the new price and ask the host to confirm again.
        try {
          final q = await _repository.quote(eventId, planKey: planKey, guestCards: cards);
          quote = q;
          _quoteKey = _currentKey;
          quoteState = QuoteState.ready;
        } catch (_) {
          quoteState = QuoteState.error;
        }
      case CheckoutRejection.paymentInProgress:
        changed = true;
        try {
          _summary = await _repository.summary(eventId);
          final pending = _summary.pendingAttempt;
          if (pending != null && pending.isPending) {
            attempt = pending;
            step = CheckoutStep.waiting;
            _schedulePoll();
          }
        } catch (_) {
          // Keep the notice; the host can check the billing screen.
        }
      case CheckoutRejection.nothingToPay:
        changed = true;
      default:
        break;
    }
  }

  /// Opens the hosted payment page again (card or other method).
  Future<void> openPaymentPage() async {
    final url = attempt?.checkoutUrl;
    if (url != null) await _links.open(Uri.parse(url));
  }

  void _schedulePoll() {
    _pollTimer?.cancel();
    _pollTimer = Timer(pollInterval, _poll);
  }

  Future<void> _poll() async {
    final current = attempt;
    if (_disposed || current == null || step != CheckoutStep.waiting) return;
    try {
      final next = await _repository.attempt(eventId, current.id);
      if (_disposed || step != CheckoutStep.waiting) return;
      attempt = next;
      if (!next.isPending) {
        _finish(next);
        _notify();
        return;
      }
    } catch (_) {
      // Network hiccup: keep waiting and try again.
    }
    if (!_disposed && step == CheckoutStep.waiting) _schedulePoll();
  }

  void _finish(PaymentAttempt a) {
    _pollTimer?.cancel();
    attempt = a;
    if (a.status == PaymentAttemptStatus.completed) {
      step = CheckoutStep.success;
      changed = true;
    } else {
      step = CheckoutStep.failure;
    }
  }

  /// After a failed or expired payment: back to review with a fresh quote.
  void retry() {
    attempt = null;
    rejection = null;
    failure = null;
    step = CheckoutStep.review;
    _requestQuote(immediate: true);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _quoteTimer?.cancel();
    _pollTimer?.cancel();
    super.dispose();
  }
}

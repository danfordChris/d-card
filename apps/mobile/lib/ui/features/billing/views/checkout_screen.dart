import 'package:dcard_core/dcard_core.dart';
import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../domain/models/billing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import '../../../core/money.dart';
import '../view_models/checkout_view_model.dart';
import 'billing_widgets.dart';

/// Host checkout: choose cards (live quote) → review → waiting (poll) → receipt or failure.
/// Pops with true when billing changed. Owns and disposes [viewModel].
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.viewModel});

  final CheckoutViewModel viewModel;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late final TextEditingController _phone;
  late final TextEditingController _cards;

  CheckoutViewModel get vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    final initial = vm.defaultPhone;
    _phone = TextEditingController(text: initial != null && isValidPhone(initial) ? formatLocalPhone(initial) : '');
    _cards = TextEditingController(text: '${vm.cards}');
    vm.addListener(_syncCards);
    vm.start();
  }

  /// Keeps the cards field in step with −/+ without fighting the host's typing.
  void _syncCards() {
    if (int.tryParse(_cards.text) != vm.cards) _cards.text = '${vm.cards}';
  }

  @override
  void dispose() {
    vm.removeListener(_syncCards);
    vm.dispose();
    _phone.dispose();
    _cards.dispose();
    super.dispose();
  }

  void _close() => Navigator.of(context).pop(vm.changed);

  String _title(AppLocalizations l10n) => switch (vm.mode) {
    CheckoutMode.buy => l10n.checkoutTitleBuy,
    CheckoutMode.addBlock => l10n.checkoutTitleAdd,
    CheckoutMode.upgrade => l10n.checkoutTitleUpgrade,
    CheckoutMode.resume => l10n.paymentTitle,
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: vm,
      builder: (context, _) => PopScope<bool>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          // Leaving the waiting screen does not cancel the payment; the billing screen shows it.
          if (vm.step == CheckoutStep.review) {
            vm.backToChoose();
          } else {
            _close();
          }
        },
        child: Scaffold(
          appBar: DcTopBar(
            title: vm.step == CheckoutStep.review ? l10n.checkoutReviewTitle : _title(l10n),
            backLabel: l10n.back,
          ),
          body: SafeArea(
            child: switch (vm.step) {
              CheckoutStep.choose => _choose(context, l10n),
              CheckoutStep.review => _review(context, l10n),
              CheckoutStep.waiting => _waiting(context, l10n),
              CheckoutStep.success => _success(context, l10n),
              CheckoutStep.failure => _failure(context, l10n),
            },
          ),
        ),
      ),
    );
  }

  String? _notice(AppLocalizations l10n) {
    final r = vm.rejection;
    if (r != null) {
      return switch (r) {
        CheckoutRejection.quoteChanged => l10n.checkoutQuoteChanged,
        CheckoutRejection.nothingToPay => l10n.checkoutNothingToPayError,
        CheckoutRejection.paymentInProgress => l10n.checkoutPaymentInProgress,
        CheckoutRejection.providerUnavailable => l10n.checkoutProviderUnavailable,
        CheckoutRejection.eventClosed => l10n.checkoutEventClosed,
        CheckoutRejection.invalid => l10n.checkoutValidation,
        CheckoutRejection.forbidden => l10n.checkoutForbidden,
      };
    }
    final f = vm.failure;
    return f == null ? null : l10n.failure(f);
  }

  Widget _quoteBlock(BuildContext context, AppLocalizations l10n) {
    final q = vm.quote;
    final c = context.dc;
    if (vm.quoteState == QuoteState.error) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DcNoticeTile(tone: DcTone.danger, message: l10n.checkoutQuoteError),
          const SizedBox(height: DcSpace.sm),
          DcButton(variant: DcButtonVariant.tonal, label: l10n.retry, onPressed: vm.retryQuote),
        ],
      );
    }
    final Widget child;
    if (q == null) {
      child = Padding(
        padding: const EdgeInsets.symmetric(vertical: DcSpace.md),
        child: Text(l10n.checkoutCalculating, style: DcType.ui(14).copyWith(color: c.heroMuted)),
      );
    } else {
      child = Opacity(
        opacity: vm.quoteFresh ? 1 : 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            QuoteBreakdown(quote: q, onHero: true),
            if (!vm.quoteFresh) ...[
              const SizedBox(height: DcSpace.xs),
              Text(l10n.checkoutCalculating, style: DcType.ui(12).copyWith(color: c.heroMuted)),
            ],
          ],
        ),
      );
    }
    return DcTile(
      variant: DcTileVariant.hero,
      radius: DcRadius.hero,
      padding: const EdgeInsets.all(DcSpace.xl),
      child: child,
    );
  }

  Widget _hint(BuildContext context, String text) => Text(text, style: DcType.ui(13).copyWith(color: context.dc.muted));

  Widget _choose(BuildContext context, AppLocalizations l10n) {
    final s = vm.summary;
    final q = vm.quote;
    final c = context.dc;
    final notice = _notice(l10n);
    return ListView(
      padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xxxl),
      children: [
        Text(l10n.checkoutIntro, style: DcType.ui(14).copyWith(color: c.muted)),
        if (vm.plans.length > 1) ...[
          DcSectionHeader(title: l10n.checkoutPlan),
          const SizedBox(height: DcSpace.xs),
          for (final p in vm.plans) ...[
            DcChoice(
              key: Key('checkout.plan.${p.key}'),
              label: p.key == s.planKey
                  ? l10n.checkoutPlanCurrent(p.name, tsh(p.pricePerGuest))
                  : l10n.checkoutPlanOption(p.name, tsh(p.pricePerGuest)),
              selected: vm.planKey == p.key,
              onTap: () => vm.setPlan(p.key),
            ),
            const SizedBox(height: DcSpace.sm),
          ],
        ],
        const SizedBox(height: DcSpace.md),
        DcTile(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: DcField(
                  key: const Key('checkout.cards'),
                  label: l10n.checkoutCards,
                  controller: _cards,
                  keyboardType: TextInputType.number,
                  style: DcType.number(24).copyWith(color: c.ink),
                  onChanged: (v) {
                    final n = int.tryParse(v.trim());
                    if (n != null && n >= vm.minCards) vm.setCards(n);
                  },
                ),
              ),
              const SizedBox(width: DcSpace.md),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: DcCircleButton(
                  key: const Key('checkout.decrease'),
                  icon: HugeIcons.strokeRoundedMinusSign,
                  label: l10n.checkoutDecrease(vm.blockSize),
                  onPressed: vm.canDecrease ? vm.decreaseCards : null,
                ),
              ),
              const SizedBox(width: DcSpace.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: DcCircleButton(
                  key: const Key('checkout.increase'),
                  icon: HugeIcons.strokeRoundedPlusSign,
                  label: l10n.checkoutIncrease(vm.blockSize),
                  filled: true,
                  onPressed: vm.increaseCards,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: DcSpace.sm),
        if (s.paid)
          _hint(context, l10n.checkoutBlockHint(s.guestLimit, vm.blockSize))
        else if (s.guestCount > 0)
          _hint(context, l10n.checkoutSuggestHint(s.guestCount)),
        if (vm.minimumApplied) ...[
          const SizedBox(height: DcSpace.sm),
          DcNoticeTile(
            key: const Key('checkout.minimum'),
            tone: DcTone.neutral,
            message: l10n.checkoutMinimumNote(tsh(q!.minimumCharge), q.guestCards),
          ),
        ] else if (vm.quoteFresh && s.paid && q!.guestCards != vm.cards) ...[
          const SizedBox(height: DcSpace.sm),
          _hint(context, l10n.checkoutEffectiveCards(q.guestCards, q.blockSize)),
        ],
        const SizedBox(height: DcSpace.lg),
        _quoteBlock(context, l10n),
        if (vm.quoteFresh && !q!.payable) ...[
          const SizedBox(height: DcSpace.md),
          DcNoticeTile(tone: DcTone.neutral, message: l10n.checkoutNothingToPay),
        ],
        if (notice != null) ...[
          const SizedBox(height: DcSpace.md),
          DcNoticeTile(tone: DcTone.danger, message: notice),
        ],
        const SizedBox(height: DcSpace.xxl),
        DcButton(
          key: const Key('checkout.continue'),
          label: l10n.checkoutContinue,
          onPressed: vm.canReview ? vm.review : null,
        ),
      ],
    );
  }

  Widget _review(BuildContext context, AppLocalizations l10n) {
    final q = vm.quote;
    final c = context.dc;
    final notice = _notice(l10n);
    final info = vm.rejection == CheckoutRejection.quoteChanged;
    return ListView(
      padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xxxl),
      children: [
        if (q != null) Text(l10n.checkoutReviewIntro(q.planName, q.guestCards), style: DcType.ui(15).copyWith(color: c.ink)),
        const SizedBox(height: DcSpace.md),
        _quoteBlock(context, l10n),
        if (notice != null) ...[
          const SizedBox(height: DcSpace.md),
          DcNoticeTile(key: const Key('checkout.notice'), tone: info ? DcTone.warning : DcTone.danger, message: notice),
        ],
        DcSectionHeader(title: l10n.checkoutMethod),
        const SizedBox(height: DcSpace.xs),
        DcChoice(
          key: const Key('checkout.method.mobile'),
          icon: HugeIcons.strokeRoundedSmartPhone01,
          label: l10n.checkoutMethodMobile,
          description: l10n.checkoutMethodMobileHint,
          selected: vm.method == CheckoutMethod.mobile,
          onTap: () => vm.setMethod(CheckoutMethod.mobile),
        ),
        const SizedBox(height: DcSpace.sm),
        DcChoice(
          key: const Key('checkout.method.session'),
          icon: HugeIcons.strokeRoundedCreditCard,
          label: l10n.checkoutMethodSession,
          description: l10n.checkoutMethodSessionHint,
          selected: vm.method == CheckoutMethod.session,
          onTap: () => vm.setMethod(CheckoutMethod.session),
        ),
        if (vm.method == CheckoutMethod.mobile) ...[
          const SizedBox(height: DcSpace.lg),
          DcField(
            key: const Key('checkout.phone'),
            controller: _phone,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            label: l10n.checkoutPhone,
            hint: l10n.checkoutPhoneHint,
            prefixIcon: HugeIcons.strokeRoundedSmartPhone01,
            errorText: switch (vm.phoneError) {
              PhoneError.required => l10n.checkoutPhoneRequired,
              PhoneError.invalid => l10n.checkoutPhoneInvalid,
              null => null,
            },
          ),
        ],
        const SizedBox(height: DcSpace.lg),
        Row(
          children: [
            HugeIcon(icon: HugeIcons.strokeRoundedSecurityCheck, size: 18, color: c.muted),
            const SizedBox(width: DcSpace.sm),
            Expanded(child: Text(l10n.checkoutSecure, style: DcType.ui(12).copyWith(color: c.muted))),
          ],
        ),
        const SizedBox(height: DcSpace.lg),
        DcButton(
          key: const Key('checkout.pay'),
          label: vm.busy ? l10n.checkoutPaying : l10n.checkoutPay(tsh(q?.total ?? 0)),
          onPressed: vm.busy || !vm.canReview ? null : () => vm.pay(_phone.text),
        ),
        const SizedBox(height: DcSpace.sm),
        DcButton(
          variant: DcButtonVariant.tonal,
          label: l10n.checkoutBack,
          onPressed: vm.busy ? null : vm.backToChoose,
        ),
      ],
    );
  }

  Widget _state({
    required DcTone tone,
    required List<List<dynamic>> icon,
    required String title,
    required String body,
    bool busy = false,
    List<Widget> children = const [],
  }) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xxxl),
      children: [
        DcStatusTile(tone: tone, icon: icon, title: title, message: body, busy: busy, titleSize: 26),
        const SizedBox(height: DcSpace.lg),
        ...children,
      ],
    );
  }

  Widget _waiting(BuildContext context, AppLocalizations l10n) {
    final a = vm.attempt!;
    final mobile = a.method == CheckoutMethod.mobile;
    final c = context.dc;
    final notice = _notice(l10n);
    return _state(
      tone: DcTone.neutral,
      icon: mobile ? HugeIcons.strokeRoundedSmartPhone01 : HugeIcons.strokeRoundedCreditCard,
      title: mobile ? l10n.checkoutWaitingMobileTitle : l10n.checkoutWaitingSessionTitle,
      body: mobile
          ? l10n.checkoutWaitingMobileBody(tsh(a.amount), a.phone != null && isValidPhone(a.phone!) ? formatLocalPhone(a.phone!) : '')
          : l10n.checkoutWaitingSessionBody(tsh(a.amount)),
      children: [
        if (notice != null) ...[DcNoticeTile(tone: DcTone.warning, message: notice), const SizedBox(height: DcSpace.lg)],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2, color: c.primary)),
            const SizedBox(width: DcSpace.sm),
            Text(l10n.checkoutPolling, key: const Key('checkout.polling'), style: DcType.ui(13).copyWith(color: c.muted)),
          ],
        ),
        const SizedBox(height: DcSpace.xxl),
        if (!mobile && a.checkoutUrl != null) ...[
          DcButton(
            icon: HugeIcons.strokeRoundedLinkSquare02,
            label: l10n.checkoutOpenPage,
            onPressed: vm.openPaymentPage,
          ),
          const SizedBox(height: DcSpace.sm),
        ],
        DcButton(
          key: const Key('checkout.later'),
          variant: DcButtonVariant.tonal,
          label: l10n.checkoutLater,
          onPressed: _close,
        ),
      ],
    );
  }

  Widget _success(BuildContext context, AppLocalizations l10n) {
    final a = vm.attempt!;
    return _state(
      tone: DcTone.success,
      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
      title: l10n.checkoutSuccessTitle,
      body: l10n.checkoutSuccessNext(a.guestCards),
      children: [
        DcTile(
          key: const Key('checkout.receipt'),
          child: ReceiptDetails(
            reference: a.reference,
            amount: a.amount,
            guestCards: a.guestCards,
            planName: vm.planName(a.planKey),
            date: a.completedAt ?? a.createdAt,
          ),
        ),
        const SizedBox(height: DcSpace.xxl),
        DcButton(key: const Key('checkout.done'), label: l10n.checkoutDone, onPressed: _close),
      ],
    );
  }

  Widget _failure(BuildContext context, AppLocalizations l10n) {
    final a = vm.attempt!;
    return _state(
      tone: DcTone.danger,
      icon: HugeIcons.strokeRoundedCancelCircle,
      title: a.status == PaymentAttemptStatus.expired ? l10n.checkoutExpiredTitle : l10n.checkoutFailureTitle,
      body: l10n.checkoutFailureBody,
      children: [
        DcButton(
          key: const Key('checkout.retry'),
          icon: HugeIcons.strokeRoundedRefresh,
          label: l10n.retry,
          onPressed: vm.retry,
        ),
        const SizedBox(height: DcSpace.sm),
        DcButton(variant: DcButtonVariant.tonal, label: l10n.checkoutBack, onPressed: _close),
      ],
    );
  }
}

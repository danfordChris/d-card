import 'package:dcard_core/dcard_core.dart';
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
          appBar: AppBar(
            title: Text(vm.step == CheckoutStep.review ? l10n.checkoutReviewTitle : _title(l10n)),
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
    final text = Theme.of(context).textTheme;
    if (vm.quoteState == QuoteState.error) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Notice(text: l10n.checkoutQuoteError, error: true),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: vm.retryQuote, child: Text(l10n.retry)),
        ],
      );
    }
    if (q == null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(l10n.checkoutCalculating, style: text.bodyMedium),
      );
    }
    return Opacity(
      opacity: vm.quoteFresh ? 1 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          QuoteBreakdown(quote: q),
          if (!vm.quoteFresh) ...[
            const SizedBox(height: 4),
            Text(l10n.checkoutCalculating, style: text.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _choose(BuildContext context, AppLocalizations l10n) {
    final s = vm.summary;
    final q = vm.quote;
    final text = Theme.of(context).textTheme;
    final notice = _notice(l10n);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(l10n.checkoutIntro, style: text.bodyMedium),
        const SizedBox(height: 16),
        if (vm.plans.length > 1) ...[
          Text(l10n.checkoutPlan, style: text.labelLarge),
          const SizedBox(height: 4),
          RadioGroup<String>(
            groupValue: vm.planKey,
            onChanged: (key) => key == null ? null : vm.setPlan(key),
            child: Column(
              children: [
                for (final p in vm.plans)
                  RadioListTile<String>(
                    key: Key('checkout.plan.${p.key}'),
                    contentPadding: EdgeInsets.zero,
                    value: p.key,
                    title: Text(
                      p.key == s.planKey
                          ? l10n.checkoutPlanCurrent(p.name, tsh(p.pricePerGuest))
                          : l10n.checkoutPlanOption(p.name, tsh(p.pricePerGuest)),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        Text(l10n.checkoutCards, style: text.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton.outlined(
              key: const Key('checkout.decrease'),
              tooltip: l10n.checkoutDecrease(vm.blockSize),
              onPressed: vm.canDecrease ? vm.decreaseCards : null,
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedMinusSign, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                key: const Key('checkout.cards'),
                controller: _cards,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                style: text.titleLarge?.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
                decoration: const InputDecoration(border: OutlineInputBorder()),
                onChanged: (v) {
                  final n = int.tryParse(v.trim());
                  if (n != null && n >= vm.minCards) vm.setCards(n);
                },
              ),
            ),
            const SizedBox(width: 12),
            IconButton.outlined(
              key: const Key('checkout.increase'),
              tooltip: l10n.checkoutIncrease(vm.blockSize),
              onPressed: vm.increaseCards,
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedPlusSign, size: 20),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (s.paid)
          Text(l10n.checkoutBlockHint(s.guestLimit, vm.blockSize), style: text.bodySmall)
        else if (s.guestCount > 0)
          Text(l10n.checkoutSuggestHint(s.guestCount), style: text.bodySmall),
        if (vm.minimumApplied) ...[
          const SizedBox(height: 8),
          Notice(key: const Key('checkout.minimum'), text: l10n.checkoutMinimumNote(tsh(q!.minimumCharge), q.guestCards)),
        ] else if (vm.quoteFresh && s.paid && q!.guestCards != vm.cards) ...[
          const SizedBox(height: 8),
          Text(l10n.checkoutEffectiveCards(q.guestCards, q.blockSize), style: text.bodySmall),
        ],
        const SizedBox(height: 16),
        FlatCard(child: _quoteBlock(context, l10n)),
        if (vm.quoteFresh && !q!.payable) ...[
          const SizedBox(height: 12),
          Notice(text: l10n.checkoutNothingToPay),
        ],
        if (notice != null) ...[
          const SizedBox(height: 12),
          Notice(text: notice, error: true),
        ],
        const SizedBox(height: 24),
        FilledButton(
          key: const Key('checkout.continue'),
          onPressed: vm.canReview ? vm.review : null,
          child: Text(l10n.checkoutContinue),
        ),
      ],
    );
  }

  Widget _review(BuildContext context, AppLocalizations l10n) {
    final q = vm.quote;
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final notice = _notice(l10n);
    final info = vm.rejection == CheckoutRejection.quoteChanged;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (q != null) Text(l10n.checkoutReviewIntro(q.planName, q.guestCards), style: text.bodyLarge),
        const SizedBox(height: 12),
        FlatCard(child: _quoteBlock(context, l10n)),
        if (notice != null) ...[
          const SizedBox(height: 12),
          Notice(key: const Key('checkout.notice'), text: notice, error: !info),
        ],
        const SizedBox(height: 20),
        Text(l10n.checkoutMethod, style: text.labelLarge),
        const SizedBox(height: 4),
        RadioGroup<CheckoutMethod>(
          groupValue: vm.method,
          onChanged: (m) => m == null ? null : vm.setMethod(m),
          child: Column(
            children: [
              RadioListTile<CheckoutMethod>(
                key: const Key('checkout.method.mobile'),
                contentPadding: EdgeInsets.zero,
                value: CheckoutMethod.mobile,
                title: Text(l10n.checkoutMethodMobile),
                subtitle: Text(l10n.checkoutMethodMobileHint),
              ),
              RadioListTile<CheckoutMethod>(
                key: const Key('checkout.method.session'),
                contentPadding: EdgeInsets.zero,
                value: CheckoutMethod.session,
                title: Text(l10n.checkoutMethodSession),
                subtitle: Text(l10n.checkoutMethodSessionHint),
              ),
            ],
          ),
        ),
        if (vm.method == CheckoutMethod.mobile) ...[
          const SizedBox(height: 8),
          TextField(
            key: const Key('checkout.phone'),
            controller: _phone,
            keyboardType: TextInputType.phone,
            autofillHints: const [AutofillHints.telephoneNumber],
            decoration: InputDecoration(
              labelText: l10n.checkoutPhone,
              hintText: l10n.checkoutPhoneHint,
              border: const OutlineInputBorder(),
              prefixIcon: const Padding(
                padding: EdgeInsets.all(12),
                child: HugeIcon(icon: HugeIcons.strokeRoundedSmartPhone01, size: 20),
              ),
              errorText: switch (vm.phoneError) {
                PhoneError.required => l10n.checkoutPhoneRequired,
                PhoneError.invalid => l10n.checkoutPhoneInvalid,
                null => null,
              },
            ),
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            HugeIcon(icon: HugeIcons.strokeRoundedSecurityCheck, size: 18, color: scheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(l10n.checkoutSecure, style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton(
          key: const Key('checkout.pay'),
          onPressed: vm.busy || !vm.canReview ? null : () => vm.pay(_phone.text),
          child: Text(vm.busy ? l10n.checkoutPaying : l10n.checkoutPay(tsh(q?.total ?? 0))),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: vm.busy ? null : vm.backToChoose, child: Text(l10n.checkoutBack)),
      ],
    );
  }

  Widget _state(
    BuildContext context, {
    required List<List<dynamic>> icon,
    required String title,
    required String body,
    Color? background,
    Color? foreground,
    List<Widget> children = const [],
  }) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),
        Center(child: IconDisc(icon: icon, size: 72, background: background, foreground: foreground)),
        const SizedBox(height: 20),
        Text(title, style: text.titleLarge, textAlign: TextAlign.center),
        const SizedBox(height: 8),
        Text(body, style: text.bodyMedium, textAlign: TextAlign.center),
        const SizedBox(height: 24),
        ...children,
      ],
    );
  }

  Widget _waiting(BuildContext context, AppLocalizations l10n) {
    final a = vm.attempt!;
    final mobile = a.method == CheckoutMethod.mobile;
    final text = Theme.of(context).textTheme;
    final notice = _notice(l10n);
    return _state(
      context,
      icon: mobile ? HugeIcons.strokeRoundedSmartPhone01 : HugeIcons.strokeRoundedCreditCard,
      title: mobile ? l10n.checkoutWaitingMobileTitle : l10n.checkoutWaitingSessionTitle,
      body: mobile
          ? l10n.checkoutWaitingMobileBody(tsh(a.amount), a.phone != null && isValidPhone(a.phone!) ? formatLocalPhone(a.phone!) : '')
          : l10n.checkoutWaitingSessionBody(tsh(a.amount)),
      children: [
        if (notice != null) ...[Notice(text: notice), const SizedBox(height: 16)],
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox.square(dimension: 16, child: CircularProgressIndicator(strokeWidth: 2)),
            const SizedBox(width: 8),
            Text(l10n.checkoutPolling, key: const Key('checkout.polling'), style: text.bodySmall),
          ],
        ),
        const SizedBox(height: 24),
        if (!mobile && a.checkoutUrl != null) ...[
          FilledButton.icon(
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedLinkSquare02, size: 20),
            label: Text(l10n.checkoutOpenPage),
            onPressed: vm.openPaymentPage,
          ),
          const SizedBox(height: 8),
        ],
        OutlinedButton(key: const Key('checkout.later'), onPressed: _close, child: Text(l10n.checkoutLater)),
      ],
    );
  }

  Widget _success(BuildContext context, AppLocalizations l10n) {
    final a = vm.attempt!;
    final scheme = Theme.of(context).colorScheme;
    return _state(
      context,
      icon: HugeIcons.strokeRoundedCheckmarkCircle02,
      title: l10n.checkoutSuccessTitle,
      body: l10n.checkoutSuccessNext(a.guestCards),
      background: scheme.primaryContainer,
      foreground: scheme.onPrimaryContainer,
      children: [
        FlatCard(
          key: const Key('checkout.receipt'),
          child: ReceiptDetails(
            reference: a.reference,
            amount: a.amount,
            guestCards: a.guestCards,
            planName: vm.planName(a.planKey),
            date: a.completedAt ?? a.createdAt,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(key: const Key('checkout.done'), onPressed: _close, child: Text(l10n.checkoutDone)),
      ],
    );
  }

  Widget _failure(BuildContext context, AppLocalizations l10n) {
    final a = vm.attempt!;
    final scheme = Theme.of(context).colorScheme;
    return _state(
      context,
      icon: HugeIcons.strokeRoundedCancelCircle,
      title: a.status == PaymentAttemptStatus.expired ? l10n.checkoutExpiredTitle : l10n.checkoutFailureTitle,
      body: l10n.checkoutFailureBody,
      background: scheme.errorContainer,
      foreground: scheme.onErrorContainer,
      children: [
        FilledButton.icon(
          key: const Key('checkout.retry'),
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedRefresh, size: 20),
          label: Text(l10n.retry),
          onPressed: vm.retry,
        ),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: _close, child: Text(l10n.checkoutBack)),
      ],
    );
  }
}

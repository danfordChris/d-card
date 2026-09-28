import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../domain/models/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/app_scope.dart';
import '../../../core/failure_text.dart';
import '../../../core/money.dart';
import '../view_models/billing_view_model.dart';
import '../view_models/checkout_view_model.dart';
import 'billing_widgets.dart';
import 'checkout_screen.dart';

/// Opens the event's plan and payments; returns whether the event is paid for.
Future<bool?> openBilling(BuildContext context, {required String eventId}) {
  final scope = AppScope.of(context);
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => BillingScreen(viewModel: BillingViewModel(eventId: eventId, repository: scope.billing)..load()),
    ),
  );
}

/// Plan, paid and issued cards, a waiting payment and receipts; entry to checkout (host only).
class BillingScreen extends StatelessWidget {
  const BillingScreen({super.key, required this.viewModel});

  final BillingViewModel viewModel;

  Future<void> _checkout(BuildContext context, CheckoutMode mode) async {
    final summary = viewModel.summary;
    if (summary == null) return;
    final scope = AppScope.of(context);
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CheckoutScreen(
          viewModel: CheckoutViewModel(
            eventId: viewModel.eventId,
            repository: scope.billing,
            links: scope.links,
            summary: summary,
            mode: mode,
          ),
        ),
      ),
    );
    // Also reload after "close and check later": the waiting payment shows here.
    await viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => PopScope<bool>(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) Navigator.of(context).pop(viewModel.summary?.paid);
        },
        child: Scaffold(
          appBar: AppBar(title: Text(l10n.paymentTitle)),
          body: _body(context, l10n),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n) {
    final vm = viewModel;
    final s = vm.summary;
    if (s == null) {
      if (vm.loading) return const Center(child: CircularProgressIndicator());
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.failure(vm.failure ?? AppFailure.unknown), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(onPressed: vm.load, child: Text(l10n.retry)),
            ],
          ),
        ),
      );
    }
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final pending = s.pendingAttempt;
    return RefreshIndicator(
      onRefresh: vm.load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FlatCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const IconDisc(icon: HugeIcons.strokeRoundedTicket01),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.billingPlan(s.planName), style: text.titleMedium),
                          Text(l10n.billingPricePerGuest(tsh(s.pricePerGuest)), style: text.bodySmall),
                        ],
                      ),
                    ),
                    _Badge(paid: s.paid),
                  ],
                ),
                if (s.paid) ...[
                  const SizedBox(height: 12),
                  AmountRow(label: l10n.billingCardsPaid, value: '${s.guestLimit}', valueKey: const Key('billing.cardsPaid')),
                  AmountRow(label: l10n.billingCardsIssued, value: '${s.issuedCards}'),
                  AmountRow(label: l10n.billingGuests, value: '${s.guestCount}'),
                  AmountRow(label: l10n.billingAmountPaid, value: tsh(s.amountPaid)),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (pending != null && pending.isPending) ...[
            FlatCard(
              color: scheme.secondaryContainer,
              child: Row(
                children: [
                  const IconDisc(icon: HugeIcons.strokeRoundedClock01),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.billingPendingTitle, style: text.titleSmall),
                        Text(l10n.billingPendingBody(tsh(pending.amount), formatEat(context, pending.createdAt))),
                      ],
                    ),
                  ),
                  TextButton(
                    key: const Key('billing.resume'),
                    onPressed: () => _checkout(context, CheckoutMode.resume),
                    child: Text(l10n.billingPendingResume),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (!s.paid) ...[
            Text(l10n.billingUnpaidText),
            if (s.launchOfferEligible) ...[
              const SizedBox(height: 8),
              Notice(text: l10n.billingLaunchOffer(s.launchOfferPercent)),
            ],
            const SizedBox(height: 12),
            FilledButton.icon(
              key: const Key('billing.buy'),
              icon: const HugeIcon(icon: HugeIcons.strokeRoundedWallet01, size: 20),
              label: Text(l10n.billingPayForCards),
              onPressed: () => _checkout(context, CheckoutMode.buy),
            ),
          ] else ...[
            if (s.guestCount > s.guestLimit) ...[
              Notice(text: l10n.billingOverLimit(s.guestCount, s.guestLimit)),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('billing.addBlock'),
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedAdd01, size: 20),
                    label: Text(l10n.billingAddBlock(CheckoutViewModel.defaultBlockSize)),
                    onPressed: () => _checkout(context, CheckoutMode.addBlock),
                  ),
                ),
                if (vm.canUpgrade) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('billing.upgrade'),
                      icon: const HugeIcon(icon: HugeIcons.strokeRoundedArrowUp02, size: 20),
                      label: Text(l10n.billingUpgrade),
                      onPressed: () => _checkout(context, CheckoutMode.upgrade),
                    ),
                  ),
                ],
              ],
            ),
          ],
          const SizedBox(height: 24),
          Text(l10n.billingReceiptsTitle, style: text.titleMedium),
          const SizedBox(height: 8),
          if (s.payments.isEmpty)
            Text(l10n.billingReceiptsEmpty, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))
          else
            for (final p in s.payments)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FlatCard(
                  child: ReceiptDetails(
                    reference: p.reference,
                    amount: p.amount,
                    discount: p.discountAmount,
                    guestCards: p.guestCards,
                    planName: vm.planName(p.planKey),
                    date: p.paidAt,
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.paid});

  final bool paid;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = paid
        ? (scheme.primaryContainer, scheme.onPrimaryContainer)
        : (scheme.errorContainer, scheme.onErrorContainer);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(paid ? l10n.billingPaidBadge : l10n.billingUnpaidBadge, style: TextStyle(color: fg, fontSize: 12)),
    );
  }
}

import 'package:dcard_ui/dcard_ui.dart';
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
          appBar: DcTopBar(title: l10n.paymentTitle, backLabel: l10n.back),
          body: _body(context, l10n),
        ),
      ),
    );
  }

  Widget _body(BuildContext context, AppLocalizations l10n) {
    final vm = viewModel;
    final s = vm.summary;
    if (s == null) {
      if (vm.loading) return const DcStateView(kind: DcStateKind.loading);
      return DcStateView(
        kind: DcStateKind.error,
        title: l10n.failure(vm.failure ?? AppFailure.unknown),
        actionLabel: l10n.retry,
        onAction: vm.load,
      );
    }
    final c = context.dc;
    final pending = s.pendingAttempt;
    return RefreshIndicator(
      onRefresh: vm.load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xxxl),
        children: [
          DcTile(
            variant: DcTileVariant.hero,
            radius: DcRadius.hero,
            padding: const EdgeInsets.all(DcSpace.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(l10n.billingPlan(s.planName), style: DcType.heading(26).copyWith(color: c.onHero)),
                    ),
                    DcBadge(
                      label: s.paid ? l10n.billingPaidBadge : l10n.billingUnpaidBadge,
                      tone: s.paid ? DcTone.success : DcTone.warning,
                    ),
                  ],
                ),
                const SizedBox(height: DcSpace.xs),
                Text(
                  l10n.billingPricePerGuest(tsh(s.pricePerGuest)),
                  style: DcType.ui(13).copyWith(color: c.heroMuted),
                ),
              ],
            ),
          ),
          if (s.paid) ...[
            const SizedBox(height: DcSpace.gap),
            DcBento(
              items: [
                DcBentoItem(
                  DcStatTile(
                    key: const Key('billing.cardsPaid'),
                    label: l10n.billingCardsPaid,
                    value: '${s.guestLimit}',
                    progress: s.guestLimit == 0 ? null : s.issuedCards / s.guestLimit,
                    note: '${l10n.billingCardsIssued}: ${s.issuedCards}',
                  ),
                ),
                DcBentoItem(
                  DcStatTile(
                    variant: DcTileVariant.soft,
                    label: l10n.billingGuests,
                    value: '${s.guestCount}',
                  ),
                ),
                DcBentoItem(
                  DcStatTile(label: l10n.billingAmountPaid, value: tsh(s.amountPaid), valueSize: 22),
                  span: 2,
                ),
              ],
            ),
          ],
          const SizedBox(height: DcSpace.gap),
          if (pending != null && pending.isPending) ...[
            DcNoticeTile(
              tone: DcTone.warning,
              icon: HugeIcons.strokeRoundedClock01,
              title: l10n.billingPendingTitle,
              message: l10n.billingPendingBody(tsh(pending.amount), formatEat(context, pending.createdAt)),
              trailing: TextButton(
                key: const Key('billing.resume'),
                onPressed: () => _checkout(context, CheckoutMode.resume),
                child: Text(l10n.billingPendingResume),
              ),
            ),
            const SizedBox(height: DcSpace.gap),
          ],
          if (!s.paid) ...[
            Text(l10n.billingUnpaidText, style: DcType.ui(14).copyWith(color: c.muted)),
            if (s.launchOfferEligible) ...[
              const SizedBox(height: DcSpace.gap),
              DcNoticeTile(
                tone: DcTone.success,
                icon: HugeIcons.strokeRoundedDiscount,
                message: l10n.billingLaunchOffer(s.launchOfferPercent),
              ),
            ],
            const SizedBox(height: DcSpace.lg),
            DcButton(
              key: const Key('billing.buy'),
              icon: HugeIcons.strokeRoundedWallet01,
              label: l10n.billingPayForCards,
              onPressed: () => _checkout(context, CheckoutMode.buy),
            ),
          ] else ...[
            if (s.guestCount > s.guestLimit) ...[
              DcNoticeTile(tone: DcTone.warning, message: l10n.billingOverLimit(s.guestCount, s.guestLimit)),
              const SizedBox(height: DcSpace.gap),
            ],
            DcButton(
              key: const Key('billing.addBlock'),
              icon: HugeIcons.strokeRoundedAdd01,
              label: l10n.billingAddBlock(CheckoutViewModel.defaultBlockSize),
              onPressed: () => _checkout(context, CheckoutMode.addBlock),
            ),
            if (vm.canUpgrade) ...[
              const SizedBox(height: DcSpace.sm),
              DcButton(
                key: const Key('billing.upgrade'),
                variant: DcButtonVariant.tonal,
                icon: HugeIcons.strokeRoundedArrowUp02,
                label: l10n.billingUpgrade,
                onPressed: () => _checkout(context, CheckoutMode.upgrade),
              ),
            ],
          ],
          DcSectionHeader(title: l10n.billingReceiptsTitle),
          if (s.payments.isEmpty)
            Text(l10n.billingReceiptsEmpty, style: DcType.ui(14).copyWith(color: c.muted))
          else
            for (final p in s.payments)
              Padding(
                padding: const EdgeInsets.only(top: DcSpace.sm),
                child: DcTile(
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

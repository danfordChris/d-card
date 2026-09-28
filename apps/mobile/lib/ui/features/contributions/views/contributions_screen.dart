import 'package:dcard_core/dcard_core.dart';
import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../domain/models/contributor.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/app_scope.dart';
import '../../../core/failure_text.dart';
import '../view_models/contributions_view_model.dart';
import '../view_models/record_payment_view_model.dart';
import '../../../core/money.dart';
import 'record_payment_screen.dart';

class ContributionsScreen extends StatefulWidget {
  const ContributionsScreen({super.key, required this.viewModel, required this.canRecord});

  final ContributionsViewModel viewModel;
  final bool canRecord;

  @override
  State<ContributionsScreen> createState() => _ContributionsScreenState();
}

class _ContributionsScreenState extends State<ContributionsScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  Future<void> _open(Contributor c) async {
    final scope = AppScope.of(context);
    final result = await Navigator.of(context).push<Contributor>(
      MaterialPageRoute(
        builder: (_) => RecordPaymentScreen(
          viewModel: RecordPaymentViewModel(
            eventId: widget.viewModel.eventId,
            contributor: c,
            repository: scope.contributions,
          ),
        ),
      ),
    );
    if (result != null) await widget.viewModel.updated(result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: DcTopBar(title: l10n.contributionsTitle, backLabel: l10n.back),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          if (vm.loading && vm.totals == null) return const DcStateView(kind: DcStateKind.loading);
          if (vm.failure != null && vm.totals == null) {
            return DcStateView(
              kind: DcStateKind.error,
              title: l10n.failure(vm.failure!),
              actionLabel: l10n.retry,
              onAction: vm.load,
            );
          }
          final t = vm.totals!;
          final list = vm.visible;
          final c = context.dc;
          final percent = t.pledged == 0 ? 0 : (t.collected * 100 / t.pledged).round();
          return RefreshIndicator(
            onRefresh: vm.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xxxl),
              children: [
                DcBento(
                  items: [
                    DcBentoItem(
                      DcTile(
                        variant: DcTileVariant.hero,
                        radius: DcRadius.hero,
                        padding: const EdgeInsets.all(DcSpace.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.totalCollected, style: DcType.ui(13).copyWith(color: c.heroMuted)),
                            const SizedBox(height: DcSpace.xs),
                            Text(tsh(t.collected), style: DcType.number(32).copyWith(color: c.onHero)),
                            const SizedBox(height: DcSpace.md),
                            DcProgress(
                              value: t.pledged == 0 ? 0 : t.collected / t.pledged,
                              height: 6,
                              color: c.onHero,
                              trackColor: c.heroMuted.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: DcSpace.sm),
                            Text(l10n.contributionsCollectedNote(percent), style: DcType.ui(12).copyWith(color: c.heroMuted)),
                          ],
                        ),
                      ),
                      span: 2,
                    ),
                    DcBentoItem(DcStatTile(label: l10n.totalPledged, value: tsh(t.pledged), valueSize: 20)),
                    DcBentoItem(
                      DcStatTile(
                        variant: DcTileVariant.soft,
                        label: l10n.totalOutstanding,
                        value: tsh(t.outstanding),
                        valueSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DcSpace.lg),
                DcField(
                  key: const Key('contributions.search'),
                  label: l10n.contributionsSearch,
                  prefixIcon: HugeIcons.strokeRoundedSearch01,
                  onChanged: vm.search,
                ),
                const SizedBox(height: DcSpace.md),
                Wrap(
                  spacing: DcSpace.sm,
                  runSpacing: DcSpace.sm,
                  children: [
                    for (final f in ContributorFilter.values)
                      ChoiceChip(
                        showCheckmark: false,
                        label: Text(_filterLabel(l10n, f)),
                        labelStyle: DcType.ui(13, weight: FontWeight.w700)
                            .copyWith(color: vm.filter == f ? c.onPrimary : c.ink),
                        selected: vm.filter == f,
                        onSelected: (_) => vm.setFilter(f),
                      ),
                  ],
                ),
                DcSectionHeader(title: l10n.contributionsListTitle),
                if (list.isEmpty)
                  DcStateView(
                    kind: vm.query.trim().isEmpty && vm.filter == ContributorFilter.all
                        ? DcStateKind.empty
                        : DcStateKind.noResults,
                    message: l10n.contributionsEmpty,
                  )
                else
                  for (var i = 0; i < list.length; i++)
                    DcListRow(
                      divider: i > 0,
                      title: list[i].name,
                      subtitle: '${formatLocalPhone(list[i].phone)} · ${l10n.paidOf(tsh(list[i].paid), tsh(list[i].pledged))}',
                      trailing: _StatusText(contributor: list[i]),
                      onTap: widget.canRecord && !list[i].cancelled ? () => _open(list[i]) : null,
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _filterLabel(AppLocalizations l10n, ContributorFilter f) => switch (f) {
    ContributorFilter.all => l10n.filterAll,
    ContributorFilter.notPaid => l10n.statusNotPaid,
    ContributorFilter.partPaid => l10n.statusPartPaid,
    ContributorFilter.fullyPaid => l10n.statusFullyPaid,
  };
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.contributor});

  final Contributor contributor;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = contributor;
    final label = c.cancelled
        ? l10n.statusCancelled
        : switch (c.status) {
            PledgeStatus.fullyPaid => l10n.statusFullyPaid,
            PledgeStatus.partPaid => l10n.statusPartPaid,
            PledgeStatus.notPaid => l10n.statusNotPaid,
          };
    final tone = c.cancelled
        ? DcTone.neutral
        : switch (c.status) {
            PledgeStatus.fullyPaid => DcTone.success,
            PledgeStatus.partPaid => DcTone.warning,
            PledgeStatus.notPaid => DcTone.danger,
          };
    final muted = DcType.ui(12).copyWith(color: context.dc.muted);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DcBadge(label: label, tone: tone),
        if (c.balance > 0) Text(l10n.balanceShort(tsh(c.balance)), style: muted),
        if (c.cardNumber != null) Text(c.cardNumber!, style: muted),
      ],
    );
  }
}

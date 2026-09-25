import 'package:dcard_core/dcard_core.dart';
import 'package:flutter/material.dart';

import '../../../../domain/models/contributor.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/app_scope.dart';
import '../../../core/failure_text.dart';
import '../view_models/contributions_view_model.dart';
import '../view_models/record_payment_view_model.dart';
import 'money.dart';
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
      appBar: AppBar(title: Text(l10n.contributionsTitle)),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          if (vm.loading && vm.totals == null) return const Center(child: CircularProgressIndicator());
          if (vm.failure != null && vm.totals == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.failure(vm.failure!)),
                  TextButton(onPressed: vm.load, child: Text(l10n.retry)),
                ],
              ),
            );
          }
          final t = vm.totals!;
          final list = vm.visible;
          return RefreshIndicator(
            onRefresh: vm.load,
            child: ListView(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _Total(label: l10n.totalPledged, value: t.pledged),
                      _Total(label: l10n.totalCollected, value: t.collected),
                      _Total(label: l10n.totalOutstanding, value: t.outstanding),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    key: const Key('contributions.search'),
                    onChanged: vm.search,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: l10n.contributionsSearch,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      for (final f in ContributorFilter.values)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(_filterLabel(l10n, f)),
                            selected: vm.filter == f,
                            onSelected: (_) => vm.setFilter(f),
                          ),
                        ),
                    ],
                  ),
                ),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Center(child: Text(l10n.contributionsEmpty)),
                  )
                else
                  for (final c in list)
                    ListTile(
                      title: Text(c.name),
                      subtitle: Text('${formatLocalPhone(c.phone)} · ${l10n.paidOf(tsh(c.paid), tsh(c.pledged))}'),
                      trailing: _StatusText(contributor: c),
                      onTap: widget.canRecord && !c.cancelled ? () => _open(c) : null,
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

class _Total extends StatelessWidget {
  const _Total({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: text.labelSmall),
          FittedBox(child: Text(tsh(value), style: text.titleSmall)),
        ],
      ),
    );
  }
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        if (c.balance > 0) Text(l10n.balanceShort(tsh(c.balance)), style: Theme.of(context).textTheme.bodySmall),
        if (c.cardNumber != null) Text(c.cardNumber!, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

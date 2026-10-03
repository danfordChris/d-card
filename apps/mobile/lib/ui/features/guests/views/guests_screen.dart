import 'package:dcard_api/api.dart';
import 'package:dcard_core/dcard_core.dart';
import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/app_scope.dart';
import '../../../core/failure_text.dart';
import '../view_models/guests_view_model.dart';
import 'guest_detail_screen.dart';
import 'guest_result.dart';

class GuestsScreen extends StatefulWidget {
  const GuestsScreen({super.key, required this.viewModel, required this.canManage});

  final GuestsViewModel viewModel;
  final bool canManage;

  @override
  State<GuestsScreen> createState() => _GuestsScreenState();
}

class _GuestsScreenState extends State<GuestsScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  Future<void> _open(Guest guest) async {
    final scope = AppScope.of(context);
    final result = await Navigator.of(context).push<GuestResult>(
      MaterialPageRoute(
        builder: (_) => GuestDetailScreen(
          eventId: widget.viewModel.eventId,
          guest: guest,
          repository: scope.guests,
          canManage: widget.canManage,
        ),
      ),
    );
    if (result == null || !mounted) return;
    switch (result) {
      case GuestUpdated(:final guest):
        widget.viewModel.replaceGuest(guest);
      case GuestRemoved(:final guestId):
        widget.viewModel.removeGuest(guestId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: DcTopBar(title: l10n.guestsTitle, backLabel: l10n.back),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          if (vm.loading && vm.totalCount == 0) return const DcStateView(kind: DcStateKind.loading);
          if (vm.failure != null && vm.totalCount == 0) {
            return DcStateView(
              kind: DcStateKind.error,
              title: l10n.failure(vm.failure!),
              actionLabel: l10n.retry,
              onAction: vm.load,
            );
          }
          final list = vm.visible;
          final c = context.dc;
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
                            Text(l10n.guestsTotal, style: DcType.ui(13).copyWith(color: c.heroMuted)),
                            const SizedBox(height: DcSpace.xs),
                            Text('${vm.totalCount}', style: DcType.number(32).copyWith(color: c.onHero)),
                          ],
                        ),
                      ),
                      span: 2,
                    ),
                    DcBentoItem(DcStatTile(label: l10n.guestsCardsSent, value: '${vm.issuedCount}')),
                    DcBentoItem(
                      DcStatTile(variant: DcTileVariant.soft, label: l10n.guestsPending, value: '${vm.pendingCount}'),
                    ),
                  ],
                ),
                const SizedBox(height: DcSpace.lg),
                DcField(
                  key: const Key('guests.search'),
                  label: l10n.guestsSearch,
                  prefixIcon: HugeIcons.strokeRoundedSearch01,
                  onChanged: vm.search,
                ),
                const SizedBox(height: DcSpace.md),
                Wrap(
                  spacing: DcSpace.sm,
                  runSpacing: DcSpace.sm,
                  children: [
                    for (final f in GuestFilter.values)
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
                DcSectionHeader(title: l10n.guestsListTitle),
                if (list.isEmpty)
                  DcStateView(
                    kind: vm.query.trim().isEmpty && vm.filter == GuestFilter.all
                        ? DcStateKind.empty
                        : DcStateKind.noResults,
                    message: l10n.guestsEmpty,
                  )
                else
                  for (var i = 0; i < list.length; i++)
                    DcListRow(
                      divider: i > 0,
                      title: list[i].name,
                      subtitle: formatLocalPhone(list[i].phone),
                      trailing: _GuestStatus(guest: list[i]),
                      onTap: () => _open(list[i]),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _filterLabel(AppLocalizations l10n, GuestFilter f) => switch (f) {
    GuestFilter.all => l10n.filterAll,
    GuestFilter.pending => l10n.guestStatusPending,
    GuestFilter.issued => l10n.guestStatusIssued,
    GuestFilter.cancelled => l10n.statusCancelled,
  };
}

class _GuestStatus extends StatelessWidget {
  const _GuestStatus({required this.guest});

  final Guest guest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = switch (guest.status) {
      GuestStatusEnum.pending => l10n.guestStatusPending,
      GuestStatusEnum.issued => l10n.guestStatusIssued,
      GuestStatusEnum.cancelled => l10n.statusCancelled,
      _ => '',
    };
    final tone = switch (guest.status) {
      GuestStatusEnum.pending => DcTone.warning,
      GuestStatusEnum.issued => DcTone.success,
      GuestStatusEnum.cancelled => DcTone.neutral,
      _ => DcTone.neutral,
    };
    final muted = DcType.ui(12).copyWith(color: context.dc.muted);
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        DcBadge(label: label, tone: tone),
        if (guest.cardNumber != null) Text(guest.cardNumber!, style: muted),
      ],
    );
  }
}


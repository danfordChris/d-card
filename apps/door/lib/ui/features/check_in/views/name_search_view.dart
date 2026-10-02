import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../domain/models/check_in.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/door_field.dart';
import '../view_models/check_in_view_model.dart';
import 'result_view.dart';

/// Search by guest name, then pick the right card from the results (one tile per card).
class NameSearchView extends StatefulWidget {
  const NameSearchView({super.key, required this.viewModel, this.footer});

  final CheckInViewModel viewModel;

  /// Shown under the results (e.g. the walk-in tile).
  final Widget? footer;

  @override
  State<NameSearchView> createState() => _NameSearchViewState();
}

class _NameSearchViewState extends State<NameSearchView> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _search() => widget.viewModel.searchName(_query.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final vm = widget.viewModel;
    final matches = vm.nameMatches;
    const gap = SizedBox(height: DcSpace.gap);
    return ListView(
      padding: const EdgeInsets.fromLTRB(DcSpace.page, 0, DcSpace.page, DcSpace.xl),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: DoorField(
                key: const Key('name.query'),
                label: l10n.nameSearchLabel,
                hint: l10n.nameSearchLabel,
                showLabel: false,
                controller: _query,
                large: true,
                prefixIcon: HugeIcons.strokeRoundedSearch01,
                textInputAction: TextInputAction.search,
                textCapitalization: TextCapitalization.words,
                onSubmitted: (_) => _search(),
                errorText: vm.nameTooShort ? l10n.nameTooShort : null,
              ),
            ),
            const SizedBox(width: DcSpace.sm),
            DcButton(
              key: const Key('name.search'),
              label: l10n.find,
              expand: false,
              loading: vm.busy,
              onPressed: _search,
            ),
          ],
        ),
        const SizedBox(height: DcSpace.md),
        if (matches != null && matches.isEmpty)
          DcStateView(kind: DcStateKind.noResults, title: l10n.nameNoMatches)
        else if (matches != null) ...[
          for (final card in matches) ...[_MatchTile(card: card, onTap: () => vm.selectMatch(card)), gap],
          if (vm.nameMatchesOffline) Text(l10n.nameOffline, style: DcType.ui(12).copyWith(color: c.muted)),
        ],
        if (widget.footer != null) ...[const SizedBox(height: DcSpace.md), widget.footer!],
      ],
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.card, required this.onTap});

  final CheckInCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final verdict = verdictOf(card);
    final state = switch (card.refusal) {
      null => l10n.matchCanEnter,
      RefusalReason.fullyUsed => l10n.matchUsed,
      RefusalReason.cancelled => l10n.statusCancelled,
      RefusalReason.notIssued => l10n.statusPending,
      final other => refusalTitle(l10n, other),
    };
    return DcTile(
      key: Key('match.${card.invitationId}'),
      onTap: onTap,
      minHeight: 56,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(cardNames(card), style: DcType.heading(18).copyWith(color: c.ink)),
                const SizedBox(height: 2),
                Text(
                  [
                    cardTypeLabel(l10n, card.cardType),
                    ?card.cardNumber,
                    l10n.entriesLeft(card.entriesLeft, card.totalEntries),
                  ].join(' · '),
                  style: DcType.ui(12).copyWith(color: c.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: DcSpace.md),
          DcBadge(label: state, tone: verdict.tone),
        ],
      ),
    );
  }
}

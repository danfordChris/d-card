import 'package:flutter/material.dart';

import '../../../../domain/models/check_in.dart';
import '../../../../l10n/app_localizations.dart';
import '../view_models/check_in_view_model.dart';
import 'result_view.dart';

/// Search by guest name, then pick the right card from the list.
class NameSearchView extends StatefulWidget {
  const NameSearchView({super.key, required this.viewModel});

  final CheckInViewModel viewModel;

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
    final vm = widget.viewModel;
    final matches = vm.nameMatches;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: TextField(
                  key: const Key('name.query'),
                  controller: _query,
                  textInputAction: TextInputAction.search,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(fontSize: 20),
                  onSubmitted: (_) => _search(),
                  decoration: InputDecoration(
                    labelText: l10n.nameSearchLabel,
                    errorText: vm.nameTooShort ? l10n.nameTooShort : null,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 60,
                child: FilledButton(
                  key: const Key('name.search'),
                  onPressed: vm.busy ? null : _search,
                  child: vm.busy
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(l10n.find),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: matches == null
              ? const SizedBox.shrink()
              : matches.isEmpty
              ? Center(child: Text(l10n.nameNoMatches, style: Theme.of(context).textTheme.titleMedium))
              : ListView.separated(
                  itemCount: matches.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, i) => _MatchTile(card: matches[i], onTap: () => vm.selectMatch(matches[i])),
                ),
        ),
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
    return ListTile(
      key: Key('match.${card.invitationId}'),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(cardNames(card), style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        [
          if (card.cardNumber != null) l10n.cardNumberLabel(card.cardNumber!),
          cardTypeLabel(l10n, card.cardType),
          l10n.entriesLeft(card.entriesLeft, card.totalEntries),
        ].join(' · '),
      ),
      trailing: Icon(verdictOf(card).icon, color: verdictOf(card).color),
      onTap: onTap,
    );
  }
}

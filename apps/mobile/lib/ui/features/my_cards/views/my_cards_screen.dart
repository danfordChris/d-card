import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/guest_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import '../../billing/views/billing_widgets.dart';
import '../../events/views/event_format.dart';
import '../view_models/card_view_model.dart';
import '../view_models/my_cards_view_model.dart';
import 'card_badges.dart';
import 'card_screen.dart';

/// "My cards" (AUTH-4): the signed-in guest's cards, newest first, and "Link a card".
class MyCardsScreen extends StatefulWidget {
  const MyCardsScreen({super.key, required this.viewModel});

  final MyCardsViewModel viewModel;

  @override
  State<MyCardsScreen> createState() => _MyCardsScreenState();
}

class _MyCardsScreenState extends State<MyCardsScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  Future<void> _link() async {
    final vm = widget.viewModel;
    vm.clearLinkError();
    final linked = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => LinkCardSheet(viewModel: vm),
    );
    if (linked == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context).linkCardDone)));
    }
  }

  Future<void> _open(MyCard card) async {
    final vm = widget.viewModel;
    final cardVm = CardViewModel(token: card.linkToken, repository: vm.repository);
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CardScreen(viewModel: cardVm)));
    if (cardVm.changed) await vm.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.myCardsTitle),
        actions: [
          IconButton(
            key: const Key('myCards.link'),
            tooltip: l10n.linkCard,
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedLink01),
            onPressed: _link,
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          if (vm.loading && !vm.loaded) return const Center(child: CircularProgressIndicator());
          if (vm.failure != null && vm.cards.isEmpty) {
            return _Centered(
              children: [
                Text(l10n.failure(vm.failure!), textAlign: TextAlign.center),
                TextButton(onPressed: vm.load, child: Text(l10n.retry)),
              ],
            );
          }
          return RefreshIndicator(
            onRefresh: vm.load,
            child: vm.cards.isEmpty
                ? ListView(children: [_Empty(onLink: _link)])
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: vm.cards.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => _CardTile(card: vm.cards[i], onTap: () => _open(vm.cards[i])),
                  ),
          );
        },
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card, required this.onTap});

  final MyCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant);
    return InkWell(
      key: Key('myCards.card.${card.cardNumber}'),
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: FlatCard(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconDisc(icon: HugeIcons.strokeRoundedTicket01),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(card.eventTitle, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(formatEventDate(context, card.startsAt), style: muted),
                  if (card.venueName != null && card.venueName!.isNotEmpty) Text(card.venueName!, style: muted),
                  const SizedBox(height: 4),
                  Text('${card.guestName} · ${card.cardNumber}', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      CardStatusBadge(status: card.status),
                      if (card.status == CardStatus.issued) RsvpBadge(answer: card.rsvp),
                    ],
                  ),
                ],
              ),
            ),
            const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({required this.onLink});

  final VoidCallback onLink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const IconDisc(icon: HugeIcons.strokeRoundedTicket01, size: 64),
          const SizedBox(height: 16),
          Text(l10n.myCardsEmptyTitle, style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(
            l10n.myCardsEmptyBody,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            key: const Key('myCards.emptyLink'),
            onPressed: onLink,
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedLink01, size: 20),
            label: Text(l10n.linkCard),
          ),
        ],
      ),
    );
  }
}

class _Centered extends StatelessWidget {
  const _Centered({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: children),
    ),
  );
}

/// Paste a card link (or token) to link it to this account.
class LinkCardSheet extends StatefulWidget {
  const LinkCardSheet({super.key, required this.viewModel});

  final MyCardsViewModel viewModel;

  @override
  State<LinkCardSheet> createState() => _LinkCardSheetState();
}

class _LinkCardSheetState extends State<LinkCardSheet> {
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    final text = data?.text?.trim();
    if (text != null && text.isNotEmpty) {
      _input.text = text;
      widget.viewModel.clearLinkError();
    }
  }

  Future<void> _submit() async {
    final ok = await widget.viewModel.link(_input.text);
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          final error = switch (vm.linkRefusal) {
            LinkRefusal.invalidLink => l10n.linkErrorInvalid,
            LinkRefusal.notFound => l10n.linkErrorNotFound,
            LinkRefusal.personLinked => l10n.linkErrorPersonLinked,
            LinkRefusal.accountLinked => l10n.linkErrorAccountLinked,
            null => vm.linkFailure == null ? null : l10n.failure(vm.linkFailure ?? AppFailure.unknown),
          };
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.linkCard, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l10n.linkCardHint),
              const SizedBox(height: 16),
              TextField(
                key: const Key('link.input'),
                controller: _input,
                autofocus: true,
                keyboardType: TextInputType.url,
                autocorrect: false,
                onChanged: (_) => vm.clearLinkError(),
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: l10n.linkCardField,
                  hintText: 'https://…/c/…',
                  suffixIcon: IconButton(
                    tooltip: l10n.linkCardPaste,
                    icon: const HugeIcon(icon: HugeIcons.strokeRoundedClipboard, size: 20),
                    onPressed: _paste,
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Notice(key: const Key('link.error'), text: error, error: true),
              ],
              const SizedBox(height: 16),
              FilledButton(
                key: const Key('link.submit'),
                onPressed: vm.linking ? null : _submit,
                child: vm.linking
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.linkCardSubmit),
              ),
            ],
          );
        },
      ),
    );
  }
}

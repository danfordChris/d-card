import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/guest_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
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
    final header = DcPageHeader(
      title: l10n.myCardsTitle,
      action: DcCircleButton(
        key: const Key('myCards.link'),
        icon: HugeIcons.strokeRoundedLink01,
        label: l10n.linkCard,
        onPressed: _link,
      ),
    );
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final vm = widget.viewModel;
            if (vm.cards.isEmpty && ((vm.loading && !vm.loaded) || vm.failure != null)) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: DcSpotlightNavBar.reservedHeight),
                      child: vm.failure == null
                          ? const DcStateView(kind: DcStateKind.loading)
                          : DcStateView(
                              kind: DcStateKind.error,
                              title: l10n.failure(vm.failure!),
                              actionLabel: l10n.retry,
                              onAction: vm.load,
                            ),
                    ),
                  ),
                ],
              );
            }
            return RefreshIndicator(
              onRefresh: vm.load,
              child: ListView(
                padding: const EdgeInsets.only(bottom: DcSpotlightNavBar.reservedHeight),
                children: [
                  header,
                  if (vm.cards.isEmpty)
                    DcStateView(
                      kind: DcStateKind.empty,
                      icon: HugeIcons.strokeRoundedTicket01,
                      title: l10n.myCardsEmptyTitle,
                      message: l10n.myCardsEmptyBody,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, 0),
                      child: _CardsBento(cards: vm.cards, onOpen: _open),
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.gap, DcSpace.page, 0),
                    child: DcTile(
                      key: const Key('myCards.emptyLink'),
                      onTap: _link,
                      semanticLabel: l10n.linkCard,
                      child: Row(
                        children: [
                          const DcIconDisc(icon: HugeIcons.strokeRoundedLink01),
                          const SizedBox(width: DcSpace.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(l10n.linkCard, style: DcType.ui(15, weight: FontWeight.w700).copyWith(color: context.dc.ink)),
                                Text(l10n.linkCardHint, style: DcType.ui(13).copyWith(color: context.dc.muted)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// The next card as the hero tile, then the others as tonal tiles.
class _CardsBento extends StatelessWidget {
  const _CardsBento({required this.cards, required this.onOpen});

  final List<MyCard> cards;
  final ValueChanged<MyCard> onOpen;

  @override
  Widget build(BuildContext context) {
    final upcoming = cards.where((c) => c.status == CardStatus.issued && daysUntil(c.startsAt) >= 0).toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final next = upcoming.isEmpty ? null : upcoming.first;
    final rest = [for (final c in cards) if (c != next) c];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (next != null) _CardTile(card: next, variant: DcTileVariant.hero, onTap: () => onOpen(next)),
        for (var i = 0; i < rest.length; i++) ...[
          if (next != null || i > 0) const SizedBox(height: DcSpace.gap),
          _CardTile(
            card: rest[i],
            variant: i == 0 ? DcTileVariant.soft : DcTileVariant.tile,
            onTap: () => onOpen(rest[i]),
          ),
        ],
      ],
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({required this.card, required this.variant, required this.onTap});

  final MyCard card;
  final DcTileVariant variant;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final hero = variant == DcTileVariant.hero;
    final (_, fg) = DcTile.colors(c, variant);
    final muted = switch (variant) {
      DcTileVariant.hero => c.heroMuted,
      DcTileVariant.soft => c.onSoft,
      _ => c.muted,
    };
    final (day, month) = eventDayMonth(context, card.startsAt);
    final meta = [
      formatEventDate(context, card.startsAt),
      if (card.venueName != null && card.venueName!.isNotEmpty) card.venueName!,
    ].join(' · ');
    return DcTile(
      key: Key('myCards.card.${card.cardNumber}'),
      variant: variant,
      radius: hero ? DcRadius.hero : DcRadius.tile,
      padding: EdgeInsets.all(hero ? DcSpace.xl : DcSpace.lg),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hero ? l10n.myCardsNextIn(daysUntil(card.startsAt)).toUpperCase() : '$day $month'.toUpperCase(),
            style: DcType.eyebrow().copyWith(color: muted),
          ),
          const SizedBox(height: 6),
          Text(card.eventTitle, style: DcType.heading(hero ? 26 : 20).copyWith(color: fg)),
          const SizedBox(height: DcSpace.xs),
          Text(meta, style: DcType.ui(13).copyWith(color: muted)),
          Text('${card.guestName} · ${card.cardNumber}', style: DcType.ui(13, weight: FontWeight.w600).copyWith(color: fg)),
          const SizedBox(height: DcSpace.md),
          Wrap(
            spacing: DcSpace.sm,
            runSpacing: DcSpace.xs,
            children: [
              CardStatusBadge(status: card.status),
              if (card.status == CardStatus.issued) RsvpBadge(answer: card.rsvp),
            ],
          ),
        ],
      ),
    );
  }
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
          final c = context.dc;
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.linkCard, style: DcType.heading(22).copyWith(color: c.ink)),
              const SizedBox(height: DcSpace.sm),
              Text(l10n.linkCardHint, style: DcType.ui(14).copyWith(color: c.muted)),
              const SizedBox(height: DcSpace.lg),
              DcField(
                key: const Key('link.input'),
                controller: _input,
                autofocus: true,
                keyboardType: TextInputType.url,
                autocorrect: false,
                onChanged: (_) => vm.clearLinkError(),
                onSubmitted: (_) => _submit(),
                label: l10n.linkCardField,
                hint: 'https://…/c/…',
                suffix: Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: DcCircleButton(icon: HugeIcons.strokeRoundedClipboard, label: l10n.linkCardPaste, onPressed: _paste),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: DcSpace.md),
                DcNoticeTile(key: const Key('link.error'), tone: DcTone.danger, message: error),
              ],
              const SizedBox(height: DcSpace.lg),
              DcButton(
                key: const Key('link.submit'),
                label: l10n.linkCardSubmit,
                loading: vm.linking,
                onPressed: _submit,
              ),
            ],
          );
        },
      ),
    );
  }
}

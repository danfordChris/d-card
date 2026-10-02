import 'package:dcard_core/dcard_core.dart';
import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../domain/models/guest_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/app_scope.dart';
import '../../../core/failure_text.dart';
import '../../events/views/event_format.dart';
import '../view_models/card_view_model.dart';
import 'card_badges.dart';

/// One card (AUTH-5): hero with the event, QR for the door, card number, details and RSVP.
class CardScreen extends StatefulWidget {
  const CardScreen({super.key, required this.viewModel});

  final CardViewModel viewModel;

  @override
  State<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends State<CardScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        final card = vm.card;
        return Scaffold(
          appBar: DcTopBar(title: l10n.cardScreenTitle, backLabel: l10n.back),
          body: card == null
              ? (vm.failure != null
                    ? DcStateView(
                        kind: DcStateKind.error,
                        title: l10n.failure(vm.failure!),
                        actionLabel: l10n.retry,
                        onAction: vm.load,
                      )
                    : const DcStateView(kind: DcStateKind.loading))
              : RefreshIndicator(onRefresh: vm.load, child: _Body(viewModel: vm, card: card)),
        );
      },
    );
  }
}

class _Body extends StatelessWidget {
  const _Body({required this.viewModel, required this.card});

  final CardViewModel viewModel;
  final GuestCard card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final lang = Localizations.localeOf(context).languageCode;
    final venue = [card.venueName, card.venueAddress].whereType<String>().where((v) => v.isNotEmpty).join(', ');
    final guest = card.partnerName == null || card.partnerName!.isEmpty
        ? card.guestName
        : '${card.guestName} & ${card.partnerName}';
    final qr = card.status == CardStatus.issued ? card.qrToken : null;
    final hasMap = card.venueMapUrl != null && card.venueMapUrl!.isNotEmpty;
    return ListView(
      padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xxxl),
      children: [
        if (card.eventCancelled) ...[
          DcNoticeTile(key: const Key('card.eventCancelled'), tone: DcTone.danger, message: l10n.cardEventCancelledNotice),
          const SizedBox(height: DcSpace.gap),
        ] else if (card.status == CardStatus.cancelled) ...[
          DcNoticeTile(key: const Key('card.cancelled'), tone: DcTone.danger, message: l10n.cardCancelledNotice),
          const SizedBox(height: DcSpace.gap),
        ],
        DcTile(
          variant: DcTileVariant.hero,
          radius: DcRadius.hero,
          padding: const EdgeInsets.all(DcSpace.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(card.eventType(lang).toUpperCase(), style: DcType.eyebrow().copyWith(color: c.heroMuted)),
              const SizedBox(height: 6),
              Text(card.eventTitle, style: DcType.heading(28).copyWith(color: c.onHero)),
              const SizedBox(height: 6),
              Text(formatEventDate(context, card.startsAt), style: DcType.ui(14).copyWith(color: c.heroMuted)),
            ],
          ),
        ),
        const SizedBox(height: DcSpace.gap),
        if (qr != null) ...[
          DcTile(
            child: Column(
              children: [
                Semantics(
                  label: l10n.cardQrLabel(card.cardNumber),
                  image: true,
                  child: Container(
                    key: const Key('card.qr'),
                    padding: const EdgeInsets.all(DcSpace.md),
                    // Scanners need dark modules on white, in both themes.
                    decoration: BoxDecoration(
                      color: DcColors.light.bg,
                      borderRadius: BorderRadius.circular(DcRadius.input),
                    ),
                    child: QrImageView(
                      data: qr,
                      size: 220,
                      backgroundColor: DcColors.light.bg,
                      eyeStyle: QrEyeStyle(eyeShape: QrEyeShape.square, color: DcColors.light.ink),
                      dataModuleStyle: QrDataModuleStyle(dataModuleShape: QrDataModuleShape.square, color: DcColors.light.ink),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(height: DcSpace.sm),
                Text(l10n.cardShowQr, textAlign: TextAlign.center, style: DcType.ui(13).copyWith(color: c.muted)),
              ],
            ),
          ),
          const SizedBox(height: DcSpace.gap),
        ],
        DcBento(
          items: [
            DcBentoItem(
              DcTile(
                variant: DcTileVariant.soft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.cardNumberLabel, style: DcType.ui(13).copyWith(color: c.onSoft)),
                    const SizedBox(height: DcSpace.xs),
                    Text(card.cardNumber, key: const Key('card.number'), style: DcType.number(26).copyWith(color: c.onSoft)),
                  ],
                ),
              ),
            ),
            DcBentoItem(
              DcTile(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.cardTypeTitle, style: DcType.ui(13).copyWith(color: c.muted)),
                    const SizedBox(height: DcSpace.xs),
                    Text(cardTypeLabel(l10n, isDouble: card.isDouble), style: DcType.heading(20).copyWith(color: c.ink)),
                    const SizedBox(height: DcSpace.sm),
                    CardStatusBadge(status: card.status),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: DcSpace.gap),
        _InfoTile(icon: HugeIcons.strokeRoundedUser, label: l10n.cardGuestLabel, value: guest),
        const SizedBox(height: DcSpace.gap),
        _InfoTile(
          icon: HugeIcons.strokeRoundedLocation01,
          label: l10n.eventVenue,
          value: venue.isEmpty ? l10n.notSet : venue,
          trailing: hasMap
              ? DcCircleButton(
                  icon: HugeIcons.strokeRoundedMaps,
                  label: l10n.openMap,
                  filled: true,
                  onPressed: () {
                    final uri = Uri.tryParse(card.venueMapUrl!);
                    if (uri != null) AppScope.of(context).links.open(uri);
                  },
                )
              : null,
        ),
        const SizedBox(height: DcSpace.gap),
        _InfoTile(
          icon: HugeIcons.strokeRoundedCall,
          label: l10n.eventContact,
          value: '${card.contactName} · ${formatLocalPhone(card.contactPhone)}',
        ),
        if (card.status == CardStatus.issued && !card.eventCancelled) ...[
          const SizedBox(height: DcSpace.gap),
          _Rsvp(viewModel: viewModel, card: card),
        ],
      ],
    );
  }
}

class _Rsvp extends StatelessWidget {
  const _Rsvp({required this.viewModel, required this.card});

  final CardViewModel viewModel;
  final GuestCard card;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final vm = viewModel;
    final answer = card.rsvp.answer;
    Widget choice(RsvpAnswer value, String label, List<List<dynamic>> icon) => DcChoice(
      key: Key('rsvp.${value.name}'),
      label: label,
      icon: icon,
      onTile: true,
      selected: answer == value,
      busy: vm.answering == value,
      onTap: vm.canAnswer ? () => vm.answer(value) : null,
    );

    final error = switch (vm.rsvpRefusal) {
      RsvpRefusal.closed => null, // shown as the closed notice below
      RsvpRefusal.tooMany => l10n.errorTooManyRequests,
      null => vm.rsvpFailure == null ? null : l10n.failure(vm.rsvpFailure!),
    };
    return DcTile(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.rsvpTitle, style: DcType.heading(20).copyWith(color: c.ink))),
              RsvpBadge(answer: answer),
            ],
          ),
          const SizedBox(height: DcSpace.md),
          choice(RsvpAnswer.yes, l10n.rsvpYes, HugeIcons.strokeRoundedCheckmarkCircle02),
          const SizedBox(height: DcSpace.sm),
          choice(RsvpAnswer.no, l10n.rsvpNo, HugeIcons.strokeRoundedCancelCircle),
          if (!card.rsvp.open) ...[
            const SizedBox(height: DcSpace.md),
            DcNoticeTile(key: const Key('rsvp.closed'), tone: DcTone.warning, message: l10n.rsvpClosed),
          ] else if (error != null) ...[
            const SizedBox(height: DcSpace.md),
            DcNoticeTile(key: const Key('rsvp.error'), tone: DcTone.danger, message: error),
          ] else if (vm.changed) ...[
            const SizedBox(height: DcSpace.md),
            DcNoticeTile(key: const Key('rsvp.saved'), tone: DcTone.success, message: l10n.rsvpSaved),
          ],
        ],
      ),
    );
  }
}

/// A detail tile: icon disc, muted label, value and an optional trailing button.
class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value, this.trailing});

  final List<List<dynamic>> icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    return DcTile(
      child: Row(
        children: [
          DcIconDisc(icon: icon, background: c.bg),
          const SizedBox(width: DcSpace.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DcType.ui(13).copyWith(color: c.muted)),
                Text(value, style: DcType.ui(15, weight: FontWeight.w600).copyWith(color: c.ink)),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: DcSpace.md), trailing!],
        ],
      ),
    );
  }
}

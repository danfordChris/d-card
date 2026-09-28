import 'package:dcard_core/dcard_core.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../../domain/models/guest_card.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/app_scope.dart';
import '../../../core/failure_text.dart';
import '../../billing/views/billing_widgets.dart';
import '../../events/views/event_format.dart';
import '../view_models/card_view_model.dart';
import 'card_badges.dart';

/// One card (AUTH-5): QR for the door, card number, event details and RSVP.
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
          appBar: AppBar(title: Text(card?.eventTitle ?? '')),
          body: card == null
              ? (vm.failure != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(l10n.failure(vm.failure!), textAlign: TextAlign.center),
                              TextButton(onPressed: vm.load, child: Text(l10n.retry)),
                            ],
                          ),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()))
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final venue = [card.venueName, card.venueAddress].whereType<String>().where((v) => v.isNotEmpty).join(', ');
    final guest = card.partnerName == null || card.partnerName!.isEmpty
        ? card.guestName
        : '${card.guestName} & ${card.partnerName}';
    final qr = card.status == CardStatus.issued ? card.qrToken : null;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (card.eventCancelled) ...[
          Notice(key: const Key('card.eventCancelled'), text: l10n.cardEventCancelledNotice, error: true),
          const SizedBox(height: 12),
        ] else if (card.status == CardStatus.cancelled) ...[
          Notice(key: const Key('card.cancelled'), text: l10n.cardCancelledNotice, error: true),
          const SizedBox(height: 12),
        ],
        FlatCard(
          child: Column(
            children: [
              if (qr != null) ...[
                Semantics(
                  label: l10n.cardQrLabel(card.cardNumber),
                  image: true,
                  child: Container(
                    key: const Key('card.qr'),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: QrImageView(data: qr, size: 220, backgroundColor: Colors.white, padding: EdgeInsets.zero),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.cardShowQr,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
              ],
              Text(l10n.cardNumberLabel, style: theme.textTheme.labelMedium),
              Text(card.cardNumber, key: const Key('card.number'), style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  CardStatusBadge(status: card.status),
                  Pill(
                    text: cardTypeLabel(l10n, isDouble: card.isDouble),
                    background: scheme.surfaceContainerHighest,
                    foreground: scheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _Row(icon: HugeIcons.strokeRoundedUser, label: l10n.cardGuestLabel, value: guest),
        _Row(icon: HugeIcons.strokeRoundedTicket01, label: l10n.eventType, value: card.eventType(lang)),
        _Row(icon: HugeIcons.strokeRoundedCalendar03, label: l10n.eventDate, value: formatEventDate(context, card.startsAt)),
        _Row(
          icon: HugeIcons.strokeRoundedLocation01,
          label: l10n.eventVenue,
          value: venue.isEmpty ? l10n.notSet : venue,
          trailing: card.venueMapUrl == null || card.venueMapUrl!.isEmpty
              ? null
              : IconButton(
                  tooltip: l10n.openMap,
                  icon: const HugeIcon(icon: HugeIcons.strokeRoundedLinkSquare02, size: 20),
                  onPressed: () {
                    final uri = Uri.tryParse(card.venueMapUrl!);
                    if (uri != null) AppScope.of(context).links.open(uri);
                  },
                ),
        ),
        _Row(
          icon: HugeIcons.strokeRoundedCall,
          label: l10n.eventContact,
          value: '${card.contactName} · ${formatLocalPhone(card.contactPhone)}',
        ),
        if (card.status == CardStatus.issued && !card.eventCancelled) ...[
          const SizedBox(height: 8),
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
    final vm = viewModel;
    final answer = card.rsvp.answer;
    Widget button(RsvpAnswer value, String label, List<List<dynamic>> icon) {
      final selected = answer == value;
      final busy = vm.answering == value;
      final child = busy
          ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
          : Text(label);
      final onPressed = vm.canAnswer ? () => vm.answer(value) : null;
      final key = Key('rsvp.${value.name}');
      return selected
          ? FilledButton.icon(key: key, onPressed: onPressed, icon: HugeIcon(icon: icon, size: 20), label: child)
          : OutlinedButton.icon(key: key, onPressed: onPressed, icon: HugeIcon(icon: icon, size: 20), label: child);
    }

    final error = switch (vm.rsvpRefusal) {
      RsvpRefusal.closed => null, // shown as the closed notice below
      RsvpRefusal.tooMany => l10n.errorTooManyRequests,
      null => vm.rsvpFailure == null ? null : l10n.failure(vm.rsvpFailure!),
    };
    return FlatCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(l10n.rsvpTitle, style: Theme.of(context).textTheme.titleMedium)),
              RsvpBadge(answer: answer),
            ],
          ),
          const SizedBox(height: 12),
          button(RsvpAnswer.yes, l10n.rsvpYes, HugeIcons.strokeRoundedCheckmarkCircle02),
          const SizedBox(height: 8),
          button(RsvpAnswer.no, l10n.rsvpNo, HugeIcons.strokeRoundedCancelCircle),
          if (!card.rsvp.open) ...[
            const SizedBox(height: 12),
            Notice(key: const Key('rsvp.closed'), text: l10n.rsvpClosed),
          ] else if (error != null) ...[
            const SizedBox(height: 12),
            Notice(key: const Key('rsvp.error'), text: error, error: true),
          ] else if (vm.changed) ...[
            const SizedBox(height: 12),
            Notice(key: const Key('rsvp.saved'), text: l10n.rsvpSaved),
          ],
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value, this.trailing});

  final List<List<dynamic>> icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
    leading: HugeIcon(icon: icon, size: 22),
    title: Text(label),
    subtitle: Text(value),
    trailing: trailing,
  );
}

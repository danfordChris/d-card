import 'package:dcard_core/dcard_core.dart';
import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../domain/models/event_summary.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/app_scope.dart';
import '../../billing/views/billing_screen.dart';
import '../../contacts/view_models/contacts_picker_view_model.dart';
import '../../contacts/views/contacts_picker_screen.dart';
import '../../contributions/view_models/contributions_view_model.dart';
import '../../contributions/views/contributions_screen.dart';
import '../../guests/view_models/guests_view_model.dart';
import '../../guests/views/guests_screen.dart';
import '../../messages/view_models/messages_view_model.dart';
import '../../messages/views/messages_screen.dart';
import '../../team/view_models/team_view_model.dart';
import '../../team/views/team_screen.dart';
import '../../walk_ins/views/walk_ins_screen.dart';
import 'event_format.dart';

/// Event: hero (status, title, date), stat tiles (days to go, plan), the pay tile for an unpaid
/// host, 3-column action tiles and the details as plain rows.
class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.event});

  final EventSummary event;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late bool _paid = widget.event.planPaid;

  Future<void> _openBilling() async {
    final paid = await openBilling(context, eventId: widget.event.id);
    if (paid != null && mounted) setState(() => _paid = paid);
  }

  void _openContributions() {
    final scope = AppScope.of(context);
    final event = widget.event;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContributionsScreen(
          viewModel: ContributionsViewModel(eventId: event.id, repository: scope.contributions),
          canRecord: event.canRecordPayments,
        ),
      ),
    );
  }

  void _openGuests() {
    final scope = AppScope.of(context);
    final event = widget.event;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GuestsScreen(
          viewModel: GuestsViewModel(eventId: event.id, repository: scope.guests),
          canManage: event.canManageGuests,
        ),
      ),
    );
  }

  void _openMessages() {
    final scope = AppScope.of(context);
    final event = widget.event;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MessagesScreen(
          viewModel: MessagesViewModel(eventId: event.id, repository: scope.messages),
          isHost: event.isHost,
        ),
      ),
    );
  }

  void _openTeam() {
    final scope = AppScope.of(context);
    final event = widget.event;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TeamScreen(
          viewModel: TeamViewModel(eventId: event.id, repository: scope.team),
        ),
      ),
    );
  }

  void _openContacts() {
    final scope = AppScope.of(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ContactsPickerScreen(
          viewModel: ContactsPickerViewModel(eventId: widget.event.id, contacts: scope.contacts, guests: scope.guests),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final lang = Localizations.localeOf(context).languageCode;
    final venue = [event.venueName, event.venueAddress].whereType<String>().where((v) => v.isNotEmpty).join(', ');
    String contact(String name, String phone) => '$name · ${formatLocalPhone(phone)}';
    final days = daysUntil(event.startsAt);
    final actions = <Widget>[
      if (event.canManageGuests)
        DcActionTile(
          key: const Key('event.guests'),
          icon: HugeIcons.strokeRoundedUserMultiple,
          label: l10n.guestsTitle,
          onTap: _openGuests,
        ),
      if (event.canViewContributions)
        DcActionTile(
          key: const Key('event.contributions'),
          icon: HugeIcons.strokeRoundedCoins01,
          label: l10n.contributionsTitle,
          onTap: _openContributions,
        ),
      if (event.canManageGuests)
        DcActionTile(
          key: const Key('event.contacts'),
          icon: HugeIcons.strokeRoundedUserAdd01,
          label: l10n.contactsTitle,
          onTap: _openContacts,
        ),
      if (event.canViewWalkIns)
        DcActionTile(
          key: const Key('event.walkIns'),
          icon: HugeIcons.strokeRoundedUserCheck01,
          label: l10n.walkInsTitle,
          onTap: () =>
              openWalkIns(context, eventId: event.id, eventTitle: event.title, canDecide: event.canDecideWalkIns),
        ),
      if (event.isHost)
        DcActionTile(
          key: const Key('event.messages'),
          icon: HugeIcons.strokeRoundedMessage01,
          label: l10n.messagesTitle,
          onTap: _openMessages,
        ),
      if (event.isHost)
        DcActionTile(
          key: const Key('event.team'),
          icon: HugeIcons.strokeRoundedUserGroup,
          label: l10n.teamTitle,
          onTap: _openTeam,
        ),
      if (event.isHost && _paid)
        DcActionTile(
          key: const Key('event.payment'),
          icon: HugeIcons.strokeRoundedInvoice03,
          label: l10n.paymentTitle,
          onTap: _openBilling,
        ),
    ];
    return Scaffold(
      appBar: DcTopBar(title: l10n.eventScreenTitle, backLabel: l10n.back),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xxxl),
        children: [
          DcTile(
            variant: DcTileVariant.hero,
            radius: DcRadius.hero,
            padding: const EdgeInsets.all(DcSpace.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EventStatusChip(status: event.status),
                const SizedBox(height: DcSpace.md),
                Text(event.title, style: DcType.heading(28).copyWith(color: c.onHero)),
                const SizedBox(height: 6),
                Text(formatEventDate(context, event.startsAt), style: DcType.ui(14).copyWith(color: c.heroMuted)),
              ],
            ),
          ),
          const SizedBox(height: DcSpace.gap),
          DcBento(
            items: [
              DcBentoItem(
                DcStatTile(
                  label: l10n.eventDate,
                  value: '${days < 0 ? 0 : days}',
                  note: l10n.daysToGo(days < 0 ? 0 : days),
                ),
              ),
              DcBentoItem(
                DcStatTile(
                  variant: DcTileVariant.soft,
                  label: l10n.eventPlan,
                  value: event.planName,
                  valueSize: 24,
                  note: event.isHost ? (_paid ? l10n.billingPaidBadge : l10n.billingUnpaidBadge) : null,
                ),
              ),
            ],
          ),
          if (event.isHost && !_paid) ...[
            const SizedBox(height: DcSpace.gap),
            _PayTile(onPay: _openBilling),
          ],
          if (actions.isNotEmpty) ...[
            DcSectionHeader(title: l10n.eventManage),
            const SizedBox(height: DcSpace.xs),
            DcBento(columns: 3, items: [for (final a in actions) DcBentoItem(a)]),
          ],
          DcSectionHeader(title: l10n.eventDetails),
          _Detail(icon: HugeIcons.strokeRoundedTicket01, label: l10n.eventType, value: event.typeName(lang), first: true),
          _Detail(icon: HugeIcons.strokeRoundedLocation01, label: l10n.eventVenue, value: venue.isEmpty ? l10n.notSet : venue),
          _Detail(
            icon: HugeIcons.strokeRoundedCall,
            label: l10n.eventContact,
            value: [
              contact(event.contactName, event.contactPhone),
              if (event.contact2Name != null && event.contact2Phone != null)
                contact(event.contact2Name!, event.contact2Phone!),
            ].join('\n'),
          ),
        ],
      ),
    );
  }
}

/// Unpaid event: the host must pay before sending cards.
class _PayTile extends StatelessWidget {
  const _PayTile({required this.onPay});

  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    return DcTile(
      key: const Key('event.payBanner'),
      variant: DcTileVariant.soft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DcIconDisc(icon: HugeIcons.strokeRoundedWallet01, background: c.bg),
              const SizedBox(width: DcSpace.md),
              Expanded(child: Text(l10n.billingPayBannerText, style: DcType.ui(14).copyWith(color: c.onSoft))),
            ],
          ),
          const SizedBox(height: DcSpace.md),
          DcButton(key: const Key('event.pay'), label: l10n.billingPayForCards, onPressed: onPay),
        ],
      ),
    );
  }
}

/// A detail as a plain row: icon disc, muted label, value.
class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.label, required this.value, this.first = false});

  final List<List<dynamic>> icon;
  final String label;
  final String value;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    return Container(
      decoration: BoxDecoration(border: first ? null : Border(top: BorderSide(color: c.line))),
      padding: const EdgeInsets.symmetric(vertical: DcSpace.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DcIconDisc(icon: icon, background: c.tile),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DcType.ui(13).copyWith(color: c.muted)),
                const SizedBox(height: 2),
                Text(value, style: DcType.ui(15, weight: FontWeight.w600).copyWith(color: c.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

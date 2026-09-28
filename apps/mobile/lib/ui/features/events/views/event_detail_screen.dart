import 'package:dcard_core/dcard_core.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../domain/models/event_summary.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/app_scope.dart';
import '../../billing/views/billing_screen.dart';
import '../../billing/views/billing_widgets.dart';
import '../../contacts/view_models/contacts_picker_view_model.dart';
import '../../contacts/views/contacts_picker_screen.dart';
import '../../contributions/view_models/contributions_view_model.dart';
import '../../contributions/views/contributions_screen.dart';
import '../../walk_ins/views/walk_ins_screen.dart';
import 'event_format.dart';

/// Read-only event summary: type, date, venue, contact; payment entry for the host.
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

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final venue = [event.venueName, event.venueAddress].whereType<String>().where((v) => v.isNotEmpty).join(', ');
    String contact(String name, String phone) => '$name · ${formatLocalPhone(phone)}';
    return Scaffold(
      appBar: AppBar(title: Text(event.title)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: EventStatusChip(status: event.status),
            ),
          ),
          _Row(icon: Icons.celebration_outlined, label: l10n.eventType, value: event.typeName(lang)),
          _Row(icon: Icons.event_outlined, label: l10n.eventDate, value: formatEventDate(context, event.startsAt)),
          _Row(icon: Icons.place_outlined, label: l10n.eventVenue, value: venue.isEmpty ? l10n.notSet : venue),
          _Row(
            icon: Icons.phone_outlined,
            label: l10n.eventContact,
            value: [
              contact(event.contactName, event.contactPhone),
              if (event.contact2Name != null && event.contact2Phone != null)
                contact(event.contact2Name!, event.contact2Phone!),
            ].join('\n'),
          ),
          if (event.isHost && !_paid)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: _PayBanner(onPay: _openBilling),
            ),
          _Row(icon: Icons.workspace_premium_outlined, label: l10n.eventPlan, value: event.planName),
          if (event.isHost && _paid)
            ListTile(
              key: const Key('event.payment'),
              leading: const HugeIcon(icon: HugeIcons.strokeRoundedInvoice03),
              title: Text(l10n.paymentTitle),
              subtitle: Text(l10n.billingPaidBadge),
              trailing: const HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, size: 20),
              onTap: _openBilling,
            ),
          if (event.canViewContributions)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: OutlinedButton.icon(
                icon: const Icon(Icons.payments_outlined),
                label: Text(l10n.contributionsTitle),
                onPressed: () {
                  final scope = AppScope.of(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ContributionsScreen(
                        viewModel: ContributionsViewModel(eventId: event.id, repository: scope.contributions),
                        canRecord: event.canRecordPayments,
                      ),
                    ),
                  );
                },
              ),
            ),
          if (event.canManageGuests)
            Padding(
              padding: const EdgeInsets.all(16),
              child: FilledButton.icon(
                icon: const Icon(Icons.contacts_outlined),
                label: Text(l10n.contactsTitle),
                onPressed: () {
                  final scope = AppScope.of(context);
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ContactsPickerScreen(
                        viewModel: ContactsPickerViewModel(
                          eventId: event.id,
                          contacts: scope.contacts,
                          guests: scope.guests,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          if (event.canViewWalkIns)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: OutlinedButton.icon(
                key: const Key('event.walkIns'),
                icon: const Icon(Icons.how_to_reg_outlined),
                label: Text(l10n.walkInsTitle),
                onPressed: () =>
                    openWalkIns(context, eventId: event.id, eventTitle: event.title, canDecide: event.canDecideWalkIns),
              ),
            ),
        ],
      ),
    );
  }
}

/// Unpaid event: the host must pay before sending cards.
class _PayBanner extends StatelessWidget {
  const _PayBanner({required this.onPay});

  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return FlatCard(
      key: const Key('event.payBanner'),
      color: scheme.primaryContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconDisc(icon: HugeIcons.strokeRoundedWallet01, background: scheme.surface, foreground: scheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(l10n.billingPayBannerText, style: TextStyle(color: scheme.onPrimaryContainer)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(key: const Key('event.pay'), onPressed: onPay, child: Text(l10n.billingPayForCards)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => ListTile(leading: Icon(icon), title: Text(label), subtitle: Text(value));
}

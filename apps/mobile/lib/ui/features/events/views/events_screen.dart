import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/event_summary.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import '../view_models/events_view_model.dart';
import 'event_detail_screen.dart';
import 'event_format.dart';

/// Home dashboard: a bento of the next event (days to go), counts and "New event", then the
/// events as plain rows with date blocks.
class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, required this.viewModel, this.onNewEvent});

  final EventsViewModel viewModel;

  /// Opens the New event tab.
  final VoidCallback? onNewEvent;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  void _open(EventSummary event) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EventDetailScreen(event: event)));

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final header = DcPageHeader(greeting: l10n.dashboardHello, title: l10n.eventsTitle);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final vm = widget.viewModel;
            if (vm.events.isEmpty && (vm.loading || vm.failure != null)) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  header,
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: DcSpotlightNavBar.reservedHeight),
                      child: vm.loading
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
                  if (vm.events.isEmpty)
                    DcStateView(
                      kind: DcStateKind.empty,
                      icon: HugeIcons.strokeRoundedCalendar03,
                      message: l10n.eventsEmpty,
                      actionLabel: widget.onNewEvent == null ? null : l10n.newEventTitle,
                      onAction: widget.onNewEvent,
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: DcSpace.page),
                      child: _Dashboard(events: vm.events, onOpen: _open, onNewEvent: widget.onNewEvent),
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

class _Dashboard extends StatelessWidget {
  const _Dashboard({required this.events, required this.onOpen, this.onNewEvent});

  final List<EventSummary> events;
  final ValueChanged<EventSummary> onOpen;
  final VoidCallback? onNewEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final upcoming =
        events.where((e) => e.status != EventStatus.cancelled && daysUntil(e.startsAt) >= 0).toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    final next = upcoming.isEmpty ? null : upcoming.first;
    final hosted = events.where((e) => e.isHost).length;
    final paid = events.where((e) => e.isHost && e.planPaid).length;
    final lang = Localizations.localeOf(context).languageCode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: DcSpace.sm),
        DcBento(
          items: [
            if (next != null) DcBentoItem(_NextEventTile(event: next, onTap: () => onOpen(next)), span: 2),
            DcBentoItem(
              DcStatTile(
                key: const Key('dashboard.upcoming'),
                label: l10n.statUpcoming,
                value: '${upcoming.length}',
                note: l10n.statUpcomingNote(events.length),
              ),
            ),
            DcBentoItem(
              DcStatTile(
                variant: DcTileVariant.soft,
                label: l10n.statHosting,
                value: '$hosted',
                note: l10n.statHostingNote(events.length - hosted),
              ),
            ),
            DcBentoItem(
              DcStatTile(
                label: l10n.statPaid,
                value: '$paid',
                note: l10n.statPaidNote(hosted),
                progress: hosted == 0 ? null : paid / hosted,
              ),
            ),
            if (onNewEvent != null)
              DcBentoItem(
                DcTile(
                  key: const Key('dashboard.newEvent'),
                  variant: DcTileVariant.tile2,
                  onTap: onNewEvent,
                  semanticLabel: l10n.newEventTitle,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DcIconDisc(icon: HugeIcons.strokeRoundedAdd01, background: c.primary, foreground: c.onPrimary),
                      const SizedBox(height: DcSpace.md),
                      Text(l10n.newEventTitle, style: DcType.heading(20).copyWith(color: c.ink)),
                    ],
                  ),
                ),
              ),
          ],
        ),
        DcSectionHeader(title: l10n.dashboardYourEvents),
        for (var i = 0; i < events.length; i++)
          Builder(
            builder: (context) {
              final e = events[i];
              final (day, month) = eventDayMonth(context, e.startsAt);
              return DcListRow(
                key: Key('events.row.${e.id}'),
                divider: i > 0,
                leading: DcDateBlock(day: day, month: month),
                title: e.title,
                subtitle: '${e.typeName(lang)} · ${e.planName}',
                trailing: EventStatusChip(status: e.status),
                onTap: () => onOpen(e),
              );
            },
          ),
      ],
    );
  }
}

/// Hero tile: the next event and the days left.
class _NextEventTile extends StatelessWidget {
  const _NextEventTile({required this.event, required this.onTap});

  final EventSummary event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final days = daysUntil(event.startsAt);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final meta = [
      DateFormat.MMMEd(locale).format(eatTime(event.startsAt)),
      if (event.venueName != null && event.venueName!.isNotEmpty) event.venueName!,
    ].join(' · ');
    return DcTile(
      key: const Key('dashboard.next'),
      variant: DcTileVariant.hero,
      radius: DcRadius.hero,
      padding: const EdgeInsets.all(DcSpace.xl),
      minHeight: 150,
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(l10n.dashboardNextEvent.toUpperCase(), style: DcType.eyebrow().copyWith(color: c.heroMuted)),
                const SizedBox(height: 6),
                Text(event.title, style: DcType.heading(26).copyWith(color: c.onHero)),
                const SizedBox(height: 6),
                Text(meta, style: DcType.ui(13).copyWith(color: c.heroMuted)),
              ],
            ),
          ),
          const SizedBox(width: DcSpace.md),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('$days', style: DcType.number(48).copyWith(color: c.onHero)),
              Text(l10n.daysToGo(days), style: DcType.ui(12).copyWith(color: c.heroMuted)),
            ],
          ),
        ],
      ),
    );
  }
}

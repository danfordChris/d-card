import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/door_event.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/door_format.dart';
import '../../../core/failure_text.dart';
import '../../../core/message_card.dart';
import '../view_models/event_select_view_model.dart';

/// Pick the event to check guests in for; registering the phone for it (AUTH-9).
/// Today's event is the hero tile; other events are plain tiles.
class EventSelectScreen extends StatefulWidget {
  const EventSelectScreen({
    super.key,
    required this.viewModel,
    required this.onOpened,
    required this.onSignOut,
    this.onRefused,
    this.clock,
  });

  final EventSelectViewModel viewModel;
  final ValueChanged<DoorSession> onOpened;
  final VoidCallback onSignOut;

  /// The server refused this phone for the event (403: revoked, or no door access).
  final ValueChanged<DoorEvent>? onRefused;

  /// Time source for picking today's event (tests).
  final DateTime Function()? clock;

  @override
  State<EventSelectScreen> createState() => _EventSelectScreenState();
}

class _EventSelectScreenState extends State<EventSelectScreen> {
  late final _deviceName = TextEditingController(text: widget.viewModel.deviceName);

  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    _deviceName.dispose();
    super.dispose();
  }

  Future<void> _open(DoorEvent event) async {
    await widget.viewModel.setDeviceName(_deviceName.text);
    final session = await widget.viewModel.open(event);
    if (!mounted) return;
    if (session != null) {
      widget.onOpened(session);
    } else if (widget.viewModel.notice == AppFailure.doorAccessDenied && widget.onRefused != null) {
      widget.onRefused!(event);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    return Scaffold(
      body: SafeArea(
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final vm = widget.viewModel;
            final now = (widget.clock ?? DateTime.now)();
            final today = vm.events.where((e) => e.timingAt(now) == EventTiming.open).firstOrNull;
            const gap = SizedBox(height: DcSpace.md);
            return RefreshIndicator(
              onRefresh: vm.load,
              color: c.primary,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.xxl, DcSpace.page, DcSpace.xxl),
                children: [
                  Semantics(
                    header: true,
                    child: Text(l10n.eventsTitle, style: DcType.heading(30).copyWith(color: c.ink)),
                  ),
                  gap,
                  DcField(
                    key: const Key('events.deviceName'),
                    label: l10n.deviceNameLabel,
                    hint: l10n.deviceNameHint,
                    controller: _deviceName,
                    prefixIcon: HugeIcons.strokeRoundedDoor01,
                    inputFormatters: [LengthLimitingTextInputFormatter(60)],
                  ),
                  if (vm.notice != null) ...[gap, MessageCard(text: l10n.failure(vm.notice!))],
                  if (vm.offlineSession case final cached?) ...[
                    gap,
                    DcTile(
                      key: const Key('events.offline'),
                      variant: DcTileVariant.soft,
                      onTap: () => widget.onOpened(cached),
                      child: Row(
                        children: [
                          HugeIcon(icon: HugeIcons.strokeRoundedCloudOff, color: c.onSoft, size: 24),
                          const SizedBox(width: DcSpace.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.continueOffline(cached.event.title),
                                  style: DcType.heading(18).copyWith(color: c.onSoft),
                                ),
                                const SizedBox(height: DcSpace.xs),
                                Text(l10n.continueOfflineBody, style: DcType.ui(13).copyWith(color: c.onSoft)),
                              ],
                            ),
                          ),
                          HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: c.onSoft, size: 20),
                        ],
                      ),
                    ),
                  ],
                  gap,
                  if (vm.loading && vm.events.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(DcSpace.xxxl),
                      child: DcStateView(kind: DcStateKind.loading),
                    )
                  else if (vm.failure == AppFailure.network && vm.offlineSession == null && vm.events.isEmpty)
                    DcTile(
                      key: const Key('events.noNetwork'),
                      padding: const EdgeInsets.all(DcSpace.xl),
                      child: Column(
                        children: [
                          HugeIcon(icon: HugeIcons.strokeRoundedWifiDisconnected02, size: 44, color: c.muted),
                          const SizedBox(height: DcSpace.md),
                          Text(
                            l10n.eventsOfflineTitle,
                            textAlign: TextAlign.center,
                            style: DcType.heading(22).copyWith(color: c.ink),
                          ),
                          const SizedBox(height: DcSpace.sm),
                          Text(
                            l10n.eventsOfflineBody,
                            textAlign: TextAlign.center,
                            style: DcType.ui(14).copyWith(color: c.muted),
                          ),
                          const SizedBox(height: DcSpace.lg),
                          DcButton(key: const Key('events.retry'), label: l10n.retry, onPressed: vm.load),
                        ],
                      ),
                    )
                  else if (vm.failure != null)
                    MessageCard(
                      text: l10n.failure(vm.failure!),
                      action: TextButton(onPressed: vm.load, child: Text(l10n.retry)),
                    )
                  else if (vm.events.isEmpty)
                    DcStateView(kind: DcStateKind.empty, message: l10n.eventsEmpty)
                  else ...[
                    for (final event in [?today, ...vm.events.where((e) => e != today)]) ...[
                      _EventTile(
                        event: event,
                        hero: event == today,
                        opening: vm.openingEventId == event.id,
                        onTap: vm.openingEventId == null ? () => _open(event) : null,
                      ),
                      gap,
                    ],
                  ],
                  if (vm.events.isNotEmpty || vm.failure != null) ...[
                    if (vm.failure != null) gap,
                    DcNoticeTile(
                      tone: DcTone.warning,
                      icon: HugeIcons.strokeRoundedWifi01,
                      message: l10n.eventsWifiTip,
                    ),
                  ],
                  const SizedBox(height: DcSpace.xxl),
                  DcButton(
                    key: const Key('events.signOut'),
                    label: l10n.signOut,
                    icon: HugeIcons.strokeRoundedLogout03,
                    variant: DcButtonVariant.tonal,
                    onPressed: widget.onSignOut,
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

/// One event: the hero tile for today's event, a plain tile for the others.
class _EventTile extends StatelessWidget {
  const _EventTile({required this.event, required this.hero, required this.opening, required this.onTap});

  final DoorEvent event;
  final bool hero;
  final bool opening;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final fg = hero ? c.onHero : c.ink;
    final muted = hero ? c.heroMuted : c.muted;
    final role = switch (event.role) {
      DoorRole.host => l10n.roleHost,
      DoorRole.committee => l10n.roleCommittee,
      DoorRole.doorStaff => l10n.roleDoorStaff,
    };
    return DcTile(
      key: Key('events.${event.id}'),
      variant: hero ? DcTileVariant.hero : DcTileVariant.tile,
      padding: EdgeInsets.all(hero ? DcSpace.xl : DcSpace.lg),
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hero) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: DcSpace.xs),
                    decoration: BoxDecoration(
                      color: c.onHero.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(DcRadius.pill),
                    ),
                    child: Text(
                      l10n.eventsToday(formatTime(context, event.startsAt)),
                      style: DcType.ui(12, weight: FontWeight.w700).copyWith(color: fg),
                    ),
                  ),
                  const SizedBox(height: DcSpace.sm),
                ],
                Text(event.title, style: DcType.heading(hero ? 26 : 19).copyWith(color: fg)),
                const SizedBox(height: DcSpace.xs),
                Text(
                  [if (!hero) formatEventDate(context, event.startsAt), ?event.venueName, role].join(' · '),
                  style: DcType.ui(13).copyWith(color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: DcSpace.md),
          if (opening)
            SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
          else
            HugeIcon(icon: HugeIcons.strokeRoundedArrowRight01, color: fg, size: 22),
        ],
      ),
    );
  }
}

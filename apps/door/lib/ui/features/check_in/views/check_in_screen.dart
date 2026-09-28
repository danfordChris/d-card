import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../domain/models/check_in.dart';
import '../../../../domain/models/door_event.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/door_format.dart';
import '../../../core/door_state_view.dart';
import '../../../core/failure_text.dart';
import '../../../core/message_card.dart';
import '../view_models/check_in_view_model.dart';
import 'card_number_pad.dart';
import 'name_search_view.dart';
import 'qr_scanner_view.dart';
import 'result_view.dart';

/// The door: find a card by QR, card number or name, then show the verdict (CHK-1…CHK-5).
class CheckInScreen extends StatelessWidget {
  const CheckInScreen({
    super.key,
    required this.viewModel,
    required this.onChangeEvent,
    this.scanner = cameraScanner,
    this.onWalkIn,
  });

  final CheckInViewModel viewModel;
  final VoidCallback onChangeEvent;
  final ScannerBuilder scanner;

  /// Opens a walk-in request (CHK-8), linked to a card when started from a result.
  final ValueChanged<CheckInCard?>? onWalkIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final vm = viewModel;
        return Scaffold(
          appBar: AppBar(
            title: Text(vm.session.event.title, overflow: TextOverflow.ellipsis),
            actions: [
              if (onWalkIn != null)
                IconButton(
                  key: const Key('checkIn.walkIn'),
                  tooltip: l10n.walkInAction,
                  icon: const Icon(Icons.person_add_alt),
                  onPressed: () => onWalkIn!(null),
                ),
              IconButton(
                key: const Key('checkIn.changeEvent'),
                tooltip: l10n.changeEvent,
                icon: const Icon(Icons.swap_horiz),
                onPressed: onChangeEvent,
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (vm.hasSync) SyncStatusBar(viewModel: vm),
              if (vm.clockSkewed) ClockSkewBanner(skew: vm.clockSkew!),
              Expanded(
                child: vm.result != null
                    ? ResultView(viewModel: vm, onWalkIn: onWalkIn)
                    : _blockingState(context, l10n, vm) ??
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (vm.isLocked) _LockBanner(remaining: vm.lockRemaining),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                                child: SegmentedButton<CheckInMode>(
                                  showSelectedIcon: false,
                                  segments: [
                                    ButtonSegment(
                                      value: CheckInMode.scan,
                                      icon: const Icon(Icons.qr_code_scanner),
                                      label: Text(l10n.modeScan, key: const Key('mode.scan')),
                                    ),
                                    ButtonSegment(
                                      value: CheckInMode.number,
                                      icon: const Icon(Icons.dialpad),
                                      label: Text(l10n.modeNumber, key: const Key('mode.number')),
                                    ),
                                    ButtonSegment(
                                      value: CheckInMode.name,
                                      icon: const Icon(Icons.search),
                                      label: Text(l10n.modeName, key: const Key('mode.name')),
                                    ),
                                  ],
                                  selected: {vm.mode},
                                  onSelectionChanged: (s) => vm.setMode(s.first),
                                ),
                              ),
                              if (vm.failure != null)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                                  child: MessageCard(text: l10n.failure(vm.failure!)),
                                ),
                              Expanded(
                                child: switch (vm.mode) {
                                  CheckInMode.scan => Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: Stack(
                                        fit: StackFit.expand,
                                        children: [
                                          scanner(context, vm.scanned),
                                          if (vm.busy)
                                            const ColoredBox(
                                              color: Color(0x88000000),
                                              child: Center(child: CircularProgressIndicator()),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  CheckInMode.number => SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        if (vm.isLocked)
                                          _LockedPadNotice(
                                            onScan: () => vm.setMode(CheckInMode.scan),
                                            onName: () => vm.setMode(CheckInMode.name),
                                          ),
                                        CardNumberPad(
                                          enabled: !vm.isLocked,
                                          busy: vm.busy,
                                          onSubmit: vm.lookupCardNumber,
                                        ),
                                      ],
                                    ),
                                  ),
                                  CheckInMode.name => NameSearchView(viewModel: vm),
                                },
                              ),
                            ],
                          ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// A state that replaces scanning: event over and wiped, no network without a saved guest
  /// list, or the event not started / ended (staff may continue).
  Widget? _blockingState(BuildContext context, AppLocalizations l10n, CheckInViewModel vm) {
    final changeEvent = OutlinedButton(
      key: const Key('state.changeEvent'),
      onPressed: onChangeEvent,
      child: Text(l10n.chooseAnotherEvent),
    );
    final event = vm.session.event;
    if (vm.cacheExpired) {
      return DoorStateView(
        key: const Key('checkIn.expired'),
        icon: HugeIcons.strokeRoundedCalendarRemove02,
        tone: DoorStateTone.neutral,
        title: l10n.cacheExpiredTitle,
        body: l10n.cacheExpiredBody,
        actions: [changeEvent],
      );
    }
    if (vm.offlineWithoutCache) {
      return DoorStateView(
        key: const Key('checkIn.noNetwork'),
        icon: HugeIcons.strokeRoundedWifiDisconnected02,
        title: l10n.noNetworkNoCacheTitle,
        body: l10n.noNetworkNoCacheBody,
        busy: vm.syncing,
        actions: [
          FilledButton(key: const Key('state.retry'), onPressed: vm.syncNow, child: Text(l10n.retry)),
          changeEvent,
        ],
      );
    }
    if (vm.showTimingNotice) {
      final upcoming = vm.timing == EventTiming.upcoming;
      return DoorStateView(
        key: Key(upcoming ? 'checkIn.notStarted' : 'checkIn.ended'),
        icon: upcoming ? HugeIcons.strokeRoundedCalendarClock : HugeIcons.strokeRoundedCalendarCheckOut01,
        tone: DoorStateTone.warning,
        title: upcoming ? l10n.eventNotStartedTitle : l10n.eventEndedTitle,
        body: upcoming
            ? l10n.eventNotStartedBody(event.title, formatEventDate(context, event.startsAt))
            : l10n.eventEndedBody(event.title, formatEventDate(context, event.effectiveEndsAt)),
        actions: [
          FilledButton(
            key: const Key('state.continue'),
            onPressed: vm.acknowledgeTiming,
            child: Text(l10n.checkInAnyway),
          ),
          changeEvent,
        ],
      );
    }
    return null;
  }
}

/// The phone's clock is off: offline entry times and the lockout would be wrong.
class ClockSkewBanner extends StatelessWidget {
  const ClockSkewBanner({super.key, required this.skew});

  /// Server time minus phone time.
  final Duration skew;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('checkIn.clockSkew'),
      color: scheme.tertiaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          HugeIcon(icon: HugeIcons.strokeRoundedClockAlert, color: scheme.onTertiaryContainer, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.clockSkewWarning(skew.inMinutes.abs()),
              style: TextStyle(color: scheme.onTertiaryContainer, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

/// In card-number mode while locked: what to do instead (CHK-5).
class _LockedPadNotice extends StatelessWidget {
  const _LockedPadNotice({required this.onScan, required this.onName});

  final VoidCallback onScan;
  final VoidCallback onName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Padding(
      key: const Key('checkIn.lockedPad'),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Text(l10n.lockedPadTitle, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(l10n.lockedPadBody, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              OutlinedButton(key: const Key('lockedPad.scan'), onPressed: onScan, child: Text(l10n.modeScan)),
              OutlinedButton(key: const Key('lockedPad.name'), onPressed: onName, child: Text(l10n.modeName)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LockBanner extends StatelessWidget {
  const _LockBanner({required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      key: const Key('checkIn.lockBanner'),
      color: Verdict.warning.color,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const HugeIcon(icon: HugeIcons.strokeRoundedSquareLock02, color: Colors.white, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.lockedTitle,
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800),
                ),
                Text(
                  l10n.lockedBody(formatCountdown(remaining)),
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          Text(
            formatCountdown(remaining),
            key: const Key('checkIn.lockCountdown'),
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

/// Online/offline, entries waiting to upload and the last sync time (offline-sync 9.4).
class SyncStatusBar extends StatelessWidget {
  const SyncStatusBar({super.key, required this.viewModel});

  final CheckInViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    final scheme = Theme.of(context).colorScheme;
    final offline = vm.isOffline;
    final background = offline ? Verdict.warning.color : scheme.surfaceContainerHighest;
    final foreground = offline ? Colors.white : scheme.onSurfaceVariant;
    final last = vm.lastSyncAt;
    final style = TextStyle(color: foreground, fontSize: 14);
    return Material(
      color: background,
      child: InkWell(
        key: const Key('checkIn.syncStatus'),
        onTap: vm.syncing ? null : vm.syncNow,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(offline ? Icons.cloud_off : Icons.cloud_done_outlined, color: foreground, size: 20),
              const SizedBox(width: 6),
              Text(
                offline ? l10n.offlineBadge : l10n.onlineBadge,
                key: Key(offline ? 'checkIn.offline' : 'checkIn.online'),
                style: style.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  [
                    l10n.syncWaiting(vm.pendingCount),
                    last == null ? l10n.neverSynced : l10n.lastSync(formatEntryTime(context, last)),
                    if (offline && !vm.offlineReady) l10n.offlineUnavailable,
                  ].join(' · '),
                  key: const Key('checkIn.syncText'),
                  style: style,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (vm.syncing)
                SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: foreground))
              else
                Icon(Icons.sync, color: foreground, size: 20, semanticLabel: l10n.syncNow),
            ],
          ),
        ),
      ),
    );
  }
}

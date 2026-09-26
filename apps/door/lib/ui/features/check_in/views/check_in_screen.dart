import 'package:flutter/material.dart';

import '../../../../domain/models/check_in.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/door_format.dart';
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
              Expanded(
                child: vm.result != null
                    ? ResultView(viewModel: vm, onWalkIn: onWalkIn)
                    : Column(
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
                                child: CardNumberPad(
                                  enabled: !vm.isLocked,
                                  busy: vm.busy,
                                  onSubmit: vm.lookupCardNumber,
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
          const Icon(Icons.lock_clock, color: Colors.white, size: 40),
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

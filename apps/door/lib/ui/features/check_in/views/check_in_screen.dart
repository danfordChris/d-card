import 'package:dcard_ui/dcard_ui.dart';
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
import 'sync_panel.dart';

/// The door: find a card by QR, card number or name, then show the verdict (CHK-1…CHK-5).
///
/// No bottom navigation: a header with the event, gate and sync chip, then a segmented
/// Scan / Number / Name control. The sync chip opens the sync panel and tries a sync.
class CheckInScreen extends StatefulWidget {
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
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  bool _showSync = false;

  void _openSync() {
    setState(() => _showSync = true);
    if (!widget.viewModel.syncing) widget.viewModel.syncNow();
  }

  void _closeSync() => setState(() => _showSync = false);

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Scaffold(
          body: SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CheckInHeader(viewModel: vm, onSync: _openSync, onChangeEvent: widget.onChangeEvent),
                if (vm.clockSkewed)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(DcSpace.page, 0, DcSpace.page, DcSpace.md),
                    child: ClockSkewBanner(skew: vm.clockSkew!),
                  ),
                Expanded(
                  child: vm.result != null
                      ? ResultView(viewModel: vm, onWalkIn: widget.onWalkIn)
                      : _showSync
                      ? SyncPanel(viewModel: vm, onClose: _closeSync)
                      : _blockingState(context, vm) ?? _modes(context, vm),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _modes(BuildContext context, CheckInViewModel vm) {
    final l10n = AppLocalizations.of(context);
    final walkIn = widget.onWalkIn == null ? null : _WalkInTile(onTap: () => widget.onWalkIn!(null));
    const side = EdgeInsets.symmetric(horizontal: DcSpace.page);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (vm.isLocked)
          Padding(
            padding: const EdgeInsets.fromLTRB(DcSpace.page, 0, DcSpace.page, DcSpace.md),
            child: _LockBanner(remaining: vm.lockRemaining),
          ),
        Padding(
          padding: side,
          child: DcSegmented<CheckInMode>(
            key: const Key('checkIn.modes'),
            segments: [
              DcSegment(value: CheckInMode.scan, label: l10n.modeScan, icon: HugeIcons.strokeRoundedQrCode),
              DcSegment(value: CheckInMode.number, label: l10n.modeNumber, icon: HugeIcons.strokeRoundedGrid),
              DcSegment(value: CheckInMode.name, label: l10n.modeName, icon: HugeIcons.strokeRoundedSearch01),
            ],
            selected: vm.mode,
            onChanged: vm.setMode,
          ),
        ),
        if (vm.failure != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.md, DcSpace.page, 0),
            child: MessageCard(text: l10n.failure(vm.failure!)),
          ),
        const SizedBox(height: DcSpace.md),
        Expanded(
          child: switch (vm.mode) {
            CheckInMode.scan => SafeArea(
              top: false,
              minimum: const EdgeInsets.only(bottom: DcSpace.xl),
              child: Padding(
                padding: side,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _Viewfinder(busy: vm.busy, child: widget.scanner(context, vm.scanned)),
                    ),
                    if (walkIn != null) ...[const SizedBox(height: DcSpace.md), walkIn],
                  ],
                ),
              ),
            ),
            CheckInMode.number => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(DcSpace.page, 0, DcSpace.page, DcSpace.xl),
              child: SafeArea(
                top: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (vm.isLocked) ...[
                      _LockedPadNotice(
                        onScan: () => vm.setMode(CheckInMode.scan),
                        onName: () => vm.setMode(CheckInMode.name),
                      ),
                      const SizedBox(height: DcSpace.md),
                    ],
                    CardNumberPad(enabled: !vm.isLocked, busy: vm.busy, onSubmit: vm.lookupCardNumber),
                    if (walkIn != null) ...[const SizedBox(height: DcSpace.md), walkIn],
                  ],
                ),
              ),
            ),
            CheckInMode.name => NameSearchView(viewModel: vm, footer: walkIn),
          },
        ),
      ],
    );
  }

  /// A state that replaces scanning: event over and wiped, no network without a saved guest
  /// list, or the event not started / ended (staff may continue).
  Widget? _blockingState(BuildContext context, CheckInViewModel vm) {
    final l10n = AppLocalizations.of(context);
    final changeEvent = DcButton(
      key: const Key('state.changeEvent'),
      label: l10n.chooseAnotherEvent,
      variant: DcButtonVariant.tonal,
      onPressed: widget.onChangeEvent,
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
          DcButton(
            key: const Key('state.retry'),
            label: l10n.retry,
            icon: HugeIcons.strokeRoundedRefresh,
            onPressed: vm.syncNow,
          ),
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
          DcButton(key: const Key('state.continue'), label: l10n.checkInAnyway, onPressed: vm.acknowledgeTiming),
          changeEvent,
        ],
      );
    }
    return null;
  }
}

/// Event · gate, the online state with what waits to sync, the sync chip and "change event".
class CheckInHeader extends StatelessWidget {
  const CheckInHeader({super.key, required this.viewModel, required this.onSync, required this.onChangeEvent});

  final CheckInViewModel viewModel;
  final VoidCallback onSync;
  final VoidCallback onChangeEvent;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final vm = viewModel;
    final gate = vm.session.deviceName?.trim();
    final title = DcType.heading(19).copyWith(color: c.ink);
    final small = DcType.ui(12).copyWith(color: c.muted);
    final offline = vm.isOffline;
    final last = vm.lastSyncAt;
    return Padding(
      padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.md, DcSpace.page, DcSpace.md),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Semantics(
                  header: true,
                  child: Row(
                    children: [
                      Flexible(child: Text(vm.session.event.title, style: title, overflow: TextOverflow.ellipsis)),
                      if (gate != null && gate.isNotEmpty) Text(' · $gate', style: title),
                    ],
                  ),
                ),
                if (vm.hasSync) ...[
                  const SizedBox(height: 2),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        offline ? l10n.offlineBadge : l10n.onlineBadge,
                        key: Key(offline ? 'checkIn.offline' : 'checkIn.online'),
                        style: small.copyWith(fontWeight: FontWeight.w700, color: offline ? c.warningFg : c.successFg),
                      ),
                      Text(' · ', style: small),
                      Expanded(
                        child: Text(
                          [
                            l10n.syncWaiting(vm.pendingCount),
                            last == null ? l10n.neverSynced : l10n.lastSync(formatEntryTime(context, last)),
                            if (offline && !vm.offlineReady) l10n.offlineUnavailable,
                          ].join(' · '),
                          key: const Key('checkIn.syncText'),
                          style: small,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (vm.hasSync) ...[const SizedBox(width: DcSpace.sm), _SyncChip(viewModel: vm, onTap: onSync)],
          const SizedBox(width: DcSpace.sm),
          DcCircleButton(
            key: const Key('checkIn.changeEvent'),
            icon: HugeIcons.strokeRoundedArrowLeftRight,
            label: l10n.changeEvent,
            onPressed: onChangeEvent,
          ),
        ],
      ),
    );
  }
}

/// Pill with the sync state and the number of entries waiting to upload.
class _SyncChip extends StatelessWidget {
  const _SyncChip({required this.viewModel, required this.onTap});

  final CheckInViewModel viewModel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final vm = viewModel;
    final (bg, fg) = vm.isOffline ? c.tone(DcTone.warning) : (c.tile, c.ink);
    return Semantics(
      button: true,
      label: l10n.syncChipLabel(vm.pendingCount),
      excludeSemantics: true,
      child: Material(
        color: bg,
        shape: const StadiumBorder(),
        child: InkWell(
          key: const Key('checkIn.syncStatus'),
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: SizedBox(
            height: 44,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DcSpace.md),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (vm.syncing)
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: fg))
                  else
                    HugeIcon(
                      icon: vm.isOffline ? HugeIcons.strokeRoundedCloudOff : HugeIcons.strokeRoundedRefresh,
                      color: fg,
                      size: 18,
                    ),
                  const SizedBox(width: 6),
                  Text('${vm.pendingCount}', style: DcType.ui(14, weight: FontWeight.w700).copyWith(color: fg)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Rounded camera frame with the accent square and the hint; a veil while a lookup runs.
class _Viewfinder extends StatelessWidget {
  const _Viewfinder({required this.busy, required this.child});

  final bool busy;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    // The camera area is dark in both themes, so the overlay uses the dark-theme text colour.
    final onCamera = DcColors.dark.ink;
    return ClipRRect(
      borderRadius: BorderRadius.circular(DcRadius.hero),
      child: ColoredBox(
        color: c.nav,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final frame = (constraints.biggest.shortestSide * 0.7).clamp(120.0, 220.0);
            return Stack(
              fit: StackFit.expand,
              children: [
                child,
                IgnorePointer(
                  child: Center(
                    child: Container(
                      width: frame,
                      height: frame,
                      decoration: BoxDecoration(
                        border: Border.all(color: c.navAccent, width: 3),
                        borderRadius: BorderRadius.circular(DcRadius.hero),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: DcSpace.lg,
                  right: DcSpace.lg,
                  bottom: DcSpace.xl,
                  child: IgnorePointer(
                    child: Text(
                      l10n.scanHint,
                      textAlign: TextAlign.center,
                      style: DcType.ui(14, weight: FontWeight.w600).copyWith(color: onCamera),
                    ),
                  ),
                ),
                if (busy)
                  ColoredBox(
                    color: c.nav.withValues(alpha: 0.6),
                    child: Center(child: CircularProgressIndicator(color: c.navAccent)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// "No card? Walk-in request" (CHK-8).
class _WalkInTile extends StatelessWidget {
  const _WalkInTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    return DcTile(
      key: const Key('checkIn.walkIn'),
      variant: DcTileVariant.soft,
      onTap: onTap,
      semanticLabel: l10n.walkInAction,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.walkInNoCard, style: DcType.ui(12).copyWith(color: c.onSoft)),
                Text(l10n.walkInAction, style: DcType.heading(18, weight: FontWeight.w800).copyWith(color: c.onSoft)),
              ],
            ),
          ),
          HugeIcon(icon: HugeIcons.strokeRoundedUserAdd01, color: c.onSoft, size: 24),
        ],
      ),
    );
  }
}

/// The phone's clock is off: offline entry times and the lockout would be wrong.
class ClockSkewBanner extends StatelessWidget {
  const ClockSkewBanner({super.key, required this.skew});

  /// Server time minus phone time.
  final Duration skew;

  @override
  Widget build(BuildContext context) => DcNoticeTile(
    key: const Key('checkIn.clockSkew'),
    tone: DcTone.warning,
    icon: HugeIcons.strokeRoundedClockAlert,
    message: AppLocalizations.of(context).clockSkewWarning(skew.inMinutes.abs()),
  );
}

/// In card-number mode while locked: what to do instead (CHK-5).
class _LockedPadNotice extends StatelessWidget {
  const _LockedPadNotice({required this.onScan, required this.onName});

  final VoidCallback onScan;
  final VoidCallback onName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    return DcTile(
      key: const Key('checkIn.lockedPad'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.lockedPadTitle, style: DcType.heading(18).copyWith(color: c.ink)),
          const SizedBox(height: DcSpace.xs),
          Text(l10n.lockedPadBody, style: DcType.ui(14).copyWith(color: c.muted)),
          const SizedBox(height: DcSpace.md),
          Row(
            children: [
              Expanded(
                child: DcButton(
                  key: const Key('lockedPad.scan'),
                  label: l10n.modeScan,
                  icon: HugeIcons.strokeRoundedQrCode,
                  onPressed: onScan,
                ),
              ),
              const SizedBox(width: DcSpace.gap),
              Expanded(
                child: DcButton(
                  key: const Key('lockedPad.name'),
                  label: l10n.modeName,
                  icon: HugeIcons.strokeRoundedSearch01,
                  onPressed: onName,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Card-number entry is locked (CHK-5): warning tile with a big countdown.
class _LockBanner extends StatelessWidget {
  const _LockBanner({required this.remaining});

  final Duration remaining;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return DcNoticeTile(
      key: const Key('checkIn.lockBanner'),
      tone: DcTone.warning,
      icon: HugeIcons.strokeRoundedSquareLock02,
      title: l10n.lockedTitle,
      message: l10n.lockedBody(formatCountdown(remaining)),
      trailing: Text(
        formatCountdown(remaining),
        key: const Key('checkIn.lockCountdown'),
        style: DcType.number(28).copyWith(color: context.dc.warningFg),
      ),
    );
  }
}

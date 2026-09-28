import 'dart:async';

import 'package:flutter/material.dart';

import '../../../data/repositories/door_repository.dart';
import '../../../data/repositories/door_sync_repository.dart';
import '../../../data/repositories/offline_check_in_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../domain/models/app_failure.dart';
import '../../../domain/models/check_in.dart';
import '../../../domain/models/door_event.dart';
import '../../../l10n/app_localizations.dart';
import '../check_in/view_models/check_in_view_model.dart';
import '../check_in/views/check_in_screen.dart';
import '../check_in/views/qr_scanner_view.dart';
import '../events/view_models/event_select_view_model.dart';
import '../events/views/event_select_screen.dart';
import '../walk_in/view_models/walk_in_view_model.dart';
import '../walk_in/views/walk_in_screen.dart';
import 'revoked_screen.dart';

/// Signed-in part of the app: choose the event (registering this phone), then check guests in.
/// Owns the view models so they live as long as their screen.
///
/// With [sync] and [offline] set, opening an event downloads its encrypted cache and keeps it
/// in step while the check-in screen is open (offline-sync 9.1–9.4).
class DoorHome extends StatefulWidget {
  const DoorHome({
    super.key,
    required this.session,
    required this.door,
    required this.scanner,
    this.sync,
    this.offline,
    this.clock,
  });

  final SessionRepository session;
  final DoorRepository door;
  final DoorSyncRepository? sync;
  final OfflineCheckInRepository? offline;
  final ScannerBuilder scanner;
  final DateTime Function()? clock;

  @override
  State<DoorHome> createState() => _DoorHomeState();
}

class _DoorHomeState extends State<DoorHome> {
  late EventSelectViewModel _events = _newEvents();
  CheckInViewModel? _checkIn;

  /// The event this phone was refused for (403), while the revoked screen shows.
  DoorEvent? _revokedEvent;
  Future<int>? _revokeCleanup;

  EventSelectViewModel _newEvents() => EventSelectViewModel(widget.door, sync: widget.sync);

  @override
  void initState() {
    super.initState();
    widget.sync?.onAccessDenied = _accessDenied;
  }

  void _opened(DoorSession session) {
    setState(() {
      _checkIn = CheckInViewModel(
        door: widget.door,
        session: session,
        clock: widget.clock,
        onAccessDenied: _accessDenied,
        offline: widget.offline,
        sync: widget.sync,
      );
    });
    final sync = widget.sync;
    if (sync != null) unawaited(sync.start(session).catchError((Object _) {}));
  }

  /// AUTH-9. 401 (session ended) signs out. 403 (the host revoked this phone or removed the
  /// door access) stops scanning, lets the sync layer try one last upload and wipe the cache,
  /// and shows the revoked screen (another event or sign-out from there).
  Future<void> _accessDenied(AppFailure because) async {
    if (because != AppFailure.doorAccessDenied) return widget.session.signOut(because: because);
    final event = _checkIn?.session.event ?? widget.sync?.session?.event;
    if (event == null || !mounted || _revokedEvent != null) return;
    _showRevoked(event, widget.sync?.deviceRevoked() ?? Future.value(0));
  }

  /// Registering this phone for [event] was refused (revoked earlier): wipe the offline copy
  /// if it is that event's, then explain.
  void _openRefused(DoorEvent event) {
    final sync = widget.sync;
    Future<int> cleanup() async {
      if (sync == null) return 0;
      final cached = await sync.cachedSession();
      return cached?.event.id == event.id ? sync.deviceRevoked() : 0;
    }

    _showRevoked(event, cleanup());
  }

  void _showRevoked(DoorEvent event, Future<int> cleanup) {
    final old = _checkIn;
    setState(() {
      _checkIn = null;
      _revokedEvent = event;
      _revokeCleanup = cleanup.catchError((Object _) => 0);
    });
    if (old != null) WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  void _leaveRevoked() {
    setState(() {
      _revokedEvent = null;
      _revokeCleanup = null;
      _events.dispose();
      _events = _newEvents();
    });
  }

  /// Warns before sign-out deletes entries that have not uploaded yet.
  Future<void> _signOut() async {
    final pending = widget.sync?.pendingCount ?? 0;
    if (pending > 0) {
      final l10n = AppLocalizations.of(context);
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.signOutPendingTitle),
          content: Text(l10n.signOutPendingBody(pending)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
            TextButton(
              key: const Key('signOut.confirm'),
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.signOutAnyway),
            ),
          ],
        ),
      );
      if (ok != true) return;
    }
    await widget.session.signOut();
  }

  Future<void> _walkIn(CheckInCard? card) async {
    final checkIn = _checkIn;
    if (checkIn == null) return;
    final vm = WalkInViewModel(
      door: widget.door,
      session: checkIn.session,
      onAccessDenied: _accessDenied,
      offline: widget.offline,
      sync: widget.sync,
      linkedCard: card,
    );
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => WalkInScreen(viewModel: vm)));
    vm.dispose();
  }

  void _closeEvent() {
    final old = _checkIn;
    widget.sync?.stop();
    setState(() {
      _checkIn = null;
      _events.dispose();
      _events = _newEvents();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => old?.dispose());
  }

  @override
  void dispose() {
    _events.dispose();
    _checkIn?.dispose();
    if (widget.sync?.onAccessDenied == _accessDenied) widget.sync?.onAccessDenied = null;
    widget.sync?.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final revoked = _revokedEvent;
    if (revoked != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _leaveRevoked();
        },
        child: RevokedScreen(
          event: revoked,
          cleanup: _revokeCleanup!,
          onChooseEvent: _leaveRevoked,
          onSignOut: () => widget.session.signOut(),
        ),
      );
    }
    final checkIn = _checkIn;
    if (checkIn != null) {
      return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          if (checkIn.result != null) {
            checkIn.next();
          } else {
            _closeEvent();
          }
        },
        child: CheckInScreen(
          key: ValueKey(checkIn.session.deviceId),
          viewModel: checkIn,
          scanner: widget.scanner,
          onChangeEvent: _closeEvent,
          onWalkIn: _walkIn,
        ),
      );
    }
    return EventSelectScreen(
      key: ObjectKey(_events),
      viewModel: _events,
      onOpened: _opened,
      onSignOut: _signOut,
      onRefused: _openRefused,
    );
  }
}

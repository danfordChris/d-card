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

  /// AUTH-9: a revoked device (or lost door access / ended session) goes back to sign-in.
  Future<void> _accessDenied(AppFailure because) => widget.session.signOut(because: because);

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
    );
  }
}

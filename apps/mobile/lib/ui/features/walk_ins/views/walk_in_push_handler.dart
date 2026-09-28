import 'dart:async';

import 'package:flutter/material.dart';

import '../../../../data/repositories/events_repository.dart';
import '../../../../data/repositories/walk_in_alerts_repository.dart';
import '../../../../domain/models/walk_in.dart';
import '../../../../l10n/app_localizations.dart';
import 'walk_ins_screen.dart';

/// Routes walk-in pushes for the signed-in user: a tapped notification (background or cold
/// start) opens that event's walk-ins screen; a foreground message shows a banner with Open.
/// When that event's walk-ins screen is already open it refreshes itself instead.
class WalkInPushHandler extends StatefulWidget {
  const WalkInPushHandler({super.key, required this.alerts, required this.events, required this.child});

  final WalkInAlertsRepository alerts;
  final EventsRepository events;
  final Widget child;

  @override
  State<WalkInPushHandler> createState() => _WalkInPushHandlerState();
}

class _WalkInPushHandlerState extends State<WalkInPushHandler> {
  StreamSubscription<WalkInAlert>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = widget.alerts.alerts.listen(_handle);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final initial = await widget.alerts.takeInitialAlert();
      if (initial != null && mounted) _handle(initial);
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  void _handle(WalkInAlert alert) {
    if (!mounted) return;
    if (alert.opened) {
      unawaited(_open(alert.eventId));
      return;
    }
    // Decided-elsewhere updates only refresh an open screen; new requests get a banner.
    if (WalkInsScreen.isOpen(alert.eventId)) return;
    if (alert.status != WalkInStatus.pending && alert.status != WalkInStatus.admittedOffline) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          key: const Key('walkIn.banner'),
          content: Text(alert.status == WalkInStatus.pending ? l10n.walkInPushPending : l10n.walkInPushReview),
          duration: const Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: l10n.walkInOpen, onPressed: () => unawaited(_open(alert.eventId))),
        ),
      );
  }

  Future<void> _open(String eventId) async {
    if (WalkInsScreen.isOpen(eventId)) return;
    String? title;
    // Unknown access (lookup failed): let the server decide; a 403 turns the screen read-only.
    var canDecide = true;
    try {
      final event = await widget.events.getEvent(eventId);
      title = event.title;
      canDecide = event.canDecideWalkIns;
    } catch (_) {}
    if (!mounted || WalkInsScreen.isOpen(eventId)) return;
    await openWalkIns(context, eventId: eventId, eventTitle: title, canDecide: canDecide);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

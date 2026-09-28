import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../domain/models/door_event.dart';
import '../../../l10n/app_localizations.dart';
import '../../core/door_state_view.dart';

/// Shown when the server refuses this phone for [event] (403: the host revoked it or removed
/// the account's door access, AUTH-9). Scanning has stopped; [cleanup] is the last upload try
/// and the wipe of the offline cache, and resolves to the number of items that were lost.
class RevokedScreen extends StatelessWidget {
  const RevokedScreen({
    super.key,
    required this.event,
    required this.cleanup,
    required this.onChooseEvent,
    required this.onSignOut,
  });

  final DoorEvent event;
  final Future<int> cleanup;
  final VoidCallback onChooseEvent;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      key: const Key('revoked.screen'),
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: DcSpace.md),
          child: FutureBuilder<int>(
            future: cleanup,
            builder: (context, snapshot) {
              final done = snapshot.connectionState == ConnectionState.done;
              final lost = snapshot.data ?? 0;
              return DoorStateView(
                icon: HugeIcons.strokeRoundedSquareLock02,
                title: l10n.revokedTitle,
                body: l10n.revokedBody(event.title),
                busy: !done,
                details: [
                  Text(
                    !done ? l10n.revokedWorking : (lost > 0 ? l10n.revokedLost(lost) : l10n.revokedNothingLost),
                    key: const Key('revoked.lost'),
                    textAlign: TextAlign.center,
                    style: DcType.ui(16, weight: lost > 0 ? FontWeight.w800 : FontWeight.w700)
                        .copyWith(color: context.dc.dangerFg),
                  ),
                ],
                actions: [
                  DcButton(
                    key: const Key('revoked.chooseEvent'),
                    label: l10n.chooseAnotherEvent,
                    variant: DcButtonVariant.tonal,
                    onPressed: onChooseEvent,
                  ),
                  DcButton(
                    key: const Key('revoked.signOut'),
                    label: l10n.signOut,
                    icon: HugeIcons.strokeRoundedLogout03,
                    onPressed: onSignOut,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

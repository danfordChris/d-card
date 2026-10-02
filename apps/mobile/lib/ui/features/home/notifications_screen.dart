import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../l10n/app_localizations.dart';

/// Notifications tab. The app does not keep a push history yet (walk-in pushes show as
/// banners while the app is open), so this is the empty state.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DcPageHeader(title: l10n.notificationsTitle),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: DcSpotlightNavBar.reservedHeight),
                child: DcStateView(
                  kind: DcStateKind.empty,
                  icon: HugeIcons.strokeRoundedNotification01,
                  title: l10n.notificationsEmptyTitle,
                  message: l10n.notificationsEmptyBody,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

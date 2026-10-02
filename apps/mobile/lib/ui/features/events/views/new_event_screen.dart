import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../l10n/app_localizations.dart';

/// New event tab. Events are created on the D-Card website for now (the app has no
/// create-event flow yet); new events show on Home straight away.
class NewEventScreen extends StatelessWidget {
  const NewEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DcPageHeader(title: l10n.newEventTitle),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: DcSpotlightNavBar.reservedHeight),
                child: DcStateView(
                  kind: DcStateKind.empty,
                  icon: HugeIcons.strokeRoundedCalendarAdd01,
                  title: l10n.newEventWebTitle,
                  message: l10n.newEventWebBody,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

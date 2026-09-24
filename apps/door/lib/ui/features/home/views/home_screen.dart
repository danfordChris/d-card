import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Placeholder home screen until phase 01 features land.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: BrandHeader(title: l10n.homeTitle, subtitle: l10n.homeSubtitle),
        ),
      ),
    );
  }
}

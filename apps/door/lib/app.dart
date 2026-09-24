import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';

import 'l10n/app_localizations.dart';
import 'ui/features/home/views/home_screen.dart';

/// Root widget: theme, Swahili/English localisation, home screen.
class DCardApp extends StatelessWidget {
  const DCardApp({super.key, this.locale});

  /// Forces a locale (tests); null follows the device.
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: DCardTheme.light(),
      darkTheme: DCardTheme.dark(),
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const HomeScreen(),
    );
  }
}

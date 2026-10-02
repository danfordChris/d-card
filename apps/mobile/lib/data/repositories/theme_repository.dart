import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// The Light / Dark / System theme choice from Account, kept on the device
/// (docs/design/ui/design-system.md: the theme follows the system by default).
///
/// Stored with `shared_preferences`: `flutter_pack` does not resolve in this workspace
/// (its `package_info_plus ^9` needs `win32 ^5`, the door app's secure storage needs `win32 ^6`).
class ThemeRepository extends ChangeNotifier {
  ThemeRepository(this._prefs);

  static const key = 'settings.theme_mode';

  final SharedPreferences _prefs;

  ThemeMode get mode => switch (_prefs.getString(key)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  Future<void> setMode(ThemeMode mode) async {
    if (mode == this.mode) return;
    await _prefs.setString(key, mode.name);
    notifyListeners();
  }
}

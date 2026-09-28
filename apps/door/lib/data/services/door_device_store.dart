import 'package:shared_preferences/shared_preferences.dart';

import 'uuid.dart';

/// This install's door device ID per event, and the optional gate name, in shared_preferences.
///
/// The ID is generated once per install and event and never changes, so the server
/// sees one device per event (AUTH-9) and a revoked device stays revoked.
class DoorDeviceStore {
  DoorDeviceStore(this._prefs, {String Function()? newId}) : _newId = newId ?? uuidV4;

  static const _deviceKeyPrefix = 'door.device_id.';
  static const _nameKey = 'door.device_name';

  final SharedPreferences _prefs;
  final String Function() _newId;

  /// The device ID for [eventId], created and stored on first use.
  Future<String> deviceIdFor(String eventId) async {
    final key = '$_deviceKeyPrefix$eventId';
    final existing = _prefs.getString(key);
    if (existing != null) return existing;
    final id = _newId();
    await _prefs.setString(key, id);
    return id;
  }

  /// Gate name staff gave this phone (e.g. "Gate 1"), shown to the host and in entry history.
  String? get deviceName => _prefs.getString(_nameKey);

  Future<void> setDeviceName(String? name) async {
    final trimmed = name?.trim() ?? '';
    if (trimmed.isEmpty) {
      await _prefs.remove(_nameKey);
    } else {
      await _prefs.setString(_nameKey, trimmed.length > 60 ? trimmed.substring(0, 60) : trimmed);
    }
  }
}

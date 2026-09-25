//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DeviceRegisterInput {
  /// Returns a new [DeviceRegisterInput] instance.
  DeviceRegisterInput({
    required this.token,
    required this.platform,
    required this.app,
  });

  String token;

  DevicePlatform platform;

  DeviceApp app;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DeviceRegisterInput &&
    other.token == token &&
    other.platform == platform &&
    other.app == app;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (token.hashCode) +
    (platform.hashCode) +
    (app.hashCode);

  @override
  String toString() => 'DeviceRegisterInput[token=$token, platform=$platform, app=$app]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'token'] = this.token;
      json[r'platform'] = this.platform;
      json[r'app'] = this.app;
    return json;
  }

  /// Returns a new [DeviceRegisterInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DeviceRegisterInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DeviceRegisterInput[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "DeviceRegisterInput[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return DeviceRegisterInput(
        token: mapValueOfType<String>(json, r'token')!,
        platform: DevicePlatform.fromJson(json[r'platform'])!,
        app: DeviceApp.fromJson(json[r'app'])!,
      );
    }
    return null;
  }

  static List<DeviceRegisterInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DeviceRegisterInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeviceRegisterInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DeviceRegisterInput> mapFromJson(dynamic json) {
    final map = <String, DeviceRegisterInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DeviceRegisterInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DeviceRegisterInput-objects as value to a dart map
  static Map<String, List<DeviceRegisterInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DeviceRegisterInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DeviceRegisterInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'token',
    'platform',
    'app',
  };
}


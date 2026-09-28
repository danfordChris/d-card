//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class BillingSettings {
  /// Returns a new [BillingSettings] instance.
  BillingSettings({
    required this.launchOfferEnabled,
    required this.launchOfferPercent,
  });

  bool launchOfferEnabled;

  /// Minimum value: 0
  /// Maximum value: 90
  int launchOfferPercent;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BillingSettings &&
    other.launchOfferEnabled == launchOfferEnabled &&
    other.launchOfferPercent == launchOfferPercent;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (launchOfferEnabled.hashCode) +
    (launchOfferPercent.hashCode);

  @override
  String toString() => 'BillingSettings[launchOfferEnabled=$launchOfferEnabled, launchOfferPercent=$launchOfferPercent]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'launchOfferEnabled'] = this.launchOfferEnabled;
      json[r'launchOfferPercent'] = this.launchOfferPercent;
    return json;
  }

  /// Returns a new [BillingSettings] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BillingSettings? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BillingSettings[$key]" is missing from JSON.');
        });
        return true;
      }());

      return BillingSettings(
        launchOfferEnabled: mapValueOfType<bool>(json, r'launchOfferEnabled')!,
        launchOfferPercent: mapValueOfType<int>(json, r'launchOfferPercent')!,
      );
    }
    return null;
  }

  static List<BillingSettings> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BillingSettings>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BillingSettings.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BillingSettings> mapFromJson(dynamic json) {
    final map = <String, BillingSettings>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BillingSettings.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BillingSettings-objects as value to a dart map
  static Map<String, List<BillingSettings>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BillingSettings>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BillingSettings.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'launchOfferEnabled',
    'launchOfferPercent',
  };
}


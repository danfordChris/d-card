//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class Plan {
  /// Returns a new [Plan] instance.
  Plan({
    required this.key,
    required this.name,
    required this.pricePerGuest,
    this.entitlements = const {},
  });

  String key;

  String name;

  int pricePerGuest;

  Map<String, Object> entitlements;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Plan &&
    other.key == key &&
    other.name == name &&
    other.pricePerGuest == pricePerGuest &&
    _deepEquality.equals(other.entitlements, entitlements);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (key.hashCode) +
    (name.hashCode) +
    (pricePerGuest.hashCode) +
    (entitlements.hashCode);

  @override
  String toString() => 'Plan[key=$key, name=$name, pricePerGuest=$pricePerGuest, entitlements=$entitlements]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'key'] = this.key;
      json[r'name'] = this.name;
      json[r'pricePerGuest'] = this.pricePerGuest;
      json[r'entitlements'] = this.entitlements;
    return json;
  }

  /// Returns a new [Plan] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Plan? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Plan[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Plan[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Plan(
        key: mapValueOfType<String>(json, r'key')!,
        name: mapValueOfType<String>(json, r'name')!,
        pricePerGuest: mapValueOfType<int>(json, r'pricePerGuest')!,
        entitlements: mapCastOfType<String, Object>(json, r'entitlements')!,
      );
    }
    return null;
  }

  static List<Plan> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Plan>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Plan.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Plan> mapFromJson(dynamic json) {
    final map = <String, Plan>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Plan.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Plan-objects as value to a dart map
  static Map<String, List<Plan>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Plan>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Plan.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'key',
    'name',
    'pricePerGuest',
    'entitlements',
  };
}


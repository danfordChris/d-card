//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class WalkInConflict {
  /// Returns a new [WalkInConflict] instance.
  WalkInConflict({
    required this.error,
    required this.walkIn,
  });

  DoorRefusalError error;

  WalkIn walkIn;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WalkInConflict &&
    other.error == error &&
    other.walkIn == walkIn;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (error.hashCode) +
    (walkIn.hashCode);

  @override
  String toString() => 'WalkInConflict[error=$error, walkIn=$walkIn]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'error'] = this.error;
      json[r'walkIn'] = this.walkIn;
    return json;
  }

  /// Returns a new [WalkInConflict] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WalkInConflict? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "WalkInConflict[$key]" is missing from JSON.');
        });
        return true;
      }());

      return WalkInConflict(
        error: DoorRefusalError.fromJson(json[r'error'])!,
        walkIn: WalkIn.fromJson(json[r'walkIn'])!,
      );
    }
    return null;
  }

  static List<WalkInConflict> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WalkInConflict>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WalkInConflict.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WalkInConflict> mapFromJson(dynamic json) {
    final map = <String, WalkInConflict>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WalkInConflict.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WalkInConflict-objects as value to a dart map
  static Map<String, List<WalkInConflict>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WalkInConflict>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WalkInConflict.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'error',
    'walkIn',
  };
}


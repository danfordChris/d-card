//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorRefusal {
  /// Returns a new [DoorRefusal] instance.
  DoorRefusal({
    required this.error,
    required this.card,
    required this.lockedUntil,
  });

  DoorRefusalError error;

  DoorRefusalCard card;

  DateTime? lockedUntil;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorRefusal &&
    other.error == error &&
    other.card == card &&
    other.lockedUntil == lockedUntil;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (error.hashCode) +
    (card.hashCode) +
    (lockedUntil == null ? 0 : lockedUntil!.hashCode);

  @override
  String toString() => 'DoorRefusal[error=$error, card=$card, lockedUntil=$lockedUntil]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'error'] = this.error;
      json[r'card'] = this.card;
    if (this.lockedUntil != null) {
      json[r'lockedUntil'] = this.lockedUntil!.toUtc().toIso8601String();
    } else {
      json[r'lockedUntil'] = null;
    }
    return json;
  }

  /// Returns a new [DoorRefusal] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorRefusal? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorRefusal[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorRefusal(
        error: DoorRefusalError.fromJson(json[r'error'])!,
        card: DoorRefusalCard.fromJson(json[r'card'])!,
        lockedUntil: mapDateTime(json, r'lockedUntil', r''),
      );
    }
    return null;
  }

  static List<DoorRefusal> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorRefusal>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorRefusal.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorRefusal> mapFromJson(dynamic json) {
    final map = <String, DoorRefusal>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorRefusal.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorRefusal-objects as value to a dart map
  static Map<String, List<DoorRefusal>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorRefusal>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorRefusal.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'error',
    'card',
    'lockedUntil',
  };
}


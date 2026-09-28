//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorLookupResult {
  /// Returns a new [DoorLookupResult] instance.
  DoorLookupResult({
    this.cards = const [],
  });

  List<DoorCard> cards;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorLookupResult &&
    _deepEquality.equals(other.cards, cards);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (cards.hashCode);

  @override
  String toString() => 'DoorLookupResult[cards=$cards]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'cards'] = this.cards;
    return json;
  }

  /// Returns a new [DoorLookupResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorLookupResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorLookupResult[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorLookupResult(
        cards: DoorCard.listFromJson(json[r'cards']),
      );
    }
    return null;
  }

  static List<DoorLookupResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorLookupResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorLookupResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorLookupResult> mapFromJson(dynamic json) {
    final map = <String, DoorLookupResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorLookupResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorLookupResult-objects as value to a dart map
  static Map<String, List<DoorLookupResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorLookupResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorLookupResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'cards',
  };
}


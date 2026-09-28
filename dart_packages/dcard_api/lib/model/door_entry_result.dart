//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorEntryResult {
  /// Returns a new [DoorEntryResult] instance.
  DoorEntryResult({
    required this.entry,
    required this.card,
  });

  DoorEntry entry;

  DoorCard card;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorEntryResult &&
    other.entry == entry &&
    other.card == card;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (entry.hashCode) +
    (card.hashCode);

  @override
  String toString() => 'DoorEntryResult[entry=$entry, card=$card]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'entry'] = this.entry;
      json[r'card'] = this.card;
    return json;
  }

  /// Returns a new [DoorEntryResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorEntryResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorEntryResult[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorEntryResult(
        entry: DoorEntry.fromJson(json[r'entry'])!,
        card: DoorCard.fromJson(json[r'card'])!,
      );
    }
    return null;
  }

  static List<DoorEntryResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorEntryResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorEntryResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorEntryResult> mapFromJson(dynamic json) {
    final map = <String, DoorEntryResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorEntryResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorEntryResult-objects as value to a dart map
  static Map<String, List<DoorEntryResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorEntryResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorEntryResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'entry',
    'card',
  };
}


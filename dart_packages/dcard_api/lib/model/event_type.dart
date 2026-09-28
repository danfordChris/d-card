//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class EventType {
  /// Returns a new [EventType] instance.
  EventType({
    required this.key,
    required this.nameSw,
    required this.nameEn,
  });

  String key;

  String nameSw;

  String nameEn;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EventType &&
    other.key == key &&
    other.nameSw == nameSw &&
    other.nameEn == nameEn;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (key.hashCode) +
    (nameSw.hashCode) +
    (nameEn.hashCode);

  @override
  String toString() => 'EventType[key=$key, nameSw=$nameSw, nameEn=$nameEn]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'key'] = this.key;
      json[r'nameSw'] = this.nameSw;
      json[r'nameEn'] = this.nameEn;
    return json;
  }

  /// Returns a new [EventType] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EventType? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EventType[$key]" is missing from JSON.');
        });
        return true;
      }());

      return EventType(
        key: mapValueOfType<String>(json, r'key')!,
        nameSw: mapValueOfType<String>(json, r'nameSw')!,
        nameEn: mapValueOfType<String>(json, r'nameEn')!,
      );
    }
    return null;
  }

  static List<EventType> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EventType>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EventType.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EventType> mapFromJson(dynamic json) {
    final map = <String, EventType>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EventType.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EventType-objects as value to a dart map
  static Map<String, List<EventType>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EventType>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EventType.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'key',
    'nameSw',
    'nameEn',
  };
}


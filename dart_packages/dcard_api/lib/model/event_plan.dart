//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class EventPlan {
  /// Returns a new [EventPlan] instance.
  EventPlan({
    required this.key,
    required this.name,
    required this.pricePerGuest,
    required this.guestLimit,
    required this.paid,
  });

  String key;

  String name;

  int pricePerGuest;

  int guestLimit;

  bool paid;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EventPlan &&
    other.key == key &&
    other.name == name &&
    other.pricePerGuest == pricePerGuest &&
    other.guestLimit == guestLimit &&
    other.paid == paid;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (key.hashCode) +
    (name.hashCode) +
    (pricePerGuest.hashCode) +
    (guestLimit.hashCode) +
    (paid.hashCode);

  @override
  String toString() => 'EventPlan[key=$key, name=$name, pricePerGuest=$pricePerGuest, guestLimit=$guestLimit, paid=$paid]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'key'] = this.key;
      json[r'name'] = this.name;
      json[r'pricePerGuest'] = this.pricePerGuest;
      json[r'guestLimit'] = this.guestLimit;
      json[r'paid'] = this.paid;
    return json;
  }

  /// Returns a new [EventPlan] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EventPlan? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EventPlan[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "EventPlan[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return EventPlan(
        key: mapValueOfType<String>(json, r'key')!,
        name: mapValueOfType<String>(json, r'name')!,
        pricePerGuest: mapValueOfType<int>(json, r'pricePerGuest')!,
        guestLimit: mapValueOfType<int>(json, r'guestLimit')!,
        paid: mapValueOfType<bool>(json, r'paid')!,
      );
    }
    return null;
  }

  static List<EventPlan> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EventPlan>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EventPlan.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EventPlan> mapFromJson(dynamic json) {
    final map = <String, EventPlan>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EventPlan.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EventPlan-objects as value to a dart map
  static Map<String, List<EventPlan>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EventPlan>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EventPlan.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'key',
    'name',
    'pricePerGuest',
    'guestLimit',
    'paid',
  };
}


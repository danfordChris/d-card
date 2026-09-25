//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class AdminEventType {
  /// Returns a new [AdminEventType] instance.
  AdminEventType({
    required this.id,
    required this.key,
    required this.nameSw,
    required this.nameEn,
    required this.active,
  });

  String id;

  String key;

  String nameSw;

  String nameEn;

  bool active;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminEventType &&
    other.id == id &&
    other.key == key &&
    other.nameSw == nameSw &&
    other.nameEn == nameEn &&
    other.active == active;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (key.hashCode) +
    (nameSw.hashCode) +
    (nameEn.hashCode) +
    (active.hashCode);

  @override
  String toString() => 'AdminEventType[id=$id, key=$key, nameSw=$nameSw, nameEn=$nameEn, active=$active]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'key'] = this.key;
      json[r'nameSw'] = this.nameSw;
      json[r'nameEn'] = this.nameEn;
      json[r'active'] = this.active;
    return json;
  }

  /// Returns a new [AdminEventType] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminEventType? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AdminEventType[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AdminEventType[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AdminEventType(
        id: mapValueOfType<String>(json, r'id')!,
        key: mapValueOfType<String>(json, r'key')!,
        nameSw: mapValueOfType<String>(json, r'nameSw')!,
        nameEn: mapValueOfType<String>(json, r'nameEn')!,
        active: mapValueOfType<bool>(json, r'active')!,
      );
    }
    return null;
  }

  static List<AdminEventType> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminEventType>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminEventType.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminEventType> mapFromJson(dynamic json) {
    final map = <String, AdminEventType>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminEventType.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminEventType-objects as value to a dart map
  static Map<String, List<AdminEventType>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminEventType>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminEventType.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'key',
    'nameSw',
    'nameEn',
    'active',
  };
}


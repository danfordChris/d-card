//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorDevice {
  /// Returns a new [DoorDevice] instance.
  DoorDevice({
    required this.id,
    required this.eventId,
    required this.name,
    required this.staffName,
    required this.createdAt,
    required this.lastSyncAt,
    required this.revokedAt,
  });

  String id;

  String eventId;

  String? name;

  String? staffName;

  DateTime createdAt;

  DateTime? lastSyncAt;

  DateTime? revokedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorDevice &&
    other.id == id &&
    other.eventId == eventId &&
    other.name == name &&
    other.staffName == staffName &&
    other.createdAt == createdAt &&
    other.lastSyncAt == lastSyncAt &&
    other.revokedAt == revokedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (eventId.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (staffName == null ? 0 : staffName!.hashCode) +
    (createdAt.hashCode) +
    (lastSyncAt == null ? 0 : lastSyncAt!.hashCode) +
    (revokedAt == null ? 0 : revokedAt!.hashCode);

  @override
  String toString() => 'DoorDevice[id=$id, eventId=$eventId, name=$name, staffName=$staffName, createdAt=$createdAt, lastSyncAt=$lastSyncAt, revokedAt=$revokedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'eventId'] = this.eventId;
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.staffName != null) {
      json[r'staffName'] = this.staffName;
    } else {
      json[r'staffName'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    if (this.lastSyncAt != null) {
      json[r'lastSyncAt'] = this.lastSyncAt!.toUtc().toIso8601String();
    } else {
      json[r'lastSyncAt'] = null;
    }
    if (this.revokedAt != null) {
      json[r'revokedAt'] = this.revokedAt!.toUtc().toIso8601String();
    } else {
      json[r'revokedAt'] = null;
    }
    return json;
  }

  /// Returns a new [DoorDevice] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorDevice? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorDevice[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorDevice(
        id: mapValueOfType<String>(json, r'id')!,
        eventId: mapValueOfType<String>(json, r'eventId')!,
        name: mapValueOfType<String>(json, r'name'),
        staffName: mapValueOfType<String>(json, r'staffName'),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        lastSyncAt: mapDateTime(json, r'lastSyncAt', r''),
        revokedAt: mapDateTime(json, r'revokedAt', r''),
      );
    }
    return null;
  }

  static List<DoorDevice> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorDevice>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorDevice.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorDevice> mapFromJson(dynamic json) {
    final map = <String, DoorDevice>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorDevice.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorDevice-objects as value to a dart map
  static Map<String, List<DoorDevice>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorDevice>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorDevice.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'eventId',
    'name',
    'staffName',
    'createdAt',
    'lastSyncAt',
    'revokedAt',
  };
}


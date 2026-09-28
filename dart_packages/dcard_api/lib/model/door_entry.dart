//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorEntry {
  /// Returns a new [DoorEntry] instance.
  DoorEntry({
    required this.id,
    required this.admittedCount,
    required this.method,
    required this.occurredAt,
    required this.deviceName,
    required this.staffName,
  });

  String id;

  int admittedCount;

  CheckInMethod method;

  DateTime occurredAt;

  String? deviceName;

  String? staffName;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorEntry &&
    other.id == id &&
    other.admittedCount == admittedCount &&
    other.method == method &&
    other.occurredAt == occurredAt &&
    other.deviceName == deviceName &&
    other.staffName == staffName;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (admittedCount.hashCode) +
    (method.hashCode) +
    (occurredAt.hashCode) +
    (deviceName == null ? 0 : deviceName!.hashCode) +
    (staffName == null ? 0 : staffName!.hashCode);

  @override
  String toString() => 'DoorEntry[id=$id, admittedCount=$admittedCount, method=$method, occurredAt=$occurredAt, deviceName=$deviceName, staffName=$staffName]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'admittedCount'] = this.admittedCount;
      json[r'method'] = this.method;
      json[r'occurredAt'] = this.occurredAt.toUtc().toIso8601String();
    if (this.deviceName != null) {
      json[r'deviceName'] = this.deviceName;
    } else {
      json[r'deviceName'] = null;
    }
    if (this.staffName != null) {
      json[r'staffName'] = this.staffName;
    } else {
      json[r'staffName'] = null;
    }
    return json;
  }

  /// Returns a new [DoorEntry] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorEntry? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorEntry[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorEntry(
        id: mapValueOfType<String>(json, r'id')!,
        admittedCount: mapValueOfType<int>(json, r'admittedCount')!,
        method: CheckInMethod.fromJson(json[r'method'])!,
        occurredAt: mapDateTime(json, r'occurredAt', r'')!,
        deviceName: mapValueOfType<String>(json, r'deviceName'),
        staffName: mapValueOfType<String>(json, r'staffName'),
      );
    }
    return null;
  }

  static List<DoorEntry> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorEntry>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorEntry.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorEntry> mapFromJson(dynamic json) {
    final map = <String, DoorEntry>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorEntry.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorEntry-objects as value to a dart map
  static Map<String, List<DoorEntry>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorEntry>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorEntry.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'admittedCount',
    'method',
    'occurredAt',
    'deviceName',
    'staffName',
  };
}


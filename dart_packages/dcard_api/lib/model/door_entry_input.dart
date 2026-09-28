//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorEntryInput {
  /// Returns a new [DoorEntryInput] instance.
  DoorEntryInput({
    required this.id,
    required this.deviceId,
    required this.invitationId,
    required this.admittedCount,
    required this.method,
  });

  String id;

  String deviceId;

  String invitationId;

  /// Minimum value: 1
  /// Maximum value: 2
  int admittedCount;

  CheckInMethod method;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorEntryInput &&
    other.id == id &&
    other.deviceId == deviceId &&
    other.invitationId == invitationId &&
    other.admittedCount == admittedCount &&
    other.method == method;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (deviceId.hashCode) +
    (invitationId.hashCode) +
    (admittedCount.hashCode) +
    (method.hashCode);

  @override
  String toString() => 'DoorEntryInput[id=$id, deviceId=$deviceId, invitationId=$invitationId, admittedCount=$admittedCount, method=$method]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'deviceId'] = this.deviceId;
      json[r'invitationId'] = this.invitationId;
      json[r'admittedCount'] = this.admittedCount;
      json[r'method'] = this.method;
    return json;
  }

  /// Returns a new [DoorEntryInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorEntryInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorEntryInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorEntryInput(
        id: mapValueOfType<String>(json, r'id')!,
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        invitationId: mapValueOfType<String>(json, r'invitationId')!,
        admittedCount: mapValueOfType<int>(json, r'admittedCount')!,
        method: CheckInMethod.fromJson(json[r'method'])!,
      );
    }
    return null;
  }

  static List<DoorEntryInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorEntryInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorEntryInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorEntryInput> mapFromJson(dynamic json) {
    final map = <String, DoorEntryInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorEntryInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorEntryInput-objects as value to a dart map
  static Map<String, List<DoorEntryInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorEntryInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorEntryInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'deviceId',
    'invitationId',
    'admittedCount',
    'method',
  };
}


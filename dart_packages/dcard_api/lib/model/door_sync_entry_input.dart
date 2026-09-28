//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorSyncEntryInput {
  /// Returns a new [DoorSyncEntryInput] instance.
  DoorSyncEntryInput({
    required this.id,
    required this.invitationId,
    required this.admittedCount,
    required this.method,
    required this.occurredAt,
  });

  String id;

  String invitationId;

  /// Minimum value: 1
  /// Maximum value: 2
  int admittedCount;

  CheckInMethod method;

  DateTime occurredAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorSyncEntryInput &&
    other.id == id &&
    other.invitationId == invitationId &&
    other.admittedCount == admittedCount &&
    other.method == method &&
    other.occurredAt == occurredAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (invitationId.hashCode) +
    (admittedCount.hashCode) +
    (method.hashCode) +
    (occurredAt.hashCode);

  @override
  String toString() => 'DoorSyncEntryInput[id=$id, invitationId=$invitationId, admittedCount=$admittedCount, method=$method, occurredAt=$occurredAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'invitationId'] = this.invitationId;
      json[r'admittedCount'] = this.admittedCount;
      json[r'method'] = this.method;
      json[r'occurredAt'] = this.occurredAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [DoorSyncEntryInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorSyncEntryInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorSyncEntryInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorSyncEntryInput(
        id: mapValueOfType<String>(json, r'id')!,
        invitationId: mapValueOfType<String>(json, r'invitationId')!,
        admittedCount: mapValueOfType<int>(json, r'admittedCount')!,
        method: CheckInMethod.fromJson(json[r'method'])!,
        occurredAt: mapDateTime(json, r'occurredAt', r'')!,
      );
    }
    return null;
  }

  static List<DoorSyncEntryInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorSyncEntryInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorSyncEntryInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorSyncEntryInput> mapFromJson(dynamic json) {
    final map = <String, DoorSyncEntryInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorSyncEntryInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorSyncEntryInput-objects as value to a dart map
  static Map<String, List<DoorSyncEntryInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorSyncEntryInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorSyncEntryInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'invitationId',
    'admittedCount',
    'method',
    'occurredAt',
  };
}


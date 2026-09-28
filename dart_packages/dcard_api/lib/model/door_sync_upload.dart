//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorSyncUpload {
  /// Returns a new [DoorSyncUpload] instance.
  DoorSyncUpload({
    required this.deviceId,
    this.entries = const [],
    this.attempts = const [],
    this.walkIns = const [],
    required this.pending,
  });

  String deviceId;

  List<DoorSyncEntryInput> entries;

  List<DoorSyncAttemptInput> attempts;

  List<OfflineWalkInInput> walkIns;

  /// Minimum value: 0
  /// Maximum value: 100000
  int pending;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorSyncUpload &&
    other.deviceId == deviceId &&
    _deepEquality.equals(other.entries, entries) &&
    _deepEquality.equals(other.attempts, attempts) &&
    _deepEquality.equals(other.walkIns, walkIns) &&
    other.pending == pending;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (deviceId.hashCode) +
    (entries.hashCode) +
    (attempts.hashCode) +
    (walkIns.hashCode) +
    (pending.hashCode);

  @override
  String toString() => 'DoorSyncUpload[deviceId=$deviceId, entries=$entries, attempts=$attempts, walkIns=$walkIns, pending=$pending]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'deviceId'] = this.deviceId;
      json[r'entries'] = this.entries;
      json[r'attempts'] = this.attempts;
      json[r'walkIns'] = this.walkIns;
      json[r'pending'] = this.pending;
    return json;
  }

  /// Returns a new [DoorSyncUpload] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorSyncUpload? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorSyncUpload[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorSyncUpload(
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        entries: DoorSyncEntryInput.listFromJson(json[r'entries']),
        attempts: DoorSyncAttemptInput.listFromJson(json[r'attempts']),
        walkIns: OfflineWalkInInput.listFromJson(json[r'walkIns']),
        pending: mapValueOfType<int>(json, r'pending')!,
      );
    }
    return null;
  }

  static List<DoorSyncUpload> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorSyncUpload>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorSyncUpload.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorSyncUpload> mapFromJson(dynamic json) {
    final map = <String, DoorSyncUpload>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorSyncUpload.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorSyncUpload-objects as value to a dart map
  static Map<String, List<DoorSyncUpload>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorSyncUpload>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorSyncUpload.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'deviceId',
    'entries',
    'attempts',
    'pending',
  };
}


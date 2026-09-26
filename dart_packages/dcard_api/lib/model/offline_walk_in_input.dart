//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class OfflineWalkInInput {
  /// Returns a new [OfflineWalkInInput] instance.
  OfflineWalkInInput({
    required this.id,
    required this.description,
    this.invitationId,
    required this.admittedCount,
    required this.offlineReason,
    required this.occurredAt,
  });

  String id;

  String description;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? invitationId;

  /// Minimum value: 1
  /// Maximum value: 2
  int admittedCount;

  String offlineReason;

  DateTime occurredAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is OfflineWalkInInput &&
    other.id == id &&
    other.description == description &&
    other.invitationId == invitationId &&
    other.admittedCount == admittedCount &&
    other.offlineReason == offlineReason &&
    other.occurredAt == occurredAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (description.hashCode) +
    (invitationId == null ? 0 : invitationId!.hashCode) +
    (admittedCount.hashCode) +
    (offlineReason.hashCode) +
    (occurredAt.hashCode);

  @override
  String toString() => 'OfflineWalkInInput[id=$id, description=$description, invitationId=$invitationId, admittedCount=$admittedCount, offlineReason=$offlineReason, occurredAt=$occurredAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'description'] = this.description;
    if (this.invitationId != null) {
      json[r'invitationId'] = this.invitationId;
    } else {
      json[r'invitationId'] = null;
    }
      json[r'admittedCount'] = this.admittedCount;
      json[r'offlineReason'] = this.offlineReason;
      json[r'occurredAt'] = this.occurredAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [OfflineWalkInInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static OfflineWalkInInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "OfflineWalkInInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return OfflineWalkInInput(
        id: mapValueOfType<String>(json, r'id')!,
        description: mapValueOfType<String>(json, r'description')!,
        invitationId: mapValueOfType<String>(json, r'invitationId'),
        admittedCount: mapValueOfType<int>(json, r'admittedCount')!,
        offlineReason: mapValueOfType<String>(json, r'offlineReason')!,
        occurredAt: mapDateTime(json, r'occurredAt', r'')!,
      );
    }
    return null;
  }

  static List<OfflineWalkInInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <OfflineWalkInInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = OfflineWalkInInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, OfflineWalkInInput> mapFromJson(dynamic json) {
    final map = <String, OfflineWalkInInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = OfflineWalkInInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of OfflineWalkInInput-objects as value to a dart map
  static Map<String, List<OfflineWalkInInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<OfflineWalkInInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = OfflineWalkInInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'description',
    'admittedCount',
    'offlineReason',
    'occurredAt',
  };
}


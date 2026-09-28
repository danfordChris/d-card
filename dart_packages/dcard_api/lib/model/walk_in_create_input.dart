//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class WalkInCreateInput {
  /// Returns a new [WalkInCreateInput] instance.
  WalkInCreateInput({
    required this.id,
    required this.deviceId,
    required this.description,
    this.invitationId,
    required this.admittedCount,
  });

  String id;

  String deviceId;

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

  @override
  bool operator ==(Object other) => identical(this, other) || other is WalkInCreateInput &&
    other.id == id &&
    other.deviceId == deviceId &&
    other.description == description &&
    other.invitationId == invitationId &&
    other.admittedCount == admittedCount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (deviceId.hashCode) +
    (description.hashCode) +
    (invitationId == null ? 0 : invitationId!.hashCode) +
    (admittedCount.hashCode);

  @override
  String toString() => 'WalkInCreateInput[id=$id, deviceId=$deviceId, description=$description, invitationId=$invitationId, admittedCount=$admittedCount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'deviceId'] = this.deviceId;
      json[r'description'] = this.description;
    if (this.invitationId != null) {
      json[r'invitationId'] = this.invitationId;
    } else {
      json[r'invitationId'] = null;
    }
      json[r'admittedCount'] = this.admittedCount;
    return json;
  }

  /// Returns a new [WalkInCreateInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WalkInCreateInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "WalkInCreateInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return WalkInCreateInput(
        id: mapValueOfType<String>(json, r'id')!,
        deviceId: mapValueOfType<String>(json, r'deviceId')!,
        description: mapValueOfType<String>(json, r'description')!,
        invitationId: mapValueOfType<String>(json, r'invitationId'),
        admittedCount: mapValueOfType<int>(json, r'admittedCount')!,
      );
    }
    return null;
  }

  static List<WalkInCreateInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WalkInCreateInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WalkInCreateInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WalkInCreateInput> mapFromJson(dynamic json) {
    final map = <String, WalkInCreateInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WalkInCreateInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WalkInCreateInput-objects as value to a dart map
  static Map<String, List<WalkInCreateInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WalkInCreateInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WalkInCreateInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'deviceId',
    'description',
    'admittedCount',
  };
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class UpdateMessageSettingsRequestSettingsInnerSchedule {
  /// Returns a new [UpdateMessageSettingsRequestSettingsInnerSchedule] instance.
  UpdateMessageSettingsRequestSettingsInnerSchedule({
    this.offsetDays,
    this.timeOfDay,
    this.frequencyDays,
    this.maxCount,
    this.stopOffsetDays,
  });

  /// Minimum value: -30
  /// Maximum value: 30
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? offsetDays;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? timeOfDay;

  /// Minimum value: 1
  /// Maximum value: 60
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? frequencyDays;

  /// Minimum value: 1
  /// Maximum value: 20
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? maxCount;

  /// Minimum value: 0
  /// Maximum value: 90
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? stopOffsetDays;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateMessageSettingsRequestSettingsInnerSchedule &&
    other.offsetDays == offsetDays &&
    other.timeOfDay == timeOfDay &&
    other.frequencyDays == frequencyDays &&
    other.maxCount == maxCount &&
    other.stopOffsetDays == stopOffsetDays;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (offsetDays == null ? 0 : offsetDays!.hashCode) +
    (timeOfDay == null ? 0 : timeOfDay!.hashCode) +
    (frequencyDays == null ? 0 : frequencyDays!.hashCode) +
    (maxCount == null ? 0 : maxCount!.hashCode) +
    (stopOffsetDays == null ? 0 : stopOffsetDays!.hashCode);

  @override
  String toString() => 'UpdateMessageSettingsRequestSettingsInnerSchedule[offsetDays=$offsetDays, timeOfDay=$timeOfDay, frequencyDays=$frequencyDays, maxCount=$maxCount, stopOffsetDays=$stopOffsetDays]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.offsetDays != null) {
      json[r'offsetDays'] = this.offsetDays;
    } else {
      json[r'offsetDays'] = null;
    }
    if (this.timeOfDay != null) {
      json[r'timeOfDay'] = this.timeOfDay;
    } else {
      json[r'timeOfDay'] = null;
    }
    if (this.frequencyDays != null) {
      json[r'frequencyDays'] = this.frequencyDays;
    } else {
      json[r'frequencyDays'] = null;
    }
    if (this.maxCount != null) {
      json[r'maxCount'] = this.maxCount;
    } else {
      json[r'maxCount'] = null;
    }
    if (this.stopOffsetDays != null) {
      json[r'stopOffsetDays'] = this.stopOffsetDays;
    } else {
      json[r'stopOffsetDays'] = null;
    }
    return json;
  }

  /// Returns a new [UpdateMessageSettingsRequestSettingsInnerSchedule] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateMessageSettingsRequestSettingsInnerSchedule? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdateMessageSettingsRequestSettingsInnerSchedule[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdateMessageSettingsRequestSettingsInnerSchedule[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateMessageSettingsRequestSettingsInnerSchedule(
        offsetDays: mapValueOfType<int>(json, r'offsetDays'),
        timeOfDay: mapValueOfType<String>(json, r'timeOfDay'),
        frequencyDays: mapValueOfType<int>(json, r'frequencyDays'),
        maxCount: mapValueOfType<int>(json, r'maxCount'),
        stopOffsetDays: mapValueOfType<int>(json, r'stopOffsetDays'),
      );
    }
    return null;
  }

  static List<UpdateMessageSettingsRequestSettingsInnerSchedule> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateMessageSettingsRequestSettingsInnerSchedule>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateMessageSettingsRequestSettingsInnerSchedule.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateMessageSettingsRequestSettingsInnerSchedule> mapFromJson(dynamic json) {
    final map = <String, UpdateMessageSettingsRequestSettingsInnerSchedule>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateMessageSettingsRequestSettingsInnerSchedule.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateMessageSettingsRequestSettingsInnerSchedule-objects as value to a dart map
  static Map<String, List<UpdateMessageSettingsRequestSettingsInnerSchedule>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateMessageSettingsRequestSettingsInnerSchedule>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateMessageSettingsRequestSettingsInnerSchedule.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class InviteInfo {
  /// Returns a new [InviteInfo] instance.
  InviteInfo({
    required this.eventId,
    required this.eventTitle,
    required this.role,
    required this.expiresAt,
  });

  String eventId;

  String eventTitle;

  TeamRole role;

  DateTime expiresAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InviteInfo &&
    other.eventId == eventId &&
    other.eventTitle == eventTitle &&
    other.role == role &&
    other.expiresAt == expiresAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (eventId.hashCode) +
    (eventTitle.hashCode) +
    (role.hashCode) +
    (expiresAt.hashCode);

  @override
  String toString() => 'InviteInfo[eventId=$eventId, eventTitle=$eventTitle, role=$role, expiresAt=$expiresAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'eventId'] = this.eventId;
      json[r'eventTitle'] = this.eventTitle;
      json[r'role'] = this.role;
      json[r'expiresAt'] = this.expiresAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [InviteInfo] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InviteInfo? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "InviteInfo[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "InviteInfo[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return InviteInfo(
        eventId: mapValueOfType<String>(json, r'eventId')!,
        eventTitle: mapValueOfType<String>(json, r'eventTitle')!,
        role: TeamRole.fromJson(json[r'role'])!,
        expiresAt: mapDateTime(json, r'expiresAt', r'')!,
      );
    }
    return null;
  }

  static List<InviteInfo> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InviteInfo>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InviteInfo.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InviteInfo> mapFromJson(dynamic json) {
    final map = <String, InviteInfo>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InviteInfo.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InviteInfo-objects as value to a dart map
  static Map<String, List<InviteInfo>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InviteInfo>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InviteInfo.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'eventId',
    'eventTitle',
    'role',
    'expiresAt',
  };
}


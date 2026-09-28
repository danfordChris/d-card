//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class TeamMembersInner {
  /// Returns a new [TeamMembersInner] instance.
  TeamMembersInner({
    required this.userId,
    required this.email,
    required this.role,
    required this.since,
  });

  String userId;

  String? email;

  TeamRole role;

  DateTime since;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TeamMembersInner &&
    other.userId == userId &&
    other.email == email &&
    other.role == role &&
    other.since == since;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (userId.hashCode) +
    (email == null ? 0 : email!.hashCode) +
    (role.hashCode) +
    (since.hashCode);

  @override
  String toString() => 'TeamMembersInner[userId=$userId, email=$email, role=$role, since=$since]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'userId'] = this.userId;
    if (this.email != null) {
      json[r'email'] = this.email;
    } else {
      json[r'email'] = null;
    }
      json[r'role'] = this.role;
      json[r'since'] = this.since.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [TeamMembersInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TeamMembersInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TeamMembersInner[$key]" is missing from JSON.');
        });
        return true;
      }());

      return TeamMembersInner(
        userId: mapValueOfType<String>(json, r'userId')!,
        email: mapValueOfType<String>(json, r'email'),
        role: TeamRole.fromJson(json[r'role'])!,
        since: mapDateTime(json, r'since', r'')!,
      );
    }
    return null;
  }

  static List<TeamMembersInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TeamMembersInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TeamMembersInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TeamMembersInner> mapFromJson(dynamic json) {
    final map = <String, TeamMembersInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TeamMembersInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TeamMembersInner-objects as value to a dart map
  static Map<String, List<TeamMembersInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TeamMembersInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TeamMembersInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'userId',
    'email',
    'role',
    'since',
  };
}


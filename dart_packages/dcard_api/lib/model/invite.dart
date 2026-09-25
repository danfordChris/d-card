//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class Invite {
  /// Returns a new [Invite] instance.
  Invite({
    required this.id,
    required this.eventId,
    required this.role,
    required this.email,
    required this.expiresAt,
    required this.createdAt,
  });

  String id;

  String eventId;

  TeamRole role;

  String? email;

  DateTime expiresAt;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Invite &&
    other.id == id &&
    other.eventId == eventId &&
    other.role == role &&
    other.email == email &&
    other.expiresAt == expiresAt &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (eventId.hashCode) +
    (role.hashCode) +
    (email == null ? 0 : email!.hashCode) +
    (expiresAt.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'Invite[id=$id, eventId=$eventId, role=$role, email=$email, expiresAt=$expiresAt, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'eventId'] = this.eventId;
      json[r'role'] = this.role;
    if (this.email != null) {
      json[r'email'] = this.email;
    } else {
      json[r'email'] = null;
    }
      json[r'expiresAt'] = this.expiresAt.toUtc().toIso8601String();
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Invite] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Invite? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Invite[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Invite[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Invite(
        id: mapValueOfType<String>(json, r'id')!,
        eventId: mapValueOfType<String>(json, r'eventId')!,
        role: TeamRole.fromJson(json[r'role'])!,
        email: mapValueOfType<String>(json, r'email'),
        expiresAt: mapDateTime(json, r'expiresAt', r'')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<Invite> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Invite>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Invite.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Invite> mapFromJson(dynamic json) {
    final map = <String, Invite>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Invite.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Invite-objects as value to a dart map
  static Map<String, List<Invite>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Invite>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Invite.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'eventId',
    'role',
    'email',
    'expiresAt',
    'createdAt',
  };
}


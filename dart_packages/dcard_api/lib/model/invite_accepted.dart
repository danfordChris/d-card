//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class InviteAccepted {
  /// Returns a new [InviteAccepted] instance.
  InviteAccepted({
    required this.eventId,
    required this.role,
  });

  String eventId;

  TeamRole role;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InviteAccepted &&
    other.eventId == eventId &&
    other.role == role;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (eventId.hashCode) +
    (role.hashCode);

  @override
  String toString() => 'InviteAccepted[eventId=$eventId, role=$role]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'eventId'] = this.eventId;
      json[r'role'] = this.role;
    return json;
  }

  /// Returns a new [InviteAccepted] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InviteAccepted? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "InviteAccepted[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "InviteAccepted[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return InviteAccepted(
        eventId: mapValueOfType<String>(json, r'eventId')!,
        role: TeamRole.fromJson(json[r'role'])!,
      );
    }
    return null;
  }

  static List<InviteAccepted> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InviteAccepted>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InviteAccepted.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InviteAccepted> mapFromJson(dynamic json) {
    final map = <String, InviteAccepted>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InviteAccepted.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InviteAccepted-objects as value to a dart map
  static Map<String, List<InviteAccepted>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InviteAccepted>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InviteAccepted.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'eventId',
    'role',
  };
}


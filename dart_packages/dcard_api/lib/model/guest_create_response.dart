//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class GuestCreateResponse {
  /// Returns a new [GuestCreateResponse] instance.
  GuestCreateResponse({
    required this.guest,
    required this.existing,
  });

  Guest guest;

  bool existing;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GuestCreateResponse &&
    other.guest == guest &&
    other.existing == existing;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (guest.hashCode) +
    (existing.hashCode);

  @override
  String toString() => 'GuestCreateResponse[guest=$guest, existing=$existing]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'guest'] = this.guest;
      json[r'existing'] = this.existing;
    return json;
  }

  /// Returns a new [GuestCreateResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GuestCreateResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GuestCreateResponse[$key]" is missing from JSON.');
        });
        return true;
      }());

      return GuestCreateResponse(
        guest: Guest.fromJson(json[r'guest'])!,
        existing: mapValueOfType<bool>(json, r'existing')!,
      );
    }
    return null;
  }

  static List<GuestCreateResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GuestCreateResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GuestCreateResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GuestCreateResponse> mapFromJson(dynamic json) {
    final map = <String, GuestCreateResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GuestCreateResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GuestCreateResponse-objects as value to a dart map
  static Map<String, List<GuestCreateResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GuestCreateResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GuestCreateResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'guest',
    'existing',
  };
}


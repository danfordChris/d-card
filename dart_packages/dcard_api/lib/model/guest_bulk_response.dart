//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class GuestBulkResponse {
  /// Returns a new [GuestBulkResponse] instance.
  GuestBulkResponse({
    this.added = const [],
    this.existing = const [],
    this.invalid = const [],
  });

  List<Guest> added;

  List<Guest> existing;

  List<GuestBulkResponseInvalidInner> invalid;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GuestBulkResponse &&
    _deepEquality.equals(other.added, added) &&
    _deepEquality.equals(other.existing, existing) &&
    _deepEquality.equals(other.invalid, invalid);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (added.hashCode) +
    (existing.hashCode) +
    (invalid.hashCode);

  @override
  String toString() => 'GuestBulkResponse[added=$added, existing=$existing, invalid=$invalid]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'added'] = this.added;
      json[r'existing'] = this.existing;
      json[r'invalid'] = this.invalid;
    return json;
  }

  /// Returns a new [GuestBulkResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GuestBulkResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GuestBulkResponse[$key]" is missing from JSON.');
        });
        return true;
      }());

      return GuestBulkResponse(
        added: Guest.listFromJson(json[r'added']),
        existing: Guest.listFromJson(json[r'existing']),
        invalid: GuestBulkResponseInvalidInner.listFromJson(json[r'invalid']),
      );
    }
    return null;
  }

  static List<GuestBulkResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GuestBulkResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GuestBulkResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GuestBulkResponse> mapFromJson(dynamic json) {
    final map = <String, GuestBulkResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GuestBulkResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GuestBulkResponse-objects as value to a dart map
  static Map<String, List<GuestBulkResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GuestBulkResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GuestBulkResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'added',
    'existing',
    'invalid',
  };
}


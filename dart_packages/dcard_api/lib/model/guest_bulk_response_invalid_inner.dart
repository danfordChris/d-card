//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class GuestBulkResponseInvalidInner {
  /// Returns a new [GuestBulkResponseInvalidInner] instance.
  GuestBulkResponseInvalidInner({
    required this.index,
    required this.phone,
    required this.reason,
  });

  int index;

  String phone;

  String reason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GuestBulkResponseInvalidInner &&
    other.index == index &&
    other.phone == phone &&
    other.reason == reason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (index.hashCode) +
    (phone.hashCode) +
    (reason.hashCode);

  @override
  String toString() => 'GuestBulkResponseInvalidInner[index=$index, phone=$phone, reason=$reason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'index'] = this.index;
      json[r'phone'] = this.phone;
      json[r'reason'] = this.reason;
    return json;
  }

  /// Returns a new [GuestBulkResponseInvalidInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GuestBulkResponseInvalidInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GuestBulkResponseInvalidInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GuestBulkResponseInvalidInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GuestBulkResponseInvalidInner(
        index: mapValueOfType<int>(json, r'index')!,
        phone: mapValueOfType<String>(json, r'phone')!,
        reason: mapValueOfType<String>(json, r'reason')!,
      );
    }
    return null;
  }

  static List<GuestBulkResponseInvalidInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GuestBulkResponseInvalidInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GuestBulkResponseInvalidInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GuestBulkResponseInvalidInner> mapFromJson(dynamic json) {
    final map = <String, GuestBulkResponseInvalidInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GuestBulkResponseInvalidInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GuestBulkResponseInvalidInner-objects as value to a dart map
  static Map<String, List<GuestBulkResponseInvalidInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GuestBulkResponseInvalidInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GuestBulkResponseInvalidInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'index',
    'phone',
    'reason',
  };
}


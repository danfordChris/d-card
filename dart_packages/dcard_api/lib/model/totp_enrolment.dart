//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class TotpEnrolment {
  /// Returns a new [TotpEnrolment] instance.
  TotpEnrolment({
    required this.secret,
    required this.otpauthUri,
  });

  String secret;

  String otpauthUri;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TotpEnrolment &&
    other.secret == secret &&
    other.otpauthUri == otpauthUri;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (secret.hashCode) +
    (otpauthUri.hashCode);

  @override
  String toString() => 'TotpEnrolment[secret=$secret, otpauthUri=$otpauthUri]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'secret'] = this.secret;
      json[r'otpauthUri'] = this.otpauthUri;
    return json;
  }

  /// Returns a new [TotpEnrolment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TotpEnrolment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TotpEnrolment[$key]" is missing from JSON.');
        });
        return true;
      }());

      return TotpEnrolment(
        secret: mapValueOfType<String>(json, r'secret')!,
        otpauthUri: mapValueOfType<String>(json, r'otpauthUri')!,
      );
    }
    return null;
  }

  static List<TotpEnrolment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TotpEnrolment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TotpEnrolment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TotpEnrolment> mapFromJson(dynamic json) {
    final map = <String, TotpEnrolment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TotpEnrolment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TotpEnrolment-objects as value to a dart map
  static Map<String, List<TotpEnrolment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TotpEnrolment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TotpEnrolment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'secret',
    'otpauthUri',
  };
}


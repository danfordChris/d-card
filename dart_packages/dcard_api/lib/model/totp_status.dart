//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class TotpStatus {
  /// Returns a new [TotpStatus] instance.
  TotpStatus({
    required this.enrolled,
    required this.verified,
    required this.recoveryCodesLeft,
  });

  bool enrolled;

  bool verified;

  int recoveryCodesLeft;

  @override
  bool operator ==(Object other) => identical(this, other) || other is TotpStatus &&
    other.enrolled == enrolled &&
    other.verified == verified &&
    other.recoveryCodesLeft == recoveryCodesLeft;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (enrolled.hashCode) +
    (verified.hashCode) +
    (recoveryCodesLeft.hashCode);

  @override
  String toString() => 'TotpStatus[enrolled=$enrolled, verified=$verified, recoveryCodesLeft=$recoveryCodesLeft]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'enrolled'] = this.enrolled;
      json[r'verified'] = this.verified;
      json[r'recoveryCodesLeft'] = this.recoveryCodesLeft;
    return json;
  }

  /// Returns a new [TotpStatus] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static TotpStatus? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "TotpStatus[$key]" is missing from JSON.');
        });
        return true;
      }());

      return TotpStatus(
        enrolled: mapValueOfType<bool>(json, r'enrolled')!,
        verified: mapValueOfType<bool>(json, r'verified')!,
        recoveryCodesLeft: mapValueOfType<int>(json, r'recoveryCodesLeft')!,
      );
    }
    return null;
  }

  static List<TotpStatus> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TotpStatus>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TotpStatus.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, TotpStatus> mapFromJson(dynamic json) {
    final map = <String, TotpStatus>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = TotpStatus.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of TotpStatus-objects as value to a dart map
  static Map<String, List<TotpStatus>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<TotpStatus>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = TotpStatus.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'enrolled',
    'verified',
    'recoveryCodesLeft',
  };
}


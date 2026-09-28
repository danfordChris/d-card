//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class LinkCardResult {
  /// Returns a new [LinkCardResult] instance.
  LinkCardResult({
    required this.linked,
  });

  bool linked;

  @override
  bool operator ==(Object other) => identical(this, other) || other is LinkCardResult &&
    other.linked == linked;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (linked.hashCode);

  @override
  String toString() => 'LinkCardResult[linked=$linked]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'linked'] = this.linked;
    return json;
  }

  /// Returns a new [LinkCardResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static LinkCardResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "LinkCardResult[$key]" is missing from JSON.');
        });
        return true;
      }());

      return LinkCardResult(
        linked: mapValueOfType<bool>(json, r'linked')!,
      );
    }
    return null;
  }

  static List<LinkCardResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <LinkCardResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = LinkCardResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, LinkCardResult> mapFromJson(dynamic json) {
    final map = <String, LinkCardResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = LinkCardResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of LinkCardResult-objects as value to a dart map
  static Map<String, List<LinkCardResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<LinkCardResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = LinkCardResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'linked',
  };
}


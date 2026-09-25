//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class ImportResult {
  /// Returns a new [ImportResult] instance.
  ImportResult({
    required this.imported,
    required this.existing,
    required this.invalid,
  });

  int imported;

  int existing;

  int invalid;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ImportResult &&
    other.imported == imported &&
    other.existing == existing &&
    other.invalid == invalid;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (imported.hashCode) +
    (existing.hashCode) +
    (invalid.hashCode);

  @override
  String toString() => 'ImportResult[imported=$imported, existing=$existing, invalid=$invalid]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'imported'] = this.imported;
      json[r'existing'] = this.existing;
      json[r'invalid'] = this.invalid;
    return json;
  }

  /// Returns a new [ImportResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ImportResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ImportResult[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ImportResult[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ImportResult(
        imported: mapValueOfType<int>(json, r'imported')!,
        existing: mapValueOfType<int>(json, r'existing')!,
        invalid: mapValueOfType<int>(json, r'invalid')!,
      );
    }
    return null;
  }

  static List<ImportResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ImportResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ImportResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ImportResult> mapFromJson(dynamic json) {
    final map = <String, ImportResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ImportResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ImportResult-objects as value to a dart map
  static Map<String, List<ImportResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ImportResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ImportResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'imported',
    'existing',
    'invalid',
  };
}


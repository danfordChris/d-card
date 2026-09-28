//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class ImportConfirmInput {
  /// Returns a new [ImportConfirmInput] instance.
  ImportConfirmInput({
    required this.consent,
  });

  bool consent;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ImportConfirmInput &&
    other.consent == consent;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (consent.hashCode);

  @override
  String toString() => 'ImportConfirmInput[consent=$consent]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'consent'] = this.consent;
    return json;
  }

  /// Returns a new [ImportConfirmInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ImportConfirmInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ImportConfirmInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return ImportConfirmInput(
        consent: mapValueOfType<bool>(json, r'consent')!,
      );
    }
    return null;
  }

  static List<ImportConfirmInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ImportConfirmInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ImportConfirmInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ImportConfirmInput> mapFromJson(dynamic json) {
    final map = <String, ImportConfirmInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ImportConfirmInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ImportConfirmInput-objects as value to a dart map
  static Map<String, List<ImportConfirmInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ImportConfirmInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ImportConfirmInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'consent',
  };
}


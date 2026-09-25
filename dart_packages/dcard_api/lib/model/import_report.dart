//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class ImportReport {
  /// Returns a new [ImportReport] instance.
  ImportReport({
    required this.total,
    required this.valid,
    this.invalid = const [],
    this.duplicatesInFile = const [],
    this.existing = const [],
  });

  int total;

  int valid;

  List<ImportReportInvalidInner> invalid;

  List<ImportReportDuplicatesInFileInner> duplicatesInFile;

  List<ImportReportExistingInner> existing;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ImportReport &&
    other.total == total &&
    other.valid == valid &&
    _deepEquality.equals(other.invalid, invalid) &&
    _deepEquality.equals(other.duplicatesInFile, duplicatesInFile) &&
    _deepEquality.equals(other.existing, existing);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (total.hashCode) +
    (valid.hashCode) +
    (invalid.hashCode) +
    (duplicatesInFile.hashCode) +
    (existing.hashCode);

  @override
  String toString() => 'ImportReport[total=$total, valid=$valid, invalid=$invalid, duplicatesInFile=$duplicatesInFile, existing=$existing]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'total'] = this.total;
      json[r'valid'] = this.valid;
      json[r'invalid'] = this.invalid;
      json[r'duplicatesInFile'] = this.duplicatesInFile;
      json[r'existing'] = this.existing;
    return json;
  }

  /// Returns a new [ImportReport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ImportReport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ImportReport[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ImportReport[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ImportReport(
        total: mapValueOfType<int>(json, r'total')!,
        valid: mapValueOfType<int>(json, r'valid')!,
        invalid: ImportReportInvalidInner.listFromJson(json[r'invalid']),
        duplicatesInFile: ImportReportDuplicatesInFileInner.listFromJson(json[r'duplicatesInFile']),
        existing: ImportReportExistingInner.listFromJson(json[r'existing']),
      );
    }
    return null;
  }

  static List<ImportReport> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ImportReport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ImportReport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ImportReport> mapFromJson(dynamic json) {
    final map = <String, ImportReport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ImportReport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ImportReport-objects as value to a dart map
  static Map<String, List<ImportReport>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ImportReport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ImportReport.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'total',
    'valid',
    'invalid',
    'duplicatesInFile',
    'existing',
  };
}


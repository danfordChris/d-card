//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class ImportPreview {
  /// Returns a new [ImportPreview] instance.
  ImportPreview({
    required this.jobId,
    required this.report,
  });

  String jobId;

  ImportReport report;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ImportPreview &&
    other.jobId == jobId &&
    other.report == report;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (jobId.hashCode) +
    (report.hashCode);

  @override
  String toString() => 'ImportPreview[jobId=$jobId, report=$report]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'jobId'] = this.jobId;
      json[r'report'] = this.report;
    return json;
  }

  /// Returns a new [ImportPreview] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ImportPreview? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ImportPreview[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ImportPreview[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ImportPreview(
        jobId: mapValueOfType<String>(json, r'jobId')!,
        report: ImportReport.fromJson(json[r'report'])!,
      );
    }
    return null;
  }

  static List<ImportPreview> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ImportPreview>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ImportPreview.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ImportPreview> mapFromJson(dynamic json) {
    final map = <String, ImportPreview>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ImportPreview.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ImportPreview-objects as value to a dart map
  static Map<String, List<ImportPreview>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ImportPreview>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ImportPreview.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'jobId',
    'report',
  };
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class ImportReportDuplicatesInFileInner {
  /// Returns a new [ImportReportDuplicatesInFileInner] instance.
  ImportReportDuplicatesInFileInner({
    required this.row,
    required this.phone,
    required this.firstRow,
  });

  int row;

  String phone;

  int firstRow;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ImportReportDuplicatesInFileInner &&
    other.row == row &&
    other.phone == phone &&
    other.firstRow == firstRow;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (row.hashCode) +
    (phone.hashCode) +
    (firstRow.hashCode);

  @override
  String toString() => 'ImportReportDuplicatesInFileInner[row=$row, phone=$phone, firstRow=$firstRow]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'row'] = this.row;
      json[r'phone'] = this.phone;
      json[r'firstRow'] = this.firstRow;
    return json;
  }

  /// Returns a new [ImportReportDuplicatesInFileInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ImportReportDuplicatesInFileInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ImportReportDuplicatesInFileInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ImportReportDuplicatesInFileInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ImportReportDuplicatesInFileInner(
        row: mapValueOfType<int>(json, r'row')!,
        phone: mapValueOfType<String>(json, r'phone')!,
        firstRow: mapValueOfType<int>(json, r'firstRow')!,
      );
    }
    return null;
  }

  static List<ImportReportDuplicatesInFileInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ImportReportDuplicatesInFileInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ImportReportDuplicatesInFileInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ImportReportDuplicatesInFileInner> mapFromJson(dynamic json) {
    final map = <String, ImportReportDuplicatesInFileInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ImportReportDuplicatesInFileInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ImportReportDuplicatesInFileInner-objects as value to a dart map
  static Map<String, List<ImportReportDuplicatesInFileInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ImportReportDuplicatesInFileInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ImportReportDuplicatesInFileInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'row',
    'phone',
    'firstRow',
  };
}


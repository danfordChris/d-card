//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class ImportReportInvalidInner {
  /// Returns a new [ImportReportInvalidInner] instance.
  ImportReportInvalidInner({
    required this.row,
    required this.phone,
    required this.reason,
  });

  int row;

  String phone;

  ImportReportInvalidInnerReasonEnum reason;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ImportReportInvalidInner &&
    other.row == row &&
    other.phone == phone &&
    other.reason == reason;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (row.hashCode) +
    (phone.hashCode) +
    (reason.hashCode);

  @override
  String toString() => 'ImportReportInvalidInner[row=$row, phone=$phone, reason=$reason]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'row'] = this.row;
      json[r'phone'] = this.phone;
      json[r'reason'] = this.reason;
    return json;
  }

  /// Returns a new [ImportReportInvalidInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ImportReportInvalidInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ImportReportInvalidInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ImportReportInvalidInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ImportReportInvalidInner(
        row: mapValueOfType<int>(json, r'row')!,
        phone: mapValueOfType<String>(json, r'phone')!,
        reason: ImportReportInvalidInnerReasonEnum.fromJson(json[r'reason'])!,
      );
    }
    return null;
  }

  static List<ImportReportInvalidInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ImportReportInvalidInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ImportReportInvalidInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ImportReportInvalidInner> mapFromJson(dynamic json) {
    final map = <String, ImportReportInvalidInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ImportReportInvalidInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ImportReportInvalidInner-objects as value to a dart map
  static Map<String, List<ImportReportInvalidInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ImportReportInvalidInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ImportReportInvalidInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'row',
    'phone',
    'reason',
  };
}


class ImportReportInvalidInnerReasonEnum {
  /// Instantiate a new enum with the provided [value].
  const ImportReportInvalidInnerReasonEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const invalidPhone = ImportReportInvalidInnerReasonEnum._(r'invalid_phone');
  static const nameRequired = ImportReportInvalidInnerReasonEnum._(r'name_required');
  static const invalidCardType = ImportReportInvalidInnerReasonEnum._(r'invalid_card_type');

  /// List of all possible values in this [enum][ImportReportInvalidInnerReasonEnum].
  static const values = <ImportReportInvalidInnerReasonEnum>[
    invalidPhone,
    nameRequired,
    invalidCardType,
  ];

  static ImportReportInvalidInnerReasonEnum? fromJson(dynamic value) => ImportReportInvalidInnerReasonEnumTypeTransformer().decode(value);

  static List<ImportReportInvalidInnerReasonEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ImportReportInvalidInnerReasonEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ImportReportInvalidInnerReasonEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ImportReportInvalidInnerReasonEnum] to String,
/// and [decode] dynamic data back to [ImportReportInvalidInnerReasonEnum].
class ImportReportInvalidInnerReasonEnumTypeTransformer {
  factory ImportReportInvalidInnerReasonEnumTypeTransformer() => _instance ??= const ImportReportInvalidInnerReasonEnumTypeTransformer._();

  const ImportReportInvalidInnerReasonEnumTypeTransformer._();

  String encode(ImportReportInvalidInnerReasonEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ImportReportInvalidInnerReasonEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ImportReportInvalidInnerReasonEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'invalid_phone': return ImportReportInvalidInnerReasonEnum.invalidPhone;
        case r'name_required': return ImportReportInvalidInnerReasonEnum.nameRequired;
        case r'invalid_card_type': return ImportReportInvalidInnerReasonEnum.invalidCardType;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ImportReportInvalidInnerReasonEnumTypeTransformer] instance.
  static ImportReportInvalidInnerReasonEnumTypeTransformer? _instance;
}



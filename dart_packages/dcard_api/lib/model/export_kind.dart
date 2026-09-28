//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;


class ExportKind {
  /// Instantiate a new enum with the provided [value].
  const ExportKind._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const guests = ExportKind._(r'guests');
  static const contributions = ExportKind._(r'contributions');
  static const attendance = ExportKind._(r'attendance');

  /// List of all possible values in this [enum][ExportKind].
  static const values = <ExportKind>[
    guests,
    contributions,
    attendance,
  ];

  static ExportKind? fromJson(dynamic value) => ExportKindTypeTransformer().decode(value);

  static List<ExportKind> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ExportKind>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ExportKind.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ExportKind] to String,
/// and [decode] dynamic data back to [ExportKind].
class ExportKindTypeTransformer {
  factory ExportKindTypeTransformer() => _instance ??= const ExportKindTypeTransformer._();

  const ExportKindTypeTransformer._();

  String encode(ExportKind data) => data.value;

  /// Decodes a [dynamic value][data] to a ExportKind.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ExportKind? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'guests': return ExportKind.guests;
        case r'contributions': return ExportKind.contributions;
        case r'attendance': return ExportKind.attendance;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ExportKindTypeTransformer] instance.
  static ExportKindTypeTransformer? _instance;
}


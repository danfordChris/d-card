//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;


class CheckInMethod {
  /// Instantiate a new enum with the provided [value].
  const CheckInMethod._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const qr = CheckInMethod._(r'qr');
  static const cardNumber = CheckInMethod._(r'card_number');
  static const name = CheckInMethod._(r'name');

  /// List of all possible values in this [enum][CheckInMethod].
  static const values = <CheckInMethod>[
    qr,
    cardNumber,
    name,
  ];

  static CheckInMethod? fromJson(dynamic value) => CheckInMethodTypeTransformer().decode(value);

  static List<CheckInMethod> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CheckInMethod>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CheckInMethod.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CheckInMethod] to String,
/// and [decode] dynamic data back to [CheckInMethod].
class CheckInMethodTypeTransformer {
  factory CheckInMethodTypeTransformer() => _instance ??= const CheckInMethodTypeTransformer._();

  const CheckInMethodTypeTransformer._();

  String encode(CheckInMethod data) => data.value;

  /// Decodes a [dynamic value][data] to a CheckInMethod.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CheckInMethod? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'qr': return CheckInMethod.qr;
        case r'card_number': return CheckInMethod.cardNumber;
        case r'name': return CheckInMethod.name;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CheckInMethodTypeTransformer] instance.
  static CheckInMethodTypeTransformer? _instance;
}


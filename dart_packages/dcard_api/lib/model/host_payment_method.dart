//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;


class HostPaymentMethod {
  /// Instantiate a new enum with the provided [value].
  const HostPaymentMethod._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const mobile = HostPaymentMethod._(r'mobile');
  static const session = HostPaymentMethod._(r'session');

  /// List of all possible values in this [enum][HostPaymentMethod].
  static const values = <HostPaymentMethod>[
    mobile,
    session,
  ];

  static HostPaymentMethod? fromJson(dynamic value) => HostPaymentMethodTypeTransformer().decode(value);

  static List<HostPaymentMethod> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <HostPaymentMethod>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = HostPaymentMethod.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [HostPaymentMethod] to String,
/// and [decode] dynamic data back to [HostPaymentMethod].
class HostPaymentMethodTypeTransformer {
  factory HostPaymentMethodTypeTransformer() => _instance ??= const HostPaymentMethodTypeTransformer._();

  const HostPaymentMethodTypeTransformer._();

  String encode(HostPaymentMethod data) => data.value;

  /// Decodes a [dynamic value][data] to a HostPaymentMethod.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  HostPaymentMethod? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'mobile': return HostPaymentMethod.mobile;
        case r'session': return HostPaymentMethod.session;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [HostPaymentMethodTypeTransformer] instance.
  static HostPaymentMethodTypeTransformer? _instance;
}


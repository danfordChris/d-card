//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;


class CardType {
  /// Instantiate a new enum with the provided [value].
  const CardType._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const single = CardType._(r'single');
  static const double_ = CardType._(r'double');

  /// List of all possible values in this [enum][CardType].
  static const values = <CardType>[
    single,
    double_,
  ];

  static CardType? fromJson(dynamic value) => CardTypeTypeTransformer().decode(value);

  static List<CardType> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CardType>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CardType.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CardType] to String,
/// and [decode] dynamic data back to [CardType].
class CardTypeTypeTransformer {
  factory CardTypeTypeTransformer() => _instance ??= const CardTypeTypeTransformer._();

  const CardTypeTypeTransformer._();

  String encode(CardType data) => data.value;

  /// Decodes a [dynamic value][data] to a CardType.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CardType? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'single': return CardType.single;
        case r'double': return CardType.double_;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CardTypeTypeTransformer] instance.
  static CardTypeTypeTransformer? _instance;
}


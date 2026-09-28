//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;


class PlanKey {
  /// Instantiate a new enum with the provided [value].
  const PlanKey._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const msingi = PlanKey._(r'msingi');
  static const kawaida = PlanKey._(r'kawaida');
  static const premium = PlanKey._(r'premium');

  /// List of all possible values in this [enum][PlanKey].
  static const values = <PlanKey>[
    msingi,
    kawaida,
    premium,
  ];

  static PlanKey? fromJson(dynamic value) => PlanKeyTypeTransformer().decode(value);

  static List<PlanKey> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PlanKey>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PlanKey.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PlanKey] to String,
/// and [decode] dynamic data back to [PlanKey].
class PlanKeyTypeTransformer {
  factory PlanKeyTypeTransformer() => _instance ??= const PlanKeyTypeTransformer._();

  const PlanKeyTypeTransformer._();

  String encode(PlanKey data) => data.value;

  /// Decodes a [dynamic value][data] to a PlanKey.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PlanKey? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'msingi': return PlanKey.msingi;
        case r'kawaida': return PlanKey.kawaida;
        case r'premium': return PlanKey.premium;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [PlanKeyTypeTransformer] instance.
  static PlanKeyTypeTransformer? _instance;
}


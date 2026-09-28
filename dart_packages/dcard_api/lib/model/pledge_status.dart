//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;


class PledgeStatus {
  /// Instantiate a new enum with the provided [value].
  const PledgeStatus._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const notPaid = PledgeStatus._(r'not_paid');
  static const partPaid = PledgeStatus._(r'part_paid');
  static const fullyPaid = PledgeStatus._(r'fully_paid');

  /// List of all possible values in this [enum][PledgeStatus].
  static const values = <PledgeStatus>[
    notPaid,
    partPaid,
    fullyPaid,
  ];

  static PledgeStatus? fromJson(dynamic value) => PledgeStatusTypeTransformer().decode(value);

  static List<PledgeStatus> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PledgeStatus>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PledgeStatus.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PledgeStatus] to String,
/// and [decode] dynamic data back to [PledgeStatus].
class PledgeStatusTypeTransformer {
  factory PledgeStatusTypeTransformer() => _instance ??= const PledgeStatusTypeTransformer._();

  const PledgeStatusTypeTransformer._();

  String encode(PledgeStatus data) => data.value;

  /// Decodes a [dynamic value][data] to a PledgeStatus.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PledgeStatus? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'not_paid': return PledgeStatus.notPaid;
        case r'part_paid': return PledgeStatus.partPaid;
        case r'fully_paid': return PledgeStatus.fullyPaid;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [PledgeStatusTypeTransformer] instance.
  static PledgeStatusTypeTransformer? _instance;
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;


class SharingMode {
  /// Instantiate a new enum with the provided [value].
  const SharingMode._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const private = SharingMode._(r'private');
  static const link = SharingMode._(r'link');

  /// List of all possible values in this [enum][SharingMode].
  static const values = <SharingMode>[
    private,
    link,
  ];

  static SharingMode? fromJson(dynamic value) => SharingModeTypeTransformer().decode(value);

  static List<SharingMode> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SharingMode>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SharingMode.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SharingMode] to String,
/// and [decode] dynamic data back to [SharingMode].
class SharingModeTypeTransformer {
  factory SharingModeTypeTransformer() => _instance ??= const SharingModeTypeTransformer._();

  const SharingModeTypeTransformer._();

  String encode(SharingMode data) => data.value;

  /// Decodes a [dynamic value][data] to a SharingMode.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SharingMode? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'private': return SharingMode.private;
        case r'link': return SharingMode.link;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SharingModeTypeTransformer] instance.
  static SharingModeTypeTransformer? _instance;
}


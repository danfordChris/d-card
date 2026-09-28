//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;


class DeviceApp {
  /// Instantiate a new enum with the provided [value].
  const DeviceApp._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const mobile = DeviceApp._(r'mobile');
  static const door = DeviceApp._(r'door');

  /// List of all possible values in this [enum][DeviceApp].
  static const values = <DeviceApp>[
    mobile,
    door,
  ];

  static DeviceApp? fromJson(dynamic value) => DeviceAppTypeTransformer().decode(value);

  static List<DeviceApp> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DeviceApp>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DeviceApp.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DeviceApp] to String,
/// and [decode] dynamic data back to [DeviceApp].
class DeviceAppTypeTransformer {
  factory DeviceAppTypeTransformer() => _instance ??= const DeviceAppTypeTransformer._();

  const DeviceAppTypeTransformer._();

  String encode(DeviceApp data) => data.value;

  /// Decodes a [dynamic value][data] to a DeviceApp.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DeviceApp? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'mobile': return DeviceApp.mobile;
        case r'door': return DeviceApp.door;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DeviceAppTypeTransformer] instance.
  static DeviceAppTypeTransformer? _instance;
}


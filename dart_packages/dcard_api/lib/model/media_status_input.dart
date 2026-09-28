//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class MediaStatusInput {
  /// Returns a new [MediaStatusInput] instance.
  MediaStatusInput({
    required this.status,
  });

  MediaStatusInputStatusEnum status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MediaStatusInput &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (status.hashCode);

  @override
  String toString() => 'MediaStatusInput[status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'status'] = this.status;
    return json;
  }

  /// Returns a new [MediaStatusInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MediaStatusInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MediaStatusInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return MediaStatusInput(
        status: MediaStatusInputStatusEnum.fromJson(json[r'status'])!,
      );
    }
    return null;
  }

  static List<MediaStatusInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MediaStatusInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MediaStatusInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MediaStatusInput> mapFromJson(dynamic json) {
    final map = <String, MediaStatusInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MediaStatusInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MediaStatusInput-objects as value to a dart map
  static Map<String, List<MediaStatusInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MediaStatusInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MediaStatusInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'status',
  };
}


class MediaStatusInputStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const MediaStatusInputStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const visible = MediaStatusInputStatusEnum._(r'visible');
  static const hidden = MediaStatusInputStatusEnum._(r'hidden');

  /// List of all possible values in this [enum][MediaStatusInputStatusEnum].
  static const values = <MediaStatusInputStatusEnum>[
    visible,
    hidden,
  ];

  static MediaStatusInputStatusEnum? fromJson(dynamic value) => MediaStatusInputStatusEnumTypeTransformer().decode(value);

  static List<MediaStatusInputStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MediaStatusInputStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MediaStatusInputStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MediaStatusInputStatusEnum] to String,
/// and [decode] dynamic data back to [MediaStatusInputStatusEnum].
class MediaStatusInputStatusEnumTypeTransformer {
  factory MediaStatusInputStatusEnumTypeTransformer() => _instance ??= const MediaStatusInputStatusEnumTypeTransformer._();

  const MediaStatusInputStatusEnumTypeTransformer._();

  String encode(MediaStatusInputStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MediaStatusInputStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MediaStatusInputStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'visible': return MediaStatusInputStatusEnum.visible;
        case r'hidden': return MediaStatusInputStatusEnum.hidden;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MediaStatusInputStatusEnumTypeTransformer] instance.
  static MediaStatusInputStatusEnumTypeTransformer? _instance;
}



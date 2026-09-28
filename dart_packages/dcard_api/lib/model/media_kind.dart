//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;


class MediaKind {
  /// Instantiate a new enum with the provided [value].
  const MediaKind._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const card = MediaKind._(r'card');
  static const story = MediaKind._(r'story');
  static const gallery = MediaKind._(r'gallery');

  /// List of all possible values in this [enum][MediaKind].
  static const values = <MediaKind>[
    card,
    story,
    gallery,
  ];

  static MediaKind? fromJson(dynamic value) => MediaKindTypeTransformer().decode(value);

  static List<MediaKind> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MediaKind>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MediaKind.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MediaKind] to String,
/// and [decode] dynamic data back to [MediaKind].
class MediaKindTypeTransformer {
  factory MediaKindTypeTransformer() => _instance ??= const MediaKindTypeTransformer._();

  const MediaKindTypeTransformer._();

  String encode(MediaKind data) => data.value;

  /// Decodes a [dynamic value][data] to a MediaKind.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MediaKind? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'card': return MediaKind.card;
        case r'story': return MediaKind.story;
        case r'gallery': return MediaKind.gallery;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MediaKindTypeTransformer] instance.
  static MediaKindTypeTransformer? _instance;
}


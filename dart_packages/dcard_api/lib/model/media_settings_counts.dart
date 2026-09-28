//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class MediaSettingsCounts {
  /// Returns a new [MediaSettingsCounts] instance.
  MediaSettingsCounts({
    required this.cardPhotos,
    required this.cardVideos,
    required this.storyPhotos,
    required this.storyVideos,
    required this.gallery,
  });

  int cardPhotos;

  int cardVideos;

  int storyPhotos;

  int storyVideos;

  int gallery;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MediaSettingsCounts &&
    other.cardPhotos == cardPhotos &&
    other.cardVideos == cardVideos &&
    other.storyPhotos == storyPhotos &&
    other.storyVideos == storyVideos &&
    other.gallery == gallery;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (cardPhotos.hashCode) +
    (cardVideos.hashCode) +
    (storyPhotos.hashCode) +
    (storyVideos.hashCode) +
    (gallery.hashCode);

  @override
  String toString() => 'MediaSettingsCounts[cardPhotos=$cardPhotos, cardVideos=$cardVideos, storyPhotos=$storyPhotos, storyVideos=$storyVideos, gallery=$gallery]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'cardPhotos'] = this.cardPhotos;
      json[r'cardVideos'] = this.cardVideos;
      json[r'storyPhotos'] = this.storyPhotos;
      json[r'storyVideos'] = this.storyVideos;
      json[r'gallery'] = this.gallery;
    return json;
  }

  /// Returns a new [MediaSettingsCounts] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MediaSettingsCounts? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MediaSettingsCounts[$key]" is missing from JSON.');
        });
        return true;
      }());

      return MediaSettingsCounts(
        cardPhotos: mapValueOfType<int>(json, r'cardPhotos')!,
        cardVideos: mapValueOfType<int>(json, r'cardVideos')!,
        storyPhotos: mapValueOfType<int>(json, r'storyPhotos')!,
        storyVideos: mapValueOfType<int>(json, r'storyVideos')!,
        gallery: mapValueOfType<int>(json, r'gallery')!,
      );
    }
    return null;
  }

  static List<MediaSettingsCounts> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MediaSettingsCounts>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MediaSettingsCounts.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MediaSettingsCounts> mapFromJson(dynamic json) {
    final map = <String, MediaSettingsCounts>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MediaSettingsCounts.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MediaSettingsCounts-objects as value to a dart map
  static Map<String, List<MediaSettingsCounts>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MediaSettingsCounts>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MediaSettingsCounts.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'cardPhotos',
    'cardVideos',
    'storyPhotos',
    'storyVideos',
    'gallery',
  };
}


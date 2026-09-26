//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class MediaLimits {
  /// Returns a new [MediaLimits] instance.
  MediaLimits({
    required this.cardPhotos,
    required this.cardVideos,
    required this.cardVideoSeconds,
    required this.storyPhotos,
    required this.storyVideos,
    required this.storyVideoSeconds,
    required this.galleryEnabled,
    required this.galleryVideoSeconds,
    required this.galleryUploadsPerGuest,
    required this.galleryUploadDays,
    required this.galleryOpenMonths,
    required this.maxPhotoBytes,
    required this.maxVideoBytes,
    required this.slideshow,
  });

  int cardPhotos;

  int cardVideos;

  int cardVideoSeconds;

  int storyPhotos;

  int storyVideos;

  int storyVideoSeconds;

  bool galleryEnabled;

  int galleryVideoSeconds;

  int galleryUploadsPerGuest;

  int galleryUploadDays;

  int galleryOpenMonths;

  int maxPhotoBytes;

  int maxVideoBytes;

  bool slideshow;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MediaLimits &&
    other.cardPhotos == cardPhotos &&
    other.cardVideos == cardVideos &&
    other.cardVideoSeconds == cardVideoSeconds &&
    other.storyPhotos == storyPhotos &&
    other.storyVideos == storyVideos &&
    other.storyVideoSeconds == storyVideoSeconds &&
    other.galleryEnabled == galleryEnabled &&
    other.galleryVideoSeconds == galleryVideoSeconds &&
    other.galleryUploadsPerGuest == galleryUploadsPerGuest &&
    other.galleryUploadDays == galleryUploadDays &&
    other.galleryOpenMonths == galleryOpenMonths &&
    other.maxPhotoBytes == maxPhotoBytes &&
    other.maxVideoBytes == maxVideoBytes &&
    other.slideshow == slideshow;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (cardPhotos.hashCode) +
    (cardVideos.hashCode) +
    (cardVideoSeconds.hashCode) +
    (storyPhotos.hashCode) +
    (storyVideos.hashCode) +
    (storyVideoSeconds.hashCode) +
    (galleryEnabled.hashCode) +
    (galleryVideoSeconds.hashCode) +
    (galleryUploadsPerGuest.hashCode) +
    (galleryUploadDays.hashCode) +
    (galleryOpenMonths.hashCode) +
    (maxPhotoBytes.hashCode) +
    (maxVideoBytes.hashCode) +
    (slideshow.hashCode);

  @override
  String toString() => 'MediaLimits[cardPhotos=$cardPhotos, cardVideos=$cardVideos, cardVideoSeconds=$cardVideoSeconds, storyPhotos=$storyPhotos, storyVideos=$storyVideos, storyVideoSeconds=$storyVideoSeconds, galleryEnabled=$galleryEnabled, galleryVideoSeconds=$galleryVideoSeconds, galleryUploadsPerGuest=$galleryUploadsPerGuest, galleryUploadDays=$galleryUploadDays, galleryOpenMonths=$galleryOpenMonths, maxPhotoBytes=$maxPhotoBytes, maxVideoBytes=$maxVideoBytes, slideshow=$slideshow]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'cardPhotos'] = this.cardPhotos;
      json[r'cardVideos'] = this.cardVideos;
      json[r'cardVideoSeconds'] = this.cardVideoSeconds;
      json[r'storyPhotos'] = this.storyPhotos;
      json[r'storyVideos'] = this.storyVideos;
      json[r'storyVideoSeconds'] = this.storyVideoSeconds;
      json[r'galleryEnabled'] = this.galleryEnabled;
      json[r'galleryVideoSeconds'] = this.galleryVideoSeconds;
      json[r'galleryUploadsPerGuest'] = this.galleryUploadsPerGuest;
      json[r'galleryUploadDays'] = this.galleryUploadDays;
      json[r'galleryOpenMonths'] = this.galleryOpenMonths;
      json[r'maxPhotoBytes'] = this.maxPhotoBytes;
      json[r'maxVideoBytes'] = this.maxVideoBytes;
      json[r'slideshow'] = this.slideshow;
    return json;
  }

  /// Returns a new [MediaLimits] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MediaLimits? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MediaLimits[$key]" is missing from JSON.');
        });
        return true;
      }());

      return MediaLimits(
        cardPhotos: mapValueOfType<int>(json, r'cardPhotos')!,
        cardVideos: mapValueOfType<int>(json, r'cardVideos')!,
        cardVideoSeconds: mapValueOfType<int>(json, r'cardVideoSeconds')!,
        storyPhotos: mapValueOfType<int>(json, r'storyPhotos')!,
        storyVideos: mapValueOfType<int>(json, r'storyVideos')!,
        storyVideoSeconds: mapValueOfType<int>(json, r'storyVideoSeconds')!,
        galleryEnabled: mapValueOfType<bool>(json, r'galleryEnabled')!,
        galleryVideoSeconds: mapValueOfType<int>(json, r'galleryVideoSeconds')!,
        galleryUploadsPerGuest: mapValueOfType<int>(json, r'galleryUploadsPerGuest')!,
        galleryUploadDays: mapValueOfType<int>(json, r'galleryUploadDays')!,
        galleryOpenMonths: mapValueOfType<int>(json, r'galleryOpenMonths')!,
        maxPhotoBytes: mapValueOfType<int>(json, r'maxPhotoBytes')!,
        maxVideoBytes: mapValueOfType<int>(json, r'maxVideoBytes')!,
        slideshow: mapValueOfType<bool>(json, r'slideshow')!,
      );
    }
    return null;
  }

  static List<MediaLimits> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MediaLimits>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MediaLimits.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MediaLimits> mapFromJson(dynamic json) {
    final map = <String, MediaLimits>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MediaLimits.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MediaLimits-objects as value to a dart map
  static Map<String, List<MediaLimits>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MediaLimits>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MediaLimits.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'cardPhotos',
    'cardVideos',
    'cardVideoSeconds',
    'storyPhotos',
    'storyVideos',
    'storyVideoSeconds',
    'galleryEnabled',
    'galleryVideoSeconds',
    'galleryUploadsPerGuest',
    'galleryUploadDays',
    'galleryOpenMonths',
    'maxPhotoBytes',
    'maxVideoBytes',
    'slideshow',
  };
}


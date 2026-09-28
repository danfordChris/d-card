//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class GuestMedia {
  /// Returns a new [GuestMedia] instance.
  GuestMedia({
    this.story = const [],
    this.gallery = const [],
    required this.galleryEnabled,
    required this.uploadsOpen,
    required this.uploadsClosedReason,
    required this.uploadsClosesAt,
    required this.myUploadsLeft,
    required this.limits,
  });

  List<MediaItem> story;

  List<MediaItem> gallery;

  bool galleryEnabled;

  bool uploadsOpen;

  String? uploadsClosedReason;

  DateTime? uploadsClosesAt;

  int myUploadsLeft;

  MediaLimits limits;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GuestMedia &&
    _deepEquality.equals(other.story, story) &&
    _deepEquality.equals(other.gallery, gallery) &&
    other.galleryEnabled == galleryEnabled &&
    other.uploadsOpen == uploadsOpen &&
    other.uploadsClosedReason == uploadsClosedReason &&
    other.uploadsClosesAt == uploadsClosesAt &&
    other.myUploadsLeft == myUploadsLeft &&
    other.limits == limits;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (story.hashCode) +
    (gallery.hashCode) +
    (galleryEnabled.hashCode) +
    (uploadsOpen.hashCode) +
    (uploadsClosedReason == null ? 0 : uploadsClosedReason!.hashCode) +
    (uploadsClosesAt == null ? 0 : uploadsClosesAt!.hashCode) +
    (myUploadsLeft.hashCode) +
    (limits.hashCode);

  @override
  String toString() => 'GuestMedia[story=$story, gallery=$gallery, galleryEnabled=$galleryEnabled, uploadsOpen=$uploadsOpen, uploadsClosedReason=$uploadsClosedReason, uploadsClosesAt=$uploadsClosesAt, myUploadsLeft=$myUploadsLeft, limits=$limits]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'story'] = this.story;
      json[r'gallery'] = this.gallery;
      json[r'galleryEnabled'] = this.galleryEnabled;
      json[r'uploadsOpen'] = this.uploadsOpen;
    if (this.uploadsClosedReason != null) {
      json[r'uploadsClosedReason'] = this.uploadsClosedReason;
    } else {
      json[r'uploadsClosedReason'] = null;
    }
    if (this.uploadsClosesAt != null) {
      json[r'uploadsClosesAt'] = this.uploadsClosesAt!.toUtc().toIso8601String();
    } else {
      json[r'uploadsClosesAt'] = null;
    }
      json[r'myUploadsLeft'] = this.myUploadsLeft;
      json[r'limits'] = this.limits;
    return json;
  }

  /// Returns a new [GuestMedia] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GuestMedia? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GuestMedia[$key]" is missing from JSON.');
        });
        return true;
      }());

      return GuestMedia(
        story: MediaItem.listFromJson(json[r'story']),
        gallery: MediaItem.listFromJson(json[r'gallery']),
        galleryEnabled: mapValueOfType<bool>(json, r'galleryEnabled')!,
        uploadsOpen: mapValueOfType<bool>(json, r'uploadsOpen')!,
        uploadsClosedReason: mapValueOfType<String>(json, r'uploadsClosedReason'),
        uploadsClosesAt: mapDateTime(json, r'uploadsClosesAt', r''),
        myUploadsLeft: mapValueOfType<int>(json, r'myUploadsLeft')!,
        limits: MediaLimits.fromJson(json[r'limits'])!,
      );
    }
    return null;
  }

  static List<GuestMedia> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GuestMedia>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GuestMedia.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GuestMedia> mapFromJson(dynamic json) {
    final map = <String, GuestMedia>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GuestMedia.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GuestMedia-objects as value to a dart map
  static Map<String, List<GuestMedia>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GuestMedia>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GuestMedia.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'story',
    'gallery',
    'galleryEnabled',
    'uploadsOpen',
    'uploadsClosedReason',
    'uploadsClosesAt',
    'myUploadsLeft',
    'limits',
  };
}


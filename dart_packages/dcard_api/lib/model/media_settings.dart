//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class MediaSettings {
  /// Returns a new [MediaSettings] instance.
  MediaSettings({
    required this.mediaEnabled,
    required this.connected,
    required this.googleEmail,
    required this.needsReconnect,
    required this.sharingMode,
    required this.folderUrl,
    required this.quotaUsedBytes,
    required this.quotaLimitBytes,
    required this.quotaWarning,
    required this.googlePhotosUrl,
    required this.limits,
    required this.counts,
  });

  bool mediaEnabled;

  bool connected;

  String? googleEmail;

  bool needsReconnect;

  SharingMode sharingMode;

  String? folderUrl;

  num? quotaUsedBytes;

  num? quotaLimitBytes;

  bool quotaWarning;

  String? googlePhotosUrl;

  MediaLimits limits;

  MediaSettingsCounts counts;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MediaSettings &&
    other.mediaEnabled == mediaEnabled &&
    other.connected == connected &&
    other.googleEmail == googleEmail &&
    other.needsReconnect == needsReconnect &&
    other.sharingMode == sharingMode &&
    other.folderUrl == folderUrl &&
    other.quotaUsedBytes == quotaUsedBytes &&
    other.quotaLimitBytes == quotaLimitBytes &&
    other.quotaWarning == quotaWarning &&
    other.googlePhotosUrl == googlePhotosUrl &&
    other.limits == limits &&
    other.counts == counts;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (mediaEnabled.hashCode) +
    (connected.hashCode) +
    (googleEmail == null ? 0 : googleEmail!.hashCode) +
    (needsReconnect.hashCode) +
    (sharingMode.hashCode) +
    (folderUrl == null ? 0 : folderUrl!.hashCode) +
    (quotaUsedBytes == null ? 0 : quotaUsedBytes!.hashCode) +
    (quotaLimitBytes == null ? 0 : quotaLimitBytes!.hashCode) +
    (quotaWarning.hashCode) +
    (googlePhotosUrl == null ? 0 : googlePhotosUrl!.hashCode) +
    (limits.hashCode) +
    (counts.hashCode);

  @override
  String toString() => 'MediaSettings[mediaEnabled=$mediaEnabled, connected=$connected, googleEmail=$googleEmail, needsReconnect=$needsReconnect, sharingMode=$sharingMode, folderUrl=$folderUrl, quotaUsedBytes=$quotaUsedBytes, quotaLimitBytes=$quotaLimitBytes, quotaWarning=$quotaWarning, googlePhotosUrl=$googlePhotosUrl, limits=$limits, counts=$counts]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'mediaEnabled'] = this.mediaEnabled;
      json[r'connected'] = this.connected;
    if (this.googleEmail != null) {
      json[r'googleEmail'] = this.googleEmail;
    } else {
      json[r'googleEmail'] = null;
    }
      json[r'needsReconnect'] = this.needsReconnect;
      json[r'sharingMode'] = this.sharingMode;
    if (this.folderUrl != null) {
      json[r'folderUrl'] = this.folderUrl;
    } else {
      json[r'folderUrl'] = null;
    }
    if (this.quotaUsedBytes != null) {
      json[r'quotaUsedBytes'] = this.quotaUsedBytes;
    } else {
      json[r'quotaUsedBytes'] = null;
    }
    if (this.quotaLimitBytes != null) {
      json[r'quotaLimitBytes'] = this.quotaLimitBytes;
    } else {
      json[r'quotaLimitBytes'] = null;
    }
      json[r'quotaWarning'] = this.quotaWarning;
    if (this.googlePhotosUrl != null) {
      json[r'googlePhotosUrl'] = this.googlePhotosUrl;
    } else {
      json[r'googlePhotosUrl'] = null;
    }
      json[r'limits'] = this.limits;
      json[r'counts'] = this.counts;
    return json;
  }

  /// Returns a new [MediaSettings] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MediaSettings? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MediaSettings[$key]" is missing from JSON.');
        });
        return true;
      }());

      return MediaSettings(
        mediaEnabled: mapValueOfType<bool>(json, r'mediaEnabled')!,
        connected: mapValueOfType<bool>(json, r'connected')!,
        googleEmail: mapValueOfType<String>(json, r'googleEmail'),
        needsReconnect: mapValueOfType<bool>(json, r'needsReconnect')!,
        sharingMode: SharingMode.fromJson(json[r'sharingMode'])!,
        folderUrl: mapValueOfType<String>(json, r'folderUrl'),
        quotaUsedBytes: json[r'quotaUsedBytes'] == null
            ? null
            : num.parse('${json[r'quotaUsedBytes']}'),
        quotaLimitBytes: json[r'quotaLimitBytes'] == null
            ? null
            : num.parse('${json[r'quotaLimitBytes']}'),
        quotaWarning: mapValueOfType<bool>(json, r'quotaWarning')!,
        googlePhotosUrl: mapValueOfType<String>(json, r'googlePhotosUrl'),
        limits: MediaLimits.fromJson(json[r'limits'])!,
        counts: MediaSettingsCounts.fromJson(json[r'counts'])!,
      );
    }
    return null;
  }

  static List<MediaSettings> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MediaSettings>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MediaSettings.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MediaSettings> mapFromJson(dynamic json) {
    final map = <String, MediaSettings>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MediaSettings.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MediaSettings-objects as value to a dart map
  static Map<String, List<MediaSettings>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MediaSettings>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MediaSettings.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'mediaEnabled',
    'connected',
    'googleEmail',
    'needsReconnect',
    'sharingMode',
    'folderUrl',
    'quotaUsedBytes',
    'quotaLimitBytes',
    'quotaWarning',
    'googlePhotosUrl',
    'limits',
    'counts',
  };
}


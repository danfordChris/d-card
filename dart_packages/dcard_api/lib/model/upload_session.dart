//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class UploadSession {
  /// Returns a new [UploadSession] instance.
  UploadSession({
    required this.mediaItemId,
    required this.uploadUrl,
    required this.expiresAt,
  });

  String mediaItemId;

  String uploadUrl;

  DateTime expiresAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UploadSession &&
    other.mediaItemId == mediaItemId &&
    other.uploadUrl == uploadUrl &&
    other.expiresAt == expiresAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (mediaItemId.hashCode) +
    (uploadUrl.hashCode) +
    (expiresAt.hashCode);

  @override
  String toString() => 'UploadSession[mediaItemId=$mediaItemId, uploadUrl=$uploadUrl, expiresAt=$expiresAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'mediaItemId'] = this.mediaItemId;
      json[r'uploadUrl'] = this.uploadUrl;
      json[r'expiresAt'] = this.expiresAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [UploadSession] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UploadSession? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UploadSession[$key]" is missing from JSON.');
        });
        return true;
      }());

      return UploadSession(
        mediaItemId: mapValueOfType<String>(json, r'mediaItemId')!,
        uploadUrl: mapValueOfType<String>(json, r'uploadUrl')!,
        expiresAt: mapDateTime(json, r'expiresAt', r'')!,
      );
    }
    return null;
  }

  static List<UploadSession> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UploadSession>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UploadSession.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UploadSession> mapFromJson(dynamic json) {
    final map = <String, UploadSession>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UploadSession.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UploadSession-objects as value to a dart map
  static Map<String, List<UploadSession>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UploadSession>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UploadSession.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'mediaItemId',
    'uploadUrl',
    'expiresAt',
  };
}


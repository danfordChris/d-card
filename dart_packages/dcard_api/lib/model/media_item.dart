//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class MediaItem {
  /// Returns a new [MediaItem] instance.
  MediaItem({
    required this.id,
    required this.kind,
    required this.type,
    required this.mimeType,
    required this.sizeBytes,
    required this.durationSeconds,
    required this.status,
    required this.uploadedBy,
    required this.mine,
    required this.thumbnailUrl,
    required this.url,
    required this.createdAt,
  });

  String id;

  MediaKind kind;

  MediaType type;

  String mimeType;

  num sizeBytes;

  int? durationSeconds;

  MediaStatus status;

  String? uploadedBy;

  bool mine;

  String thumbnailUrl;

  String url;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MediaItem &&
    other.id == id &&
    other.kind == kind &&
    other.type == type &&
    other.mimeType == mimeType &&
    other.sizeBytes == sizeBytes &&
    other.durationSeconds == durationSeconds &&
    other.status == status &&
    other.uploadedBy == uploadedBy &&
    other.mine == mine &&
    other.thumbnailUrl == thumbnailUrl &&
    other.url == url &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (kind.hashCode) +
    (type.hashCode) +
    (mimeType.hashCode) +
    (sizeBytes.hashCode) +
    (durationSeconds == null ? 0 : durationSeconds!.hashCode) +
    (status.hashCode) +
    (uploadedBy == null ? 0 : uploadedBy!.hashCode) +
    (mine.hashCode) +
    (thumbnailUrl.hashCode) +
    (url.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'MediaItem[id=$id, kind=$kind, type=$type, mimeType=$mimeType, sizeBytes=$sizeBytes, durationSeconds=$durationSeconds, status=$status, uploadedBy=$uploadedBy, mine=$mine, thumbnailUrl=$thumbnailUrl, url=$url, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'kind'] = this.kind;
      json[r'type'] = this.type;
      json[r'mimeType'] = this.mimeType;
      json[r'sizeBytes'] = this.sizeBytes;
    if (this.durationSeconds != null) {
      json[r'durationSeconds'] = this.durationSeconds;
    } else {
      json[r'durationSeconds'] = null;
    }
      json[r'status'] = this.status;
    if (this.uploadedBy != null) {
      json[r'uploadedBy'] = this.uploadedBy;
    } else {
      json[r'uploadedBy'] = null;
    }
      json[r'mine'] = this.mine;
      json[r'thumbnailUrl'] = this.thumbnailUrl;
      json[r'url'] = this.url;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [MediaItem] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MediaItem? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MediaItem[$key]" is missing from JSON.');
        });
        return true;
      }());

      return MediaItem(
        id: mapValueOfType<String>(json, r'id')!,
        kind: MediaKind.fromJson(json[r'kind'])!,
        type: MediaType.fromJson(json[r'type'])!,
        mimeType: mapValueOfType<String>(json, r'mimeType')!,
        sizeBytes: num.parse('${json[r'sizeBytes']}'),
        durationSeconds: mapValueOfType<int>(json, r'durationSeconds'),
        status: MediaStatus.fromJson(json[r'status'])!,
        uploadedBy: mapValueOfType<String>(json, r'uploadedBy'),
        mine: mapValueOfType<bool>(json, r'mine')!,
        thumbnailUrl: mapValueOfType<String>(json, r'thumbnailUrl')!,
        url: mapValueOfType<String>(json, r'url')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<MediaItem> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MediaItem>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MediaItem.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MediaItem> mapFromJson(dynamic json) {
    final map = <String, MediaItem>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MediaItem.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MediaItem-objects as value to a dart map
  static Map<String, List<MediaItem>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MediaItem>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MediaItem.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'kind',
    'type',
    'mimeType',
    'sizeBytes',
    'durationSeconds',
    'status',
    'uploadedBy',
    'mine',
    'thumbnailUrl',
    'url',
    'createdAt',
  };
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class UploadSessionInput {
  /// Returns a new [UploadSessionInput] instance.
  UploadSessionInput({
    required this.kind,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
    this.durationSeconds,
  });

  MediaKind kind;

  String fileName;

  String mimeType;

  /// Minimum value: 1
  int sizeBytes;

  /// Minimum value: 0
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? durationSeconds;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UploadSessionInput &&
    other.kind == kind &&
    other.fileName == fileName &&
    other.mimeType == mimeType &&
    other.sizeBytes == sizeBytes &&
    other.durationSeconds == durationSeconds;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (kind.hashCode) +
    (fileName.hashCode) +
    (mimeType.hashCode) +
    (sizeBytes.hashCode) +
    (durationSeconds == null ? 0 : durationSeconds!.hashCode);

  @override
  String toString() => 'UploadSessionInput[kind=$kind, fileName=$fileName, mimeType=$mimeType, sizeBytes=$sizeBytes, durationSeconds=$durationSeconds]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'kind'] = this.kind;
      json[r'fileName'] = this.fileName;
      json[r'mimeType'] = this.mimeType;
      json[r'sizeBytes'] = this.sizeBytes;
    if (this.durationSeconds != null) {
      json[r'durationSeconds'] = this.durationSeconds;
    } else {
      json[r'durationSeconds'] = null;
    }
    return json;
  }

  /// Returns a new [UploadSessionInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UploadSessionInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UploadSessionInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return UploadSessionInput(
        kind: MediaKind.fromJson(json[r'kind'])!,
        fileName: mapValueOfType<String>(json, r'fileName')!,
        mimeType: mapValueOfType<String>(json, r'mimeType')!,
        sizeBytes: mapValueOfType<int>(json, r'sizeBytes')!,
        durationSeconds: mapValueOfType<int>(json, r'durationSeconds'),
      );
    }
    return null;
  }

  static List<UploadSessionInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UploadSessionInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UploadSessionInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UploadSessionInput> mapFromJson(dynamic json) {
    final map = <String, UploadSessionInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UploadSessionInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UploadSessionInput-objects as value to a dart map
  static Map<String, List<UploadSessionInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UploadSessionInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UploadSessionInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'kind',
    'fileName',
    'mimeType',
    'sizeBytes',
  };
}


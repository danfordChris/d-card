//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class ErrorResponseErrorIssuesInner {
  /// Returns a new [ErrorResponseErrorIssuesInner] instance.
  ErrorResponseErrorIssuesInner({
    required this.path,
    required this.message,
  });

  String path;

  String message;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ErrorResponseErrorIssuesInner &&
    other.path == path &&
    other.message == message;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (path.hashCode) +
    (message.hashCode);

  @override
  String toString() => 'ErrorResponseErrorIssuesInner[path=$path, message=$message]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'path'] = this.path;
      json[r'message'] = this.message;
    return json;
  }

  /// Returns a new [ErrorResponseErrorIssuesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ErrorResponseErrorIssuesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ErrorResponseErrorIssuesInner[$key]" is missing from JSON.');
        });
        return true;
      }());

      return ErrorResponseErrorIssuesInner(
        path: mapValueOfType<String>(json, r'path')!,
        message: mapValueOfType<String>(json, r'message')!,
      );
    }
    return null;
  }

  static List<ErrorResponseErrorIssuesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ErrorResponseErrorIssuesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ErrorResponseErrorIssuesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ErrorResponseErrorIssuesInner> mapFromJson(dynamic json) {
    final map = <String, ErrorResponseErrorIssuesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ErrorResponseErrorIssuesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ErrorResponseErrorIssuesInner-objects as value to a dart map
  static Map<String, List<ErrorResponseErrorIssuesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ErrorResponseErrorIssuesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ErrorResponseErrorIssuesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'path',
    'message',
  };
}


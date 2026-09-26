//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class SendTestMessage202Response {
  /// Returns a new [SendTestMessage202Response] instance.
  SendTestMessage202Response({
    required this.queued,
  });

  bool queued;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SendTestMessage202Response &&
    other.queued == queued;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (queued.hashCode);

  @override
  String toString() => 'SendTestMessage202Response[queued=$queued]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'queued'] = this.queued;
    return json;
  }

  /// Returns a new [SendTestMessage202Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SendTestMessage202Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SendTestMessage202Response[$key]" is missing from JSON.');
        });
        return true;
      }());

      return SendTestMessage202Response(
        queued: mapValueOfType<bool>(json, r'queued')!,
      );
    }
    return null;
  }

  static List<SendTestMessage202Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SendTestMessage202Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SendTestMessage202Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SendTestMessage202Response> mapFromJson(dynamic json) {
    final map = <String, SendTestMessage202Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SendTestMessage202Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SendTestMessage202Response-objects as value to a dart map
  static Map<String, List<SendTestMessage202Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SendTestMessage202Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SendTestMessage202Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'queued',
  };
}


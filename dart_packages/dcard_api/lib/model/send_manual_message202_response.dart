//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class SendManualMessage202Response {
  /// Returns a new [SendManualMessage202Response] instance.
  SendManualMessage202Response({
    required this.queued,
    required this.sendsUsed,
    required this.sendsAllowed,
  });

  int queued;

  int sendsUsed;

  int sendsAllowed;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SendManualMessage202Response &&
    other.queued == queued &&
    other.sendsUsed == sendsUsed &&
    other.sendsAllowed == sendsAllowed;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (queued.hashCode) +
    (sendsUsed.hashCode) +
    (sendsAllowed.hashCode);

  @override
  String toString() => 'SendManualMessage202Response[queued=$queued, sendsUsed=$sendsUsed, sendsAllowed=$sendsAllowed]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'queued'] = this.queued;
      json[r'sendsUsed'] = this.sendsUsed;
      json[r'sendsAllowed'] = this.sendsAllowed;
    return json;
  }

  /// Returns a new [SendManualMessage202Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SendManualMessage202Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SendManualMessage202Response[$key]" is missing from JSON.');
        });
        return true;
      }());

      return SendManualMessage202Response(
        queued: mapValueOfType<int>(json, r'queued')!,
        sendsUsed: mapValueOfType<int>(json, r'sendsUsed')!,
        sendsAllowed: mapValueOfType<int>(json, r'sendsAllowed')!,
      );
    }
    return null;
  }

  static List<SendManualMessage202Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SendManualMessage202Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SendManualMessage202Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SendManualMessage202Response> mapFromJson(dynamic json) {
    final map = <String, SendManualMessage202Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SendManualMessage202Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SendManualMessage202Response-objects as value to a dart map
  static Map<String, List<SendManualMessage202Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SendManualMessage202Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SendManualMessage202Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'queued',
    'sendsUsed',
    'sendsAllowed',
  };
}


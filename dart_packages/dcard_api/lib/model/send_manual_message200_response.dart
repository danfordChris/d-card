//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class SendManualMessage200Response {
  /// Returns a new [SendManualMessage200Response] instance.
  SendManualMessage200Response({
    required this.recipients,
    required this.sendsUsed,
    required this.sendsAllowed,
  });

  int recipients;

  int sendsUsed;

  int sendsAllowed;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SendManualMessage200Response &&
    other.recipients == recipients &&
    other.sendsUsed == sendsUsed &&
    other.sendsAllowed == sendsAllowed;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (recipients.hashCode) +
    (sendsUsed.hashCode) +
    (sendsAllowed.hashCode);

  @override
  String toString() => 'SendManualMessage200Response[recipients=$recipients, sendsUsed=$sendsUsed, sendsAllowed=$sendsAllowed]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'recipients'] = this.recipients;
      json[r'sendsUsed'] = this.sendsUsed;
      json[r'sendsAllowed'] = this.sendsAllowed;
    return json;
  }

  /// Returns a new [SendManualMessage200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SendManualMessage200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SendManualMessage200Response[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "SendManualMessage200Response[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return SendManualMessage200Response(
        recipients: mapValueOfType<int>(json, r'recipients')!,
        sendsUsed: mapValueOfType<int>(json, r'sendsUsed')!,
        sendsAllowed: mapValueOfType<int>(json, r'sendsAllowed')!,
      );
    }
    return null;
  }

  static List<SendManualMessage200Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SendManualMessage200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SendManualMessage200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SendManualMessage200Response> mapFromJson(dynamic json) {
    final map = <String, SendManualMessage200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SendManualMessage200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SendManualMessage200Response-objects as value to a dart map
  static Map<String, List<SendManualMessage200Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SendManualMessage200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SendManualMessage200Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'recipients',
    'sendsUsed',
    'sendsAllowed',
  };
}


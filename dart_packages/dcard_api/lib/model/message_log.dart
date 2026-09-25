//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class MessageLog {
  /// Returns a new [MessageLog] instance.
  MessageLog({
    this.items = const [],
    required this.nextBefore,
    this.counts = const {},
    this.optOuts = const [],
  });

  List<MessageLogItemsInner> items;

  String? nextBefore;

  Map<String, int> counts;

  List<MessageLogOptOutsInner> optOuts;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MessageLog &&
    _deepEquality.equals(other.items, items) &&
    other.nextBefore == nextBefore &&
    _deepEquality.equals(other.counts, counts) &&
    _deepEquality.equals(other.optOuts, optOuts);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (items.hashCode) +
    (nextBefore == null ? 0 : nextBefore!.hashCode) +
    (counts.hashCode) +
    (optOuts.hashCode);

  @override
  String toString() => 'MessageLog[items=$items, nextBefore=$nextBefore, counts=$counts, optOuts=$optOuts]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'items'] = this.items;
    if (this.nextBefore != null) {
      json[r'nextBefore'] = this.nextBefore;
    } else {
      json[r'nextBefore'] = null;
    }
      json[r'counts'] = this.counts;
      json[r'optOuts'] = this.optOuts;
    return json;
  }

  /// Returns a new [MessageLog] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MessageLog? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MessageLog[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MessageLog[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MessageLog(
        items: MessageLogItemsInner.listFromJson(json[r'items']),
        nextBefore: mapValueOfType<String>(json, r'nextBefore'),
        counts: mapCastOfType<String, int>(json, r'counts')!,
        optOuts: MessageLogOptOutsInner.listFromJson(json[r'optOuts']),
      );
    }
    return null;
  }

  static List<MessageLog> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageLog>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageLog.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MessageLog> mapFromJson(dynamic json) {
    final map = <String, MessageLog>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MessageLog.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MessageLog-objects as value to a dart map
  static Map<String, List<MessageLog>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MessageLog>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MessageLog.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'items',
    'nextBefore',
    'counts',
    'optOuts',
  };
}


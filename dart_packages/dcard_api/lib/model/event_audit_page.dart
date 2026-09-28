//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class EventAuditPage {
  /// Returns a new [EventAuditPage] instance.
  EventAuditPage({
    this.entries = const [],
    required this.nextCursor,
  });

  List<EventAuditEntry> entries;

  String? nextCursor;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EventAuditPage &&
    _deepEquality.equals(other.entries, entries) &&
    other.nextCursor == nextCursor;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (entries.hashCode) +
    (nextCursor == null ? 0 : nextCursor!.hashCode);

  @override
  String toString() => 'EventAuditPage[entries=$entries, nextCursor=$nextCursor]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'entries'] = this.entries;
    if (this.nextCursor != null) {
      json[r'nextCursor'] = this.nextCursor;
    } else {
      json[r'nextCursor'] = null;
    }
    return json;
  }

  /// Returns a new [EventAuditPage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EventAuditPage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EventAuditPage[$key]" is missing from JSON.');
        });
        return true;
      }());

      return EventAuditPage(
        entries: EventAuditEntry.listFromJson(json[r'entries']),
        nextCursor: mapValueOfType<String>(json, r'nextCursor'),
      );
    }
    return null;
  }

  static List<EventAuditPage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EventAuditPage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EventAuditPage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EventAuditPage> mapFromJson(dynamic json) {
    final map = <String, EventAuditPage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EventAuditPage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EventAuditPage-objects as value to a dart map
  static Map<String, List<EventAuditPage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EventAuditPage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EventAuditPage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'entries',
    'nextCursor',
  };
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorSyncSnapshot {
  /// Returns a new [DoorSyncSnapshot] instance.
  DoorSyncSnapshot({
    required this.eventId,
    required this.full,
    this.cards = const [],
    this.approvers = const [],
    required this.cursor,
    required this.wipeAfter,
  });

  String eventId;

  bool full;

  List<DoorSyncCard> cards;

  List<DoorSyncSnapshotApproversInner> approvers;

  String cursor;

  DateTime wipeAfter;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorSyncSnapshot &&
    other.eventId == eventId &&
    other.full == full &&
    _deepEquality.equals(other.cards, cards) &&
    _deepEquality.equals(other.approvers, approvers) &&
    other.cursor == cursor &&
    other.wipeAfter == wipeAfter;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (eventId.hashCode) +
    (full.hashCode) +
    (cards.hashCode) +
    (approvers.hashCode) +
    (cursor.hashCode) +
    (wipeAfter.hashCode);

  @override
  String toString() => 'DoorSyncSnapshot[eventId=$eventId, full=$full, cards=$cards, approvers=$approvers, cursor=$cursor, wipeAfter=$wipeAfter]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'eventId'] = this.eventId;
      json[r'full'] = this.full;
      json[r'cards'] = this.cards;
      json[r'approvers'] = this.approvers;
      json[r'cursor'] = this.cursor;
      json[r'wipeAfter'] = this.wipeAfter.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [DoorSyncSnapshot] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorSyncSnapshot? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorSyncSnapshot[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorSyncSnapshot(
        eventId: mapValueOfType<String>(json, r'eventId')!,
        full: mapValueOfType<bool>(json, r'full')!,
        cards: DoorSyncCard.listFromJson(json[r'cards']),
        approvers: DoorSyncSnapshotApproversInner.listFromJson(json[r'approvers']),
        cursor: mapValueOfType<String>(json, r'cursor')!,
        wipeAfter: mapDateTime(json, r'wipeAfter', r'')!,
      );
    }
    return null;
  }

  static List<DoorSyncSnapshot> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorSyncSnapshot>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorSyncSnapshot.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorSyncSnapshot> mapFromJson(dynamic json) {
    final map = <String, DoorSyncSnapshot>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorSyncSnapshot.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorSyncSnapshot-objects as value to a dart map
  static Map<String, List<DoorSyncSnapshot>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorSyncSnapshot>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorSyncSnapshot.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'eventId',
    'full',
    'cards',
    'approvers',
    'cursor',
    'wipeAfter',
  };
}


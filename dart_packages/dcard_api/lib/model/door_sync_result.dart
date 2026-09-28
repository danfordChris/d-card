//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorSyncResult {
  /// Returns a new [DoorSyncResult] instance.
  DoorSyncResult({
    required this.entriesAccepted,
    required this.entriesDuplicate,
    this.entriesRejected = const [],
    required this.attemptsAccepted,
    required this.walkInsAccepted,
    this.overUsed = const [],
  });

  int entriesAccepted;

  int entriesDuplicate;

  List<String> entriesRejected;

  int attemptsAccepted;

  int walkInsAccepted;

  List<String> overUsed;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorSyncResult &&
    other.entriesAccepted == entriesAccepted &&
    other.entriesDuplicate == entriesDuplicate &&
    _deepEquality.equals(other.entriesRejected, entriesRejected) &&
    other.attemptsAccepted == attemptsAccepted &&
    other.walkInsAccepted == walkInsAccepted &&
    _deepEquality.equals(other.overUsed, overUsed);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (entriesAccepted.hashCode) +
    (entriesDuplicate.hashCode) +
    (entriesRejected.hashCode) +
    (attemptsAccepted.hashCode) +
    (walkInsAccepted.hashCode) +
    (overUsed.hashCode);

  @override
  String toString() => 'DoorSyncResult[entriesAccepted=$entriesAccepted, entriesDuplicate=$entriesDuplicate, entriesRejected=$entriesRejected, attemptsAccepted=$attemptsAccepted, walkInsAccepted=$walkInsAccepted, overUsed=$overUsed]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'entriesAccepted'] = this.entriesAccepted;
      json[r'entriesDuplicate'] = this.entriesDuplicate;
      json[r'entriesRejected'] = this.entriesRejected;
      json[r'attemptsAccepted'] = this.attemptsAccepted;
      json[r'walkInsAccepted'] = this.walkInsAccepted;
      json[r'overUsed'] = this.overUsed;
    return json;
  }

  /// Returns a new [DoorSyncResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorSyncResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorSyncResult[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorSyncResult(
        entriesAccepted: mapValueOfType<int>(json, r'entriesAccepted')!,
        entriesDuplicate: mapValueOfType<int>(json, r'entriesDuplicate')!,
        entriesRejected: json[r'entriesRejected'] is Iterable
            ? (json[r'entriesRejected'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        attemptsAccepted: mapValueOfType<int>(json, r'attemptsAccepted')!,
        walkInsAccepted: mapValueOfType<int>(json, r'walkInsAccepted')!,
        overUsed: json[r'overUsed'] is Iterable
            ? (json[r'overUsed'] as Iterable).cast<String>().toList(growable: false)
            : const [],
      );
    }
    return null;
  }

  static List<DoorSyncResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorSyncResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorSyncResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorSyncResult> mapFromJson(dynamic json) {
    final map = <String, DoorSyncResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorSyncResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorSyncResult-objects as value to a dart map
  static Map<String, List<DoorSyncResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorSyncResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorSyncResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'entriesAccepted',
    'entriesDuplicate',
    'entriesRejected',
    'attemptsAccepted',
    'walkInsAccepted',
    'overUsed',
  };
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class EventAuditEntry {
  /// Returns a new [EventAuditEntry] instance.
  EventAuditEntry({
    required this.id,
    required this.createdAt,
    required this.action,
    required this.actorType,
    required this.actorName,
    required this.targetType,
    required this.targetId,
    this.changes = const [],
  });

  String id;

  DateTime createdAt;

  String action;

  EventAuditEntryActorTypeEnum actorType;

  String? actorName;

  String targetType;

  String? targetId;

  List<AuditChange> changes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EventAuditEntry &&
    other.id == id &&
    other.createdAt == createdAt &&
    other.action == action &&
    other.actorType == actorType &&
    other.actorName == actorName &&
    other.targetType == targetType &&
    other.targetId == targetId &&
    _deepEquality.equals(other.changes, changes);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (createdAt.hashCode) +
    (action.hashCode) +
    (actorType.hashCode) +
    (actorName == null ? 0 : actorName!.hashCode) +
    (targetType.hashCode) +
    (targetId == null ? 0 : targetId!.hashCode) +
    (changes.hashCode);

  @override
  String toString() => 'EventAuditEntry[id=$id, createdAt=$createdAt, action=$action, actorType=$actorType, actorName=$actorName, targetType=$targetType, targetId=$targetId, changes=$changes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'action'] = this.action;
      json[r'actorType'] = this.actorType;
    if (this.actorName != null) {
      json[r'actorName'] = this.actorName;
    } else {
      json[r'actorName'] = null;
    }
      json[r'targetType'] = this.targetType;
    if (this.targetId != null) {
      json[r'targetId'] = this.targetId;
    } else {
      json[r'targetId'] = null;
    }
      json[r'changes'] = this.changes;
    return json;
  }

  /// Returns a new [EventAuditEntry] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EventAuditEntry? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EventAuditEntry[$key]" is missing from JSON.');
        });
        return true;
      }());

      return EventAuditEntry(
        id: mapValueOfType<String>(json, r'id')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        action: mapValueOfType<String>(json, r'action')!,
        actorType: EventAuditEntryActorTypeEnum.fromJson(json[r'actorType'])!,
        actorName: mapValueOfType<String>(json, r'actorName'),
        targetType: mapValueOfType<String>(json, r'targetType')!,
        targetId: mapValueOfType<String>(json, r'targetId'),
        changes: AuditChange.listFromJson(json[r'changes']),
      );
    }
    return null;
  }

  static List<EventAuditEntry> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EventAuditEntry>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EventAuditEntry.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EventAuditEntry> mapFromJson(dynamic json) {
    final map = <String, EventAuditEntry>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EventAuditEntry.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EventAuditEntry-objects as value to a dart map
  static Map<String, List<EventAuditEntry>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EventAuditEntry>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EventAuditEntry.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'createdAt',
    'action',
    'actorType',
    'actorName',
    'targetType',
    'targetId',
    'changes',
  };
}


class EventAuditEntryActorTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const EventAuditEntryActorTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const user = EventAuditEntryActorTypeEnum._(r'user');
  static const system = EventAuditEntryActorTypeEnum._(r'system');

  /// List of all possible values in this [enum][EventAuditEntryActorTypeEnum].
  static const values = <EventAuditEntryActorTypeEnum>[
    user,
    system,
  ];

  static EventAuditEntryActorTypeEnum? fromJson(dynamic value) => EventAuditEntryActorTypeEnumTypeTransformer().decode(value);

  static List<EventAuditEntryActorTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EventAuditEntryActorTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EventAuditEntryActorTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [EventAuditEntryActorTypeEnum] to String,
/// and [decode] dynamic data back to [EventAuditEntryActorTypeEnum].
class EventAuditEntryActorTypeEnumTypeTransformer {
  factory EventAuditEntryActorTypeEnumTypeTransformer() => _instance ??= const EventAuditEntryActorTypeEnumTypeTransformer._();

  const EventAuditEntryActorTypeEnumTypeTransformer._();

  String encode(EventAuditEntryActorTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a EventAuditEntryActorTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  EventAuditEntryActorTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'user': return EventAuditEntryActorTypeEnum.user;
        case r'system': return EventAuditEntryActorTypeEnum.system;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [EventAuditEntryActorTypeEnumTypeTransformer] instance.
  static EventAuditEntryActorTypeEnumTypeTransformer? _instance;
}



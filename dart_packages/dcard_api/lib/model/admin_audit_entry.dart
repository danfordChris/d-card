//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class AdminAuditEntry {
  /// Returns a new [AdminAuditEntry] instance.
  AdminAuditEntry({
    required this.id,
    required this.createdAt,
    required this.actorType,
    required this.actorUserId,
    required this.actorEmail,
    required this.eventId,
    required this.action,
    required this.targetType,
    required this.targetId,
    this.oldValue,
    this.newValue,
    required this.ip,
  });

  String id;

  DateTime createdAt;

  AdminAuditEntryActorTypeEnum actorType;

  String? actorUserId;

  String? actorEmail;

  String? eventId;

  String action;

  String targetType;

  String? targetId;

  Object? oldValue;

  Object? newValue;

  String? ip;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminAuditEntry &&
    other.id == id &&
    other.createdAt == createdAt &&
    other.actorType == actorType &&
    other.actorUserId == actorUserId &&
    other.actorEmail == actorEmail &&
    other.eventId == eventId &&
    other.action == action &&
    other.targetType == targetType &&
    other.targetId == targetId &&
    other.oldValue == oldValue &&
    other.newValue == newValue &&
    other.ip == ip;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (createdAt.hashCode) +
    (actorType.hashCode) +
    (actorUserId == null ? 0 : actorUserId!.hashCode) +
    (actorEmail == null ? 0 : actorEmail!.hashCode) +
    (eventId == null ? 0 : eventId!.hashCode) +
    (action.hashCode) +
    (targetType.hashCode) +
    (targetId == null ? 0 : targetId!.hashCode) +
    (oldValue == null ? 0 : oldValue!.hashCode) +
    (newValue == null ? 0 : newValue!.hashCode) +
    (ip == null ? 0 : ip!.hashCode);

  @override
  String toString() => 'AdminAuditEntry[id=$id, createdAt=$createdAt, actorType=$actorType, actorUserId=$actorUserId, actorEmail=$actorEmail, eventId=$eventId, action=$action, targetType=$targetType, targetId=$targetId, oldValue=$oldValue, newValue=$newValue, ip=$ip]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'actorType'] = this.actorType;
    if (this.actorUserId != null) {
      json[r'actorUserId'] = this.actorUserId;
    } else {
      json[r'actorUserId'] = null;
    }
    if (this.actorEmail != null) {
      json[r'actorEmail'] = this.actorEmail;
    } else {
      json[r'actorEmail'] = null;
    }
    if (this.eventId != null) {
      json[r'eventId'] = this.eventId;
    } else {
      json[r'eventId'] = null;
    }
      json[r'action'] = this.action;
      json[r'targetType'] = this.targetType;
    if (this.targetId != null) {
      json[r'targetId'] = this.targetId;
    } else {
      json[r'targetId'] = null;
    }
    if (this.oldValue != null) {
      json[r'oldValue'] = this.oldValue;
    } else {
      json[r'oldValue'] = null;
    }
    if (this.newValue != null) {
      json[r'newValue'] = this.newValue;
    } else {
      json[r'newValue'] = null;
    }
    if (this.ip != null) {
      json[r'ip'] = this.ip;
    } else {
      json[r'ip'] = null;
    }
    return json;
  }

  /// Returns a new [AdminAuditEntry] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminAuditEntry? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AdminAuditEntry[$key]" is missing from JSON.');
        });
        return true;
      }());

      return AdminAuditEntry(
        id: mapValueOfType<String>(json, r'id')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        actorType: AdminAuditEntryActorTypeEnum.fromJson(json[r'actorType'])!,
        actorUserId: mapValueOfType<String>(json, r'actorUserId'),
        actorEmail: mapValueOfType<String>(json, r'actorEmail'),
        eventId: mapValueOfType<String>(json, r'eventId'),
        action: mapValueOfType<String>(json, r'action')!,
        targetType: mapValueOfType<String>(json, r'targetType')!,
        targetId: mapValueOfType<String>(json, r'targetId'),
        oldValue: mapValueOfType<Object>(json, r'oldValue'),
        newValue: mapValueOfType<Object>(json, r'newValue'),
        ip: mapValueOfType<String>(json, r'ip'),
      );
    }
    return null;
  }

  static List<AdminAuditEntry> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminAuditEntry>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminAuditEntry.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminAuditEntry> mapFromJson(dynamic json) {
    final map = <String, AdminAuditEntry>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminAuditEntry.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminAuditEntry-objects as value to a dart map
  static Map<String, List<AdminAuditEntry>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminAuditEntry>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminAuditEntry.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'createdAt',
    'actorType',
    'actorUserId',
    'actorEmail',
    'eventId',
    'action',
    'targetType',
    'targetId',
    'ip',
  };
}


class AdminAuditEntryActorTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminAuditEntryActorTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const user = AdminAuditEntryActorTypeEnum._(r'user');
  static const system = AdminAuditEntryActorTypeEnum._(r'system');

  /// List of all possible values in this [enum][AdminAuditEntryActorTypeEnum].
  static const values = <AdminAuditEntryActorTypeEnum>[
    user,
    system,
  ];

  static AdminAuditEntryActorTypeEnum? fromJson(dynamic value) => AdminAuditEntryActorTypeEnumTypeTransformer().decode(value);

  static List<AdminAuditEntryActorTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminAuditEntryActorTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminAuditEntryActorTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminAuditEntryActorTypeEnum] to String,
/// and [decode] dynamic data back to [AdminAuditEntryActorTypeEnum].
class AdminAuditEntryActorTypeEnumTypeTransformer {
  factory AdminAuditEntryActorTypeEnumTypeTransformer() => _instance ??= const AdminAuditEntryActorTypeEnumTypeTransformer._();

  const AdminAuditEntryActorTypeEnumTypeTransformer._();

  String encode(AdminAuditEntryActorTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminAuditEntryActorTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminAuditEntryActorTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'user': return AdminAuditEntryActorTypeEnum.user;
        case r'system': return AdminAuditEntryActorTypeEnum.system;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminAuditEntryActorTypeEnumTypeTransformer] instance.
  static AdminAuditEntryActorTypeEnumTypeTransformer? _instance;
}



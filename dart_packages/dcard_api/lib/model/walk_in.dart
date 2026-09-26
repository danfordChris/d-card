//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class WalkIn {
  /// Returns a new [WalkIn] instance.
  WalkIn({
    required this.id,
    required this.eventId,
    required this.status,
    required this.description,
    required this.invitationId,
    required this.guestName,
    required this.admittedCount,
    required this.source_,
    required this.offlineReason,
    required this.requestedBy,
    required this.deviceName,
    required this.decidedBy,
    required this.decidedAt,
    required this.occurredAt,
  });

  String id;

  String eventId;

  WalkInStatus status;

  String description;

  String? invitationId;

  String? guestName;

  int admittedCount;

  WalkInSource_Enum source_;

  String? offlineReason;

  String? requestedBy;

  String? deviceName;

  String? decidedBy;

  DateTime? decidedAt;

  DateTime occurredAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WalkIn &&
    other.id == id &&
    other.eventId == eventId &&
    other.status == status &&
    other.description == description &&
    other.invitationId == invitationId &&
    other.guestName == guestName &&
    other.admittedCount == admittedCount &&
    other.source_ == source_ &&
    other.offlineReason == offlineReason &&
    other.requestedBy == requestedBy &&
    other.deviceName == deviceName &&
    other.decidedBy == decidedBy &&
    other.decidedAt == decidedAt &&
    other.occurredAt == occurredAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (eventId.hashCode) +
    (status.hashCode) +
    (description.hashCode) +
    (invitationId == null ? 0 : invitationId!.hashCode) +
    (guestName == null ? 0 : guestName!.hashCode) +
    (admittedCount.hashCode) +
    (source_.hashCode) +
    (offlineReason == null ? 0 : offlineReason!.hashCode) +
    (requestedBy == null ? 0 : requestedBy!.hashCode) +
    (deviceName == null ? 0 : deviceName!.hashCode) +
    (decidedBy == null ? 0 : decidedBy!.hashCode) +
    (decidedAt == null ? 0 : decidedAt!.hashCode) +
    (occurredAt.hashCode);

  @override
  String toString() => 'WalkIn[id=$id, eventId=$eventId, status=$status, description=$description, invitationId=$invitationId, guestName=$guestName, admittedCount=$admittedCount, source_=$source_, offlineReason=$offlineReason, requestedBy=$requestedBy, deviceName=$deviceName, decidedBy=$decidedBy, decidedAt=$decidedAt, occurredAt=$occurredAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'eventId'] = this.eventId;
      json[r'status'] = this.status;
      json[r'description'] = this.description;
    if (this.invitationId != null) {
      json[r'invitationId'] = this.invitationId;
    } else {
      json[r'invitationId'] = null;
    }
    if (this.guestName != null) {
      json[r'guestName'] = this.guestName;
    } else {
      json[r'guestName'] = null;
    }
      json[r'admittedCount'] = this.admittedCount;
      json[r'source'] = this.source_;
    if (this.offlineReason != null) {
      json[r'offlineReason'] = this.offlineReason;
    } else {
      json[r'offlineReason'] = null;
    }
    if (this.requestedBy != null) {
      json[r'requestedBy'] = this.requestedBy;
    } else {
      json[r'requestedBy'] = null;
    }
    if (this.deviceName != null) {
      json[r'deviceName'] = this.deviceName;
    } else {
      json[r'deviceName'] = null;
    }
    if (this.decidedBy != null) {
      json[r'decidedBy'] = this.decidedBy;
    } else {
      json[r'decidedBy'] = null;
    }
    if (this.decidedAt != null) {
      json[r'decidedAt'] = this.decidedAt!.toUtc().toIso8601String();
    } else {
      json[r'decidedAt'] = null;
    }
      json[r'occurredAt'] = this.occurredAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [WalkIn] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WalkIn? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "WalkIn[$key]" is missing from JSON.');
        });
        return true;
      }());

      return WalkIn(
        id: mapValueOfType<String>(json, r'id')!,
        eventId: mapValueOfType<String>(json, r'eventId')!,
        status: WalkInStatus.fromJson(json[r'status'])!,
        description: mapValueOfType<String>(json, r'description')!,
        invitationId: mapValueOfType<String>(json, r'invitationId'),
        guestName: mapValueOfType<String>(json, r'guestName'),
        admittedCount: mapValueOfType<int>(json, r'admittedCount')!,
        source_: WalkInSource_Enum.fromJson(json[r'source'])!,
        offlineReason: mapValueOfType<String>(json, r'offlineReason'),
        requestedBy: mapValueOfType<String>(json, r'requestedBy'),
        deviceName: mapValueOfType<String>(json, r'deviceName'),
        decidedBy: mapValueOfType<String>(json, r'decidedBy'),
        decidedAt: mapDateTime(json, r'decidedAt', r''),
        occurredAt: mapDateTime(json, r'occurredAt', r'')!,
      );
    }
    return null;
  }

  static List<WalkIn> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WalkIn>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WalkIn.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WalkIn> mapFromJson(dynamic json) {
    final map = <String, WalkIn>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WalkIn.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WalkIn-objects as value to a dart map
  static Map<String, List<WalkIn>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WalkIn>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WalkIn.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'eventId',
    'status',
    'description',
    'invitationId',
    'guestName',
    'admittedCount',
    'source',
    'offlineReason',
    'requestedBy',
    'deviceName',
    'decidedBy',
    'decidedAt',
    'occurredAt',
  };
}


class WalkInSource_Enum {
  /// Instantiate a new enum with the provided [value].
  const WalkInSource_Enum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const online = WalkInSource_Enum._(r'online');
  static const offline = WalkInSource_Enum._(r'offline');

  /// List of all possible values in this [enum][WalkInSource_Enum].
  static const values = <WalkInSource_Enum>[
    online,
    offline,
  ];

  static WalkInSource_Enum? fromJson(dynamic value) => WalkInSource_EnumTypeTransformer().decode(value);

  static List<WalkInSource_Enum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WalkInSource_Enum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WalkInSource_Enum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [WalkInSource_Enum] to String,
/// and [decode] dynamic data back to [WalkInSource_Enum].
class WalkInSource_EnumTypeTransformer {
  factory WalkInSource_EnumTypeTransformer() => _instance ??= const WalkInSource_EnumTypeTransformer._();

  const WalkInSource_EnumTypeTransformer._();

  String encode(WalkInSource_Enum data) => data.value;

  /// Decodes a [dynamic value][data] to a WalkInSource_Enum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  WalkInSource_Enum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'online': return WalkInSource_Enum.online;
        case r'offline': return WalkInSource_Enum.offline;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [WalkInSource_EnumTypeTransformer] instance.
  static WalkInSource_EnumTypeTransformer? _instance;
}



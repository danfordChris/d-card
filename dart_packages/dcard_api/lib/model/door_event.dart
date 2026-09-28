//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorEvent {
  /// Returns a new [DoorEvent] instance.
  DoorEvent({
    required this.id,
    required this.title,
    required this.startsAt,
    required this.endsAt,
    required this.timeZone,
    required this.venueName,
    required this.role,
  });

  String id;

  String title;

  DateTime startsAt;

  DateTime? endsAt;

  String timeZone;

  String? venueName;

  DoorEventRoleEnum role;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorEvent &&
    other.id == id &&
    other.title == title &&
    other.startsAt == startsAt &&
    other.endsAt == endsAt &&
    other.timeZone == timeZone &&
    other.venueName == venueName &&
    other.role == role;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (title.hashCode) +
    (startsAt.hashCode) +
    (endsAt == null ? 0 : endsAt!.hashCode) +
    (timeZone.hashCode) +
    (venueName == null ? 0 : venueName!.hashCode) +
    (role.hashCode);

  @override
  String toString() => 'DoorEvent[id=$id, title=$title, startsAt=$startsAt, endsAt=$endsAt, timeZone=$timeZone, venueName=$venueName, role=$role]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'title'] = this.title;
      json[r'startsAt'] = this.startsAt.toUtc().toIso8601String();
    if (this.endsAt != null) {
      json[r'endsAt'] = this.endsAt!.toUtc().toIso8601String();
    } else {
      json[r'endsAt'] = null;
    }
      json[r'timeZone'] = this.timeZone;
    if (this.venueName != null) {
      json[r'venueName'] = this.venueName;
    } else {
      json[r'venueName'] = null;
    }
      json[r'role'] = this.role;
    return json;
  }

  /// Returns a new [DoorEvent] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorEvent? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorEvent[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorEvent(
        id: mapValueOfType<String>(json, r'id')!,
        title: mapValueOfType<String>(json, r'title')!,
        startsAt: mapDateTime(json, r'startsAt', r'')!,
        endsAt: mapDateTime(json, r'endsAt', r''),
        timeZone: mapValueOfType<String>(json, r'timeZone')!,
        venueName: mapValueOfType<String>(json, r'venueName'),
        role: DoorEventRoleEnum.fromJson(json[r'role'])!,
      );
    }
    return null;
  }

  static List<DoorEvent> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorEvent>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorEvent.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorEvent> mapFromJson(dynamic json) {
    final map = <String, DoorEvent>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorEvent.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorEvent-objects as value to a dart map
  static Map<String, List<DoorEvent>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorEvent>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorEvent.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'title',
    'startsAt',
    'endsAt',
    'timeZone',
    'venueName',
    'role',
  };
}


class DoorEventRoleEnum {
  /// Instantiate a new enum with the provided [value].
  const DoorEventRoleEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const host = DoorEventRoleEnum._(r'host');
  static const committee = DoorEventRoleEnum._(r'committee');
  static const doorStaff = DoorEventRoleEnum._(r'door_staff');

  /// List of all possible values in this [enum][DoorEventRoleEnum].
  static const values = <DoorEventRoleEnum>[
    host,
    committee,
    doorStaff,
  ];

  static DoorEventRoleEnum? fromJson(dynamic value) => DoorEventRoleEnumTypeTransformer().decode(value);

  static List<DoorEventRoleEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorEventRoleEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorEventRoleEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DoorEventRoleEnum] to String,
/// and [decode] dynamic data back to [DoorEventRoleEnum].
class DoorEventRoleEnumTypeTransformer {
  factory DoorEventRoleEnumTypeTransformer() => _instance ??= const DoorEventRoleEnumTypeTransformer._();

  const DoorEventRoleEnumTypeTransformer._();

  String encode(DoorEventRoleEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a DoorEventRoleEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DoorEventRoleEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'host': return DoorEventRoleEnum.host;
        case r'committee': return DoorEventRoleEnum.committee;
        case r'door_staff': return DoorEventRoleEnum.doorStaff;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DoorEventRoleEnumTypeTransformer] instance.
  static DoorEventRoleEnumTypeTransformer? _instance;
}



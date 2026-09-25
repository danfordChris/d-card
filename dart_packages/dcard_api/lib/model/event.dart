//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class Event {
  /// Returns a new [Event] instance.
  Event({
    required this.id,
    required this.title,
    required this.status,
    required this.eventType,
    required this.plan,
    required this.startsAt,
    required this.endsAt,
    required this.timeZone,
    required this.venueName,
    required this.venueAddress,
    required this.venueMapUrl,
    required this.contactName,
    required this.contactPhone,
    required this.contact2Name,
    required this.contact2Phone,
    required this.confirmationEnabled,
    required this.confirmationOffsetDays,
    required this.headcountPct,
    required this.autoUpgradeEnabled,
    required this.singleAmount,
    required this.doubleAmount,
    required this.budgetAmount,
    required this.reminderFrequencyDays,
    required this.photoAlbumUrl,
    required this.access,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;

  String title;

  EventStatusEnum status;

  EventType eventType;

  EventPlan plan;

  DateTime startsAt;

  DateTime? endsAt;

  String timeZone;

  String? venueName;

  String? venueAddress;

  String? venueMapUrl;

  String contactName;

  String contactPhone;

  String? contact2Name;

  String? contact2Phone;

  bool confirmationEnabled;

  int confirmationOffsetDays;

  int headcountPct;

  bool autoUpgradeEnabled;

  int? singleAmount;

  int? doubleAmount;

  int? budgetAmount;

  int? reminderFrequencyDays;

  String? photoAlbumUrl;

  EventAccessEnum access;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Event &&
    other.id == id &&
    other.title == title &&
    other.status == status &&
    other.eventType == eventType &&
    other.plan == plan &&
    other.startsAt == startsAt &&
    other.endsAt == endsAt &&
    other.timeZone == timeZone &&
    other.venueName == venueName &&
    other.venueAddress == venueAddress &&
    other.venueMapUrl == venueMapUrl &&
    other.contactName == contactName &&
    other.contactPhone == contactPhone &&
    other.contact2Name == contact2Name &&
    other.contact2Phone == contact2Phone &&
    other.confirmationEnabled == confirmationEnabled &&
    other.confirmationOffsetDays == confirmationOffsetDays &&
    other.headcountPct == headcountPct &&
    other.autoUpgradeEnabled == autoUpgradeEnabled &&
    other.singleAmount == singleAmount &&
    other.doubleAmount == doubleAmount &&
    other.budgetAmount == budgetAmount &&
    other.reminderFrequencyDays == reminderFrequencyDays &&
    other.photoAlbumUrl == photoAlbumUrl &&
    other.access == access &&
    other.createdAt == createdAt &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (title.hashCode) +
    (status.hashCode) +
    (eventType.hashCode) +
    (plan.hashCode) +
    (startsAt.hashCode) +
    (endsAt == null ? 0 : endsAt!.hashCode) +
    (timeZone.hashCode) +
    (venueName == null ? 0 : venueName!.hashCode) +
    (venueAddress == null ? 0 : venueAddress!.hashCode) +
    (venueMapUrl == null ? 0 : venueMapUrl!.hashCode) +
    (contactName.hashCode) +
    (contactPhone.hashCode) +
    (contact2Name == null ? 0 : contact2Name!.hashCode) +
    (contact2Phone == null ? 0 : contact2Phone!.hashCode) +
    (confirmationEnabled.hashCode) +
    (confirmationOffsetDays.hashCode) +
    (headcountPct.hashCode) +
    (autoUpgradeEnabled.hashCode) +
    (singleAmount == null ? 0 : singleAmount!.hashCode) +
    (doubleAmount == null ? 0 : doubleAmount!.hashCode) +
    (budgetAmount == null ? 0 : budgetAmount!.hashCode) +
    (reminderFrequencyDays == null ? 0 : reminderFrequencyDays!.hashCode) +
    (photoAlbumUrl == null ? 0 : photoAlbumUrl!.hashCode) +
    (access.hashCode) +
    (createdAt.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'Event[id=$id, title=$title, status=$status, eventType=$eventType, plan=$plan, startsAt=$startsAt, endsAt=$endsAt, timeZone=$timeZone, venueName=$venueName, venueAddress=$venueAddress, venueMapUrl=$venueMapUrl, contactName=$contactName, contactPhone=$contactPhone, contact2Name=$contact2Name, contact2Phone=$contact2Phone, confirmationEnabled=$confirmationEnabled, confirmationOffsetDays=$confirmationOffsetDays, headcountPct=$headcountPct, autoUpgradeEnabled=$autoUpgradeEnabled, singleAmount=$singleAmount, doubleAmount=$doubleAmount, budgetAmount=$budgetAmount, reminderFrequencyDays=$reminderFrequencyDays, photoAlbumUrl=$photoAlbumUrl, access=$access, createdAt=$createdAt, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'title'] = this.title;
      json[r'status'] = this.status;
      json[r'eventType'] = this.eventType;
      json[r'plan'] = this.plan;
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
    if (this.venueAddress != null) {
      json[r'venueAddress'] = this.venueAddress;
    } else {
      json[r'venueAddress'] = null;
    }
    if (this.venueMapUrl != null) {
      json[r'venueMapUrl'] = this.venueMapUrl;
    } else {
      json[r'venueMapUrl'] = null;
    }
      json[r'contactName'] = this.contactName;
      json[r'contactPhone'] = this.contactPhone;
    if (this.contact2Name != null) {
      json[r'contact2Name'] = this.contact2Name;
    } else {
      json[r'contact2Name'] = null;
    }
    if (this.contact2Phone != null) {
      json[r'contact2Phone'] = this.contact2Phone;
    } else {
      json[r'contact2Phone'] = null;
    }
      json[r'confirmationEnabled'] = this.confirmationEnabled;
      json[r'confirmationOffsetDays'] = this.confirmationOffsetDays;
      json[r'headcountPct'] = this.headcountPct;
      json[r'autoUpgradeEnabled'] = this.autoUpgradeEnabled;
    if (this.singleAmount != null) {
      json[r'singleAmount'] = this.singleAmount;
    } else {
      json[r'singleAmount'] = null;
    }
    if (this.doubleAmount != null) {
      json[r'doubleAmount'] = this.doubleAmount;
    } else {
      json[r'doubleAmount'] = null;
    }
    if (this.budgetAmount != null) {
      json[r'budgetAmount'] = this.budgetAmount;
    } else {
      json[r'budgetAmount'] = null;
    }
    if (this.reminderFrequencyDays != null) {
      json[r'reminderFrequencyDays'] = this.reminderFrequencyDays;
    } else {
      json[r'reminderFrequencyDays'] = null;
    }
    if (this.photoAlbumUrl != null) {
      json[r'photoAlbumUrl'] = this.photoAlbumUrl;
    } else {
      json[r'photoAlbumUrl'] = null;
    }
      json[r'access'] = this.access;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Event] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Event? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Event[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Event[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Event(
        id: mapValueOfType<String>(json, r'id')!,
        title: mapValueOfType<String>(json, r'title')!,
        status: EventStatusEnum.fromJson(json[r'status'])!,
        eventType: EventType.fromJson(json[r'eventType'])!,
        plan: EventPlan.fromJson(json[r'plan'])!,
        startsAt: mapDateTime(json, r'startsAt', r'')!,
        endsAt: mapDateTime(json, r'endsAt', r''),
        timeZone: mapValueOfType<String>(json, r'timeZone')!,
        venueName: mapValueOfType<String>(json, r'venueName'),
        venueAddress: mapValueOfType<String>(json, r'venueAddress'),
        venueMapUrl: mapValueOfType<String>(json, r'venueMapUrl'),
        contactName: mapValueOfType<String>(json, r'contactName')!,
        contactPhone: mapValueOfType<String>(json, r'contactPhone')!,
        contact2Name: mapValueOfType<String>(json, r'contact2Name'),
        contact2Phone: mapValueOfType<String>(json, r'contact2Phone'),
        confirmationEnabled: mapValueOfType<bool>(json, r'confirmationEnabled')!,
        confirmationOffsetDays: mapValueOfType<int>(json, r'confirmationOffsetDays')!,
        headcountPct: mapValueOfType<int>(json, r'headcountPct')!,
        autoUpgradeEnabled: mapValueOfType<bool>(json, r'autoUpgradeEnabled')!,
        singleAmount: mapValueOfType<int>(json, r'singleAmount'),
        doubleAmount: mapValueOfType<int>(json, r'doubleAmount'),
        budgetAmount: mapValueOfType<int>(json, r'budgetAmount'),
        reminderFrequencyDays: mapValueOfType<int>(json, r'reminderFrequencyDays'),
        photoAlbumUrl: mapValueOfType<String>(json, r'photoAlbumUrl'),
        access: EventAccessEnum.fromJson(json[r'access'])!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
      );
    }
    return null;
  }

  static List<Event> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Event>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Event.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Event> mapFromJson(dynamic json) {
    final map = <String, Event>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Event.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Event-objects as value to a dart map
  static Map<String, List<Event>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Event>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Event.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'title',
    'status',
    'eventType',
    'plan',
    'startsAt',
    'endsAt',
    'timeZone',
    'venueName',
    'venueAddress',
    'venueMapUrl',
    'contactName',
    'contactPhone',
    'contact2Name',
    'contact2Phone',
    'confirmationEnabled',
    'confirmationOffsetDays',
    'headcountPct',
    'autoUpgradeEnabled',
    'singleAmount',
    'doubleAmount',
    'budgetAmount',
    'reminderFrequencyDays',
    'photoAlbumUrl',
    'access',
    'createdAt',
    'updatedAt',
  };
}


class EventStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const EventStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const draft = EventStatusEnum._(r'draft');
  static const published = EventStatusEnum._(r'published');
  static const completed = EventStatusEnum._(r'completed');
  static const cancelled = EventStatusEnum._(r'cancelled');

  /// List of all possible values in this [enum][EventStatusEnum].
  static const values = <EventStatusEnum>[
    draft,
    published,
    completed,
    cancelled,
  ];

  static EventStatusEnum? fromJson(dynamic value) => EventStatusEnumTypeTransformer().decode(value);

  static List<EventStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EventStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EventStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [EventStatusEnum] to String,
/// and [decode] dynamic data back to [EventStatusEnum].
class EventStatusEnumTypeTransformer {
  factory EventStatusEnumTypeTransformer() => _instance ??= const EventStatusEnumTypeTransformer._();

  const EventStatusEnumTypeTransformer._();

  String encode(EventStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a EventStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  EventStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'draft': return EventStatusEnum.draft;
        case r'published': return EventStatusEnum.published;
        case r'completed': return EventStatusEnum.completed;
        case r'cancelled': return EventStatusEnum.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [EventStatusEnumTypeTransformer] instance.
  static EventStatusEnumTypeTransformer? _instance;
}



class EventAccessEnum {
  /// Instantiate a new enum with the provided [value].
  const EventAccessEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const host = EventAccessEnum._(r'host');
  static const treasurer = EventAccessEnum._(r'treasurer');
  static const committee = EventAccessEnum._(r'committee');
  static const doorStaff = EventAccessEnum._(r'door_staff');
  static const walkinApprover = EventAccessEnum._(r'walkin_approver');

  /// List of all possible values in this [enum][EventAccessEnum].
  static const values = <EventAccessEnum>[
    host,
    treasurer,
    committee,
    doorStaff,
    walkinApprover,
  ];

  static EventAccessEnum? fromJson(dynamic value) => EventAccessEnumTypeTransformer().decode(value);

  static List<EventAccessEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EventAccessEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EventAccessEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [EventAccessEnum] to String,
/// and [decode] dynamic data back to [EventAccessEnum].
class EventAccessEnumTypeTransformer {
  factory EventAccessEnumTypeTransformer() => _instance ??= const EventAccessEnumTypeTransformer._();

  const EventAccessEnumTypeTransformer._();

  String encode(EventAccessEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a EventAccessEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  EventAccessEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'host': return EventAccessEnum.host;
        case r'treasurer': return EventAccessEnum.treasurer;
        case r'committee': return EventAccessEnum.committee;
        case r'door_staff': return EventAccessEnum.doorStaff;
        case r'walkin_approver': return EventAccessEnum.walkinApprover;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [EventAccessEnumTypeTransformer] instance.
  static EventAccessEnumTypeTransformer? _instance;
}



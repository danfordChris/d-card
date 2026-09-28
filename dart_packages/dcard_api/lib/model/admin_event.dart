//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class AdminEvent {
  /// Returns a new [AdminEvent] instance.
  AdminEvent({
    required this.id,
    required this.title,
    required this.hostEmail,
    required this.startsAt,
    required this.status,
    required this.planKey,
    required this.guestLimit,
    required this.amountPaid,
    required this.guests,
    required this.cardsIssued,
    required this.messagesSent,
    required this.createdAt,
  });

  String id;

  String title;

  String? hostEmail;

  DateTime startsAt;

  AdminEventStatusEnum status;

  String? planKey;

  int guestLimit;

  int amountPaid;

  int guests;

  int cardsIssued;

  int messagesSent;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminEvent &&
    other.id == id &&
    other.title == title &&
    other.hostEmail == hostEmail &&
    other.startsAt == startsAt &&
    other.status == status &&
    other.planKey == planKey &&
    other.guestLimit == guestLimit &&
    other.amountPaid == amountPaid &&
    other.guests == guests &&
    other.cardsIssued == cardsIssued &&
    other.messagesSent == messagesSent &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (title.hashCode) +
    (hostEmail == null ? 0 : hostEmail!.hashCode) +
    (startsAt.hashCode) +
    (status.hashCode) +
    (planKey == null ? 0 : planKey!.hashCode) +
    (guestLimit.hashCode) +
    (amountPaid.hashCode) +
    (guests.hashCode) +
    (cardsIssued.hashCode) +
    (messagesSent.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'AdminEvent[id=$id, title=$title, hostEmail=$hostEmail, startsAt=$startsAt, status=$status, planKey=$planKey, guestLimit=$guestLimit, amountPaid=$amountPaid, guests=$guests, cardsIssued=$cardsIssued, messagesSent=$messagesSent, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'title'] = this.title;
    if (this.hostEmail != null) {
      json[r'hostEmail'] = this.hostEmail;
    } else {
      json[r'hostEmail'] = null;
    }
      json[r'startsAt'] = this.startsAt.toUtc().toIso8601String();
      json[r'status'] = this.status;
    if (this.planKey != null) {
      json[r'planKey'] = this.planKey;
    } else {
      json[r'planKey'] = null;
    }
      json[r'guestLimit'] = this.guestLimit;
      json[r'amountPaid'] = this.amountPaid;
      json[r'guests'] = this.guests;
      json[r'cardsIssued'] = this.cardsIssued;
      json[r'messagesSent'] = this.messagesSent;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [AdminEvent] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminEvent? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AdminEvent[$key]" is missing from JSON.');
        });
        return true;
      }());

      return AdminEvent(
        id: mapValueOfType<String>(json, r'id')!,
        title: mapValueOfType<String>(json, r'title')!,
        hostEmail: mapValueOfType<String>(json, r'hostEmail'),
        startsAt: mapDateTime(json, r'startsAt', r'')!,
        status: AdminEventStatusEnum.fromJson(json[r'status'])!,
        planKey: mapValueOfType<String>(json, r'planKey'),
        guestLimit: mapValueOfType<int>(json, r'guestLimit')!,
        amountPaid: mapValueOfType<int>(json, r'amountPaid')!,
        guests: mapValueOfType<int>(json, r'guests')!,
        cardsIssued: mapValueOfType<int>(json, r'cardsIssued')!,
        messagesSent: mapValueOfType<int>(json, r'messagesSent')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<AdminEvent> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminEvent>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminEvent.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminEvent> mapFromJson(dynamic json) {
    final map = <String, AdminEvent>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminEvent.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminEvent-objects as value to a dart map
  static Map<String, List<AdminEvent>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminEvent>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminEvent.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'title',
    'hostEmail',
    'startsAt',
    'status',
    'planKey',
    'guestLimit',
    'amountPaid',
    'guests',
    'cardsIssued',
    'messagesSent',
    'createdAt',
  };
}


class AdminEventStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminEventStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const draft = AdminEventStatusEnum._(r'draft');
  static const published = AdminEventStatusEnum._(r'published');
  static const completed = AdminEventStatusEnum._(r'completed');
  static const cancelled = AdminEventStatusEnum._(r'cancelled');

  /// List of all possible values in this [enum][AdminEventStatusEnum].
  static const values = <AdminEventStatusEnum>[
    draft,
    published,
    completed,
    cancelled,
  ];

  static AdminEventStatusEnum? fromJson(dynamic value) => AdminEventStatusEnumTypeTransformer().decode(value);

  static List<AdminEventStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminEventStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminEventStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminEventStatusEnum] to String,
/// and [decode] dynamic data back to [AdminEventStatusEnum].
class AdminEventStatusEnumTypeTransformer {
  factory AdminEventStatusEnumTypeTransformer() => _instance ??= const AdminEventStatusEnumTypeTransformer._();

  const AdminEventStatusEnumTypeTransformer._();

  String encode(AdminEventStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminEventStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminEventStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'draft': return AdminEventStatusEnum.draft;
        case r'published': return AdminEventStatusEnum.published;
        case r'completed': return AdminEventStatusEnum.completed;
        case r'cancelled': return AdminEventStatusEnum.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminEventStatusEnumTypeTransformer] instance.
  static AdminEventStatusEnumTypeTransformer? _instance;
}



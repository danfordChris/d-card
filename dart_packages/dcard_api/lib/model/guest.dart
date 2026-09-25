//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class Guest {
  /// Returns a new [Guest] instance.
  Guest({
    required this.id,
    required this.eventId,
    required this.personId,
    required this.name,
    required this.phone,
    required this.partnerName,
    required this.cardType,
    required this.totalEntries,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  String id;

  String eventId;

  String? personId;

  String name;

  String phone;

  String? partnerName;

  CardType cardType;

  int totalEntries;

  GuestStatusEnum status;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Guest &&
    other.id == id &&
    other.eventId == eventId &&
    other.personId == personId &&
    other.name == name &&
    other.phone == phone &&
    other.partnerName == partnerName &&
    other.cardType == cardType &&
    other.totalEntries == totalEntries &&
    other.status == status &&
    other.createdAt == createdAt &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (eventId.hashCode) +
    (personId == null ? 0 : personId!.hashCode) +
    (name.hashCode) +
    (phone.hashCode) +
    (partnerName == null ? 0 : partnerName!.hashCode) +
    (cardType.hashCode) +
    (totalEntries.hashCode) +
    (status.hashCode) +
    (createdAt.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'Guest[id=$id, eventId=$eventId, personId=$personId, name=$name, phone=$phone, partnerName=$partnerName, cardType=$cardType, totalEntries=$totalEntries, status=$status, createdAt=$createdAt, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'eventId'] = this.eventId;
    if (this.personId != null) {
      json[r'personId'] = this.personId;
    } else {
      json[r'personId'] = null;
    }
      json[r'name'] = this.name;
      json[r'phone'] = this.phone;
    if (this.partnerName != null) {
      json[r'partnerName'] = this.partnerName;
    } else {
      json[r'partnerName'] = null;
    }
      json[r'cardType'] = this.cardType;
      json[r'totalEntries'] = this.totalEntries;
      json[r'status'] = this.status;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Guest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Guest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Guest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Guest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Guest(
        id: mapValueOfType<String>(json, r'id')!,
        eventId: mapValueOfType<String>(json, r'eventId')!,
        personId: mapValueOfType<String>(json, r'personId'),
        name: mapValueOfType<String>(json, r'name')!,
        phone: mapValueOfType<String>(json, r'phone')!,
        partnerName: mapValueOfType<String>(json, r'partnerName'),
        cardType: CardType.fromJson(json[r'cardType'])!,
        totalEntries: mapValueOfType<int>(json, r'totalEntries')!,
        status: GuestStatusEnum.fromJson(json[r'status'])!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
      );
    }
    return null;
  }

  static List<Guest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Guest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Guest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Guest> mapFromJson(dynamic json) {
    final map = <String, Guest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Guest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Guest-objects as value to a dart map
  static Map<String, List<Guest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Guest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Guest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'eventId',
    'personId',
    'name',
    'phone',
    'partnerName',
    'cardType',
    'totalEntries',
    'status',
    'createdAt',
    'updatedAt',
  };
}


class GuestStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const GuestStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const pending = GuestStatusEnum._(r'pending');
  static const issued = GuestStatusEnum._(r'issued');
  static const cancelled = GuestStatusEnum._(r'cancelled');

  /// List of all possible values in this [enum][GuestStatusEnum].
  static const values = <GuestStatusEnum>[
    pending,
    issued,
    cancelled,
  ];

  static GuestStatusEnum? fromJson(dynamic value) => GuestStatusEnumTypeTransformer().decode(value);

  static List<GuestStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GuestStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GuestStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [GuestStatusEnum] to String,
/// and [decode] dynamic data back to [GuestStatusEnum].
class GuestStatusEnumTypeTransformer {
  factory GuestStatusEnumTypeTransformer() => _instance ??= const GuestStatusEnumTypeTransformer._();

  const GuestStatusEnumTypeTransformer._();

  String encode(GuestStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a GuestStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  GuestStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'pending': return GuestStatusEnum.pending;
        case r'issued': return GuestStatusEnum.issued;
        case r'cancelled': return GuestStatusEnum.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [GuestStatusEnumTypeTransformer] instance.
  static GuestStatusEnumTypeTransformer? _instance;
}



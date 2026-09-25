//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class PublicCardEvent {
  /// Returns a new [PublicCardEvent] instance.
  PublicCardEvent({
    required this.title,
    required this.typeKey,
    required this.typeNameSw,
    required this.typeNameEn,
    required this.startsAt,
    required this.endsAt,
    required this.timeZone,
    required this.venueName,
    required this.venueAddress,
    required this.venueMapUrl,
    required this.contactName,
    required this.contactPhone,
    required this.status,
  });

  String title;

  String typeKey;

  String typeNameSw;

  String typeNameEn;

  DateTime startsAt;

  DateTime? endsAt;

  String timeZone;

  String? venueName;

  String? venueAddress;

  String? venueMapUrl;

  String contactName;

  String contactPhone;

  PublicCardEventStatusEnum status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PublicCardEvent &&
    other.title == title &&
    other.typeKey == typeKey &&
    other.typeNameSw == typeNameSw &&
    other.typeNameEn == typeNameEn &&
    other.startsAt == startsAt &&
    other.endsAt == endsAt &&
    other.timeZone == timeZone &&
    other.venueName == venueName &&
    other.venueAddress == venueAddress &&
    other.venueMapUrl == venueMapUrl &&
    other.contactName == contactName &&
    other.contactPhone == contactPhone &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (title.hashCode) +
    (typeKey.hashCode) +
    (typeNameSw.hashCode) +
    (typeNameEn.hashCode) +
    (startsAt.hashCode) +
    (endsAt == null ? 0 : endsAt!.hashCode) +
    (timeZone.hashCode) +
    (venueName == null ? 0 : venueName!.hashCode) +
    (venueAddress == null ? 0 : venueAddress!.hashCode) +
    (venueMapUrl == null ? 0 : venueMapUrl!.hashCode) +
    (contactName.hashCode) +
    (contactPhone.hashCode) +
    (status.hashCode);

  @override
  String toString() => 'PublicCardEvent[title=$title, typeKey=$typeKey, typeNameSw=$typeNameSw, typeNameEn=$typeNameEn, startsAt=$startsAt, endsAt=$endsAt, timeZone=$timeZone, venueName=$venueName, venueAddress=$venueAddress, venueMapUrl=$venueMapUrl, contactName=$contactName, contactPhone=$contactPhone, status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'title'] = this.title;
      json[r'typeKey'] = this.typeKey;
      json[r'typeNameSw'] = this.typeNameSw;
      json[r'typeNameEn'] = this.typeNameEn;
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
      json[r'status'] = this.status;
    return json;
  }

  /// Returns a new [PublicCardEvent] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PublicCardEvent? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PublicCardEvent[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PublicCardEvent[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PublicCardEvent(
        title: mapValueOfType<String>(json, r'title')!,
        typeKey: mapValueOfType<String>(json, r'typeKey')!,
        typeNameSw: mapValueOfType<String>(json, r'typeNameSw')!,
        typeNameEn: mapValueOfType<String>(json, r'typeNameEn')!,
        startsAt: mapDateTime(json, r'startsAt', r'')!,
        endsAt: mapDateTime(json, r'endsAt', r''),
        timeZone: mapValueOfType<String>(json, r'timeZone')!,
        venueName: mapValueOfType<String>(json, r'venueName'),
        venueAddress: mapValueOfType<String>(json, r'venueAddress'),
        venueMapUrl: mapValueOfType<String>(json, r'venueMapUrl'),
        contactName: mapValueOfType<String>(json, r'contactName')!,
        contactPhone: mapValueOfType<String>(json, r'contactPhone')!,
        status: PublicCardEventStatusEnum.fromJson(json[r'status'])!,
      );
    }
    return null;
  }

  static List<PublicCardEvent> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PublicCardEvent>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PublicCardEvent.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PublicCardEvent> mapFromJson(dynamic json) {
    final map = <String, PublicCardEvent>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PublicCardEvent.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PublicCardEvent-objects as value to a dart map
  static Map<String, List<PublicCardEvent>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PublicCardEvent>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PublicCardEvent.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'title',
    'typeKey',
    'typeNameSw',
    'typeNameEn',
    'startsAt',
    'endsAt',
    'timeZone',
    'venueName',
    'venueAddress',
    'venueMapUrl',
    'contactName',
    'contactPhone',
    'status',
  };
}


class PublicCardEventStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const PublicCardEventStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const draft = PublicCardEventStatusEnum._(r'draft');
  static const published = PublicCardEventStatusEnum._(r'published');
  static const completed = PublicCardEventStatusEnum._(r'completed');
  static const cancelled = PublicCardEventStatusEnum._(r'cancelled');

  /// List of all possible values in this [enum][PublicCardEventStatusEnum].
  static const values = <PublicCardEventStatusEnum>[
    draft,
    published,
    completed,
    cancelled,
  ];

  static PublicCardEventStatusEnum? fromJson(dynamic value) => PublicCardEventStatusEnumTypeTransformer().decode(value);

  static List<PublicCardEventStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PublicCardEventStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PublicCardEventStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PublicCardEventStatusEnum] to String,
/// and [decode] dynamic data back to [PublicCardEventStatusEnum].
class PublicCardEventStatusEnumTypeTransformer {
  factory PublicCardEventStatusEnumTypeTransformer() => _instance ??= const PublicCardEventStatusEnumTypeTransformer._();

  const PublicCardEventStatusEnumTypeTransformer._();

  String encode(PublicCardEventStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a PublicCardEventStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PublicCardEventStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'draft': return PublicCardEventStatusEnum.draft;
        case r'published': return PublicCardEventStatusEnum.published;
        case r'completed': return PublicCardEventStatusEnum.completed;
        case r'cancelled': return PublicCardEventStatusEnum.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [PublicCardEventStatusEnumTypeTransformer] instance.
  static PublicCardEventStatusEnumTypeTransformer? _instance;
}



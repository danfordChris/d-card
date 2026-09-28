//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class MyCard {
  /// Returns a new [MyCard] instance.
  MyCard({
    required this.eventTitle,
    required this.startsAt,
    required this.endsAt,
    required this.timeZone,
    required this.venueName,
    required this.guestName,
    required this.cardType,
    required this.cardNumber,
    required this.status,
    required this.rsvpStatus,
    required this.linkToken,
  });

  String eventTitle;

  DateTime startsAt;

  DateTime? endsAt;

  String timeZone;

  String? venueName;

  String guestName;

  CardType cardType;

  String cardNumber;

  MyCardStatusEnum status;

  MyCardRsvpStatusEnum rsvpStatus;

  String linkToken;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MyCard &&
    other.eventTitle == eventTitle &&
    other.startsAt == startsAt &&
    other.endsAt == endsAt &&
    other.timeZone == timeZone &&
    other.venueName == venueName &&
    other.guestName == guestName &&
    other.cardType == cardType &&
    other.cardNumber == cardNumber &&
    other.status == status &&
    other.rsvpStatus == rsvpStatus &&
    other.linkToken == linkToken;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (eventTitle.hashCode) +
    (startsAt.hashCode) +
    (endsAt == null ? 0 : endsAt!.hashCode) +
    (timeZone.hashCode) +
    (venueName == null ? 0 : venueName!.hashCode) +
    (guestName.hashCode) +
    (cardType.hashCode) +
    (cardNumber.hashCode) +
    (status.hashCode) +
    (rsvpStatus.hashCode) +
    (linkToken.hashCode);

  @override
  String toString() => 'MyCard[eventTitle=$eventTitle, startsAt=$startsAt, endsAt=$endsAt, timeZone=$timeZone, venueName=$venueName, guestName=$guestName, cardType=$cardType, cardNumber=$cardNumber, status=$status, rsvpStatus=$rsvpStatus, linkToken=$linkToken]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'eventTitle'] = this.eventTitle;
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
      json[r'guestName'] = this.guestName;
      json[r'cardType'] = this.cardType;
      json[r'cardNumber'] = this.cardNumber;
      json[r'status'] = this.status;
      json[r'rsvpStatus'] = this.rsvpStatus;
      json[r'linkToken'] = this.linkToken;
    return json;
  }

  /// Returns a new [MyCard] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MyCard? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MyCard[$key]" is missing from JSON.');
        });
        return true;
      }());

      return MyCard(
        eventTitle: mapValueOfType<String>(json, r'eventTitle')!,
        startsAt: mapDateTime(json, r'startsAt', r'')!,
        endsAt: mapDateTime(json, r'endsAt', r''),
        timeZone: mapValueOfType<String>(json, r'timeZone')!,
        venueName: mapValueOfType<String>(json, r'venueName'),
        guestName: mapValueOfType<String>(json, r'guestName')!,
        cardType: CardType.fromJson(json[r'cardType'])!,
        cardNumber: mapValueOfType<String>(json, r'cardNumber')!,
        status: MyCardStatusEnum.fromJson(json[r'status'])!,
        rsvpStatus: MyCardRsvpStatusEnum.fromJson(json[r'rsvpStatus'])!,
        linkToken: mapValueOfType<String>(json, r'linkToken')!,
      );
    }
    return null;
  }

  static List<MyCard> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MyCard>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MyCard.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MyCard> mapFromJson(dynamic json) {
    final map = <String, MyCard>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MyCard.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MyCard-objects as value to a dart map
  static Map<String, List<MyCard>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MyCard>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MyCard.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'eventTitle',
    'startsAt',
    'endsAt',
    'timeZone',
    'venueName',
    'guestName',
    'cardType',
    'cardNumber',
    'status',
    'rsvpStatus',
    'linkToken',
  };
}


class MyCardStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const MyCardStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const issued = MyCardStatusEnum._(r'issued');
  static const cancelled = MyCardStatusEnum._(r'cancelled');

  /// List of all possible values in this [enum][MyCardStatusEnum].
  static const values = <MyCardStatusEnum>[
    issued,
    cancelled,
  ];

  static MyCardStatusEnum? fromJson(dynamic value) => MyCardStatusEnumTypeTransformer().decode(value);

  static List<MyCardStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MyCardStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MyCardStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MyCardStatusEnum] to String,
/// and [decode] dynamic data back to [MyCardStatusEnum].
class MyCardStatusEnumTypeTransformer {
  factory MyCardStatusEnumTypeTransformer() => _instance ??= const MyCardStatusEnumTypeTransformer._();

  const MyCardStatusEnumTypeTransformer._();

  String encode(MyCardStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MyCardStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MyCardStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'issued': return MyCardStatusEnum.issued;
        case r'cancelled': return MyCardStatusEnum.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MyCardStatusEnumTypeTransformer] instance.
  static MyCardStatusEnumTypeTransformer? _instance;
}



class MyCardRsvpStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const MyCardRsvpStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const none = MyCardRsvpStatusEnum._(r'none');
  static const yes = MyCardRsvpStatusEnum._(r'yes');
  static const no = MyCardRsvpStatusEnum._(r'no');

  /// List of all possible values in this [enum][MyCardRsvpStatusEnum].
  static const values = <MyCardRsvpStatusEnum>[
    none,
    yes,
    no,
  ];

  static MyCardRsvpStatusEnum? fromJson(dynamic value) => MyCardRsvpStatusEnumTypeTransformer().decode(value);

  static List<MyCardRsvpStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MyCardRsvpStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MyCardRsvpStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MyCardRsvpStatusEnum] to String,
/// and [decode] dynamic data back to [MyCardRsvpStatusEnum].
class MyCardRsvpStatusEnumTypeTransformer {
  factory MyCardRsvpStatusEnumTypeTransformer() => _instance ??= const MyCardRsvpStatusEnumTypeTransformer._();

  const MyCardRsvpStatusEnumTypeTransformer._();

  String encode(MyCardRsvpStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MyCardRsvpStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MyCardRsvpStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'none': return MyCardRsvpStatusEnum.none;
        case r'yes': return MyCardRsvpStatusEnum.yes;
        case r'no': return MyCardRsvpStatusEnum.no;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MyCardRsvpStatusEnumTypeTransformer] instance.
  static MyCardRsvpStatusEnumTypeTransformer? _instance;
}



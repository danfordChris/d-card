//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorRefusalCard {
  /// Returns a new [DoorRefusalCard] instance.
  DoorRefusalCard({
    required this.invitationId,
    required this.guestName,
    required this.partnerName,
    required this.cardNumber,
    required this.cardType,
    required this.status,
    required this.totalEntries,
    required this.entriesUsed,
    required this.entriesLeft,
    required this.table,
    required this.overUsed,
    this.entries = const [],
  });

  String invitationId;

  String guestName;

  String partnerName;

  String cardNumber;

  DoorRefusalCardCardTypeEnum cardType;

  DoorRefusalCardStatusEnum status;

  int totalEntries;

  int entriesUsed;

  int entriesLeft;

  String table;

  bool overUsed;

  List<DoorEntry> entries;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorRefusalCard &&
    other.invitationId == invitationId &&
    other.guestName == guestName &&
    other.partnerName == partnerName &&
    other.cardNumber == cardNumber &&
    other.cardType == cardType &&
    other.status == status &&
    other.totalEntries == totalEntries &&
    other.entriesUsed == entriesUsed &&
    other.entriesLeft == entriesLeft &&
    other.table == table &&
    other.overUsed == overUsed &&
    _deepEquality.equals(other.entries, entries);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (invitationId.hashCode) +
    (guestName.hashCode) +
    (partnerName.hashCode) +
    (cardNumber.hashCode) +
    (cardType.hashCode) +
    (status.hashCode) +
    (totalEntries.hashCode) +
    (entriesUsed.hashCode) +
    (entriesLeft.hashCode) +
    (table.hashCode) +
    (overUsed.hashCode) +
    (entries.hashCode);

  @override
  String toString() => 'DoorRefusalCard[invitationId=$invitationId, guestName=$guestName, partnerName=$partnerName, cardNumber=$cardNumber, cardType=$cardType, status=$status, totalEntries=$totalEntries, entriesUsed=$entriesUsed, entriesLeft=$entriesLeft, table=$table, overUsed=$overUsed, entries=$entries]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'invitationId'] = this.invitationId;
      json[r'guestName'] = this.guestName;
      json[r'partnerName'] = this.partnerName;
      json[r'cardNumber'] = this.cardNumber;
      json[r'cardType'] = this.cardType;
      json[r'status'] = this.status;
      json[r'totalEntries'] = this.totalEntries;
      json[r'entriesUsed'] = this.entriesUsed;
      json[r'entriesLeft'] = this.entriesLeft;
      json[r'table'] = this.table;
      json[r'overUsed'] = this.overUsed;
      json[r'entries'] = this.entries;
    return json;
  }

  /// Returns a new [DoorRefusalCard] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorRefusalCard? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorRefusalCard[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorRefusalCard(
        invitationId: mapValueOfType<String>(json, r'invitationId')!,
        guestName: mapValueOfType<String>(json, r'guestName')!,
        partnerName: mapValueOfType<String>(json, r'partnerName')!,
        cardNumber: mapValueOfType<String>(json, r'cardNumber')!,
        cardType: DoorRefusalCardCardTypeEnum.fromJson(json[r'cardType'])!,
        status: DoorRefusalCardStatusEnum.fromJson(json[r'status'])!,
        totalEntries: mapValueOfType<int>(json, r'totalEntries')!,
        entriesUsed: mapValueOfType<int>(json, r'entriesUsed')!,
        entriesLeft: mapValueOfType<int>(json, r'entriesLeft')!,
        table: mapValueOfType<String>(json, r'table')!,
        overUsed: mapValueOfType<bool>(json, r'overUsed')!,
        entries: DoorEntry.listFromJson(json[r'entries']),
      );
    }
    return null;
  }

  static List<DoorRefusalCard> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorRefusalCard>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorRefusalCard.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorRefusalCard> mapFromJson(dynamic json) {
    final map = <String, DoorRefusalCard>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorRefusalCard.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorRefusalCard-objects as value to a dart map
  static Map<String, List<DoorRefusalCard>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorRefusalCard>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorRefusalCard.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'invitationId',
    'guestName',
    'partnerName',
    'cardNumber',
    'cardType',
    'status',
    'totalEntries',
    'entriesUsed',
    'entriesLeft',
    'table',
    'overUsed',
    'entries',
  };
}


class DoorRefusalCardCardTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const DoorRefusalCardCardTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const single = DoorRefusalCardCardTypeEnum._(r'single');
  static const double_ = DoorRefusalCardCardTypeEnum._(r'double');

  /// List of all possible values in this [enum][DoorRefusalCardCardTypeEnum].
  static const values = <DoorRefusalCardCardTypeEnum>[
    single,
    double_,
  ];

  static DoorRefusalCardCardTypeEnum? fromJson(dynamic value) => DoorRefusalCardCardTypeEnumTypeTransformer().decode(value);

  static List<DoorRefusalCardCardTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorRefusalCardCardTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorRefusalCardCardTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DoorRefusalCardCardTypeEnum] to String,
/// and [decode] dynamic data back to [DoorRefusalCardCardTypeEnum].
class DoorRefusalCardCardTypeEnumTypeTransformer {
  factory DoorRefusalCardCardTypeEnumTypeTransformer() => _instance ??= const DoorRefusalCardCardTypeEnumTypeTransformer._();

  const DoorRefusalCardCardTypeEnumTypeTransformer._();

  String encode(DoorRefusalCardCardTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a DoorRefusalCardCardTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DoorRefusalCardCardTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'single': return DoorRefusalCardCardTypeEnum.single;
        case r'double': return DoorRefusalCardCardTypeEnum.double_;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DoorRefusalCardCardTypeEnumTypeTransformer] instance.
  static DoorRefusalCardCardTypeEnumTypeTransformer? _instance;
}



class DoorRefusalCardStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const DoorRefusalCardStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const pending = DoorRefusalCardStatusEnum._(r'pending');
  static const issued = DoorRefusalCardStatusEnum._(r'issued');
  static const cancelled = DoorRefusalCardStatusEnum._(r'cancelled');

  /// List of all possible values in this [enum][DoorRefusalCardStatusEnum].
  static const values = <DoorRefusalCardStatusEnum>[
    pending,
    issued,
    cancelled,
  ];

  static DoorRefusalCardStatusEnum? fromJson(dynamic value) => DoorRefusalCardStatusEnumTypeTransformer().decode(value);

  static List<DoorRefusalCardStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorRefusalCardStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorRefusalCardStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DoorRefusalCardStatusEnum] to String,
/// and [decode] dynamic data back to [DoorRefusalCardStatusEnum].
class DoorRefusalCardStatusEnumTypeTransformer {
  factory DoorRefusalCardStatusEnumTypeTransformer() => _instance ??= const DoorRefusalCardStatusEnumTypeTransformer._();

  const DoorRefusalCardStatusEnumTypeTransformer._();

  String encode(DoorRefusalCardStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a DoorRefusalCardStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DoorRefusalCardStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'pending': return DoorRefusalCardStatusEnum.pending;
        case r'issued': return DoorRefusalCardStatusEnum.issued;
        case r'cancelled': return DoorRefusalCardStatusEnum.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DoorRefusalCardStatusEnumTypeTransformer] instance.
  static DoorRefusalCardStatusEnumTypeTransformer? _instance;
}



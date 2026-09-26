//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorCard {
  /// Returns a new [DoorCard] instance.
  DoorCard({
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

  String? partnerName;

  String? cardNumber;

  DoorCardCardTypeEnum cardType;

  DoorCardStatusEnum status;

  int totalEntries;

  int entriesUsed;

  int entriesLeft;

  String? table;

  bool overUsed;

  List<DoorEntry> entries;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorCard &&
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
    (partnerName == null ? 0 : partnerName!.hashCode) +
    (cardNumber == null ? 0 : cardNumber!.hashCode) +
    (cardType.hashCode) +
    (status.hashCode) +
    (totalEntries.hashCode) +
    (entriesUsed.hashCode) +
    (entriesLeft.hashCode) +
    (table == null ? 0 : table!.hashCode) +
    (overUsed.hashCode) +
    (entries.hashCode);

  @override
  String toString() => 'DoorCard[invitationId=$invitationId, guestName=$guestName, partnerName=$partnerName, cardNumber=$cardNumber, cardType=$cardType, status=$status, totalEntries=$totalEntries, entriesUsed=$entriesUsed, entriesLeft=$entriesLeft, table=$table, overUsed=$overUsed, entries=$entries]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'invitationId'] = this.invitationId;
      json[r'guestName'] = this.guestName;
    if (this.partnerName != null) {
      json[r'partnerName'] = this.partnerName;
    } else {
      json[r'partnerName'] = null;
    }
    if (this.cardNumber != null) {
      json[r'cardNumber'] = this.cardNumber;
    } else {
      json[r'cardNumber'] = null;
    }
      json[r'cardType'] = this.cardType;
      json[r'status'] = this.status;
      json[r'totalEntries'] = this.totalEntries;
      json[r'entriesUsed'] = this.entriesUsed;
      json[r'entriesLeft'] = this.entriesLeft;
    if (this.table != null) {
      json[r'table'] = this.table;
    } else {
      json[r'table'] = null;
    }
      json[r'overUsed'] = this.overUsed;
      json[r'entries'] = this.entries;
    return json;
  }

  /// Returns a new [DoorCard] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorCard? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorCard[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorCard(
        invitationId: mapValueOfType<String>(json, r'invitationId')!,
        guestName: mapValueOfType<String>(json, r'guestName')!,
        partnerName: mapValueOfType<String>(json, r'partnerName'),
        cardNumber: mapValueOfType<String>(json, r'cardNumber'),
        cardType: DoorCardCardTypeEnum.fromJson(json[r'cardType'])!,
        status: DoorCardStatusEnum.fromJson(json[r'status'])!,
        totalEntries: mapValueOfType<int>(json, r'totalEntries')!,
        entriesUsed: mapValueOfType<int>(json, r'entriesUsed')!,
        entriesLeft: mapValueOfType<int>(json, r'entriesLeft')!,
        table: mapValueOfType<String>(json, r'table'),
        overUsed: mapValueOfType<bool>(json, r'overUsed')!,
        entries: DoorEntry.listFromJson(json[r'entries']),
      );
    }
    return null;
  }

  static List<DoorCard> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorCard>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorCard.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorCard> mapFromJson(dynamic json) {
    final map = <String, DoorCard>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorCard.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorCard-objects as value to a dart map
  static Map<String, List<DoorCard>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorCard>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorCard.listFromJson(entry.value, growable: growable,);
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


class DoorCardCardTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const DoorCardCardTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const single = DoorCardCardTypeEnum._(r'single');
  static const double_ = DoorCardCardTypeEnum._(r'double');

  /// List of all possible values in this [enum][DoorCardCardTypeEnum].
  static const values = <DoorCardCardTypeEnum>[
    single,
    double_,
  ];

  static DoorCardCardTypeEnum? fromJson(dynamic value) => DoorCardCardTypeEnumTypeTransformer().decode(value);

  static List<DoorCardCardTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorCardCardTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorCardCardTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DoorCardCardTypeEnum] to String,
/// and [decode] dynamic data back to [DoorCardCardTypeEnum].
class DoorCardCardTypeEnumTypeTransformer {
  factory DoorCardCardTypeEnumTypeTransformer() => _instance ??= const DoorCardCardTypeEnumTypeTransformer._();

  const DoorCardCardTypeEnumTypeTransformer._();

  String encode(DoorCardCardTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a DoorCardCardTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DoorCardCardTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'single': return DoorCardCardTypeEnum.single;
        case r'double': return DoorCardCardTypeEnum.double_;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DoorCardCardTypeEnumTypeTransformer] instance.
  static DoorCardCardTypeEnumTypeTransformer? _instance;
}



class DoorCardStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const DoorCardStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const pending = DoorCardStatusEnum._(r'pending');
  static const issued = DoorCardStatusEnum._(r'issued');
  static const cancelled = DoorCardStatusEnum._(r'cancelled');

  /// List of all possible values in this [enum][DoorCardStatusEnum].
  static const values = <DoorCardStatusEnum>[
    pending,
    issued,
    cancelled,
  ];

  static DoorCardStatusEnum? fromJson(dynamic value) => DoorCardStatusEnumTypeTransformer().decode(value);

  static List<DoorCardStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorCardStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorCardStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DoorCardStatusEnum] to String,
/// and [decode] dynamic data back to [DoorCardStatusEnum].
class DoorCardStatusEnumTypeTransformer {
  factory DoorCardStatusEnumTypeTransformer() => _instance ??= const DoorCardStatusEnumTypeTransformer._();

  const DoorCardStatusEnumTypeTransformer._();

  String encode(DoorCardStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a DoorCardStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DoorCardStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'pending': return DoorCardStatusEnum.pending;
        case r'issued': return DoorCardStatusEnum.issued;
        case r'cancelled': return DoorCardStatusEnum.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DoorCardStatusEnumTypeTransformer] instance.
  static DoorCardStatusEnumTypeTransformer? _instance;
}



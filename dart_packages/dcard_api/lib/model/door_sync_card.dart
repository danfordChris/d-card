//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorSyncCard {
  /// Returns a new [DoorSyncCard] instance.
  DoorSyncCard({
    required this.invitationId,
    required this.guestName,
    required this.partnerName,
    required this.cardNumber,
    required this.qrTokenDigest,
    required this.cardType,
    required this.status,
    required this.totalEntries,
    required this.entriesUsed,
    required this.table,
    required this.overUsed,
    required this.updatedAt,
  });

  String invitationId;

  String guestName;

  String? partnerName;

  String? cardNumber;

  String? qrTokenDigest;

  DoorSyncCardCardTypeEnum cardType;

  DoorSyncCardStatusEnum status;

  int totalEntries;

  int entriesUsed;

  String? table;

  bool overUsed;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorSyncCard &&
    other.invitationId == invitationId &&
    other.guestName == guestName &&
    other.partnerName == partnerName &&
    other.cardNumber == cardNumber &&
    other.qrTokenDigest == qrTokenDigest &&
    other.cardType == cardType &&
    other.status == status &&
    other.totalEntries == totalEntries &&
    other.entriesUsed == entriesUsed &&
    other.table == table &&
    other.overUsed == overUsed &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (invitationId.hashCode) +
    (guestName.hashCode) +
    (partnerName == null ? 0 : partnerName!.hashCode) +
    (cardNumber == null ? 0 : cardNumber!.hashCode) +
    (qrTokenDigest == null ? 0 : qrTokenDigest!.hashCode) +
    (cardType.hashCode) +
    (status.hashCode) +
    (totalEntries.hashCode) +
    (entriesUsed.hashCode) +
    (table == null ? 0 : table!.hashCode) +
    (overUsed.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'DoorSyncCard[invitationId=$invitationId, guestName=$guestName, partnerName=$partnerName, cardNumber=$cardNumber, qrTokenDigest=$qrTokenDigest, cardType=$cardType, status=$status, totalEntries=$totalEntries, entriesUsed=$entriesUsed, table=$table, overUsed=$overUsed, updatedAt=$updatedAt]';

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
    if (this.qrTokenDigest != null) {
      json[r'qrTokenDigest'] = this.qrTokenDigest;
    } else {
      json[r'qrTokenDigest'] = null;
    }
      json[r'cardType'] = this.cardType;
      json[r'status'] = this.status;
      json[r'totalEntries'] = this.totalEntries;
      json[r'entriesUsed'] = this.entriesUsed;
    if (this.table != null) {
      json[r'table'] = this.table;
    } else {
      json[r'table'] = null;
    }
      json[r'overUsed'] = this.overUsed;
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [DoorSyncCard] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorSyncCard? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorSyncCard[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorSyncCard(
        invitationId: mapValueOfType<String>(json, r'invitationId')!,
        guestName: mapValueOfType<String>(json, r'guestName')!,
        partnerName: mapValueOfType<String>(json, r'partnerName'),
        cardNumber: mapValueOfType<String>(json, r'cardNumber'),
        qrTokenDigest: mapValueOfType<String>(json, r'qrTokenDigest'),
        cardType: DoorSyncCardCardTypeEnum.fromJson(json[r'cardType'])!,
        status: DoorSyncCardStatusEnum.fromJson(json[r'status'])!,
        totalEntries: mapValueOfType<int>(json, r'totalEntries')!,
        entriesUsed: mapValueOfType<int>(json, r'entriesUsed')!,
        table: mapValueOfType<String>(json, r'table'),
        overUsed: mapValueOfType<bool>(json, r'overUsed')!,
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
      );
    }
    return null;
  }

  static List<DoorSyncCard> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorSyncCard>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorSyncCard.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorSyncCard> mapFromJson(dynamic json) {
    final map = <String, DoorSyncCard>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorSyncCard.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorSyncCard-objects as value to a dart map
  static Map<String, List<DoorSyncCard>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorSyncCard>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorSyncCard.listFromJson(entry.value, growable: growable,);
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
    'qrTokenDigest',
    'cardType',
    'status',
    'totalEntries',
    'entriesUsed',
    'table',
    'overUsed',
    'updatedAt',
  };
}


class DoorSyncCardCardTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const DoorSyncCardCardTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const single = DoorSyncCardCardTypeEnum._(r'single');
  static const double_ = DoorSyncCardCardTypeEnum._(r'double');

  /// List of all possible values in this [enum][DoorSyncCardCardTypeEnum].
  static const values = <DoorSyncCardCardTypeEnum>[
    single,
    double_,
  ];

  static DoorSyncCardCardTypeEnum? fromJson(dynamic value) => DoorSyncCardCardTypeEnumTypeTransformer().decode(value);

  static List<DoorSyncCardCardTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorSyncCardCardTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorSyncCardCardTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DoorSyncCardCardTypeEnum] to String,
/// and [decode] dynamic data back to [DoorSyncCardCardTypeEnum].
class DoorSyncCardCardTypeEnumTypeTransformer {
  factory DoorSyncCardCardTypeEnumTypeTransformer() => _instance ??= const DoorSyncCardCardTypeEnumTypeTransformer._();

  const DoorSyncCardCardTypeEnumTypeTransformer._();

  String encode(DoorSyncCardCardTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a DoorSyncCardCardTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DoorSyncCardCardTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'single': return DoorSyncCardCardTypeEnum.single;
        case r'double': return DoorSyncCardCardTypeEnum.double_;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DoorSyncCardCardTypeEnumTypeTransformer] instance.
  static DoorSyncCardCardTypeEnumTypeTransformer? _instance;
}



class DoorSyncCardStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const DoorSyncCardStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const pending = DoorSyncCardStatusEnum._(r'pending');
  static const issued = DoorSyncCardStatusEnum._(r'issued');
  static const cancelled = DoorSyncCardStatusEnum._(r'cancelled');

  /// List of all possible values in this [enum][DoorSyncCardStatusEnum].
  static const values = <DoorSyncCardStatusEnum>[
    pending,
    issued,
    cancelled,
  ];

  static DoorSyncCardStatusEnum? fromJson(dynamic value) => DoorSyncCardStatusEnumTypeTransformer().decode(value);

  static List<DoorSyncCardStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorSyncCardStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorSyncCardStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DoorSyncCardStatusEnum] to String,
/// and [decode] dynamic data back to [DoorSyncCardStatusEnum].
class DoorSyncCardStatusEnumTypeTransformer {
  factory DoorSyncCardStatusEnumTypeTransformer() => _instance ??= const DoorSyncCardStatusEnumTypeTransformer._();

  const DoorSyncCardStatusEnumTypeTransformer._();

  String encode(DoorSyncCardStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a DoorSyncCardStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DoorSyncCardStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'pending': return DoorSyncCardStatusEnum.pending;
        case r'issued': return DoorSyncCardStatusEnum.issued;
        case r'cancelled': return DoorSyncCardStatusEnum.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DoorSyncCardStatusEnumTypeTransformer] instance.
  static DoorSyncCardStatusEnumTypeTransformer? _instance;
}



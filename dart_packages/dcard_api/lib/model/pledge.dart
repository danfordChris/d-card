//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class Pledge {
  /// Returns a new [Pledge] instance.
  Pledge({
    required this.id,
    required this.guestId,
    required this.name,
    required this.phone,
    required this.partnerName,
    required this.cardType,
    required this.amountPledged,
    required this.amountPaid,
    required this.amountExtra,
    required this.balance,
    required this.status,
    required this.upgradedAt,
    required this.invitationStatus,
    required this.cardNumber,
  });

  String id;

  String guestId;

  String name;

  String phone;

  String? partnerName;

  CardType cardType;

  int amountPledged;

  int amountPaid;

  int amountExtra;

  int balance;

  PledgeStatus status;

  DateTime? upgradedAt;

  PledgeInvitationStatusEnum invitationStatus;

  String? cardNumber;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Pledge &&
    other.id == id &&
    other.guestId == guestId &&
    other.name == name &&
    other.phone == phone &&
    other.partnerName == partnerName &&
    other.cardType == cardType &&
    other.amountPledged == amountPledged &&
    other.amountPaid == amountPaid &&
    other.amountExtra == amountExtra &&
    other.balance == balance &&
    other.status == status &&
    other.upgradedAt == upgradedAt &&
    other.invitationStatus == invitationStatus &&
    other.cardNumber == cardNumber;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (guestId.hashCode) +
    (name.hashCode) +
    (phone.hashCode) +
    (partnerName == null ? 0 : partnerName!.hashCode) +
    (cardType.hashCode) +
    (amountPledged.hashCode) +
    (amountPaid.hashCode) +
    (amountExtra.hashCode) +
    (balance.hashCode) +
    (status.hashCode) +
    (upgradedAt == null ? 0 : upgradedAt!.hashCode) +
    (invitationStatus.hashCode) +
    (cardNumber == null ? 0 : cardNumber!.hashCode);

  @override
  String toString() => 'Pledge[id=$id, guestId=$guestId, name=$name, phone=$phone, partnerName=$partnerName, cardType=$cardType, amountPledged=$amountPledged, amountPaid=$amountPaid, amountExtra=$amountExtra, balance=$balance, status=$status, upgradedAt=$upgradedAt, invitationStatus=$invitationStatus, cardNumber=$cardNumber]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'guestId'] = this.guestId;
      json[r'name'] = this.name;
      json[r'phone'] = this.phone;
    if (this.partnerName != null) {
      json[r'partnerName'] = this.partnerName;
    } else {
      json[r'partnerName'] = null;
    }
      json[r'cardType'] = this.cardType;
      json[r'amountPledged'] = this.amountPledged;
      json[r'amountPaid'] = this.amountPaid;
      json[r'amountExtra'] = this.amountExtra;
      json[r'balance'] = this.balance;
      json[r'status'] = this.status;
    if (this.upgradedAt != null) {
      json[r'upgradedAt'] = this.upgradedAt!.toUtc().toIso8601String();
    } else {
      json[r'upgradedAt'] = null;
    }
      json[r'invitationStatus'] = this.invitationStatus;
    if (this.cardNumber != null) {
      json[r'cardNumber'] = this.cardNumber;
    } else {
      json[r'cardNumber'] = null;
    }
    return json;
  }

  /// Returns a new [Pledge] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Pledge? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Pledge[$key]" is missing from JSON.');
        });
        return true;
      }());

      return Pledge(
        id: mapValueOfType<String>(json, r'id')!,
        guestId: mapValueOfType<String>(json, r'guestId')!,
        name: mapValueOfType<String>(json, r'name')!,
        phone: mapValueOfType<String>(json, r'phone')!,
        partnerName: mapValueOfType<String>(json, r'partnerName'),
        cardType: CardType.fromJson(json[r'cardType'])!,
        amountPledged: mapValueOfType<int>(json, r'amountPledged')!,
        amountPaid: mapValueOfType<int>(json, r'amountPaid')!,
        amountExtra: mapValueOfType<int>(json, r'amountExtra')!,
        balance: mapValueOfType<int>(json, r'balance')!,
        status: PledgeStatus.fromJson(json[r'status'])!,
        upgradedAt: mapDateTime(json, r'upgradedAt', r''),
        invitationStatus: PledgeInvitationStatusEnum.fromJson(json[r'invitationStatus'])!,
        cardNumber: mapValueOfType<String>(json, r'cardNumber'),
      );
    }
    return null;
  }

  static List<Pledge> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Pledge>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Pledge.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Pledge> mapFromJson(dynamic json) {
    final map = <String, Pledge>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Pledge.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Pledge-objects as value to a dart map
  static Map<String, List<Pledge>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Pledge>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Pledge.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'guestId',
    'name',
    'phone',
    'partnerName',
    'cardType',
    'amountPledged',
    'amountPaid',
    'amountExtra',
    'balance',
    'status',
    'upgradedAt',
    'invitationStatus',
    'cardNumber',
  };
}


class PledgeInvitationStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const PledgeInvitationStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const pending = PledgeInvitationStatusEnum._(r'pending');
  static const issued = PledgeInvitationStatusEnum._(r'issued');
  static const cancelled = PledgeInvitationStatusEnum._(r'cancelled');

  /// List of all possible values in this [enum][PledgeInvitationStatusEnum].
  static const values = <PledgeInvitationStatusEnum>[
    pending,
    issued,
    cancelled,
  ];

  static PledgeInvitationStatusEnum? fromJson(dynamic value) => PledgeInvitationStatusEnumTypeTransformer().decode(value);

  static List<PledgeInvitationStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PledgeInvitationStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PledgeInvitationStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PledgeInvitationStatusEnum] to String,
/// and [decode] dynamic data back to [PledgeInvitationStatusEnum].
class PledgeInvitationStatusEnumTypeTransformer {
  factory PledgeInvitationStatusEnumTypeTransformer() => _instance ??= const PledgeInvitationStatusEnumTypeTransformer._();

  const PledgeInvitationStatusEnumTypeTransformer._();

  String encode(PledgeInvitationStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a PledgeInvitationStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PledgeInvitationStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'pending': return PledgeInvitationStatusEnum.pending;
        case r'issued': return PledgeInvitationStatusEnum.issued;
        case r'cancelled': return PledgeInvitationStatusEnum.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [PledgeInvitationStatusEnumTypeTransformer] instance.
  static PledgeInvitationStatusEnumTypeTransformer? _instance;
}



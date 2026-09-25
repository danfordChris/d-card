//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class Card {
  /// Returns a new [Card] instance.
  Card({
    required this.guestId,
    required this.status,
    required this.cardNumber,
    required this.cardType,
    required this.issuedAt,
    required this.cancelledAt,
  });

  String guestId;

  CardStatusEnum status;

  String? cardNumber;

  CardType cardType;

  DateTime? issuedAt;

  DateTime? cancelledAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Card &&
    other.guestId == guestId &&
    other.status == status &&
    other.cardNumber == cardNumber &&
    other.cardType == cardType &&
    other.issuedAt == issuedAt &&
    other.cancelledAt == cancelledAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (guestId.hashCode) +
    (status.hashCode) +
    (cardNumber == null ? 0 : cardNumber!.hashCode) +
    (cardType.hashCode) +
    (issuedAt == null ? 0 : issuedAt!.hashCode) +
    (cancelledAt == null ? 0 : cancelledAt!.hashCode);

  @override
  String toString() => 'Card[guestId=$guestId, status=$status, cardNumber=$cardNumber, cardType=$cardType, issuedAt=$issuedAt, cancelledAt=$cancelledAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'guestId'] = this.guestId;
      json[r'status'] = this.status;
    if (this.cardNumber != null) {
      json[r'cardNumber'] = this.cardNumber;
    } else {
      json[r'cardNumber'] = null;
    }
      json[r'cardType'] = this.cardType;
    if (this.issuedAt != null) {
      json[r'issuedAt'] = this.issuedAt!.toUtc().toIso8601String();
    } else {
      json[r'issuedAt'] = null;
    }
    if (this.cancelledAt != null) {
      json[r'cancelledAt'] = this.cancelledAt!.toUtc().toIso8601String();
    } else {
      json[r'cancelledAt'] = null;
    }
    return json;
  }

  /// Returns a new [Card] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Card? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Card[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Card[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Card(
        guestId: mapValueOfType<String>(json, r'guestId')!,
        status: CardStatusEnum.fromJson(json[r'status'])!,
        cardNumber: mapValueOfType<String>(json, r'cardNumber'),
        cardType: CardType.fromJson(json[r'cardType'])!,
        issuedAt: mapDateTime(json, r'issuedAt', r''),
        cancelledAt: mapDateTime(json, r'cancelledAt', r''),
      );
    }
    return null;
  }

  static List<Card> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Card>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Card.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Card> mapFromJson(dynamic json) {
    final map = <String, Card>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Card.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Card-objects as value to a dart map
  static Map<String, List<Card>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Card>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Card.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'guestId',
    'status',
    'cardNumber',
    'cardType',
    'issuedAt',
    'cancelledAt',
  };
}


class CardStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const CardStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const pending = CardStatusEnum._(r'pending');
  static const issued = CardStatusEnum._(r'issued');
  static const cancelled = CardStatusEnum._(r'cancelled');

  /// List of all possible values in this [enum][CardStatusEnum].
  static const values = <CardStatusEnum>[
    pending,
    issued,
    cancelled,
  ];

  static CardStatusEnum? fromJson(dynamic value) => CardStatusEnumTypeTransformer().decode(value);

  static List<CardStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CardStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CardStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CardStatusEnum] to String,
/// and [decode] dynamic data back to [CardStatusEnum].
class CardStatusEnumTypeTransformer {
  factory CardStatusEnumTypeTransformer() => _instance ??= const CardStatusEnumTypeTransformer._();

  const CardStatusEnumTypeTransformer._();

  String encode(CardStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a CardStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CardStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'pending': return CardStatusEnum.pending;
        case r'issued': return CardStatusEnum.issued;
        case r'cancelled': return CardStatusEnum.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CardStatusEnumTypeTransformer] instance.
  static CardStatusEnumTypeTransformer? _instance;
}



//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class CardLink {
  /// Returns a new [CardLink] instance.
  CardLink({
    required this.guestId,
    required this.status,
    required this.cardNumber,
    required this.cardType,
    required this.issuedAt,
    required this.cancelledAt,
    required this.link,
  });

  String guestId;

  CardLinkStatusEnum status;

  String cardNumber;

  CardType cardType;

  DateTime issuedAt;

  DateTime cancelledAt;

  String link;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CardLink &&
    other.guestId == guestId &&
    other.status == status &&
    other.cardNumber == cardNumber &&
    other.cardType == cardType &&
    other.issuedAt == issuedAt &&
    other.cancelledAt == cancelledAt &&
    other.link == link;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (guestId.hashCode) +
    (status.hashCode) +
    (cardNumber.hashCode) +
    (cardType.hashCode) +
    (issuedAt.hashCode) +
    (cancelledAt.hashCode) +
    (link.hashCode);

  @override
  String toString() => 'CardLink[guestId=$guestId, status=$status, cardNumber=$cardNumber, cardType=$cardType, issuedAt=$issuedAt, cancelledAt=$cancelledAt, link=$link]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'guestId'] = this.guestId;
      json[r'status'] = this.status;
      json[r'cardNumber'] = this.cardNumber;
      json[r'cardType'] = this.cardType;
      json[r'issuedAt'] = this.issuedAt.toUtc().toIso8601String();
      json[r'cancelledAt'] = this.cancelledAt.toUtc().toIso8601String();
      json[r'link'] = this.link;
    return json;
  }

  /// Returns a new [CardLink] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CardLink? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CardLink[$key]" is missing from JSON.');
        });
        return true;
      }());

      return CardLink(
        guestId: mapValueOfType<String>(json, r'guestId')!,
        status: CardLinkStatusEnum.fromJson(json[r'status'])!,
        cardNumber: mapValueOfType<String>(json, r'cardNumber')!,
        cardType: CardType.fromJson(json[r'cardType'])!,
        issuedAt: mapDateTime(json, r'issuedAt', r'')!,
        cancelledAt: mapDateTime(json, r'cancelledAt', r'')!,
        link: mapValueOfType<String>(json, r'link')!,
      );
    }
    return null;
  }

  static List<CardLink> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CardLink>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CardLink.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CardLink> mapFromJson(dynamic json) {
    final map = <String, CardLink>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CardLink.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CardLink-objects as value to a dart map
  static Map<String, List<CardLink>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CardLink>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CardLink.listFromJson(entry.value, growable: growable,);
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
    'link',
  };
}


class CardLinkStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const CardLinkStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const pending = CardLinkStatusEnum._(r'pending');
  static const issued = CardLinkStatusEnum._(r'issued');
  static const cancelled = CardLinkStatusEnum._(r'cancelled');

  /// List of all possible values in this [enum][CardLinkStatusEnum].
  static const values = <CardLinkStatusEnum>[
    pending,
    issued,
    cancelled,
  ];

  static CardLinkStatusEnum? fromJson(dynamic value) => CardLinkStatusEnumTypeTransformer().decode(value);

  static List<CardLinkStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CardLinkStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CardLinkStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [CardLinkStatusEnum] to String,
/// and [decode] dynamic data back to [CardLinkStatusEnum].
class CardLinkStatusEnumTypeTransformer {
  factory CardLinkStatusEnumTypeTransformer() => _instance ??= const CardLinkStatusEnumTypeTransformer._();

  const CardLinkStatusEnumTypeTransformer._();

  String encode(CardLinkStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a CardLinkStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  CardLinkStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'pending': return CardLinkStatusEnum.pending;
        case r'issued': return CardLinkStatusEnum.issued;
        case r'cancelled': return CardLinkStatusEnum.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [CardLinkStatusEnumTypeTransformer] instance.
  static CardLinkStatusEnumTypeTransformer? _instance;
}



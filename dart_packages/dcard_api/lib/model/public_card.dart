//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class PublicCard {
  /// Returns a new [PublicCard] instance.
  PublicCard({
    required this.status,
    required this.guestName,
    required this.partnerName,
    required this.cardType,
    required this.cardNumber,
    required this.qrToken,
    required this.rsvp,
    required this.event,
  });

  PublicCardStatusEnum status;

  String guestName;

  String? partnerName;

  CardType cardType;

  String cardNumber;

  String? qrToken;

  Rsvp rsvp;

  PublicCardEvent event;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PublicCard &&
    other.status == status &&
    other.guestName == guestName &&
    other.partnerName == partnerName &&
    other.cardType == cardType &&
    other.cardNumber == cardNumber &&
    other.qrToken == qrToken &&
    other.rsvp == rsvp &&
    other.event == event;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (status.hashCode) +
    (guestName.hashCode) +
    (partnerName == null ? 0 : partnerName!.hashCode) +
    (cardType.hashCode) +
    (cardNumber.hashCode) +
    (qrToken == null ? 0 : qrToken!.hashCode) +
    (rsvp.hashCode) +
    (event.hashCode);

  @override
  String toString() => 'PublicCard[status=$status, guestName=$guestName, partnerName=$partnerName, cardType=$cardType, cardNumber=$cardNumber, qrToken=$qrToken, rsvp=$rsvp, event=$event]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'status'] = this.status;
      json[r'guestName'] = this.guestName;
    if (this.partnerName != null) {
      json[r'partnerName'] = this.partnerName;
    } else {
      json[r'partnerName'] = null;
    }
      json[r'cardType'] = this.cardType;
      json[r'cardNumber'] = this.cardNumber;
    if (this.qrToken != null) {
      json[r'qrToken'] = this.qrToken;
    } else {
      json[r'qrToken'] = null;
    }
      json[r'rsvp'] = this.rsvp;
      json[r'event'] = this.event;
    return json;
  }

  /// Returns a new [PublicCard] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PublicCard? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PublicCard[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PublicCard[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PublicCard(
        status: PublicCardStatusEnum.fromJson(json[r'status'])!,
        guestName: mapValueOfType<String>(json, r'guestName')!,
        partnerName: mapValueOfType<String>(json, r'partnerName'),
        cardType: CardType.fromJson(json[r'cardType'])!,
        cardNumber: mapValueOfType<String>(json, r'cardNumber')!,
        qrToken: mapValueOfType<String>(json, r'qrToken'),
        rsvp: Rsvp.fromJson(json[r'rsvp'])!,
        event: PublicCardEvent.fromJson(json[r'event'])!,
      );
    }
    return null;
  }

  static List<PublicCard> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PublicCard>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PublicCard.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PublicCard> mapFromJson(dynamic json) {
    final map = <String, PublicCard>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PublicCard.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PublicCard-objects as value to a dart map
  static Map<String, List<PublicCard>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PublicCard>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PublicCard.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'status',
    'guestName',
    'partnerName',
    'cardType',
    'cardNumber',
    'qrToken',
    'rsvp',
    'event',
  };
}


class PublicCardStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const PublicCardStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const issued = PublicCardStatusEnum._(r'issued');
  static const cancelled = PublicCardStatusEnum._(r'cancelled');

  /// List of all possible values in this [enum][PublicCardStatusEnum].
  static const values = <PublicCardStatusEnum>[
    issued,
    cancelled,
  ];

  static PublicCardStatusEnum? fromJson(dynamic value) => PublicCardStatusEnumTypeTransformer().decode(value);

  static List<PublicCardStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PublicCardStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PublicCardStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PublicCardStatusEnum] to String,
/// and [decode] dynamic data back to [PublicCardStatusEnum].
class PublicCardStatusEnumTypeTransformer {
  factory PublicCardStatusEnumTypeTransformer() => _instance ??= const PublicCardStatusEnumTypeTransformer._();

  const PublicCardStatusEnumTypeTransformer._();

  String encode(PublicCardStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a PublicCardStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PublicCardStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'issued': return PublicCardStatusEnum.issued;
        case r'cancelled': return PublicCardStatusEnum.cancelled;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [PublicCardStatusEnumTypeTransformer] instance.
  static PublicCardStatusEnumTypeTransformer? _instance;
}



//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class MessageSettingsTemplatesInner {
  /// Returns a new [MessageSettingsTemplatesInner] instance.
  MessageSettingsTemplatesInner({
    required this.messageType,
    required this.variantName,
    required this.language,
  });

  MessageSettingsTemplatesInnerMessageTypeEnum messageType;

  String variantName;

  MessageSettingsTemplatesInnerLanguageEnum language;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MessageSettingsTemplatesInner &&
    other.messageType == messageType &&
    other.variantName == variantName &&
    other.language == language;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (messageType.hashCode) +
    (variantName.hashCode) +
    (language.hashCode);

  @override
  String toString() => 'MessageSettingsTemplatesInner[messageType=$messageType, variantName=$variantName, language=$language]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'messageType'] = this.messageType;
      json[r'variantName'] = this.variantName;
      json[r'language'] = this.language;
    return json;
  }

  /// Returns a new [MessageSettingsTemplatesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MessageSettingsTemplatesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MessageSettingsTemplatesInner[$key]" is missing from JSON.');
        });
        return true;
      }());

      return MessageSettingsTemplatesInner(
        messageType: MessageSettingsTemplatesInnerMessageTypeEnum.fromJson(json[r'messageType'])!,
        variantName: mapValueOfType<String>(json, r'variantName')!,
        language: MessageSettingsTemplatesInnerLanguageEnum.fromJson(json[r'language'])!,
      );
    }
    return null;
  }

  static List<MessageSettingsTemplatesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageSettingsTemplatesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageSettingsTemplatesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MessageSettingsTemplatesInner> mapFromJson(dynamic json) {
    final map = <String, MessageSettingsTemplatesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MessageSettingsTemplatesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MessageSettingsTemplatesInner-objects as value to a dart map
  static Map<String, List<MessageSettingsTemplatesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MessageSettingsTemplatesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MessageSettingsTemplatesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'messageType',
    'variantName',
    'language',
  };
}


class MessageSettingsTemplatesInnerMessageTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const MessageSettingsTemplatesInnerMessageTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const contributionRequest = MessageSettingsTemplatesInnerMessageTypeEnum._(r'contribution_request');
  static const thankYou = MessageSettingsTemplatesInnerMessageTypeEnum._(r'thank_you');
  static const contributionReminder = MessageSettingsTemplatesInnerMessageTypeEnum._(r'contribution_reminder');
  static const invitationCard = MessageSettingsTemplatesInnerMessageTypeEnum._(r'invitation_card');
  static const cardUpgraded = MessageSettingsTemplatesInnerMessageTypeEnum._(r'card_upgraded');
  static const attendanceConfirmation = MessageSettingsTemplatesInnerMessageTypeEnum._(r'attendance_confirmation');
  static const eventReminder = MessageSettingsTemplatesInnerMessageTypeEnum._(r'event_reminder');
  static const postEventThanks = MessageSettingsTemplatesInnerMessageTypeEnum._(r'post_event_thanks');

  /// List of all possible values in this [enum][MessageSettingsTemplatesInnerMessageTypeEnum].
  static const values = <MessageSettingsTemplatesInnerMessageTypeEnum>[
    contributionRequest,
    thankYou,
    contributionReminder,
    invitationCard,
    cardUpgraded,
    attendanceConfirmation,
    eventReminder,
    postEventThanks,
  ];

  static MessageSettingsTemplatesInnerMessageTypeEnum? fromJson(dynamic value) => MessageSettingsTemplatesInnerMessageTypeEnumTypeTransformer().decode(value);

  static List<MessageSettingsTemplatesInnerMessageTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageSettingsTemplatesInnerMessageTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageSettingsTemplatesInnerMessageTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MessageSettingsTemplatesInnerMessageTypeEnum] to String,
/// and [decode] dynamic data back to [MessageSettingsTemplatesInnerMessageTypeEnum].
class MessageSettingsTemplatesInnerMessageTypeEnumTypeTransformer {
  factory MessageSettingsTemplatesInnerMessageTypeEnumTypeTransformer() => _instance ??= const MessageSettingsTemplatesInnerMessageTypeEnumTypeTransformer._();

  const MessageSettingsTemplatesInnerMessageTypeEnumTypeTransformer._();

  String encode(MessageSettingsTemplatesInnerMessageTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MessageSettingsTemplatesInnerMessageTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MessageSettingsTemplatesInnerMessageTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'contribution_request': return MessageSettingsTemplatesInnerMessageTypeEnum.contributionRequest;
        case r'thank_you': return MessageSettingsTemplatesInnerMessageTypeEnum.thankYou;
        case r'contribution_reminder': return MessageSettingsTemplatesInnerMessageTypeEnum.contributionReminder;
        case r'invitation_card': return MessageSettingsTemplatesInnerMessageTypeEnum.invitationCard;
        case r'card_upgraded': return MessageSettingsTemplatesInnerMessageTypeEnum.cardUpgraded;
        case r'attendance_confirmation': return MessageSettingsTemplatesInnerMessageTypeEnum.attendanceConfirmation;
        case r'event_reminder': return MessageSettingsTemplatesInnerMessageTypeEnum.eventReminder;
        case r'post_event_thanks': return MessageSettingsTemplatesInnerMessageTypeEnum.postEventThanks;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MessageSettingsTemplatesInnerMessageTypeEnumTypeTransformer] instance.
  static MessageSettingsTemplatesInnerMessageTypeEnumTypeTransformer? _instance;
}



class MessageSettingsTemplatesInnerLanguageEnum {
  /// Instantiate a new enum with the provided [value].
  const MessageSettingsTemplatesInnerLanguageEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const sw = MessageSettingsTemplatesInnerLanguageEnum._(r'sw');
  static const en = MessageSettingsTemplatesInnerLanguageEnum._(r'en');

  /// List of all possible values in this [enum][MessageSettingsTemplatesInnerLanguageEnum].
  static const values = <MessageSettingsTemplatesInnerLanguageEnum>[
    sw,
    en,
  ];

  static MessageSettingsTemplatesInnerLanguageEnum? fromJson(dynamic value) => MessageSettingsTemplatesInnerLanguageEnumTypeTransformer().decode(value);

  static List<MessageSettingsTemplatesInnerLanguageEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageSettingsTemplatesInnerLanguageEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageSettingsTemplatesInnerLanguageEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MessageSettingsTemplatesInnerLanguageEnum] to String,
/// and [decode] dynamic data back to [MessageSettingsTemplatesInnerLanguageEnum].
class MessageSettingsTemplatesInnerLanguageEnumTypeTransformer {
  factory MessageSettingsTemplatesInnerLanguageEnumTypeTransformer() => _instance ??= const MessageSettingsTemplatesInnerLanguageEnumTypeTransformer._();

  const MessageSettingsTemplatesInnerLanguageEnumTypeTransformer._();

  String encode(MessageSettingsTemplatesInnerLanguageEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MessageSettingsTemplatesInnerLanguageEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MessageSettingsTemplatesInnerLanguageEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'sw': return MessageSettingsTemplatesInnerLanguageEnum.sw;
        case r'en': return MessageSettingsTemplatesInnerLanguageEnum.en;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MessageSettingsTemplatesInnerLanguageEnumTypeTransformer] instance.
  static MessageSettingsTemplatesInnerLanguageEnumTypeTransformer? _instance;
}



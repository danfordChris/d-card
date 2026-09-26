//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class MessageSettingsSettingsInner {
  /// Returns a new [MessageSettingsSettingsInner] instance.
  MessageSettingsSettingsInner({
    required this.messageType,
    required this.enabled,
    required this.channels,
    required this.smsTextSw,
    required this.smsTextEn,
    required this.whatsappTemplateVariant,
    required this.whatsappNote,
    required this.schedule,
  });

  MessageSettingsSettingsInnerMessageTypeEnum messageType;

  bool enabled;

  MessageSettingsSettingsInnerChannelsEnum channels;

  String smsTextSw;

  String smsTextEn;

  String whatsappTemplateVariant;

  String whatsappNote;

  UpdateMessageSettingsRequestSettingsInnerSchedule schedule;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MessageSettingsSettingsInner &&
    other.messageType == messageType &&
    other.enabled == enabled &&
    other.channels == channels &&
    other.smsTextSw == smsTextSw &&
    other.smsTextEn == smsTextEn &&
    other.whatsappTemplateVariant == whatsappTemplateVariant &&
    other.whatsappNote == whatsappNote &&
    other.schedule == schedule;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (messageType.hashCode) +
    (enabled.hashCode) +
    (channels.hashCode) +
    (smsTextSw.hashCode) +
    (smsTextEn.hashCode) +
    (whatsappTemplateVariant.hashCode) +
    (whatsappNote.hashCode) +
    (schedule.hashCode);

  @override
  String toString() => 'MessageSettingsSettingsInner[messageType=$messageType, enabled=$enabled, channels=$channels, smsTextSw=$smsTextSw, smsTextEn=$smsTextEn, whatsappTemplateVariant=$whatsappTemplateVariant, whatsappNote=$whatsappNote, schedule=$schedule]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'messageType'] = this.messageType;
      json[r'enabled'] = this.enabled;
      json[r'channels'] = this.channels;
      json[r'smsTextSw'] = this.smsTextSw;
      json[r'smsTextEn'] = this.smsTextEn;
      json[r'whatsappTemplateVariant'] = this.whatsappTemplateVariant;
      json[r'whatsappNote'] = this.whatsappNote;
      json[r'schedule'] = this.schedule;
    return json;
  }

  /// Returns a new [MessageSettingsSettingsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MessageSettingsSettingsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MessageSettingsSettingsInner[$key]" is missing from JSON.');
        });
        return true;
      }());

      return MessageSettingsSettingsInner(
        messageType: MessageSettingsSettingsInnerMessageTypeEnum.fromJson(json[r'messageType'])!,
        enabled: mapValueOfType<bool>(json, r'enabled')!,
        channels: MessageSettingsSettingsInnerChannelsEnum.fromJson(json[r'channels'])!,
        smsTextSw: mapValueOfType<String>(json, r'smsTextSw')!,
        smsTextEn: mapValueOfType<String>(json, r'smsTextEn')!,
        whatsappTemplateVariant: mapValueOfType<String>(json, r'whatsappTemplateVariant')!,
        whatsappNote: mapValueOfType<String>(json, r'whatsappNote')!,
        schedule: UpdateMessageSettingsRequestSettingsInnerSchedule.fromJson(json[r'schedule'])!,
      );
    }
    return null;
  }

  static List<MessageSettingsSettingsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageSettingsSettingsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageSettingsSettingsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MessageSettingsSettingsInner> mapFromJson(dynamic json) {
    final map = <String, MessageSettingsSettingsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MessageSettingsSettingsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MessageSettingsSettingsInner-objects as value to a dart map
  static Map<String, List<MessageSettingsSettingsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MessageSettingsSettingsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MessageSettingsSettingsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'messageType',
    'enabled',
    'channels',
    'smsTextSw',
    'smsTextEn',
    'whatsappTemplateVariant',
    'whatsappNote',
    'schedule',
  };
}


class MessageSettingsSettingsInnerMessageTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const MessageSettingsSettingsInnerMessageTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const contributionRequest = MessageSettingsSettingsInnerMessageTypeEnum._(r'contribution_request');
  static const thankYou = MessageSettingsSettingsInnerMessageTypeEnum._(r'thank_you');
  static const contributionReminder = MessageSettingsSettingsInnerMessageTypeEnum._(r'contribution_reminder');
  static const invitationCard = MessageSettingsSettingsInnerMessageTypeEnum._(r'invitation_card');
  static const cardUpgraded = MessageSettingsSettingsInnerMessageTypeEnum._(r'card_upgraded');
  static const attendanceConfirmation = MessageSettingsSettingsInnerMessageTypeEnum._(r'attendance_confirmation');
  static const eventReminder = MessageSettingsSettingsInnerMessageTypeEnum._(r'event_reminder');
  static const postEventThanks = MessageSettingsSettingsInnerMessageTypeEnum._(r'post_event_thanks');

  /// List of all possible values in this [enum][MessageSettingsSettingsInnerMessageTypeEnum].
  static const values = <MessageSettingsSettingsInnerMessageTypeEnum>[
    contributionRequest,
    thankYou,
    contributionReminder,
    invitationCard,
    cardUpgraded,
    attendanceConfirmation,
    eventReminder,
    postEventThanks,
  ];

  static MessageSettingsSettingsInnerMessageTypeEnum? fromJson(dynamic value) => MessageSettingsSettingsInnerMessageTypeEnumTypeTransformer().decode(value);

  static List<MessageSettingsSettingsInnerMessageTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageSettingsSettingsInnerMessageTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageSettingsSettingsInnerMessageTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MessageSettingsSettingsInnerMessageTypeEnum] to String,
/// and [decode] dynamic data back to [MessageSettingsSettingsInnerMessageTypeEnum].
class MessageSettingsSettingsInnerMessageTypeEnumTypeTransformer {
  factory MessageSettingsSettingsInnerMessageTypeEnumTypeTransformer() => _instance ??= const MessageSettingsSettingsInnerMessageTypeEnumTypeTransformer._();

  const MessageSettingsSettingsInnerMessageTypeEnumTypeTransformer._();

  String encode(MessageSettingsSettingsInnerMessageTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MessageSettingsSettingsInnerMessageTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MessageSettingsSettingsInnerMessageTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'contribution_request': return MessageSettingsSettingsInnerMessageTypeEnum.contributionRequest;
        case r'thank_you': return MessageSettingsSettingsInnerMessageTypeEnum.thankYou;
        case r'contribution_reminder': return MessageSettingsSettingsInnerMessageTypeEnum.contributionReminder;
        case r'invitation_card': return MessageSettingsSettingsInnerMessageTypeEnum.invitationCard;
        case r'card_upgraded': return MessageSettingsSettingsInnerMessageTypeEnum.cardUpgraded;
        case r'attendance_confirmation': return MessageSettingsSettingsInnerMessageTypeEnum.attendanceConfirmation;
        case r'event_reminder': return MessageSettingsSettingsInnerMessageTypeEnum.eventReminder;
        case r'post_event_thanks': return MessageSettingsSettingsInnerMessageTypeEnum.postEventThanks;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MessageSettingsSettingsInnerMessageTypeEnumTypeTransformer] instance.
  static MessageSettingsSettingsInnerMessageTypeEnumTypeTransformer? _instance;
}



class MessageSettingsSettingsInnerChannelsEnum {
  /// Instantiate a new enum with the provided [value].
  const MessageSettingsSettingsInnerChannelsEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const both = MessageSettingsSettingsInnerChannelsEnum._(r'both');
  static const sms = MessageSettingsSettingsInnerChannelsEnum._(r'sms');
  static const whatsapp = MessageSettingsSettingsInnerChannelsEnum._(r'whatsapp');

  /// List of all possible values in this [enum][MessageSettingsSettingsInnerChannelsEnum].
  static const values = <MessageSettingsSettingsInnerChannelsEnum>[
    both,
    sms,
    whatsapp,
  ];

  static MessageSettingsSettingsInnerChannelsEnum? fromJson(dynamic value) => MessageSettingsSettingsInnerChannelsEnumTypeTransformer().decode(value);

  static List<MessageSettingsSettingsInnerChannelsEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageSettingsSettingsInnerChannelsEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageSettingsSettingsInnerChannelsEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MessageSettingsSettingsInnerChannelsEnum] to String,
/// and [decode] dynamic data back to [MessageSettingsSettingsInnerChannelsEnum].
class MessageSettingsSettingsInnerChannelsEnumTypeTransformer {
  factory MessageSettingsSettingsInnerChannelsEnumTypeTransformer() => _instance ??= const MessageSettingsSettingsInnerChannelsEnumTypeTransformer._();

  const MessageSettingsSettingsInnerChannelsEnumTypeTransformer._();

  String encode(MessageSettingsSettingsInnerChannelsEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MessageSettingsSettingsInnerChannelsEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MessageSettingsSettingsInnerChannelsEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'both': return MessageSettingsSettingsInnerChannelsEnum.both;
        case r'sms': return MessageSettingsSettingsInnerChannelsEnum.sms;
        case r'whatsapp': return MessageSettingsSettingsInnerChannelsEnum.whatsapp;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MessageSettingsSettingsInnerChannelsEnumTypeTransformer] instance.
  static MessageSettingsSettingsInnerChannelsEnumTypeTransformer? _instance;
}



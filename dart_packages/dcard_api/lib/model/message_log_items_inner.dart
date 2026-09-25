//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class MessageLogItemsInner {
  /// Returns a new [MessageLogItemsInner] instance.
  MessageLogItemsInner({
    required this.id,
    required this.guestName,
    required this.toPhone,
    required this.messageType,
    required this.channel,
    required this.status,
    required this.error,
    required this.createdAt,
    required this.sentAt,
    required this.deliveredAt,
  });

  String id;

  String? guestName;

  String? toPhone;

  MessageLogItemsInnerMessageTypeEnum? messageType;

  MessageLogItemsInnerChannelEnum channel;

  MessageLogItemsInnerStatusEnum status;

  String? error;

  String createdAt;

  String? sentAt;

  String? deliveredAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MessageLogItemsInner &&
    other.id == id &&
    other.guestName == guestName &&
    other.toPhone == toPhone &&
    other.messageType == messageType &&
    other.channel == channel &&
    other.status == status &&
    other.error == error &&
    other.createdAt == createdAt &&
    other.sentAt == sentAt &&
    other.deliveredAt == deliveredAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (guestName == null ? 0 : guestName!.hashCode) +
    (toPhone == null ? 0 : toPhone!.hashCode) +
    (messageType == null ? 0 : messageType!.hashCode) +
    (channel.hashCode) +
    (status.hashCode) +
    (error == null ? 0 : error!.hashCode) +
    (createdAt.hashCode) +
    (sentAt == null ? 0 : sentAt!.hashCode) +
    (deliveredAt == null ? 0 : deliveredAt!.hashCode);

  @override
  String toString() => 'MessageLogItemsInner[id=$id, guestName=$guestName, toPhone=$toPhone, messageType=$messageType, channel=$channel, status=$status, error=$error, createdAt=$createdAt, sentAt=$sentAt, deliveredAt=$deliveredAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    if (this.guestName != null) {
      json[r'guestName'] = this.guestName;
    } else {
      json[r'guestName'] = null;
    }
    if (this.toPhone != null) {
      json[r'toPhone'] = this.toPhone;
    } else {
      json[r'toPhone'] = null;
    }
    if (this.messageType != null) {
      json[r'messageType'] = this.messageType;
    } else {
      json[r'messageType'] = null;
    }
      json[r'channel'] = this.channel;
      json[r'status'] = this.status;
    if (this.error != null) {
      json[r'error'] = this.error;
    } else {
      json[r'error'] = null;
    }
      json[r'createdAt'] = this.createdAt;
    if (this.sentAt != null) {
      json[r'sentAt'] = this.sentAt;
    } else {
      json[r'sentAt'] = null;
    }
    if (this.deliveredAt != null) {
      json[r'deliveredAt'] = this.deliveredAt;
    } else {
      json[r'deliveredAt'] = null;
    }
    return json;
  }

  /// Returns a new [MessageLogItemsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MessageLogItemsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MessageLogItemsInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MessageLogItemsInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MessageLogItemsInner(
        id: mapValueOfType<String>(json, r'id')!,
        guestName: mapValueOfType<String>(json, r'guestName'),
        toPhone: mapValueOfType<String>(json, r'toPhone'),
        messageType: MessageLogItemsInnerMessageTypeEnum.fromJson(json[r'messageType']),
        channel: MessageLogItemsInnerChannelEnum.fromJson(json[r'channel'])!,
        status: MessageLogItemsInnerStatusEnum.fromJson(json[r'status'])!,
        error: mapValueOfType<String>(json, r'error'),
        createdAt: mapValueOfType<String>(json, r'createdAt')!,
        sentAt: mapValueOfType<String>(json, r'sentAt'),
        deliveredAt: mapValueOfType<String>(json, r'deliveredAt'),
      );
    }
    return null;
  }

  static List<MessageLogItemsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageLogItemsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageLogItemsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MessageLogItemsInner> mapFromJson(dynamic json) {
    final map = <String, MessageLogItemsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MessageLogItemsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MessageLogItemsInner-objects as value to a dart map
  static Map<String, List<MessageLogItemsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MessageLogItemsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MessageLogItemsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'guestName',
    'toPhone',
    'messageType',
    'channel',
    'status',
    'error',
    'createdAt',
    'sentAt',
    'deliveredAt',
  };
}


class MessageLogItemsInnerMessageTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const MessageLogItemsInnerMessageTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const contributionRequest = MessageLogItemsInnerMessageTypeEnum._(r'contribution_request');
  static const thankYou = MessageLogItemsInnerMessageTypeEnum._(r'thank_you');
  static const contributionReminder = MessageLogItemsInnerMessageTypeEnum._(r'contribution_reminder');
  static const invitationCard = MessageLogItemsInnerMessageTypeEnum._(r'invitation_card');
  static const cardUpgraded = MessageLogItemsInnerMessageTypeEnum._(r'card_upgraded');
  static const attendanceConfirmation = MessageLogItemsInnerMessageTypeEnum._(r'attendance_confirmation');
  static const eventReminder = MessageLogItemsInnerMessageTypeEnum._(r'event_reminder');
  static const postEventThanks = MessageLogItemsInnerMessageTypeEnum._(r'post_event_thanks');

  /// List of all possible values in this [enum][MessageLogItemsInnerMessageTypeEnum].
  static const values = <MessageLogItemsInnerMessageTypeEnum>[
    contributionRequest,
    thankYou,
    contributionReminder,
    invitationCard,
    cardUpgraded,
    attendanceConfirmation,
    eventReminder,
    postEventThanks,
  ];

  static MessageLogItemsInnerMessageTypeEnum? fromJson(dynamic value) => MessageLogItemsInnerMessageTypeEnumTypeTransformer().decode(value);

  static List<MessageLogItemsInnerMessageTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageLogItemsInnerMessageTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageLogItemsInnerMessageTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MessageLogItemsInnerMessageTypeEnum] to String,
/// and [decode] dynamic data back to [MessageLogItemsInnerMessageTypeEnum].
class MessageLogItemsInnerMessageTypeEnumTypeTransformer {
  factory MessageLogItemsInnerMessageTypeEnumTypeTransformer() => _instance ??= const MessageLogItemsInnerMessageTypeEnumTypeTransformer._();

  const MessageLogItemsInnerMessageTypeEnumTypeTransformer._();

  String encode(MessageLogItemsInnerMessageTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MessageLogItemsInnerMessageTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MessageLogItemsInnerMessageTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'contribution_request': return MessageLogItemsInnerMessageTypeEnum.contributionRequest;
        case r'thank_you': return MessageLogItemsInnerMessageTypeEnum.thankYou;
        case r'contribution_reminder': return MessageLogItemsInnerMessageTypeEnum.contributionReminder;
        case r'invitation_card': return MessageLogItemsInnerMessageTypeEnum.invitationCard;
        case r'card_upgraded': return MessageLogItemsInnerMessageTypeEnum.cardUpgraded;
        case r'attendance_confirmation': return MessageLogItemsInnerMessageTypeEnum.attendanceConfirmation;
        case r'event_reminder': return MessageLogItemsInnerMessageTypeEnum.eventReminder;
        case r'post_event_thanks': return MessageLogItemsInnerMessageTypeEnum.postEventThanks;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MessageLogItemsInnerMessageTypeEnumTypeTransformer] instance.
  static MessageLogItemsInnerMessageTypeEnumTypeTransformer? _instance;
}



class MessageLogItemsInnerChannelEnum {
  /// Instantiate a new enum with the provided [value].
  const MessageLogItemsInnerChannelEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const sms = MessageLogItemsInnerChannelEnum._(r'sms');
  static const whatsapp = MessageLogItemsInnerChannelEnum._(r'whatsapp');

  /// List of all possible values in this [enum][MessageLogItemsInnerChannelEnum].
  static const values = <MessageLogItemsInnerChannelEnum>[
    sms,
    whatsapp,
  ];

  static MessageLogItemsInnerChannelEnum? fromJson(dynamic value) => MessageLogItemsInnerChannelEnumTypeTransformer().decode(value);

  static List<MessageLogItemsInnerChannelEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageLogItemsInnerChannelEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageLogItemsInnerChannelEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MessageLogItemsInnerChannelEnum] to String,
/// and [decode] dynamic data back to [MessageLogItemsInnerChannelEnum].
class MessageLogItemsInnerChannelEnumTypeTransformer {
  factory MessageLogItemsInnerChannelEnumTypeTransformer() => _instance ??= const MessageLogItemsInnerChannelEnumTypeTransformer._();

  const MessageLogItemsInnerChannelEnumTypeTransformer._();

  String encode(MessageLogItemsInnerChannelEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MessageLogItemsInnerChannelEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MessageLogItemsInnerChannelEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'sms': return MessageLogItemsInnerChannelEnum.sms;
        case r'whatsapp': return MessageLogItemsInnerChannelEnum.whatsapp;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MessageLogItemsInnerChannelEnumTypeTransformer] instance.
  static MessageLogItemsInnerChannelEnumTypeTransformer? _instance;
}



class MessageLogItemsInnerStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const MessageLogItemsInnerStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const queued = MessageLogItemsInnerStatusEnum._(r'queued');
  static const sent = MessageLogItemsInnerStatusEnum._(r'sent');
  static const delivered = MessageLogItemsInnerStatusEnum._(r'delivered');
  static const read = MessageLogItemsInnerStatusEnum._(r'read');
  static const failed = MessageLogItemsInnerStatusEnum._(r'failed');
  static const held = MessageLogItemsInnerStatusEnum._(r'held');

  /// List of all possible values in this [enum][MessageLogItemsInnerStatusEnum].
  static const values = <MessageLogItemsInnerStatusEnum>[
    queued,
    sent,
    delivered,
    read,
    failed,
    held,
  ];

  static MessageLogItemsInnerStatusEnum? fromJson(dynamic value) => MessageLogItemsInnerStatusEnumTypeTransformer().decode(value);

  static List<MessageLogItemsInnerStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageLogItemsInnerStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageLogItemsInnerStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [MessageLogItemsInnerStatusEnum] to String,
/// and [decode] dynamic data back to [MessageLogItemsInnerStatusEnum].
class MessageLogItemsInnerStatusEnumTypeTransformer {
  factory MessageLogItemsInnerStatusEnumTypeTransformer() => _instance ??= const MessageLogItemsInnerStatusEnumTypeTransformer._();

  const MessageLogItemsInnerStatusEnumTypeTransformer._();

  String encode(MessageLogItemsInnerStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a MessageLogItemsInnerStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  MessageLogItemsInnerStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'queued': return MessageLogItemsInnerStatusEnum.queued;
        case r'sent': return MessageLogItemsInnerStatusEnum.sent;
        case r'delivered': return MessageLogItemsInnerStatusEnum.delivered;
        case r'read': return MessageLogItemsInnerStatusEnum.read;
        case r'failed': return MessageLogItemsInnerStatusEnum.failed;
        case r'held': return MessageLogItemsInnerStatusEnum.held;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [MessageLogItemsInnerStatusEnumTypeTransformer] instance.
  static MessageLogItemsInnerStatusEnumTypeTransformer? _instance;
}



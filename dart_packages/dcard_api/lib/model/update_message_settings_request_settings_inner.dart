//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class UpdateMessageSettingsRequestSettingsInner {
  /// Returns a new [UpdateMessageSettingsRequestSettingsInner] instance.
  UpdateMessageSettingsRequestSettingsInner({
    required this.messageType,
    required this.enabled,
    required this.channels,
    required this.smsTextSw,
    required this.smsTextEn,
    required this.whatsappTemplateVariant,
    required this.whatsappNote,
    required this.schedule,
  });

  UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum messageType;

  bool enabled;

  UpdateMessageSettingsRequestSettingsInnerChannelsEnum channels;

  String smsTextSw;

  String smsTextEn;

  String whatsappTemplateVariant;

  String whatsappNote;

  UpdateMessageSettingsRequestSettingsInnerSchedule schedule;

  @override
  bool operator ==(Object other) => identical(this, other) || other is UpdateMessageSettingsRequestSettingsInner &&
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
  String toString() => 'UpdateMessageSettingsRequestSettingsInner[messageType=$messageType, enabled=$enabled, channels=$channels, smsTextSw=$smsTextSw, smsTextEn=$smsTextEn, whatsappTemplateVariant=$whatsappTemplateVariant, whatsappNote=$whatsappNote, schedule=$schedule]';

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

  /// Returns a new [UpdateMessageSettingsRequestSettingsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static UpdateMessageSettingsRequestSettingsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "UpdateMessageSettingsRequestSettingsInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "UpdateMessageSettingsRequestSettingsInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return UpdateMessageSettingsRequestSettingsInner(
        messageType: UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum.fromJson(json[r'messageType'])!,
        enabled: mapValueOfType<bool>(json, r'enabled')!,
        channels: UpdateMessageSettingsRequestSettingsInnerChannelsEnum.fromJson(json[r'channels'])!,
        smsTextSw: mapValueOfType<String>(json, r'smsTextSw')!,
        smsTextEn: mapValueOfType<String>(json, r'smsTextEn')!,
        whatsappTemplateVariant: mapValueOfType<String>(json, r'whatsappTemplateVariant')!,
        whatsappNote: mapValueOfType<String>(json, r'whatsappNote')!,
        schedule: UpdateMessageSettingsRequestSettingsInnerSchedule.fromJson(json[r'schedule'])!,
      );
    }
    return null;
  }

  static List<UpdateMessageSettingsRequestSettingsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateMessageSettingsRequestSettingsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateMessageSettingsRequestSettingsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, UpdateMessageSettingsRequestSettingsInner> mapFromJson(dynamic json) {
    final map = <String, UpdateMessageSettingsRequestSettingsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = UpdateMessageSettingsRequestSettingsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of UpdateMessageSettingsRequestSettingsInner-objects as value to a dart map
  static Map<String, List<UpdateMessageSettingsRequestSettingsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<UpdateMessageSettingsRequestSettingsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = UpdateMessageSettingsRequestSettingsInner.listFromJson(entry.value, growable: growable,);
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


class UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const contributionRequest = UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum._(r'contribution_request');
  static const thankYou = UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum._(r'thank_you');
  static const contributionReminder = UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum._(r'contribution_reminder');
  static const invitationCard = UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum._(r'invitation_card');
  static const cardUpgraded = UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum._(r'card_upgraded');
  static const attendanceConfirmation = UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum._(r'attendance_confirmation');
  static const eventReminder = UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum._(r'event_reminder');
  static const postEventThanks = UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum._(r'post_event_thanks');

  /// List of all possible values in this [enum][UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum].
  static const values = <UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum>[
    contributionRequest,
    thankYou,
    contributionReminder,
    invitationCard,
    cardUpgraded,
    attendanceConfirmation,
    eventReminder,
    postEventThanks,
  ];

  static UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum? fromJson(dynamic value) => UpdateMessageSettingsRequestSettingsInnerMessageTypeEnumTypeTransformer().decode(value);

  static List<UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum] to String,
/// and [decode] dynamic data back to [UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum].
class UpdateMessageSettingsRequestSettingsInnerMessageTypeEnumTypeTransformer {
  factory UpdateMessageSettingsRequestSettingsInnerMessageTypeEnumTypeTransformer() => _instance ??= const UpdateMessageSettingsRequestSettingsInnerMessageTypeEnumTypeTransformer._();

  const UpdateMessageSettingsRequestSettingsInnerMessageTypeEnumTypeTransformer._();

  String encode(UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'contribution_request': return UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum.contributionRequest;
        case r'thank_you': return UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum.thankYou;
        case r'contribution_reminder': return UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum.contributionReminder;
        case r'invitation_card': return UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum.invitationCard;
        case r'card_upgraded': return UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum.cardUpgraded;
        case r'attendance_confirmation': return UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum.attendanceConfirmation;
        case r'event_reminder': return UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum.eventReminder;
        case r'post_event_thanks': return UpdateMessageSettingsRequestSettingsInnerMessageTypeEnum.postEventThanks;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [UpdateMessageSettingsRequestSettingsInnerMessageTypeEnumTypeTransformer] instance.
  static UpdateMessageSettingsRequestSettingsInnerMessageTypeEnumTypeTransformer? _instance;
}



class UpdateMessageSettingsRequestSettingsInnerChannelsEnum {
  /// Instantiate a new enum with the provided [value].
  const UpdateMessageSettingsRequestSettingsInnerChannelsEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const both = UpdateMessageSettingsRequestSettingsInnerChannelsEnum._(r'both');
  static const sms = UpdateMessageSettingsRequestSettingsInnerChannelsEnum._(r'sms');
  static const whatsapp = UpdateMessageSettingsRequestSettingsInnerChannelsEnum._(r'whatsapp');

  /// List of all possible values in this [enum][UpdateMessageSettingsRequestSettingsInnerChannelsEnum].
  static const values = <UpdateMessageSettingsRequestSettingsInnerChannelsEnum>[
    both,
    sms,
    whatsapp,
  ];

  static UpdateMessageSettingsRequestSettingsInnerChannelsEnum? fromJson(dynamic value) => UpdateMessageSettingsRequestSettingsInnerChannelsEnumTypeTransformer().decode(value);

  static List<UpdateMessageSettingsRequestSettingsInnerChannelsEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <UpdateMessageSettingsRequestSettingsInnerChannelsEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = UpdateMessageSettingsRequestSettingsInnerChannelsEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [UpdateMessageSettingsRequestSettingsInnerChannelsEnum] to String,
/// and [decode] dynamic data back to [UpdateMessageSettingsRequestSettingsInnerChannelsEnum].
class UpdateMessageSettingsRequestSettingsInnerChannelsEnumTypeTransformer {
  factory UpdateMessageSettingsRequestSettingsInnerChannelsEnumTypeTransformer() => _instance ??= const UpdateMessageSettingsRequestSettingsInnerChannelsEnumTypeTransformer._();

  const UpdateMessageSettingsRequestSettingsInnerChannelsEnumTypeTransformer._();

  String encode(UpdateMessageSettingsRequestSettingsInnerChannelsEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a UpdateMessageSettingsRequestSettingsInnerChannelsEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  UpdateMessageSettingsRequestSettingsInnerChannelsEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'both': return UpdateMessageSettingsRequestSettingsInnerChannelsEnum.both;
        case r'sms': return UpdateMessageSettingsRequestSettingsInnerChannelsEnum.sms;
        case r'whatsapp': return UpdateMessageSettingsRequestSettingsInnerChannelsEnum.whatsapp;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [UpdateMessageSettingsRequestSettingsInnerChannelsEnumTypeTransformer] instance.
  static UpdateMessageSettingsRequestSettingsInnerChannelsEnumTypeTransformer? _instance;
}



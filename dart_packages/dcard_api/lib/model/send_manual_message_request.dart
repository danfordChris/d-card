//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class SendManualMessageRequest {
  /// Returns a new [SendManualMessageRequest] instance.
  SendManualMessageRequest({
    required this.messageType,
    required this.group,
    this.preview,
  });

  SendManualMessageRequestMessageTypeEnum messageType;

  SendManualMessageRequestGroupEnum group;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? preview;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SendManualMessageRequest &&
    other.messageType == messageType &&
    other.group == group &&
    other.preview == preview;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (messageType.hashCode) +
    (group.hashCode) +
    (preview == null ? 0 : preview!.hashCode);

  @override
  String toString() => 'SendManualMessageRequest[messageType=$messageType, group=$group, preview=$preview]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'messageType'] = this.messageType;
      json[r'group'] = this.group;
    if (this.preview != null) {
      json[r'preview'] = this.preview;
    } else {
      json[r'preview'] = null;
    }
    return json;
  }

  /// Returns a new [SendManualMessageRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SendManualMessageRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SendManualMessageRequest[$key]" is missing from JSON.');
        });
        return true;
      }());

      return SendManualMessageRequest(
        messageType: SendManualMessageRequestMessageTypeEnum.fromJson(json[r'messageType'])!,
        group: SendManualMessageRequestGroupEnum.fromJson(json[r'group'])!,
        preview: mapValueOfType<bool>(json, r'preview'),
      );
    }
    return null;
  }

  static List<SendManualMessageRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SendManualMessageRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SendManualMessageRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SendManualMessageRequest> mapFromJson(dynamic json) {
    final map = <String, SendManualMessageRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SendManualMessageRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SendManualMessageRequest-objects as value to a dart map
  static Map<String, List<SendManualMessageRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SendManualMessageRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SendManualMessageRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'messageType',
    'group',
  };
}


class SendManualMessageRequestMessageTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const SendManualMessageRequestMessageTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const invitationCard = SendManualMessageRequestMessageTypeEnum._(r'invitation_card');
  static const contributionReminder = SendManualMessageRequestMessageTypeEnum._(r'contribution_reminder');
  static const attendanceConfirmation = SendManualMessageRequestMessageTypeEnum._(r'attendance_confirmation');
  static const eventReminder = SendManualMessageRequestMessageTypeEnum._(r'event_reminder');
  static const postEventThanks = SendManualMessageRequestMessageTypeEnum._(r'post_event_thanks');

  /// List of all possible values in this [enum][SendManualMessageRequestMessageTypeEnum].
  static const values = <SendManualMessageRequestMessageTypeEnum>[
    invitationCard,
    contributionReminder,
    attendanceConfirmation,
    eventReminder,
    postEventThanks,
  ];

  static SendManualMessageRequestMessageTypeEnum? fromJson(dynamic value) => SendManualMessageRequestMessageTypeEnumTypeTransformer().decode(value);

  static List<SendManualMessageRequestMessageTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SendManualMessageRequestMessageTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SendManualMessageRequestMessageTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SendManualMessageRequestMessageTypeEnum] to String,
/// and [decode] dynamic data back to [SendManualMessageRequestMessageTypeEnum].
class SendManualMessageRequestMessageTypeEnumTypeTransformer {
  factory SendManualMessageRequestMessageTypeEnumTypeTransformer() => _instance ??= const SendManualMessageRequestMessageTypeEnumTypeTransformer._();

  const SendManualMessageRequestMessageTypeEnumTypeTransformer._();

  String encode(SendManualMessageRequestMessageTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SendManualMessageRequestMessageTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SendManualMessageRequestMessageTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'invitation_card': return SendManualMessageRequestMessageTypeEnum.invitationCard;
        case r'contribution_reminder': return SendManualMessageRequestMessageTypeEnum.contributionReminder;
        case r'attendance_confirmation': return SendManualMessageRequestMessageTypeEnum.attendanceConfirmation;
        case r'event_reminder': return SendManualMessageRequestMessageTypeEnum.eventReminder;
        case r'post_event_thanks': return SendManualMessageRequestMessageTypeEnum.postEventThanks;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SendManualMessageRequestMessageTypeEnumTypeTransformer] instance.
  static SendManualMessageRequestMessageTypeEnumTypeTransformer? _instance;
}



class SendManualMessageRequestGroupEnum {
  /// Instantiate a new enum with the provided [value].
  const SendManualMessageRequestGroupEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const all = SendManualMessageRequestGroupEnum._(r'all');
  static const unpaid = SendManualMessageRequestGroupEnum._(r'unpaid');
  static const notConfirmed = SendManualMessageRequestGroupEnum._(r'not_confirmed');
  static const confirmed = SendManualMessageRequestGroupEnum._(r'confirmed');

  /// List of all possible values in this [enum][SendManualMessageRequestGroupEnum].
  static const values = <SendManualMessageRequestGroupEnum>[
    all,
    unpaid,
    notConfirmed,
    confirmed,
  ];

  static SendManualMessageRequestGroupEnum? fromJson(dynamic value) => SendManualMessageRequestGroupEnumTypeTransformer().decode(value);

  static List<SendManualMessageRequestGroupEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SendManualMessageRequestGroupEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SendManualMessageRequestGroupEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SendManualMessageRequestGroupEnum] to String,
/// and [decode] dynamic data back to [SendManualMessageRequestGroupEnum].
class SendManualMessageRequestGroupEnumTypeTransformer {
  factory SendManualMessageRequestGroupEnumTypeTransformer() => _instance ??= const SendManualMessageRequestGroupEnumTypeTransformer._();

  const SendManualMessageRequestGroupEnumTypeTransformer._();

  String encode(SendManualMessageRequestGroupEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SendManualMessageRequestGroupEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SendManualMessageRequestGroupEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'all': return SendManualMessageRequestGroupEnum.all;
        case r'unpaid': return SendManualMessageRequestGroupEnum.unpaid;
        case r'not_confirmed': return SendManualMessageRequestGroupEnum.notConfirmed;
        case r'confirmed': return SendManualMessageRequestGroupEnum.confirmed;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SendManualMessageRequestGroupEnumTypeTransformer] instance.
  static SendManualMessageRequestGroupEnumTypeTransformer? _instance;
}



//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class SendTestMessageRequest {
  /// Returns a new [SendTestMessageRequest] instance.
  SendTestMessageRequest({
    this.channels,
  });

  SendTestMessageRequestChannelsEnum? channels;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SendTestMessageRequest &&
    other.channels == channels;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (channels == null ? 0 : channels!.hashCode);

  @override
  String toString() => 'SendTestMessageRequest[channels=$channels]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.channels != null) {
      json[r'channels'] = this.channels;
    } else {
      json[r'channels'] = null;
    }
    return json;
  }

  /// Returns a new [SendTestMessageRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SendTestMessageRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SendTestMessageRequest[$key]" is missing from JSON.');
        });
        return true;
      }());

      return SendTestMessageRequest(
        channels: SendTestMessageRequestChannelsEnum.fromJson(json[r'channels']),
      );
    }
    return null;
  }

  static List<SendTestMessageRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SendTestMessageRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SendTestMessageRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SendTestMessageRequest> mapFromJson(dynamic json) {
    final map = <String, SendTestMessageRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SendTestMessageRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SendTestMessageRequest-objects as value to a dart map
  static Map<String, List<SendTestMessageRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SendTestMessageRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SendTestMessageRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}


class SendTestMessageRequestChannelsEnum {
  /// Instantiate a new enum with the provided [value].
  const SendTestMessageRequestChannelsEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const both = SendTestMessageRequestChannelsEnum._(r'both');
  static const sms = SendTestMessageRequestChannelsEnum._(r'sms');
  static const whatsapp = SendTestMessageRequestChannelsEnum._(r'whatsapp');

  /// List of all possible values in this [enum][SendTestMessageRequestChannelsEnum].
  static const values = <SendTestMessageRequestChannelsEnum>[
    both,
    sms,
    whatsapp,
  ];

  static SendTestMessageRequestChannelsEnum? fromJson(dynamic value) => SendTestMessageRequestChannelsEnumTypeTransformer().decode(value);

  static List<SendTestMessageRequestChannelsEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SendTestMessageRequestChannelsEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SendTestMessageRequestChannelsEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SendTestMessageRequestChannelsEnum] to String,
/// and [decode] dynamic data back to [SendTestMessageRequestChannelsEnum].
class SendTestMessageRequestChannelsEnumTypeTransformer {
  factory SendTestMessageRequestChannelsEnumTypeTransformer() => _instance ??= const SendTestMessageRequestChannelsEnumTypeTransformer._();

  const SendTestMessageRequestChannelsEnumTypeTransformer._();

  String encode(SendTestMessageRequestChannelsEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SendTestMessageRequestChannelsEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SendTestMessageRequestChannelsEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'both': return SendTestMessageRequestChannelsEnum.both;
        case r'sms': return SendTestMessageRequestChannelsEnum.sms;
        case r'whatsapp': return SendTestMessageRequestChannelsEnum.whatsapp;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SendTestMessageRequestChannelsEnumTypeTransformer] instance.
  static SendTestMessageRequestChannelsEnumTypeTransformer? _instance;
}



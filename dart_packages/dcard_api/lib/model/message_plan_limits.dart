//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class MessagePlanLimits {
  /// Returns a new [MessagePlanLimits] instance.
  MessagePlanLimits({
    required this.channelPerMessage,
    required this.smsWordingEdit,
    required this.maxSmsSegments,
    required this.whatsappTemplateStyles,
    required this.customTiming,
    required this.maxContributionReminders,
    required this.maxManualSends,
    required this.marketingMessages,
  });

  bool channelPerMessage;

  bool smsWordingEdit;

  int maxSmsSegments;

  bool whatsappTemplateStyles;

  bool customTiming;

  int maxContributionReminders;

  int maxManualSends;

  bool marketingMessages;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MessagePlanLimits &&
    other.channelPerMessage == channelPerMessage &&
    other.smsWordingEdit == smsWordingEdit &&
    other.maxSmsSegments == maxSmsSegments &&
    other.whatsappTemplateStyles == whatsappTemplateStyles &&
    other.customTiming == customTiming &&
    other.maxContributionReminders == maxContributionReminders &&
    other.maxManualSends == maxManualSends &&
    other.marketingMessages == marketingMessages;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (channelPerMessage.hashCode) +
    (smsWordingEdit.hashCode) +
    (maxSmsSegments.hashCode) +
    (whatsappTemplateStyles.hashCode) +
    (customTiming.hashCode) +
    (maxContributionReminders.hashCode) +
    (maxManualSends.hashCode) +
    (marketingMessages.hashCode);

  @override
  String toString() => 'MessagePlanLimits[channelPerMessage=$channelPerMessage, smsWordingEdit=$smsWordingEdit, maxSmsSegments=$maxSmsSegments, whatsappTemplateStyles=$whatsappTemplateStyles, customTiming=$customTiming, maxContributionReminders=$maxContributionReminders, maxManualSends=$maxManualSends, marketingMessages=$marketingMessages]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'channelPerMessage'] = this.channelPerMessage;
      json[r'smsWordingEdit'] = this.smsWordingEdit;
      json[r'maxSmsSegments'] = this.maxSmsSegments;
      json[r'whatsappTemplateStyles'] = this.whatsappTemplateStyles;
      json[r'customTiming'] = this.customTiming;
      json[r'maxContributionReminders'] = this.maxContributionReminders;
      json[r'maxManualSends'] = this.maxManualSends;
      json[r'marketingMessages'] = this.marketingMessages;
    return json;
  }

  /// Returns a new [MessagePlanLimits] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MessagePlanLimits? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MessagePlanLimits[$key]" is missing from JSON.');
        });
        return true;
      }());

      return MessagePlanLimits(
        channelPerMessage: mapValueOfType<bool>(json, r'channelPerMessage')!,
        smsWordingEdit: mapValueOfType<bool>(json, r'smsWordingEdit')!,
        maxSmsSegments: mapValueOfType<int>(json, r'maxSmsSegments')!,
        whatsappTemplateStyles: mapValueOfType<bool>(json, r'whatsappTemplateStyles')!,
        customTiming: mapValueOfType<bool>(json, r'customTiming')!,
        maxContributionReminders: mapValueOfType<int>(json, r'maxContributionReminders')!,
        maxManualSends: mapValueOfType<int>(json, r'maxManualSends')!,
        marketingMessages: mapValueOfType<bool>(json, r'marketingMessages')!,
      );
    }
    return null;
  }

  static List<MessagePlanLimits> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessagePlanLimits>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessagePlanLimits.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MessagePlanLimits> mapFromJson(dynamic json) {
    final map = <String, MessagePlanLimits>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MessagePlanLimits.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MessagePlanLimits-objects as value to a dart map
  static Map<String, List<MessagePlanLimits>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MessagePlanLimits>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MessagePlanLimits.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'channelPerMessage',
    'smsWordingEdit',
    'maxSmsSegments',
    'whatsappTemplateStyles',
    'customTiming',
    'maxContributionReminders',
    'maxManualSends',
    'marketingMessages',
  };
}


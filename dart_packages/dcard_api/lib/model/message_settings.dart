//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class MessageSettings {
  /// Returns a new [MessageSettings] instance.
  MessageSettings({
    this.settings = const [],
    required this.limits,
    this.templates = const [],
    required this.usage,
  });

  List<MessageSettingsSettingsInner> settings;

  MessagePlanLimits limits;

  List<MessageSettingsTemplatesInner> templates;

  MessageSettingsUsage usage;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MessageSettings &&
    _deepEquality.equals(other.settings, settings) &&
    other.limits == limits &&
    _deepEquality.equals(other.templates, templates) &&
    other.usage == usage;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (settings.hashCode) +
    (limits.hashCode) +
    (templates.hashCode) +
    (usage.hashCode);

  @override
  String toString() => 'MessageSettings[settings=$settings, limits=$limits, templates=$templates, usage=$usage]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'settings'] = this.settings;
      json[r'limits'] = this.limits;
      json[r'templates'] = this.templates;
      json[r'usage'] = this.usage;
    return json;
  }

  /// Returns a new [MessageSettings] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MessageSettings? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MessageSettings[$key]" is missing from JSON.');
        });
        return true;
      }());

      return MessageSettings(
        settings: MessageSettingsSettingsInner.listFromJson(json[r'settings']),
        limits: MessagePlanLimits.fromJson(json[r'limits'])!,
        templates: MessageSettingsTemplatesInner.listFromJson(json[r'templates']),
        usage: MessageSettingsUsage.fromJson(json[r'usage'])!,
      );
    }
    return null;
  }

  static List<MessageSettings> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageSettings>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageSettings.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MessageSettings> mapFromJson(dynamic json) {
    final map = <String, MessageSettings>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MessageSettings.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MessageSettings-objects as value to a dart map
  static Map<String, List<MessageSettings>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MessageSettings>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MessageSettings.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'settings',
    'limits',
    'templates',
    'usage',
  };
}


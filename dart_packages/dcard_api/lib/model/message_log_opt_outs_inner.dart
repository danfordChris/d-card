//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class MessageLogOptOutsInner {
  /// Returns a new [MessageLogOptOutsInner] instance.
  MessageLogOptOutsInner({
    required this.name,
    required this.phone,
    required this.createdAt,
  });

  String name;

  String? phone;

  String createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is MessageLogOptOutsInner &&
    other.name == name &&
    other.phone == phone &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (phone == null ? 0 : phone!.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'MessageLogOptOutsInner[name=$name, phone=$phone, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
    if (this.phone != null) {
      json[r'phone'] = this.phone;
    } else {
      json[r'phone'] = null;
    }
      json[r'createdAt'] = this.createdAt;
    return json;
  }

  /// Returns a new [MessageLogOptOutsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static MessageLogOptOutsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "MessageLogOptOutsInner[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "MessageLogOptOutsInner[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return MessageLogOptOutsInner(
        name: mapValueOfType<String>(json, r'name')!,
        phone: mapValueOfType<String>(json, r'phone'),
        createdAt: mapValueOfType<String>(json, r'createdAt')!,
      );
    }
    return null;
  }

  static List<MessageLogOptOutsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <MessageLogOptOutsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = MessageLogOptOutsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, MessageLogOptOutsInner> mapFromJson(dynamic json) {
    final map = <String, MessageLogOptOutsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = MessageLogOptOutsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of MessageLogOptOutsInner-objects as value to a dart map
  static Map<String, List<MessageLogOptOutsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<MessageLogOptOutsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = MessageLogOptOutsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'phone',
    'createdAt',
  };
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class EventCreateInput {
  /// Returns a new [EventCreateInput] instance.
  EventCreateInput({
    required this.planKey,
    required this.eventTypeKey,
    required this.title,
    required this.startsAt,
    this.endsAt,
    this.timeZone,
    this.venueName,
    this.venueAddress,
    this.venueMapUrl,
    required this.contactName,
    required this.contactPhone,
    this.contact2Name,
    this.contact2Phone,
    this.confirmationEnabled,
    this.confirmationOffsetDays,
    this.headcountPct,
    this.autoUpgradeEnabled,
    this.singleAmount,
    this.doubleAmount,
    this.reminderFrequencyDays,
    this.photoAlbumUrl,
  });

  String planKey;

  String eventTypeKey;

  String title;

  DateTime startsAt;

  DateTime? endsAt;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? timeZone;

  String? venueName;

  String? venueAddress;

  String? venueMapUrl;

  String contactName;

  String contactPhone;

  String? contact2Name;

  String? contact2Phone;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? confirmationEnabled;

  /// Minimum value: 0
  /// Maximum value: 30
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? confirmationOffsetDays;

  /// Minimum value: 0
  /// Maximum value: 100
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? headcountPct;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? autoUpgradeEnabled;

  /// Minimum value: 0
  int? singleAmount;

  /// Minimum value: 0
  int? doubleAmount;

  /// Minimum value: 1
  /// Maximum value: 60
  int? reminderFrequencyDays;

  String? photoAlbumUrl;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EventCreateInput &&
    other.planKey == planKey &&
    other.eventTypeKey == eventTypeKey &&
    other.title == title &&
    other.startsAt == startsAt &&
    other.endsAt == endsAt &&
    other.timeZone == timeZone &&
    other.venueName == venueName &&
    other.venueAddress == venueAddress &&
    other.venueMapUrl == venueMapUrl &&
    other.contactName == contactName &&
    other.contactPhone == contactPhone &&
    other.contact2Name == contact2Name &&
    other.contact2Phone == contact2Phone &&
    other.confirmationEnabled == confirmationEnabled &&
    other.confirmationOffsetDays == confirmationOffsetDays &&
    other.headcountPct == headcountPct &&
    other.autoUpgradeEnabled == autoUpgradeEnabled &&
    other.singleAmount == singleAmount &&
    other.doubleAmount == doubleAmount &&
    other.reminderFrequencyDays == reminderFrequencyDays &&
    other.photoAlbumUrl == photoAlbumUrl;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (planKey.hashCode) +
    (eventTypeKey.hashCode) +
    (title.hashCode) +
    (startsAt.hashCode) +
    (endsAt == null ? 0 : endsAt!.hashCode) +
    (timeZone == null ? 0 : timeZone!.hashCode) +
    (venueName == null ? 0 : venueName!.hashCode) +
    (venueAddress == null ? 0 : venueAddress!.hashCode) +
    (venueMapUrl == null ? 0 : venueMapUrl!.hashCode) +
    (contactName.hashCode) +
    (contactPhone.hashCode) +
    (contact2Name == null ? 0 : contact2Name!.hashCode) +
    (contact2Phone == null ? 0 : contact2Phone!.hashCode) +
    (confirmationEnabled == null ? 0 : confirmationEnabled!.hashCode) +
    (confirmationOffsetDays == null ? 0 : confirmationOffsetDays!.hashCode) +
    (headcountPct == null ? 0 : headcountPct!.hashCode) +
    (autoUpgradeEnabled == null ? 0 : autoUpgradeEnabled!.hashCode) +
    (singleAmount == null ? 0 : singleAmount!.hashCode) +
    (doubleAmount == null ? 0 : doubleAmount!.hashCode) +
    (reminderFrequencyDays == null ? 0 : reminderFrequencyDays!.hashCode) +
    (photoAlbumUrl == null ? 0 : photoAlbumUrl!.hashCode);

  @override
  String toString() => 'EventCreateInput[planKey=$planKey, eventTypeKey=$eventTypeKey, title=$title, startsAt=$startsAt, endsAt=$endsAt, timeZone=$timeZone, venueName=$venueName, venueAddress=$venueAddress, venueMapUrl=$venueMapUrl, contactName=$contactName, contactPhone=$contactPhone, contact2Name=$contact2Name, contact2Phone=$contact2Phone, confirmationEnabled=$confirmationEnabled, confirmationOffsetDays=$confirmationOffsetDays, headcountPct=$headcountPct, autoUpgradeEnabled=$autoUpgradeEnabled, singleAmount=$singleAmount, doubleAmount=$doubleAmount, reminderFrequencyDays=$reminderFrequencyDays, photoAlbumUrl=$photoAlbumUrl]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'planKey'] = this.planKey;
      json[r'eventTypeKey'] = this.eventTypeKey;
      json[r'title'] = this.title;
      json[r'startsAt'] = this.startsAt.toUtc().toIso8601String();
    if (this.endsAt != null) {
      json[r'endsAt'] = this.endsAt!.toUtc().toIso8601String();
    } else {
      json[r'endsAt'] = null;
    }
    if (this.timeZone != null) {
      json[r'timeZone'] = this.timeZone;
    } else {
      json[r'timeZone'] = null;
    }
    if (this.venueName != null) {
      json[r'venueName'] = this.venueName;
    } else {
      json[r'venueName'] = null;
    }
    if (this.venueAddress != null) {
      json[r'venueAddress'] = this.venueAddress;
    } else {
      json[r'venueAddress'] = null;
    }
    if (this.venueMapUrl != null) {
      json[r'venueMapUrl'] = this.venueMapUrl;
    } else {
      json[r'venueMapUrl'] = null;
    }
      json[r'contactName'] = this.contactName;
      json[r'contactPhone'] = this.contactPhone;
    if (this.contact2Name != null) {
      json[r'contact2Name'] = this.contact2Name;
    } else {
      json[r'contact2Name'] = null;
    }
    if (this.contact2Phone != null) {
      json[r'contact2Phone'] = this.contact2Phone;
    } else {
      json[r'contact2Phone'] = null;
    }
    if (this.confirmationEnabled != null) {
      json[r'confirmationEnabled'] = this.confirmationEnabled;
    } else {
      json[r'confirmationEnabled'] = null;
    }
    if (this.confirmationOffsetDays != null) {
      json[r'confirmationOffsetDays'] = this.confirmationOffsetDays;
    } else {
      json[r'confirmationOffsetDays'] = null;
    }
    if (this.headcountPct != null) {
      json[r'headcountPct'] = this.headcountPct;
    } else {
      json[r'headcountPct'] = null;
    }
    if (this.autoUpgradeEnabled != null) {
      json[r'autoUpgradeEnabled'] = this.autoUpgradeEnabled;
    } else {
      json[r'autoUpgradeEnabled'] = null;
    }
    if (this.singleAmount != null) {
      json[r'singleAmount'] = this.singleAmount;
    } else {
      json[r'singleAmount'] = null;
    }
    if (this.doubleAmount != null) {
      json[r'doubleAmount'] = this.doubleAmount;
    } else {
      json[r'doubleAmount'] = null;
    }
    if (this.reminderFrequencyDays != null) {
      json[r'reminderFrequencyDays'] = this.reminderFrequencyDays;
    } else {
      json[r'reminderFrequencyDays'] = null;
    }
    if (this.photoAlbumUrl != null) {
      json[r'photoAlbumUrl'] = this.photoAlbumUrl;
    } else {
      json[r'photoAlbumUrl'] = null;
    }
    return json;
  }

  /// Returns a new [EventCreateInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EventCreateInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "EventCreateInput[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "EventCreateInput[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return EventCreateInput(
        planKey: mapValueOfType<String>(json, r'planKey')!,
        eventTypeKey: mapValueOfType<String>(json, r'eventTypeKey')!,
        title: mapValueOfType<String>(json, r'title')!,
        startsAt: mapDateTime(json, r'startsAt', r'')!,
        endsAt: mapDateTime(json, r'endsAt', r''),
        timeZone: mapValueOfType<String>(json, r'timeZone'),
        venueName: mapValueOfType<String>(json, r'venueName'),
        venueAddress: mapValueOfType<String>(json, r'venueAddress'),
        venueMapUrl: mapValueOfType<String>(json, r'venueMapUrl'),
        contactName: mapValueOfType<String>(json, r'contactName')!,
        contactPhone: mapValueOfType<String>(json, r'contactPhone')!,
        contact2Name: mapValueOfType<String>(json, r'contact2Name'),
        contact2Phone: mapValueOfType<String>(json, r'contact2Phone'),
        confirmationEnabled: mapValueOfType<bool>(json, r'confirmationEnabled'),
        confirmationOffsetDays: mapValueOfType<int>(json, r'confirmationOffsetDays'),
        headcountPct: mapValueOfType<int>(json, r'headcountPct'),
        autoUpgradeEnabled: mapValueOfType<bool>(json, r'autoUpgradeEnabled'),
        singleAmount: mapValueOfType<int>(json, r'singleAmount'),
        doubleAmount: mapValueOfType<int>(json, r'doubleAmount'),
        reminderFrequencyDays: mapValueOfType<int>(json, r'reminderFrequencyDays'),
        photoAlbumUrl: mapValueOfType<String>(json, r'photoAlbumUrl'),
      );
    }
    return null;
  }

  static List<EventCreateInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EventCreateInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EventCreateInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, EventCreateInput> mapFromJson(dynamic json) {
    final map = <String, EventCreateInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = EventCreateInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of EventCreateInput-objects as value to a dart map
  static Map<String, List<EventCreateInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<EventCreateInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = EventCreateInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'planKey',
    'eventTypeKey',
    'title',
    'startsAt',
    'contactName',
    'contactPhone',
  };
}


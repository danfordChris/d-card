//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class GuestCreateInput {
  /// Returns a new [GuestCreateInput] instance.
  GuestCreateInput({
    required this.name,
    required this.phone,
    this.cardType,
    this.partnerName,
    required this.consent,
  });

  String name;

  String phone;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  CardType? cardType;

  String? partnerName;

  /// Host confirms the guest agreed to receive event messages
  bool consent;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GuestCreateInput &&
    other.name == name &&
    other.phone == phone &&
    other.cardType == cardType &&
    other.partnerName == partnerName &&
    other.consent == consent;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name.hashCode) +
    (phone.hashCode) +
    (cardType == null ? 0 : cardType!.hashCode) +
    (partnerName == null ? 0 : partnerName!.hashCode) +
    (consent.hashCode);

  @override
  String toString() => 'GuestCreateInput[name=$name, phone=$phone, cardType=$cardType, partnerName=$partnerName, consent=$consent]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'name'] = this.name;
      json[r'phone'] = this.phone;
    if (this.cardType != null) {
      json[r'cardType'] = this.cardType;
    } else {
      json[r'cardType'] = null;
    }
    if (this.partnerName != null) {
      json[r'partnerName'] = this.partnerName;
    } else {
      json[r'partnerName'] = null;
    }
      json[r'consent'] = this.consent;
    return json;
  }

  /// Returns a new [GuestCreateInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GuestCreateInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GuestCreateInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return GuestCreateInput(
        name: mapValueOfType<String>(json, r'name')!,
        phone: mapValueOfType<String>(json, r'phone')!,
        cardType: CardType.fromJson(json[r'cardType']),
        partnerName: mapValueOfType<String>(json, r'partnerName'),
        consent: mapValueOfType<bool>(json, r'consent')!,
      );
    }
    return null;
  }

  static List<GuestCreateInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GuestCreateInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GuestCreateInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GuestCreateInput> mapFromJson(dynamic json) {
    final map = <String, GuestCreateInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GuestCreateInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GuestCreateInput-objects as value to a dart map
  static Map<String, List<GuestCreateInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GuestCreateInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GuestCreateInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'name',
    'phone',
    'consent',
  };
}


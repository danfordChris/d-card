//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class GuestUpdateInput {
  /// Returns a new [GuestUpdateInput] instance.
  GuestUpdateInput({
    this.name,
    this.partnerName,
    this.cardType,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? name;

  String? partnerName;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  CardType? cardType;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GuestUpdateInput &&
    other.name == name &&
    other.partnerName == partnerName &&
    other.cardType == cardType;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (name == null ? 0 : name!.hashCode) +
    (partnerName == null ? 0 : partnerName!.hashCode) +
    (cardType == null ? 0 : cardType!.hashCode);

  @override
  String toString() => 'GuestUpdateInput[name=$name, partnerName=$partnerName, cardType=$cardType]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
    if (this.partnerName != null) {
      json[r'partnerName'] = this.partnerName;
    } else {
      json[r'partnerName'] = null;
    }
    if (this.cardType != null) {
      json[r'cardType'] = this.cardType;
    } else {
      json[r'cardType'] = null;
    }
    return json;
  }

  /// Returns a new [GuestUpdateInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GuestUpdateInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GuestUpdateInput[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GuestUpdateInput[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GuestUpdateInput(
        name: mapValueOfType<String>(json, r'name'),
        partnerName: mapValueOfType<String>(json, r'partnerName'),
        cardType: CardType.fromJson(json[r'cardType']),
      );
    }
    return null;
  }

  static List<GuestUpdateInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GuestUpdateInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GuestUpdateInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GuestUpdateInput> mapFromJson(dynamic json) {
    final map = <String, GuestUpdateInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GuestUpdateInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GuestUpdateInput-objects as value to a dart map
  static Map<String, List<GuestUpdateInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GuestUpdateInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GuestUpdateInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class GuestBulkInput {
  /// Returns a new [GuestBulkInput] instance.
  GuestBulkInput({
    this.guests = const [],
    required this.consent,
  });

  List<GuestBulkInputGuestsInner> guests;

  /// Host confirms these guests agreed to receive event messages
  bool consent;

  @override
  bool operator ==(Object other) => identical(this, other) || other is GuestBulkInput &&
    _deepEquality.equals(other.guests, guests) &&
    other.consent == consent;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (guests.hashCode) +
    (consent.hashCode);

  @override
  String toString() => 'GuestBulkInput[guests=$guests, consent=$consent]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'guests'] = this.guests;
      json[r'consent'] = this.consent;
    return json;
  }

  /// Returns a new [GuestBulkInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static GuestBulkInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "GuestBulkInput[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "GuestBulkInput[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return GuestBulkInput(
        guests: GuestBulkInputGuestsInner.listFromJson(json[r'guests']),
        consent: mapValueOfType<bool>(json, r'consent')!,
      );
    }
    return null;
  }

  static List<GuestBulkInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <GuestBulkInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = GuestBulkInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, GuestBulkInput> mapFromJson(dynamic json) {
    final map = <String, GuestBulkInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = GuestBulkInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of GuestBulkInput-objects as value to a dart map
  static Map<String, List<GuestBulkInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<GuestBulkInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = GuestBulkInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'guests',
    'consent',
  };
}


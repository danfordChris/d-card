//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class BillingQuoteInput {
  /// Returns a new [BillingQuoteInput] instance.
  BillingQuoteInput({
    this.planKey,
    required this.guestCards,
  });

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  PlanKey? planKey;

  /// Minimum value: 1
  /// Maximum value: 100000
  int guestCards;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BillingQuoteInput &&
    other.planKey == planKey &&
    other.guestCards == guestCards;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (planKey == null ? 0 : planKey!.hashCode) +
    (guestCards.hashCode);

  @override
  String toString() => 'BillingQuoteInput[planKey=$planKey, guestCards=$guestCards]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.planKey != null) {
      json[r'planKey'] = this.planKey;
    } else {
      json[r'planKey'] = null;
    }
      json[r'guestCards'] = this.guestCards;
    return json;
  }

  /// Returns a new [BillingQuoteInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BillingQuoteInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BillingQuoteInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return BillingQuoteInput(
        planKey: PlanKey.fromJson(json[r'planKey']),
        guestCards: mapValueOfType<int>(json, r'guestCards')!,
      );
    }
    return null;
  }

  static List<BillingQuoteInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BillingQuoteInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BillingQuoteInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BillingQuoteInput> mapFromJson(dynamic json) {
    final map = <String, BillingQuoteInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BillingQuoteInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BillingQuoteInput-objects as value to a dart map
  static Map<String, List<BillingQuoteInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BillingQuoteInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BillingQuoteInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'guestCards',
  };
}


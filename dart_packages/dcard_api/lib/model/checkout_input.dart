//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class CheckoutInput {
  /// Returns a new [CheckoutInput] instance.
  CheckoutInput({
    this.planKey,
    required this.guestCards,
    required this.method,
    this.phone,
    required this.expectedTotal,
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

  HostPaymentMethod method;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? phone;

  /// Minimum value: 0
  int expectedTotal;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CheckoutInput &&
    other.planKey == planKey &&
    other.guestCards == guestCards &&
    other.method == method &&
    other.phone == phone &&
    other.expectedTotal == expectedTotal;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (planKey == null ? 0 : planKey!.hashCode) +
    (guestCards.hashCode) +
    (method.hashCode) +
    (phone == null ? 0 : phone!.hashCode) +
    (expectedTotal.hashCode);

  @override
  String toString() => 'CheckoutInput[planKey=$planKey, guestCards=$guestCards, method=$method, phone=$phone, expectedTotal=$expectedTotal]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.planKey != null) {
      json[r'planKey'] = this.planKey;
    } else {
      json[r'planKey'] = null;
    }
      json[r'guestCards'] = this.guestCards;
      json[r'method'] = this.method;
    if (this.phone != null) {
      json[r'phone'] = this.phone;
    } else {
      json[r'phone'] = null;
    }
      json[r'expectedTotal'] = this.expectedTotal;
    return json;
  }

  /// Returns a new [CheckoutInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CheckoutInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CheckoutInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return CheckoutInput(
        planKey: PlanKey.fromJson(json[r'planKey']),
        guestCards: mapValueOfType<int>(json, r'guestCards')!,
        method: HostPaymentMethod.fromJson(json[r'method'])!,
        phone: mapValueOfType<String>(json, r'phone'),
        expectedTotal: mapValueOfType<int>(json, r'expectedTotal')!,
      );
    }
    return null;
  }

  static List<CheckoutInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CheckoutInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CheckoutInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CheckoutInput> mapFromJson(dynamic json) {
    final map = <String, CheckoutInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CheckoutInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CheckoutInput-objects as value to a dart map
  static Map<String, List<CheckoutInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CheckoutInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CheckoutInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'guestCards',
    'method',
    'expectedTotal',
  };
}


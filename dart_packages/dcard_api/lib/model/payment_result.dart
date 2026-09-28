//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class PaymentResult {
  /// Returns a new [PaymentResult] instance.
  PaymentResult({
    required this.pledge,
    required this.payment,
  });

  Pledge pledge;

  Payment payment;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PaymentResult &&
    other.pledge == pledge &&
    other.payment == payment;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (pledge.hashCode) +
    (payment.hashCode);

  @override
  String toString() => 'PaymentResult[pledge=$pledge, payment=$payment]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'pledge'] = this.pledge;
      json[r'payment'] = this.payment;
    return json;
  }

  /// Returns a new [PaymentResult] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PaymentResult? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PaymentResult[$key]" is missing from JSON.');
        });
        return true;
      }());

      return PaymentResult(
        pledge: Pledge.fromJson(json[r'pledge'])!,
        payment: Payment.fromJson(json[r'payment'])!,
      );
    }
    return null;
  }

  static List<PaymentResult> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentResult>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentResult.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PaymentResult> mapFromJson(dynamic json) {
    final map = <String, PaymentResult>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PaymentResult.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PaymentResult-objects as value to a dart map
  static Map<String, List<PaymentResult>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PaymentResult>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PaymentResult.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'pledge',
    'payment',
  };
}


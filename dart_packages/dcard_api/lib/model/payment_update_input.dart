//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class PaymentUpdateInput {
  /// Returns a new [PaymentUpdateInput] instance.
  PaymentUpdateInput({
    this.amount,
    this.method,
    this.reference,
    this.paidOn,
  });

  /// Minimum value: 1
  /// Maximum value: 100000000
  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  int? amount;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  PaymentMethod? method;

  String? reference;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  DateTime? paidOn;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PaymentUpdateInput &&
    other.amount == amount &&
    other.method == method &&
    other.reference == reference &&
    other.paidOn == paidOn;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (amount == null ? 0 : amount!.hashCode) +
    (method == null ? 0 : method!.hashCode) +
    (reference == null ? 0 : reference!.hashCode) +
    (paidOn == null ? 0 : paidOn!.hashCode);

  @override
  String toString() => 'PaymentUpdateInput[amount=$amount, method=$method, reference=$reference, paidOn=$paidOn]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.amount != null) {
      json[r'amount'] = this.amount;
    } else {
      json[r'amount'] = null;
    }
    if (this.method != null) {
      json[r'method'] = this.method;
    } else {
      json[r'method'] = null;
    }
    if (this.reference != null) {
      json[r'reference'] = this.reference;
    } else {
      json[r'reference'] = null;
    }
    if (this.paidOn != null) {
      json[r'paidOn'] = _dateFormatter.format(this.paidOn!.toUtc());
    } else {
      json[r'paidOn'] = null;
    }
    return json;
  }

  /// Returns a new [PaymentUpdateInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PaymentUpdateInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PaymentUpdateInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return PaymentUpdateInput(
        amount: mapValueOfType<int>(json, r'amount'),
        method: PaymentMethod.fromJson(json[r'method']),
        reference: mapValueOfType<String>(json, r'reference'),
        paidOn: mapDateTime(json, r'paidOn', r''),
      );
    }
    return null;
  }

  static List<PaymentUpdateInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentUpdateInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentUpdateInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PaymentUpdateInput> mapFromJson(dynamic json) {
    final map = <String, PaymentUpdateInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PaymentUpdateInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PaymentUpdateInput-objects as value to a dart map
  static Map<String, List<PaymentUpdateInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PaymentUpdateInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PaymentUpdateInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}


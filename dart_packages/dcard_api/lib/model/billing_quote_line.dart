//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class BillingQuoteLine {
  /// Returns a new [BillingQuoteLine] instance.
  BillingQuoteLine({
    required this.code,
    required this.quantity,
    required this.unitPrice,
    required this.amount,
  });

  String code;

  int quantity;

  int unitPrice;

  int amount;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BillingQuoteLine &&
    other.code == code &&
    other.quantity == quantity &&
    other.unitPrice == unitPrice &&
    other.amount == amount;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (code.hashCode) +
    (quantity.hashCode) +
    (unitPrice.hashCode) +
    (amount.hashCode);

  @override
  String toString() => 'BillingQuoteLine[code=$code, quantity=$quantity, unitPrice=$unitPrice, amount=$amount]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'code'] = this.code;
      json[r'quantity'] = this.quantity;
      json[r'unitPrice'] = this.unitPrice;
      json[r'amount'] = this.amount;
    return json;
  }

  /// Returns a new [BillingQuoteLine] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BillingQuoteLine? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BillingQuoteLine[$key]" is missing from JSON.');
        });
        return true;
      }());

      return BillingQuoteLine(
        code: mapValueOfType<String>(json, r'code')!,
        quantity: mapValueOfType<int>(json, r'quantity')!,
        unitPrice: mapValueOfType<int>(json, r'unitPrice')!,
        amount: mapValueOfType<int>(json, r'amount')!,
      );
    }
    return null;
  }

  static List<BillingQuoteLine> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BillingQuoteLine>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BillingQuoteLine.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BillingQuoteLine> mapFromJson(dynamic json) {
    final map = <String, BillingQuoteLine>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BillingQuoteLine.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BillingQuoteLine-objects as value to a dart map
  static Map<String, List<BillingQuoteLine>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BillingQuoteLine>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BillingQuoteLine.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'code',
    'quantity',
    'unitPrice',
    'amount',
  };
}


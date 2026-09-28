//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class HostPayment {
  /// Returns a new [HostPayment] instance.
  HostPayment({
    required this.id,
    required this.planKey,
    required this.guestCards,
    required this.amount,
    required this.discountAmount,
    required this.method,
    required this.reference,
    required this.paidAt,
  });

  String id;

  PlanKey planKey;

  int guestCards;

  int amount;

  int discountAmount;

  String method;

  String reference;

  DateTime paidAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is HostPayment &&
    other.id == id &&
    other.planKey == planKey &&
    other.guestCards == guestCards &&
    other.amount == amount &&
    other.discountAmount == discountAmount &&
    other.method == method &&
    other.reference == reference &&
    other.paidAt == paidAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (planKey.hashCode) +
    (guestCards.hashCode) +
    (amount.hashCode) +
    (discountAmount.hashCode) +
    (method.hashCode) +
    (reference.hashCode) +
    (paidAt.hashCode);

  @override
  String toString() => 'HostPayment[id=$id, planKey=$planKey, guestCards=$guestCards, amount=$amount, discountAmount=$discountAmount, method=$method, reference=$reference, paidAt=$paidAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'planKey'] = this.planKey;
      json[r'guestCards'] = this.guestCards;
      json[r'amount'] = this.amount;
      json[r'discountAmount'] = this.discountAmount;
      json[r'method'] = this.method;
      json[r'reference'] = this.reference;
      json[r'paidAt'] = this.paidAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [HostPayment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static HostPayment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "HostPayment[$key]" is missing from JSON.');
        });
        return true;
      }());

      return HostPayment(
        id: mapValueOfType<String>(json, r'id')!,
        planKey: PlanKey.fromJson(json[r'planKey'])!,
        guestCards: mapValueOfType<int>(json, r'guestCards')!,
        amount: mapValueOfType<int>(json, r'amount')!,
        discountAmount: mapValueOfType<int>(json, r'discountAmount')!,
        method: mapValueOfType<String>(json, r'method')!,
        reference: mapValueOfType<String>(json, r'reference')!,
        paidAt: mapDateTime(json, r'paidAt', r'')!,
      );
    }
    return null;
  }

  static List<HostPayment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <HostPayment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = HostPayment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, HostPayment> mapFromJson(dynamic json) {
    final map = <String, HostPayment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = HostPayment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of HostPayment-objects as value to a dart map
  static Map<String, List<HostPayment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<HostPayment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = HostPayment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'planKey',
    'guestCards',
    'amount',
    'discountAmount',
    'method',
    'reference',
    'paidAt',
  };
}


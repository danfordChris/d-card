//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class Payment {
  /// Returns a new [Payment] instance.
  Payment({
    required this.id,
    required this.kind,
    required this.amount,
    required this.method,
    required this.reference,
    required this.paidOn,
    required this.recordedBy,
    required this.recordedAt,
  });

  String id;

  PaymentKindEnum kind;

  /// Signed: refunds are negative
  int amount;

  PaymentMethod method;

  String? reference;

  DateTime paidOn;

  String? recordedBy;

  DateTime recordedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Payment &&
    other.id == id &&
    other.kind == kind &&
    other.amount == amount &&
    other.method == method &&
    other.reference == reference &&
    other.paidOn == paidOn &&
    other.recordedBy == recordedBy &&
    other.recordedAt == recordedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (kind.hashCode) +
    (amount.hashCode) +
    (method.hashCode) +
    (reference == null ? 0 : reference!.hashCode) +
    (paidOn.hashCode) +
    (recordedBy == null ? 0 : recordedBy!.hashCode) +
    (recordedAt.hashCode);

  @override
  String toString() => 'Payment[id=$id, kind=$kind, amount=$amount, method=$method, reference=$reference, paidOn=$paidOn, recordedBy=$recordedBy, recordedAt=$recordedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'kind'] = this.kind;
      json[r'amount'] = this.amount;
      json[r'method'] = this.method;
    if (this.reference != null) {
      json[r'reference'] = this.reference;
    } else {
      json[r'reference'] = null;
    }
      json[r'paidOn'] = _dateFormatter.format(this.paidOn.toUtc());
    if (this.recordedBy != null) {
      json[r'recordedBy'] = this.recordedBy;
    } else {
      json[r'recordedBy'] = null;
    }
      json[r'recordedAt'] = this.recordedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Payment] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Payment? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Payment[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Payment[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Payment(
        id: mapValueOfType<String>(json, r'id')!,
        kind: PaymentKindEnum.fromJson(json[r'kind'])!,
        amount: mapValueOfType<int>(json, r'amount')!,
        method: PaymentMethod.fromJson(json[r'method'])!,
        reference: mapValueOfType<String>(json, r'reference'),
        paidOn: mapDateTime(json, r'paidOn', r'')!,
        recordedBy: mapValueOfType<String>(json, r'recordedBy'),
        recordedAt: mapDateTime(json, r'recordedAt', r'')!,
      );
    }
    return null;
  }

  static List<Payment> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Payment>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Payment.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Payment> mapFromJson(dynamic json) {
    final map = <String, Payment>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Payment.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Payment-objects as value to a dart map
  static Map<String, List<Payment>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Payment>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Payment.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'kind',
    'amount',
    'method',
    'reference',
    'paidOn',
    'recordedBy',
    'recordedAt',
  };
}


class PaymentKindEnum {
  /// Instantiate a new enum with the provided [value].
  const PaymentKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const payment = PaymentKindEnum._(r'payment');
  static const refund = PaymentKindEnum._(r'refund');

  /// List of all possible values in this [enum][PaymentKindEnum].
  static const values = <PaymentKindEnum>[
    payment,
    refund,
  ];

  static PaymentKindEnum? fromJson(dynamic value) => PaymentKindEnumTypeTransformer().decode(value);

  static List<PaymentKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PaymentKindEnum] to String,
/// and [decode] dynamic data back to [PaymentKindEnum].
class PaymentKindEnumTypeTransformer {
  factory PaymentKindEnumTypeTransformer() => _instance ??= const PaymentKindEnumTypeTransformer._();

  const PaymentKindEnumTypeTransformer._();

  String encode(PaymentKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a PaymentKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PaymentKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'payment': return PaymentKindEnum.payment;
        case r'refund': return PaymentKindEnum.refund;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [PaymentKindEnumTypeTransformer] instance.
  static PaymentKindEnumTypeTransformer? _instance;
}



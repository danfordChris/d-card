//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class PaymentCreateInput {
  /// Returns a new [PaymentCreateInput] instance.
  PaymentCreateInput({
    this.kind,
    required this.amount,
    required this.method,
    this.reference,
    required this.paidOn,
  });

  PaymentCreateInputKindEnum? kind;

  /// Positive; refunds are stored negative
  ///
  /// Minimum value: 1
  /// Maximum value: 100000000
  int amount;

  PaymentMethod method;

  String? reference;

  DateTime paidOn;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PaymentCreateInput &&
    other.kind == kind &&
    other.amount == amount &&
    other.method == method &&
    other.reference == reference &&
    other.paidOn == paidOn;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (kind == null ? 0 : kind!.hashCode) +
    (amount.hashCode) +
    (method.hashCode) +
    (reference == null ? 0 : reference!.hashCode) +
    (paidOn.hashCode);

  @override
  String toString() => 'PaymentCreateInput[kind=$kind, amount=$amount, method=$method, reference=$reference, paidOn=$paidOn]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.kind != null) {
      json[r'kind'] = this.kind;
    } else {
      json[r'kind'] = null;
    }
      json[r'amount'] = this.amount;
      json[r'method'] = this.method;
    if (this.reference != null) {
      json[r'reference'] = this.reference;
    } else {
      json[r'reference'] = null;
    }
      json[r'paidOn'] = _dateFormatter.format(this.paidOn.toUtc());
    return json;
  }

  /// Returns a new [PaymentCreateInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PaymentCreateInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PaymentCreateInput[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PaymentCreateInput[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PaymentCreateInput(
        kind: PaymentCreateInputKindEnum.fromJson(json[r'kind']),
        amount: mapValueOfType<int>(json, r'amount')!,
        method: PaymentMethod.fromJson(json[r'method'])!,
        reference: mapValueOfType<String>(json, r'reference'),
        paidOn: mapDateTime(json, r'paidOn', r'')!,
      );
    }
    return null;
  }

  static List<PaymentCreateInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentCreateInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentCreateInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PaymentCreateInput> mapFromJson(dynamic json) {
    final map = <String, PaymentCreateInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PaymentCreateInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PaymentCreateInput-objects as value to a dart map
  static Map<String, List<PaymentCreateInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PaymentCreateInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PaymentCreateInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'amount',
    'method',
    'paidOn',
  };
}


class PaymentCreateInputKindEnum {
  /// Instantiate a new enum with the provided [value].
  const PaymentCreateInputKindEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const payment = PaymentCreateInputKindEnum._(r'payment');
  static const refund = PaymentCreateInputKindEnum._(r'refund');

  /// List of all possible values in this [enum][PaymentCreateInputKindEnum].
  static const values = <PaymentCreateInputKindEnum>[
    payment,
    refund,
  ];

  static PaymentCreateInputKindEnum? fromJson(dynamic value) => PaymentCreateInputKindEnumTypeTransformer().decode(value);

  static List<PaymentCreateInputKindEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentCreateInputKindEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentCreateInputKindEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [PaymentCreateInputKindEnum] to String,
/// and [decode] dynamic data back to [PaymentCreateInputKindEnum].
class PaymentCreateInputKindEnumTypeTransformer {
  factory PaymentCreateInputKindEnumTypeTransformer() => _instance ??= const PaymentCreateInputKindEnumTypeTransformer._();

  const PaymentCreateInputKindEnumTypeTransformer._();

  String encode(PaymentCreateInputKindEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a PaymentCreateInputKindEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  PaymentCreateInputKindEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'payment': return PaymentCreateInputKindEnum.payment;
        case r'refund': return PaymentCreateInputKindEnum.refund;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [PaymentCreateInputKindEnumTypeTransformer] instance.
  static PaymentCreateInputKindEnumTypeTransformer? _instance;
}



//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class PaymentAttempt {
  /// Returns a new [PaymentAttempt] instance.
  PaymentAttempt({
    required this.id,
    required this.status,
    required this.method,
    required this.amount,
    required this.planKey,
    required this.guestCards,
    required this.phone,
    required this.checkoutUrl,
    required this.reference,
    required this.failureReason,
    required this.createdAt,
    required this.completedAt,
  });

  String id;

  PaymentStatus status;

  HostPaymentMethod method;

  int amount;

  PlanKey planKey;

  int guestCards;

  String? phone;

  String? checkoutUrl;

  String? reference;

  String? failureReason;

  DateTime createdAt;

  DateTime? completedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PaymentAttempt &&
    other.id == id &&
    other.status == status &&
    other.method == method &&
    other.amount == amount &&
    other.planKey == planKey &&
    other.guestCards == guestCards &&
    other.phone == phone &&
    other.checkoutUrl == checkoutUrl &&
    other.reference == reference &&
    other.failureReason == failureReason &&
    other.createdAt == createdAt &&
    other.completedAt == completedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (status.hashCode) +
    (method.hashCode) +
    (amount.hashCode) +
    (planKey.hashCode) +
    (guestCards.hashCode) +
    (phone == null ? 0 : phone!.hashCode) +
    (checkoutUrl == null ? 0 : checkoutUrl!.hashCode) +
    (reference == null ? 0 : reference!.hashCode) +
    (failureReason == null ? 0 : failureReason!.hashCode) +
    (createdAt.hashCode) +
    (completedAt == null ? 0 : completedAt!.hashCode);

  @override
  String toString() => 'PaymentAttempt[id=$id, status=$status, method=$method, amount=$amount, planKey=$planKey, guestCards=$guestCards, phone=$phone, checkoutUrl=$checkoutUrl, reference=$reference, failureReason=$failureReason, createdAt=$createdAt, completedAt=$completedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'status'] = this.status;
      json[r'method'] = this.method;
      json[r'amount'] = this.amount;
      json[r'planKey'] = this.planKey;
      json[r'guestCards'] = this.guestCards;
    if (this.phone != null) {
      json[r'phone'] = this.phone;
    } else {
      json[r'phone'] = null;
    }
    if (this.checkoutUrl != null) {
      json[r'checkoutUrl'] = this.checkoutUrl;
    } else {
      json[r'checkoutUrl'] = null;
    }
    if (this.reference != null) {
      json[r'reference'] = this.reference;
    } else {
      json[r'reference'] = null;
    }
    if (this.failureReason != null) {
      json[r'failureReason'] = this.failureReason;
    } else {
      json[r'failureReason'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    if (this.completedAt != null) {
      json[r'completedAt'] = this.completedAt!.toUtc().toIso8601String();
    } else {
      json[r'completedAt'] = null;
    }
    return json;
  }

  /// Returns a new [PaymentAttempt] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PaymentAttempt? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PaymentAttempt[$key]" is missing from JSON.');
        });
        return true;
      }());

      return PaymentAttempt(
        id: mapValueOfType<String>(json, r'id')!,
        status: PaymentStatus.fromJson(json[r'status'])!,
        method: HostPaymentMethod.fromJson(json[r'method'])!,
        amount: mapValueOfType<int>(json, r'amount')!,
        planKey: PlanKey.fromJson(json[r'planKey'])!,
        guestCards: mapValueOfType<int>(json, r'guestCards')!,
        phone: mapValueOfType<String>(json, r'phone'),
        checkoutUrl: mapValueOfType<String>(json, r'checkoutUrl'),
        reference: mapValueOfType<String>(json, r'reference'),
        failureReason: mapValueOfType<String>(json, r'failureReason'),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        completedAt: mapDateTime(json, r'completedAt', r''),
      );
    }
    return null;
  }

  static List<PaymentAttempt> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PaymentAttempt>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PaymentAttempt.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PaymentAttempt> mapFromJson(dynamic json) {
    final map = <String, PaymentAttempt>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PaymentAttempt.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PaymentAttempt-objects as value to a dart map
  static Map<String, List<PaymentAttempt>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PaymentAttempt>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PaymentAttempt.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'status',
    'method',
    'amount',
    'planKey',
    'guestCards',
    'phone',
    'checkoutUrl',
    'reference',
    'failureReason',
    'createdAt',
    'completedAt',
  };
}


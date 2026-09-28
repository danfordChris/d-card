//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class BillingSummary {
  /// Returns a new [BillingSummary] instance.
  BillingSummary({
    required this.planKey,
    required this.planName,
    required this.pricePerGuest,
    required this.guestLimit,
    required this.amountPaid,
    required this.paid,
    required this.issuedCards,
    required this.guestCount,
    required this.launchOfferPercent,
    required this.launchOfferEligible,
    required this.pendingAttempt,
    this.payments = const [],
  });

  PlanKey planKey;

  String planName;

  int pricePerGuest;

  int guestLimit;

  int amountPaid;

  bool paid;

  int issuedCards;

  int guestCount;

  int launchOfferPercent;

  bool launchOfferEligible;

  PaymentAttempt pendingAttempt;

  List<HostPayment> payments;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BillingSummary &&
    other.planKey == planKey &&
    other.planName == planName &&
    other.pricePerGuest == pricePerGuest &&
    other.guestLimit == guestLimit &&
    other.amountPaid == amountPaid &&
    other.paid == paid &&
    other.issuedCards == issuedCards &&
    other.guestCount == guestCount &&
    other.launchOfferPercent == launchOfferPercent &&
    other.launchOfferEligible == launchOfferEligible &&
    other.pendingAttempt == pendingAttempt &&
    _deepEquality.equals(other.payments, payments);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (planKey.hashCode) +
    (planName.hashCode) +
    (pricePerGuest.hashCode) +
    (guestLimit.hashCode) +
    (amountPaid.hashCode) +
    (paid.hashCode) +
    (issuedCards.hashCode) +
    (guestCount.hashCode) +
    (launchOfferPercent.hashCode) +
    (launchOfferEligible.hashCode) +
    (pendingAttempt.hashCode) +
    (payments.hashCode);

  @override
  String toString() => 'BillingSummary[planKey=$planKey, planName=$planName, pricePerGuest=$pricePerGuest, guestLimit=$guestLimit, amountPaid=$amountPaid, paid=$paid, issuedCards=$issuedCards, guestCount=$guestCount, launchOfferPercent=$launchOfferPercent, launchOfferEligible=$launchOfferEligible, pendingAttempt=$pendingAttempt, payments=$payments]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'planKey'] = this.planKey;
      json[r'planName'] = this.planName;
      json[r'pricePerGuest'] = this.pricePerGuest;
      json[r'guestLimit'] = this.guestLimit;
      json[r'amountPaid'] = this.amountPaid;
      json[r'paid'] = this.paid;
      json[r'issuedCards'] = this.issuedCards;
      json[r'guestCount'] = this.guestCount;
      json[r'launchOfferPercent'] = this.launchOfferPercent;
      json[r'launchOfferEligible'] = this.launchOfferEligible;
      json[r'pendingAttempt'] = this.pendingAttempt;
      json[r'payments'] = this.payments;
    return json;
  }

  /// Returns a new [BillingSummary] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BillingSummary? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BillingSummary[$key]" is missing from JSON.');
        });
        return true;
      }());

      return BillingSummary(
        planKey: PlanKey.fromJson(json[r'planKey'])!,
        planName: mapValueOfType<String>(json, r'planName')!,
        pricePerGuest: mapValueOfType<int>(json, r'pricePerGuest')!,
        guestLimit: mapValueOfType<int>(json, r'guestLimit')!,
        amountPaid: mapValueOfType<int>(json, r'amountPaid')!,
        paid: mapValueOfType<bool>(json, r'paid')!,
        issuedCards: mapValueOfType<int>(json, r'issuedCards')!,
        guestCount: mapValueOfType<int>(json, r'guestCount')!,
        launchOfferPercent: mapValueOfType<int>(json, r'launchOfferPercent')!,
        launchOfferEligible: mapValueOfType<bool>(json, r'launchOfferEligible')!,
        pendingAttempt: PaymentAttempt.fromJson(json[r'pendingAttempt'])!,
        payments: HostPayment.listFromJson(json[r'payments']),
      );
    }
    return null;
  }

  static List<BillingSummary> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BillingSummary>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BillingSummary.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BillingSummary> mapFromJson(dynamic json) {
    final map = <String, BillingSummary>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BillingSummary.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BillingSummary-objects as value to a dart map
  static Map<String, List<BillingSummary>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BillingSummary>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BillingSummary.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'planKey',
    'planName',
    'pricePerGuest',
    'guestLimit',
    'amountPaid',
    'paid',
    'issuedCards',
    'guestCount',
    'launchOfferPercent',
    'launchOfferEligible',
    'pendingAttempt',
    'payments',
  };
}


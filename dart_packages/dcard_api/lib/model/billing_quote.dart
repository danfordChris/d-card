//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class BillingQuote {
  /// Returns a new [BillingQuote] instance.
  BillingQuote({
    required this.planKey,
    required this.planName,
    required this.pricePerGuest,
    required this.currentGuestCards,
    required this.guestCards,
    required this.blockSize,
    required this.minimumCharge,
    this.lines = const [],
    required this.subtotal,
    required this.discountPercent,
    required this.discountAmount,
    required this.total,
    required this.payable,
  });

  PlanKey planKey;

  String planName;

  int pricePerGuest;

  int currentGuestCards;

  int guestCards;

  int blockSize;

  int minimumCharge;

  List<BillingQuoteLine> lines;

  int subtotal;

  int discountPercent;

  int discountAmount;

  int total;

  bool payable;

  @override
  bool operator ==(Object other) => identical(this, other) || other is BillingQuote &&
    other.planKey == planKey &&
    other.planName == planName &&
    other.pricePerGuest == pricePerGuest &&
    other.currentGuestCards == currentGuestCards &&
    other.guestCards == guestCards &&
    other.blockSize == blockSize &&
    other.minimumCharge == minimumCharge &&
    _deepEquality.equals(other.lines, lines) &&
    other.subtotal == subtotal &&
    other.discountPercent == discountPercent &&
    other.discountAmount == discountAmount &&
    other.total == total &&
    other.payable == payable;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (planKey.hashCode) +
    (planName.hashCode) +
    (pricePerGuest.hashCode) +
    (currentGuestCards.hashCode) +
    (guestCards.hashCode) +
    (blockSize.hashCode) +
    (minimumCharge.hashCode) +
    (lines.hashCode) +
    (subtotal.hashCode) +
    (discountPercent.hashCode) +
    (discountAmount.hashCode) +
    (total.hashCode) +
    (payable.hashCode);

  @override
  String toString() => 'BillingQuote[planKey=$planKey, planName=$planName, pricePerGuest=$pricePerGuest, currentGuestCards=$currentGuestCards, guestCards=$guestCards, blockSize=$blockSize, minimumCharge=$minimumCharge, lines=$lines, subtotal=$subtotal, discountPercent=$discountPercent, discountAmount=$discountAmount, total=$total, payable=$payable]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'planKey'] = this.planKey;
      json[r'planName'] = this.planName;
      json[r'pricePerGuest'] = this.pricePerGuest;
      json[r'currentGuestCards'] = this.currentGuestCards;
      json[r'guestCards'] = this.guestCards;
      json[r'blockSize'] = this.blockSize;
      json[r'minimumCharge'] = this.minimumCharge;
      json[r'lines'] = this.lines;
      json[r'subtotal'] = this.subtotal;
      json[r'discountPercent'] = this.discountPercent;
      json[r'discountAmount'] = this.discountAmount;
      json[r'total'] = this.total;
      json[r'payable'] = this.payable;
    return json;
  }

  /// Returns a new [BillingQuote] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static BillingQuote? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "BillingQuote[$key]" is missing from JSON.');
        });
        return true;
      }());

      return BillingQuote(
        planKey: PlanKey.fromJson(json[r'planKey'])!,
        planName: mapValueOfType<String>(json, r'planName')!,
        pricePerGuest: mapValueOfType<int>(json, r'pricePerGuest')!,
        currentGuestCards: mapValueOfType<int>(json, r'currentGuestCards')!,
        guestCards: mapValueOfType<int>(json, r'guestCards')!,
        blockSize: mapValueOfType<int>(json, r'blockSize')!,
        minimumCharge: mapValueOfType<int>(json, r'minimumCharge')!,
        lines: BillingQuoteLine.listFromJson(json[r'lines']),
        subtotal: mapValueOfType<int>(json, r'subtotal')!,
        discountPercent: mapValueOfType<int>(json, r'discountPercent')!,
        discountAmount: mapValueOfType<int>(json, r'discountAmount')!,
        total: mapValueOfType<int>(json, r'total')!,
        payable: mapValueOfType<bool>(json, r'payable')!,
      );
    }
    return null;
  }

  static List<BillingQuote> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <BillingQuote>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = BillingQuote.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, BillingQuote> mapFromJson(dynamic json) {
    final map = <String, BillingQuote>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = BillingQuote.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of BillingQuote-objects as value to a dart map
  static Map<String, List<BillingQuote>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<BillingQuote>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = BillingQuote.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'planKey',
    'planName',
    'pricePerGuest',
    'currentGuestCards',
    'guestCards',
    'blockSize',
    'minimumCharge',
    'lines',
    'subtotal',
    'discountPercent',
    'discountAmount',
    'total',
    'payable',
  };
}


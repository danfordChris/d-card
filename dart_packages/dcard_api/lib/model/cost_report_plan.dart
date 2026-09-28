//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class CostReportPlan {
  /// Returns a new [CostReportPlan] instance.
  CostReportPlan({
    required this.planKey,
    required this.revenue,
    required this.whatsappMessages,
    required this.whatsappCost,
    required this.smsMessages,
    required this.smsCost,
    required this.uncostedMessages,
    required this.paymentFee,
    required this.margin,
    required this.marginPct,
  });

  String planKey;

  num revenue;

  int whatsappMessages;

  num whatsappCost;

  int smsMessages;

  num smsCost;

  int uncostedMessages;

  num paymentFee;

  num margin;

  num? marginPct;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CostReportPlan &&
    other.planKey == planKey &&
    other.revenue == revenue &&
    other.whatsappMessages == whatsappMessages &&
    other.whatsappCost == whatsappCost &&
    other.smsMessages == smsMessages &&
    other.smsCost == smsCost &&
    other.uncostedMessages == uncostedMessages &&
    other.paymentFee == paymentFee &&
    other.margin == margin &&
    other.marginPct == marginPct;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (planKey.hashCode) +
    (revenue.hashCode) +
    (whatsappMessages.hashCode) +
    (whatsappCost.hashCode) +
    (smsMessages.hashCode) +
    (smsCost.hashCode) +
    (uncostedMessages.hashCode) +
    (paymentFee.hashCode) +
    (margin.hashCode) +
    (marginPct == null ? 0 : marginPct!.hashCode);

  @override
  String toString() => 'CostReportPlan[planKey=$planKey, revenue=$revenue, whatsappMessages=$whatsappMessages, whatsappCost=$whatsappCost, smsMessages=$smsMessages, smsCost=$smsCost, uncostedMessages=$uncostedMessages, paymentFee=$paymentFee, margin=$margin, marginPct=$marginPct]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'planKey'] = this.planKey;
      json[r'revenue'] = this.revenue;
      json[r'whatsappMessages'] = this.whatsappMessages;
      json[r'whatsappCost'] = this.whatsappCost;
      json[r'smsMessages'] = this.smsMessages;
      json[r'smsCost'] = this.smsCost;
      json[r'uncostedMessages'] = this.uncostedMessages;
      json[r'paymentFee'] = this.paymentFee;
      json[r'margin'] = this.margin;
    if (this.marginPct != null) {
      json[r'marginPct'] = this.marginPct;
    } else {
      json[r'marginPct'] = null;
    }
    return json;
  }

  /// Returns a new [CostReportPlan] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CostReportPlan? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CostReportPlan[$key]" is missing from JSON.');
        });
        return true;
      }());

      return CostReportPlan(
        planKey: mapValueOfType<String>(json, r'planKey')!,
        revenue: num.parse('${json[r'revenue']}'),
        whatsappMessages: mapValueOfType<int>(json, r'whatsappMessages')!,
        whatsappCost: num.parse('${json[r'whatsappCost']}'),
        smsMessages: mapValueOfType<int>(json, r'smsMessages')!,
        smsCost: num.parse('${json[r'smsCost']}'),
        uncostedMessages: mapValueOfType<int>(json, r'uncostedMessages')!,
        paymentFee: num.parse('${json[r'paymentFee']}'),
        margin: num.parse('${json[r'margin']}'),
        marginPct: json[r'marginPct'] == null
            ? null
            : num.parse('${json[r'marginPct']}'),
      );
    }
    return null;
  }

  static List<CostReportPlan> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CostReportPlan>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CostReportPlan.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CostReportPlan> mapFromJson(dynamic json) {
    final map = <String, CostReportPlan>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CostReportPlan.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CostReportPlan-objects as value to a dart map
  static Map<String, List<CostReportPlan>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CostReportPlan>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CostReportPlan.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'planKey',
    'revenue',
    'whatsappMessages',
    'whatsappCost',
    'smsMessages',
    'smsCost',
    'uncostedMessages',
    'paymentFee',
    'margin',
    'marginPct',
  };
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class CostLine {
  /// Returns a new [CostLine] instance.
  CostLine({
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
  bool operator ==(Object other) => identical(this, other) || other is CostLine &&
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
  String toString() => 'CostLine[revenue=$revenue, whatsappMessages=$whatsappMessages, whatsappCost=$whatsappCost, smsMessages=$smsMessages, smsCost=$smsCost, uncostedMessages=$uncostedMessages, paymentFee=$paymentFee, margin=$margin, marginPct=$marginPct]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
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

  /// Returns a new [CostLine] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CostLine? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CostLine[$key]" is missing from JSON.');
        });
        return true;
      }());

      return CostLine(
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

  static List<CostLine> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CostLine>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CostLine.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CostLine> mapFromJson(dynamic json) {
    final map = <String, CostLine>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CostLine.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CostLine-objects as value to a dart map
  static Map<String, List<CostLine>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CostLine>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CostLine.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
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


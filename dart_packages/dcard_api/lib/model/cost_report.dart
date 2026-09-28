//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class CostReport {
  /// Returns a new [CostReport] instance.
  CostReport({
    required this.from,
    required this.to,
    required this.feePercent,
    this.events = const [],
    this.byPlan = const [],
    this.byMonth = const [],
    required this.total,
  });

  DateTime from;

  DateTime to;

  num feePercent;

  List<CostReportEvent> events;

  List<CostReportPlan> byPlan;

  List<CostReportMonth> byMonth;

  CostLine total;

  @override
  bool operator ==(Object other) => identical(this, other) || other is CostReport &&
    other.from == from &&
    other.to == to &&
    other.feePercent == feePercent &&
    _deepEquality.equals(other.events, events) &&
    _deepEquality.equals(other.byPlan, byPlan) &&
    _deepEquality.equals(other.byMonth, byMonth) &&
    other.total == total;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (from.hashCode) +
    (to.hashCode) +
    (feePercent.hashCode) +
    (events.hashCode) +
    (byPlan.hashCode) +
    (byMonth.hashCode) +
    (total.hashCode);

  @override
  String toString() => 'CostReport[from=$from, to=$to, feePercent=$feePercent, events=$events, byPlan=$byPlan, byMonth=$byMonth, total=$total]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'from'] = this.from.toUtc().toIso8601String();
      json[r'to'] = this.to.toUtc().toIso8601String();
      json[r'feePercent'] = this.feePercent;
      json[r'events'] = this.events;
      json[r'byPlan'] = this.byPlan;
      json[r'byMonth'] = this.byMonth;
      json[r'total'] = this.total;
    return json;
  }

  /// Returns a new [CostReport] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CostReport? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CostReport[$key]" is missing from JSON.');
        });
        return true;
      }());

      return CostReport(
        from: mapDateTime(json, r'from', r'')!,
        to: mapDateTime(json, r'to', r'')!,
        feePercent: num.parse('${json[r'feePercent']}'),
        events: CostReportEvent.listFromJson(json[r'events']),
        byPlan: CostReportPlan.listFromJson(json[r'byPlan']),
        byMonth: CostReportMonth.listFromJson(json[r'byMonth']),
        total: CostLine.fromJson(json[r'total'])!,
      );
    }
    return null;
  }

  static List<CostReport> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CostReport>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CostReport.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CostReport> mapFromJson(dynamic json) {
    final map = <String, CostReport>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CostReport.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CostReport-objects as value to a dart map
  static Map<String, List<CostReport>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CostReport>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CostReport.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'from',
    'to',
    'feePercent',
    'events',
    'byPlan',
    'byMonth',
    'total',
  };
}


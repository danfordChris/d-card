//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class CostReportEvent {
  /// Returns a new [CostReportEvent] instance.
  CostReportEvent({
    required this.eventId,
    required this.title,
    required this.startsAt,
    required this.planKey,
    required this.cardsPaid,
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

  String eventId;

  String title;

  DateTime startsAt;

  String? planKey;

  int cardsPaid;

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
  bool operator ==(Object other) => identical(this, other) || other is CostReportEvent &&
    other.eventId == eventId &&
    other.title == title &&
    other.startsAt == startsAt &&
    other.planKey == planKey &&
    other.cardsPaid == cardsPaid &&
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
    (eventId.hashCode) +
    (title.hashCode) +
    (startsAt.hashCode) +
    (planKey == null ? 0 : planKey!.hashCode) +
    (cardsPaid.hashCode) +
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
  String toString() => 'CostReportEvent[eventId=$eventId, title=$title, startsAt=$startsAt, planKey=$planKey, cardsPaid=$cardsPaid, revenue=$revenue, whatsappMessages=$whatsappMessages, whatsappCost=$whatsappCost, smsMessages=$smsMessages, smsCost=$smsCost, uncostedMessages=$uncostedMessages, paymentFee=$paymentFee, margin=$margin, marginPct=$marginPct]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'eventId'] = this.eventId;
      json[r'title'] = this.title;
      json[r'startsAt'] = this.startsAt.toUtc().toIso8601String();
    if (this.planKey != null) {
      json[r'planKey'] = this.planKey;
    } else {
      json[r'planKey'] = null;
    }
      json[r'cardsPaid'] = this.cardsPaid;
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

  /// Returns a new [CostReportEvent] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static CostReportEvent? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "CostReportEvent[$key]" is missing from JSON.');
        });
        return true;
      }());

      return CostReportEvent(
        eventId: mapValueOfType<String>(json, r'eventId')!,
        title: mapValueOfType<String>(json, r'title')!,
        startsAt: mapDateTime(json, r'startsAt', r'')!,
        planKey: mapValueOfType<String>(json, r'planKey'),
        cardsPaid: mapValueOfType<int>(json, r'cardsPaid')!,
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

  static List<CostReportEvent> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <CostReportEvent>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = CostReportEvent.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, CostReportEvent> mapFromJson(dynamic json) {
    final map = <String, CostReportEvent>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = CostReportEvent.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of CostReportEvent-objects as value to a dart map
  static Map<String, List<CostReportEvent>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<CostReportEvent>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = CostReportEvent.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'eventId',
    'title',
    'startsAt',
    'planKey',
    'cardsPaid',
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


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class ContributionsSummary {
  /// Returns a new [ContributionsSummary] instance.
  ContributionsSummary({
    required this.pledged,
    required this.collected,
    required this.outstanding,
    required this.extras,
    required this.refunds,
    required this.budget,
    required this.counts,
  });

  int pledged;

  int collected;

  int outstanding;

  int extras;

  int refunds;

  int? budget;

  ContributionsSummaryCounts counts;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ContributionsSummary &&
    other.pledged == pledged &&
    other.collected == collected &&
    other.outstanding == outstanding &&
    other.extras == extras &&
    other.refunds == refunds &&
    other.budget == budget &&
    other.counts == counts;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (pledged.hashCode) +
    (collected.hashCode) +
    (outstanding.hashCode) +
    (extras.hashCode) +
    (refunds.hashCode) +
    (budget == null ? 0 : budget!.hashCode) +
    (counts.hashCode);

  @override
  String toString() => 'ContributionsSummary[pledged=$pledged, collected=$collected, outstanding=$outstanding, extras=$extras, refunds=$refunds, budget=$budget, counts=$counts]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'pledged'] = this.pledged;
      json[r'collected'] = this.collected;
      json[r'outstanding'] = this.outstanding;
      json[r'extras'] = this.extras;
      json[r'refunds'] = this.refunds;
    if (this.budget != null) {
      json[r'budget'] = this.budget;
    } else {
      json[r'budget'] = null;
    }
      json[r'counts'] = this.counts;
    return json;
  }

  /// Returns a new [ContributionsSummary] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ContributionsSummary? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ContributionsSummary[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ContributionsSummary[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ContributionsSummary(
        pledged: mapValueOfType<int>(json, r'pledged')!,
        collected: mapValueOfType<int>(json, r'collected')!,
        outstanding: mapValueOfType<int>(json, r'outstanding')!,
        extras: mapValueOfType<int>(json, r'extras')!,
        refunds: mapValueOfType<int>(json, r'refunds')!,
        budget: mapValueOfType<int>(json, r'budget'),
        counts: ContributionsSummaryCounts.fromJson(json[r'counts'])!,
      );
    }
    return null;
  }

  static List<ContributionsSummary> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ContributionsSummary>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ContributionsSummary.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ContributionsSummary> mapFromJson(dynamic json) {
    final map = <String, ContributionsSummary>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ContributionsSummary.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ContributionsSummary-objects as value to a dart map
  static Map<String, List<ContributionsSummary>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ContributionsSummary>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ContributionsSummary.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'pledged',
    'collected',
    'outstanding',
    'extras',
    'refunds',
    'budget',
    'counts',
  };
}


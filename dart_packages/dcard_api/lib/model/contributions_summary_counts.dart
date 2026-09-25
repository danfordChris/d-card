//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class ContributionsSummaryCounts {
  /// Returns a new [ContributionsSummaryCounts] instance.
  ContributionsSummaryCounts({
    required this.notPaid,
    required this.partPaid,
    required this.fullyPaid,
    required this.cancelled,
  });

  int notPaid;

  int partPaid;

  int fullyPaid;

  int cancelled;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ContributionsSummaryCounts &&
    other.notPaid == notPaid &&
    other.partPaid == partPaid &&
    other.fullyPaid == fullyPaid &&
    other.cancelled == cancelled;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (notPaid.hashCode) +
    (partPaid.hashCode) +
    (fullyPaid.hashCode) +
    (cancelled.hashCode);

  @override
  String toString() => 'ContributionsSummaryCounts[notPaid=$notPaid, partPaid=$partPaid, fullyPaid=$fullyPaid, cancelled=$cancelled]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'not_paid'] = this.notPaid;
      json[r'part_paid'] = this.partPaid;
      json[r'fully_paid'] = this.fullyPaid;
      json[r'cancelled'] = this.cancelled;
    return json;
  }

  /// Returns a new [ContributionsSummaryCounts] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ContributionsSummaryCounts? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ContributionsSummaryCounts[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "ContributionsSummaryCounts[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return ContributionsSummaryCounts(
        notPaid: mapValueOfType<int>(json, r'not_paid')!,
        partPaid: mapValueOfType<int>(json, r'part_paid')!,
        fullyPaid: mapValueOfType<int>(json, r'fully_paid')!,
        cancelled: mapValueOfType<int>(json, r'cancelled')!,
      );
    }
    return null;
  }

  static List<ContributionsSummaryCounts> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ContributionsSummaryCounts>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ContributionsSummaryCounts.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ContributionsSummaryCounts> mapFromJson(dynamic json) {
    final map = <String, ContributionsSummaryCounts>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ContributionsSummaryCounts.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ContributionsSummaryCounts-objects as value to a dart map
  static Map<String, List<ContributionsSummaryCounts>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ContributionsSummaryCounts>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ContributionsSummaryCounts.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'not_paid',
    'part_paid',
    'fully_paid',
    'cancelled',
  };
}


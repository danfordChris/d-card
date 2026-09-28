//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class Contributions {
  /// Returns a new [Contributions] instance.
  Contributions({
    required this.summary,
    this.contributors = const [],
  });

  ContributionsSummary summary;

  List<Pledge> contributors;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Contributions &&
    other.summary == summary &&
    _deepEquality.equals(other.contributors, contributors);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (summary.hashCode) +
    (contributors.hashCode);

  @override
  String toString() => 'Contributions[summary=$summary, contributors=$contributors]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'summary'] = this.summary;
      json[r'contributors'] = this.contributors;
    return json;
  }

  /// Returns a new [Contributions] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Contributions? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Contributions[$key]" is missing from JSON.');
        });
        return true;
      }());

      return Contributions(
        summary: ContributionsSummary.fromJson(json[r'summary'])!,
        contributors: Pledge.listFromJson(json[r'contributors']),
      );
    }
    return null;
  }

  static List<Contributions> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Contributions>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Contributions.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Contributions> mapFromJson(dynamic json) {
    final map = <String, Contributions>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Contributions.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Contributions-objects as value to a dart map
  static Map<String, List<Contributions>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Contributions>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Contributions.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'summary',
    'contributors',
  };
}


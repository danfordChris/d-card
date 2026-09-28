//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class ListConfirmations200ResponseCounts {
  /// Returns a new [ListConfirmations200ResponseCounts] instance.
  ListConfirmations200ResponseCounts({
    required this.total,
    required this.yes,
    required this.no,
    required this.none,
  });

  int total;

  int yes;

  int no;

  int none;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ListConfirmations200ResponseCounts &&
    other.total == total &&
    other.yes == yes &&
    other.no == no &&
    other.none == none;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (total.hashCode) +
    (yes.hashCode) +
    (no.hashCode) +
    (none.hashCode);

  @override
  String toString() => 'ListConfirmations200ResponseCounts[total=$total, yes=$yes, no=$no, none=$none]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'total'] = this.total;
      json[r'yes'] = this.yes;
      json[r'no'] = this.no;
      json[r'none'] = this.none;
    return json;
  }

  /// Returns a new [ListConfirmations200ResponseCounts] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ListConfirmations200ResponseCounts? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ListConfirmations200ResponseCounts[$key]" is missing from JSON.');
        });
        return true;
      }());

      return ListConfirmations200ResponseCounts(
        total: mapValueOfType<int>(json, r'total')!,
        yes: mapValueOfType<int>(json, r'yes')!,
        no: mapValueOfType<int>(json, r'no')!,
        none: mapValueOfType<int>(json, r'none')!,
      );
    }
    return null;
  }

  static List<ListConfirmations200ResponseCounts> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ListConfirmations200ResponseCounts>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ListConfirmations200ResponseCounts.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ListConfirmations200ResponseCounts> mapFromJson(dynamic json) {
    final map = <String, ListConfirmations200ResponseCounts>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ListConfirmations200ResponseCounts.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ListConfirmations200ResponseCounts-objects as value to a dart map
  static Map<String, List<ListConfirmations200ResponseCounts>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ListConfirmations200ResponseCounts>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ListConfirmations200ResponseCounts.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'total',
    'yes',
    'no',
    'none',
  };
}


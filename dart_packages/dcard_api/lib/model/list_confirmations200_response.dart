//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class ListConfirmations200Response {
  /// Returns a new [ListConfirmations200Response] instance.
  ListConfirmations200Response({
    this.guests = const [],
    required this.counts,
    required this.totalEntries,
    required this.expectedHeadcount,
    required this.headcountPct,
  });

  List<ListConfirmations200ResponseGuestsInner> guests;

  ListConfirmations200ResponseCounts counts;

  int totalEntries;

  num expectedHeadcount;

  int headcountPct;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ListConfirmations200Response &&
    _deepEquality.equals(other.guests, guests) &&
    other.counts == counts &&
    other.totalEntries == totalEntries &&
    other.expectedHeadcount == expectedHeadcount &&
    other.headcountPct == headcountPct;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (guests.hashCode) +
    (counts.hashCode) +
    (totalEntries.hashCode) +
    (expectedHeadcount.hashCode) +
    (headcountPct.hashCode);

  @override
  String toString() => 'ListConfirmations200Response[guests=$guests, counts=$counts, totalEntries=$totalEntries, expectedHeadcount=$expectedHeadcount, headcountPct=$headcountPct]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'guests'] = this.guests;
      json[r'counts'] = this.counts;
      json[r'totalEntries'] = this.totalEntries;
      json[r'expectedHeadcount'] = this.expectedHeadcount;
      json[r'headcountPct'] = this.headcountPct;
    return json;
  }

  /// Returns a new [ListConfirmations200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ListConfirmations200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ListConfirmations200Response[$key]" is missing from JSON.');
        });
        return true;
      }());

      return ListConfirmations200Response(
        guests: ListConfirmations200ResponseGuestsInner.listFromJson(json[r'guests']),
        counts: ListConfirmations200ResponseCounts.fromJson(json[r'counts'])!,
        totalEntries: mapValueOfType<int>(json, r'totalEntries')!,
        expectedHeadcount: num.parse('${json[r'expectedHeadcount']}'),
        headcountPct: mapValueOfType<int>(json, r'headcountPct')!,
      );
    }
    return null;
  }

  static List<ListConfirmations200Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ListConfirmations200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ListConfirmations200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ListConfirmations200Response> mapFromJson(dynamic json) {
    final map = <String, ListConfirmations200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ListConfirmations200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ListConfirmations200Response-objects as value to a dart map
  static Map<String, List<ListConfirmations200Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ListConfirmations200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ListConfirmations200Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'guests',
    'counts',
    'totalEntries',
    'expectedHeadcount',
    'headcountPct',
  };
}


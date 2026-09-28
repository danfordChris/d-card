//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class AdminListProviderRates200Response {
  /// Returns a new [AdminListProviderRates200Response] instance.
  AdminListProviderRates200Response({
    this.rates = const [],
  });

  List<AdminListProviderRates200ResponseRatesInner> rates;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminListProviderRates200Response &&
    _deepEquality.equals(other.rates, rates);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (rates.hashCode);

  @override
  String toString() => 'AdminListProviderRates200Response[rates=$rates]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'rates'] = this.rates;
    return json;
  }

  /// Returns a new [AdminListProviderRates200Response] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminListProviderRates200Response? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AdminListProviderRates200Response[$key]" is missing from JSON.');
        });
        return true;
      }());

      return AdminListProviderRates200Response(
        rates: AdminListProviderRates200ResponseRatesInner.listFromJson(json[r'rates']),
      );
    }
    return null;
  }

  static List<AdminListProviderRates200Response> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminListProviderRates200Response>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminListProviderRates200Response.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminListProviderRates200Response> mapFromJson(dynamic json) {
    final map = <String, AdminListProviderRates200Response>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminListProviderRates200Response.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminListProviderRates200Response-objects as value to a dart map
  static Map<String, List<AdminListProviderRates200Response>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminListProviderRates200Response>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminListProviderRates200Response.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'rates',
  };
}


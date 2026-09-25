//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class PledgeDetail {
  /// Returns a new [PledgeDetail] instance.
  PledgeDetail({
    required this.pledge,
    this.payments = const [],
  });

  Pledge pledge;

  List<Payment> payments;

  @override
  bool operator ==(Object other) => identical(this, other) || other is PledgeDetail &&
    other.pledge == pledge &&
    _deepEquality.equals(other.payments, payments);

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (pledge.hashCode) +
    (payments.hashCode);

  @override
  String toString() => 'PledgeDetail[pledge=$pledge, payments=$payments]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'pledge'] = this.pledge;
      json[r'payments'] = this.payments;
    return json;
  }

  /// Returns a new [PledgeDetail] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static PledgeDetail? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "PledgeDetail[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "PledgeDetail[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return PledgeDetail(
        pledge: Pledge.fromJson(json[r'pledge'])!,
        payments: Payment.listFromJson(json[r'payments']),
      );
    }
    return null;
  }

  static List<PledgeDetail> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <PledgeDetail>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = PledgeDetail.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, PledgeDetail> mapFromJson(dynamic json) {
    final map = <String, PledgeDetail>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = PledgeDetail.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of PledgeDetail-objects as value to a dart map
  static Map<String, List<PledgeDetail>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<PledgeDetail>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = PledgeDetail.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'pledge',
    'payments',
  };
}


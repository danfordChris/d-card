//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class WalkInDecisionInput {
  /// Returns a new [WalkInDecisionInput] instance.
  WalkInDecisionInput({
    required this.decision,
  });

  WalkInDecisionInputDecisionEnum decision;

  @override
  bool operator ==(Object other) => identical(this, other) || other is WalkInDecisionInput &&
    other.decision == decision;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (decision.hashCode);

  @override
  String toString() => 'WalkInDecisionInput[decision=$decision]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'decision'] = this.decision;
    return json;
  }

  /// Returns a new [WalkInDecisionInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static WalkInDecisionInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "WalkInDecisionInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return WalkInDecisionInput(
        decision: WalkInDecisionInputDecisionEnum.fromJson(json[r'decision'])!,
      );
    }
    return null;
  }

  static List<WalkInDecisionInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WalkInDecisionInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WalkInDecisionInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, WalkInDecisionInput> mapFromJson(dynamic json) {
    final map = <String, WalkInDecisionInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = WalkInDecisionInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of WalkInDecisionInput-objects as value to a dart map
  static Map<String, List<WalkInDecisionInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<WalkInDecisionInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = WalkInDecisionInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'decision',
  };
}


class WalkInDecisionInputDecisionEnum {
  /// Instantiate a new enum with the provided [value].
  const WalkInDecisionInputDecisionEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const approve = WalkInDecisionInputDecisionEnum._(r'approve');
  static const refuse = WalkInDecisionInputDecisionEnum._(r'refuse');
  static const accept = WalkInDecisionInputDecisionEnum._(r'accept');
  static const flag = WalkInDecisionInputDecisionEnum._(r'flag');

  /// List of all possible values in this [enum][WalkInDecisionInputDecisionEnum].
  static const values = <WalkInDecisionInputDecisionEnum>[
    approve,
    refuse,
    accept,
    flag,
  ];

  static WalkInDecisionInputDecisionEnum? fromJson(dynamic value) => WalkInDecisionInputDecisionEnumTypeTransformer().decode(value);

  static List<WalkInDecisionInputDecisionEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <WalkInDecisionInputDecisionEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = WalkInDecisionInputDecisionEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [WalkInDecisionInputDecisionEnum] to String,
/// and [decode] dynamic data back to [WalkInDecisionInputDecisionEnum].
class WalkInDecisionInputDecisionEnumTypeTransformer {
  factory WalkInDecisionInputDecisionEnumTypeTransformer() => _instance ??= const WalkInDecisionInputDecisionEnumTypeTransformer._();

  const WalkInDecisionInputDecisionEnumTypeTransformer._();

  String encode(WalkInDecisionInputDecisionEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a WalkInDecisionInputDecisionEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  WalkInDecisionInputDecisionEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'approve': return WalkInDecisionInputDecisionEnum.approve;
        case r'refuse': return WalkInDecisionInputDecisionEnum.refuse;
        case r'accept': return WalkInDecisionInputDecisionEnum.accept;
        case r'flag': return WalkInDecisionInputDecisionEnum.flag;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [WalkInDecisionInputDecisionEnumTypeTransformer] instance.
  static WalkInDecisionInputDecisionEnumTypeTransformer? _instance;
}



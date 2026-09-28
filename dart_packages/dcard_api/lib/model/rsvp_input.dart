//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class RsvpInput {
  /// Returns a new [RsvpInput] instance.
  RsvpInput({
    required this.answer,
    this.dietaryNotes,
  });

  RsvpInputAnswerEnum answer;

  String? dietaryNotes;

  @override
  bool operator ==(Object other) => identical(this, other) || other is RsvpInput &&
    other.answer == answer &&
    other.dietaryNotes == dietaryNotes;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (answer.hashCode) +
    (dietaryNotes == null ? 0 : dietaryNotes!.hashCode);

  @override
  String toString() => 'RsvpInput[answer=$answer, dietaryNotes=$dietaryNotes]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'answer'] = this.answer;
    if (this.dietaryNotes != null) {
      json[r'dietaryNotes'] = this.dietaryNotes;
    } else {
      json[r'dietaryNotes'] = null;
    }
    return json;
  }

  /// Returns a new [RsvpInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static RsvpInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "RsvpInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return RsvpInput(
        answer: RsvpInputAnswerEnum.fromJson(json[r'answer'])!,
        dietaryNotes: mapValueOfType<String>(json, r'dietaryNotes'),
      );
    }
    return null;
  }

  static List<RsvpInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RsvpInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RsvpInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, RsvpInput> mapFromJson(dynamic json) {
    final map = <String, RsvpInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = RsvpInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of RsvpInput-objects as value to a dart map
  static Map<String, List<RsvpInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<RsvpInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = RsvpInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'answer',
  };
}


class RsvpInputAnswerEnum {
  /// Instantiate a new enum with the provided [value].
  const RsvpInputAnswerEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const yes = RsvpInputAnswerEnum._(r'yes');
  static const no = RsvpInputAnswerEnum._(r'no');

  /// List of all possible values in this [enum][RsvpInputAnswerEnum].
  static const values = <RsvpInputAnswerEnum>[
    yes,
    no,
  ];

  static RsvpInputAnswerEnum? fromJson(dynamic value) => RsvpInputAnswerEnumTypeTransformer().decode(value);

  static List<RsvpInputAnswerEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RsvpInputAnswerEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RsvpInputAnswerEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RsvpInputAnswerEnum] to String,
/// and [decode] dynamic data back to [RsvpInputAnswerEnum].
class RsvpInputAnswerEnumTypeTransformer {
  factory RsvpInputAnswerEnumTypeTransformer() => _instance ??= const RsvpInputAnswerEnumTypeTransformer._();

  const RsvpInputAnswerEnumTypeTransformer._();

  String encode(RsvpInputAnswerEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a RsvpInputAnswerEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RsvpInputAnswerEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'yes': return RsvpInputAnswerEnum.yes;
        case r'no': return RsvpInputAnswerEnum.no;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RsvpInputAnswerEnumTypeTransformer] instance.
  static RsvpInputAnswerEnumTypeTransformer? _instance;
}



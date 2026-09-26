//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class Rsvp {
  /// Returns a new [Rsvp] instance.
  Rsvp({
    required this.status,
    required this.dietaryNotes,
    required this.at,
    required this.open,
  });

  RsvpStatusEnum status;

  String? dietaryNotes;

  DateTime? at;

  bool open;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Rsvp &&
    other.status == status &&
    other.dietaryNotes == dietaryNotes &&
    other.at == at &&
    other.open == open;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (status.hashCode) +
    (dietaryNotes == null ? 0 : dietaryNotes!.hashCode) +
    (at == null ? 0 : at!.hashCode) +
    (open.hashCode);

  @override
  String toString() => 'Rsvp[status=$status, dietaryNotes=$dietaryNotes, at=$at, open=$open]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'status'] = this.status;
    if (this.dietaryNotes != null) {
      json[r'dietaryNotes'] = this.dietaryNotes;
    } else {
      json[r'dietaryNotes'] = null;
    }
    if (this.at != null) {
      json[r'at'] = this.at!.toUtc().toIso8601String();
    } else {
      json[r'at'] = null;
    }
      json[r'open'] = this.open;
    return json;
  }

  /// Returns a new [Rsvp] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Rsvp? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Rsvp[$key]" is missing from JSON.');
        });
        return true;
      }());

      return Rsvp(
        status: RsvpStatusEnum.fromJson(json[r'status'])!,
        dietaryNotes: mapValueOfType<String>(json, r'dietaryNotes'),
        at: mapDateTime(json, r'at', r''),
        open: mapValueOfType<bool>(json, r'open')!,
      );
    }
    return null;
  }

  static List<Rsvp> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Rsvp>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Rsvp.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Rsvp> mapFromJson(dynamic json) {
    final map = <String, Rsvp>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Rsvp.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Rsvp-objects as value to a dart map
  static Map<String, List<Rsvp>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Rsvp>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Rsvp.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'status',
    'dietaryNotes',
    'at',
    'open',
  };
}


class RsvpStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const RsvpStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const none = RsvpStatusEnum._(r'none');
  static const yes = RsvpStatusEnum._(r'yes');
  static const no = RsvpStatusEnum._(r'no');

  /// List of all possible values in this [enum][RsvpStatusEnum].
  static const values = <RsvpStatusEnum>[
    none,
    yes,
    no,
  ];

  static RsvpStatusEnum? fromJson(dynamic value) => RsvpStatusEnumTypeTransformer().decode(value);

  static List<RsvpStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <RsvpStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = RsvpStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [RsvpStatusEnum] to String,
/// and [decode] dynamic data back to [RsvpStatusEnum].
class RsvpStatusEnumTypeTransformer {
  factory RsvpStatusEnumTypeTransformer() => _instance ??= const RsvpStatusEnumTypeTransformer._();

  const RsvpStatusEnumTypeTransformer._();

  String encode(RsvpStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a RsvpStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  RsvpStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'none': return RsvpStatusEnum.none;
        case r'yes': return RsvpStatusEnum.yes;
        case r'no': return RsvpStatusEnum.no;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [RsvpStatusEnumTypeTransformer] instance.
  static RsvpStatusEnumTypeTransformer? _instance;
}



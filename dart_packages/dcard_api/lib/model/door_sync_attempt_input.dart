//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class DoorSyncAttemptInput {
  /// Returns a new [DoorSyncAttemptInput] instance.
  DoorSyncAttemptInput({
    required this.id,
    this.invitationId,
    required this.method,
    this.query,
    required this.outcome,
    required this.occurredAt,
  });

  String id;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? invitationId;

  CheckInMethod method;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? query;

  DoorSyncAttemptInputOutcomeEnum outcome;

  DateTime occurredAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is DoorSyncAttemptInput &&
    other.id == id &&
    other.invitationId == invitationId &&
    other.method == method &&
    other.query == query &&
    other.outcome == outcome &&
    other.occurredAt == occurredAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (invitationId == null ? 0 : invitationId!.hashCode) +
    (method.hashCode) +
    (query == null ? 0 : query!.hashCode) +
    (outcome.hashCode) +
    (occurredAt.hashCode);

  @override
  String toString() => 'DoorSyncAttemptInput[id=$id, invitationId=$invitationId, method=$method, query=$query, outcome=$outcome, occurredAt=$occurredAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    if (this.invitationId != null) {
      json[r'invitationId'] = this.invitationId;
    } else {
      json[r'invitationId'] = null;
    }
      json[r'method'] = this.method;
    if (this.query != null) {
      json[r'query'] = this.query;
    } else {
      json[r'query'] = null;
    }
      json[r'outcome'] = this.outcome;
      json[r'occurredAt'] = this.occurredAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [DoorSyncAttemptInput] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static DoorSyncAttemptInput? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "DoorSyncAttemptInput[$key]" is missing from JSON.');
        });
        return true;
      }());

      return DoorSyncAttemptInput(
        id: mapValueOfType<String>(json, r'id')!,
        invitationId: mapValueOfType<String>(json, r'invitationId'),
        method: CheckInMethod.fromJson(json[r'method'])!,
        query: mapValueOfType<String>(json, r'query'),
        outcome: DoorSyncAttemptInputOutcomeEnum.fromJson(json[r'outcome'])!,
        occurredAt: mapDateTime(json, r'occurredAt', r'')!,
      );
    }
    return null;
  }

  static List<DoorSyncAttemptInput> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorSyncAttemptInput>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorSyncAttemptInput.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, DoorSyncAttemptInput> mapFromJson(dynamic json) {
    final map = <String, DoorSyncAttemptInput>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = DoorSyncAttemptInput.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of DoorSyncAttemptInput-objects as value to a dart map
  static Map<String, List<DoorSyncAttemptInput>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<DoorSyncAttemptInput>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = DoorSyncAttemptInput.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'method',
    'outcome',
    'occurredAt',
  };
}


class DoorSyncAttemptInputOutcomeEnum {
  /// Instantiate a new enum with the provided [value].
  const DoorSyncAttemptInputOutcomeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const fullyUsed = DoorSyncAttemptInputOutcomeEnum._(r'fully_used');
  static const cancelled = DoorSyncAttemptInputOutcomeEnum._(r'cancelled');
  static const notIssued = DoorSyncAttemptInputOutcomeEnum._(r'not_issued');
  static const tooMany = DoorSyncAttemptInputOutcomeEnum._(r'too_many');
  static const notFound = DoorSyncAttemptInputOutcomeEnum._(r'not_found');
  static const locked = DoorSyncAttemptInputOutcomeEnum._(r'locked');

  /// List of all possible values in this [enum][DoorSyncAttemptInputOutcomeEnum].
  static const values = <DoorSyncAttemptInputOutcomeEnum>[
    fullyUsed,
    cancelled,
    notIssued,
    tooMany,
    notFound,
    locked,
  ];

  static DoorSyncAttemptInputOutcomeEnum? fromJson(dynamic value) => DoorSyncAttemptInputOutcomeEnumTypeTransformer().decode(value);

  static List<DoorSyncAttemptInputOutcomeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <DoorSyncAttemptInputOutcomeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = DoorSyncAttemptInputOutcomeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [DoorSyncAttemptInputOutcomeEnum] to String,
/// and [decode] dynamic data back to [DoorSyncAttemptInputOutcomeEnum].
class DoorSyncAttemptInputOutcomeEnumTypeTransformer {
  factory DoorSyncAttemptInputOutcomeEnumTypeTransformer() => _instance ??= const DoorSyncAttemptInputOutcomeEnumTypeTransformer._();

  const DoorSyncAttemptInputOutcomeEnumTypeTransformer._();

  String encode(DoorSyncAttemptInputOutcomeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a DoorSyncAttemptInputOutcomeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  DoorSyncAttemptInputOutcomeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'fully_used': return DoorSyncAttemptInputOutcomeEnum.fullyUsed;
        case r'cancelled': return DoorSyncAttemptInputOutcomeEnum.cancelled;
        case r'not_issued': return DoorSyncAttemptInputOutcomeEnum.notIssued;
        case r'too_many': return DoorSyncAttemptInputOutcomeEnum.tooMany;
        case r'not_found': return DoorSyncAttemptInputOutcomeEnum.notFound;
        case r'locked': return DoorSyncAttemptInputOutcomeEnum.locked;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [DoorSyncAttemptInputOutcomeEnumTypeTransformer] instance.
  static DoorSyncAttemptInputOutcomeEnumTypeTransformer? _instance;
}



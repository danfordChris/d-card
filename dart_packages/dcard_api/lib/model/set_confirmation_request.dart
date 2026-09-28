//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class SetConfirmationRequest {
  /// Returns a new [SetConfirmationRequest] instance.
  SetConfirmationRequest({
    required this.status,
  });

  SetConfirmationRequestStatusEnum status;

  @override
  bool operator ==(Object other) => identical(this, other) || other is SetConfirmationRequest &&
    other.status == status;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (status.hashCode);

  @override
  String toString() => 'SetConfirmationRequest[status=$status]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'status'] = this.status;
    return json;
  }

  /// Returns a new [SetConfirmationRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static SetConfirmationRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "SetConfirmationRequest[$key]" is missing from JSON.');
        });
        return true;
      }());

      return SetConfirmationRequest(
        status: SetConfirmationRequestStatusEnum.fromJson(json[r'status'])!,
      );
    }
    return null;
  }

  static List<SetConfirmationRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SetConfirmationRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SetConfirmationRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, SetConfirmationRequest> mapFromJson(dynamic json) {
    final map = <String, SetConfirmationRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = SetConfirmationRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of SetConfirmationRequest-objects as value to a dart map
  static Map<String, List<SetConfirmationRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<SetConfirmationRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = SetConfirmationRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'status',
  };
}


class SetConfirmationRequestStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const SetConfirmationRequestStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const none = SetConfirmationRequestStatusEnum._(r'none');
  static const yes = SetConfirmationRequestStatusEnum._(r'yes');
  static const no = SetConfirmationRequestStatusEnum._(r'no');

  /// List of all possible values in this [enum][SetConfirmationRequestStatusEnum].
  static const values = <SetConfirmationRequestStatusEnum>[
    none,
    yes,
    no,
  ];

  static SetConfirmationRequestStatusEnum? fromJson(dynamic value) => SetConfirmationRequestStatusEnumTypeTransformer().decode(value);

  static List<SetConfirmationRequestStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <SetConfirmationRequestStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = SetConfirmationRequestStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [SetConfirmationRequestStatusEnum] to String,
/// and [decode] dynamic data back to [SetConfirmationRequestStatusEnum].
class SetConfirmationRequestStatusEnumTypeTransformer {
  factory SetConfirmationRequestStatusEnumTypeTransformer() => _instance ??= const SetConfirmationRequestStatusEnumTypeTransformer._();

  const SetConfirmationRequestStatusEnumTypeTransformer._();

  String encode(SetConfirmationRequestStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a SetConfirmationRequestStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  SetConfirmationRequestStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'none': return SetConfirmationRequestStatusEnum.none;
        case r'yes': return SetConfirmationRequestStatusEnum.yes;
        case r'no': return SetConfirmationRequestStatusEnum.no;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [SetConfirmationRequestStatusEnumTypeTransformer] instance.
  static SetConfirmationRequestStatusEnumTypeTransformer? _instance;
}



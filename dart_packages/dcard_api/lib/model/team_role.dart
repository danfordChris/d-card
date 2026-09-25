//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;


class TeamRole {
  /// Instantiate a new enum with the provided [value].
  const TeamRole._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const treasurer = TeamRole._(r'treasurer');
  static const committee = TeamRole._(r'committee');
  static const doorStaff = TeamRole._(r'door_staff');
  static const walkinApprover = TeamRole._(r'walkin_approver');

  /// List of all possible values in this [enum][TeamRole].
  static const values = <TeamRole>[
    treasurer,
    committee,
    doorStaff,
    walkinApprover,
  ];

  static TeamRole? fromJson(dynamic value) => TeamRoleTypeTransformer().decode(value);

  static List<TeamRole> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <TeamRole>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = TeamRole.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [TeamRole] to String,
/// and [decode] dynamic data back to [TeamRole].
class TeamRoleTypeTransformer {
  factory TeamRoleTypeTransformer() => _instance ??= const TeamRoleTypeTransformer._();

  const TeamRoleTypeTransformer._();

  String encode(TeamRole data) => data.value;

  /// Decodes a [dynamic value][data] to a TeamRole.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  TeamRole? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'treasurer': return TeamRole.treasurer;
        case r'committee': return TeamRole.committee;
        case r'door_staff': return TeamRole.doorStaff;
        case r'walkin_approver': return TeamRole.walkinApprover;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [TeamRoleTypeTransformer] instance.
  static TeamRoleTypeTransformer? _instance;
}


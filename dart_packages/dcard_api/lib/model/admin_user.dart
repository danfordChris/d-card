//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class AdminUser {
  /// Returns a new [AdminUser] instance.
  AdminUser({
    required this.id,
    required this.email,
    required this.phone,
    required this.name,
    required this.authProvider,
    required this.isAdmin,
    required this.disabledAt,
    required this.deletedAt,
    required this.createdAt,
    required this.eventsHosted,
    required this.teamRoles,
  });

  String id;

  String? email;

  String? phone;

  String? name;

  AdminUserAuthProviderEnum authProvider;

  bool isAdmin;

  DateTime? disabledAt;

  DateTime? deletedAt;

  DateTime createdAt;

  int eventsHosted;

  int teamRoles;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminUser &&
    other.id == id &&
    other.email == email &&
    other.phone == phone &&
    other.name == name &&
    other.authProvider == authProvider &&
    other.isAdmin == isAdmin &&
    other.disabledAt == disabledAt &&
    other.deletedAt == deletedAt &&
    other.createdAt == createdAt &&
    other.eventsHosted == eventsHosted &&
    other.teamRoles == teamRoles;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (email == null ? 0 : email!.hashCode) +
    (phone == null ? 0 : phone!.hashCode) +
    (name == null ? 0 : name!.hashCode) +
    (authProvider.hashCode) +
    (isAdmin.hashCode) +
    (disabledAt == null ? 0 : disabledAt!.hashCode) +
    (deletedAt == null ? 0 : deletedAt!.hashCode) +
    (createdAt.hashCode) +
    (eventsHosted.hashCode) +
    (teamRoles.hashCode);

  @override
  String toString() => 'AdminUser[id=$id, email=$email, phone=$phone, name=$name, authProvider=$authProvider, isAdmin=$isAdmin, disabledAt=$disabledAt, deletedAt=$deletedAt, createdAt=$createdAt, eventsHosted=$eventsHosted, teamRoles=$teamRoles]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
    if (this.email != null) {
      json[r'email'] = this.email;
    } else {
      json[r'email'] = null;
    }
    if (this.phone != null) {
      json[r'phone'] = this.phone;
    } else {
      json[r'phone'] = null;
    }
    if (this.name != null) {
      json[r'name'] = this.name;
    } else {
      json[r'name'] = null;
    }
      json[r'authProvider'] = this.authProvider;
      json[r'isAdmin'] = this.isAdmin;
    if (this.disabledAt != null) {
      json[r'disabledAt'] = this.disabledAt!.toUtc().toIso8601String();
    } else {
      json[r'disabledAt'] = null;
    }
    if (this.deletedAt != null) {
      json[r'deletedAt'] = this.deletedAt!.toUtc().toIso8601String();
    } else {
      json[r'deletedAt'] = null;
    }
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'eventsHosted'] = this.eventsHosted;
      json[r'teamRoles'] = this.teamRoles;
    return json;
  }

  /// Returns a new [AdminUser] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminUser? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AdminUser[$key]" is missing from JSON.');
        });
        return true;
      }());

      return AdminUser(
        id: mapValueOfType<String>(json, r'id')!,
        email: mapValueOfType<String>(json, r'email'),
        phone: mapValueOfType<String>(json, r'phone'),
        name: mapValueOfType<String>(json, r'name'),
        authProvider: AdminUserAuthProviderEnum.fromJson(json[r'authProvider'])!,
        isAdmin: mapValueOfType<bool>(json, r'isAdmin')!,
        disabledAt: mapDateTime(json, r'disabledAt', r''),
        deletedAt: mapDateTime(json, r'deletedAt', r''),
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        eventsHosted: mapValueOfType<int>(json, r'eventsHosted')!,
        teamRoles: mapValueOfType<int>(json, r'teamRoles')!,
      );
    }
    return null;
  }

  static List<AdminUser> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminUser>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminUser.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminUser> mapFromJson(dynamic json) {
    final map = <String, AdminUser>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminUser.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminUser-objects as value to a dart map
  static Map<String, List<AdminUser>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminUser>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminUser.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'email',
    'phone',
    'name',
    'authProvider',
    'isAdmin',
    'disabledAt',
    'deletedAt',
    'createdAt',
    'eventsHosted',
    'teamRoles',
  };
}


class AdminUserAuthProviderEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminUserAuthProviderEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const password = AdminUserAuthProviderEnum._(r'password');
  static const google = AdminUserAuthProviderEnum._(r'google');
  static const apple = AdminUserAuthProviderEnum._(r'apple');

  /// List of all possible values in this [enum][AdminUserAuthProviderEnum].
  static const values = <AdminUserAuthProviderEnum>[
    password,
    google,
    apple,
  ];

  static AdminUserAuthProviderEnum? fromJson(dynamic value) => AdminUserAuthProviderEnumTypeTransformer().decode(value);

  static List<AdminUserAuthProviderEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminUserAuthProviderEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminUserAuthProviderEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminUserAuthProviderEnum] to String,
/// and [decode] dynamic data back to [AdminUserAuthProviderEnum].
class AdminUserAuthProviderEnumTypeTransformer {
  factory AdminUserAuthProviderEnumTypeTransformer() => _instance ??= const AdminUserAuthProviderEnumTypeTransformer._();

  const AdminUserAuthProviderEnumTypeTransformer._();

  String encode(AdminUserAuthProviderEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminUserAuthProviderEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminUserAuthProviderEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'password': return AdminUserAuthProviderEnum.password;
        case r'google': return AdminUserAuthProviderEnum.google;
        case r'apple': return AdminUserAuthProviderEnum.apple;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminUserAuthProviderEnumTypeTransformer] instance.
  static AdminUserAuthProviderEnumTypeTransformer? _instance;
}



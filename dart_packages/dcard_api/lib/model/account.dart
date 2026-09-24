//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class Account {
  /// Returns a new [Account] instance.
  Account({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.authProvider,
    required this.personId,
    required this.isAdmin,
    required this.emailVerified,
    required this.createdAt,
  });

  String id;

  String firebaseUid;

  String? email;

  AuthProvider authProvider;

  String? personId;

  bool isAdmin;

  bool emailVerified;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is Account &&
    other.id == id &&
    other.firebaseUid == firebaseUid &&
    other.email == email &&
    other.authProvider == authProvider &&
    other.personId == personId &&
    other.isAdmin == isAdmin &&
    other.emailVerified == emailVerified &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (firebaseUid.hashCode) +
    (email == null ? 0 : email!.hashCode) +
    (authProvider.hashCode) +
    (personId == null ? 0 : personId!.hashCode) +
    (isAdmin.hashCode) +
    (emailVerified.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'Account[id=$id, firebaseUid=$firebaseUid, email=$email, authProvider=$authProvider, personId=$personId, isAdmin=$isAdmin, emailVerified=$emailVerified, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'firebaseUid'] = this.firebaseUid;
    if (this.email != null) {
      json[r'email'] = this.email;
    } else {
      json[r'email'] = null;
    }
      json[r'authProvider'] = this.authProvider;
    if (this.personId != null) {
      json[r'personId'] = this.personId;
    } else {
      json[r'personId'] = null;
    }
      json[r'isAdmin'] = this.isAdmin;
      json[r'emailVerified'] = this.emailVerified;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [Account] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static Account? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "Account[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "Account[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return Account(
        id: mapValueOfType<String>(json, r'id')!,
        firebaseUid: mapValueOfType<String>(json, r'firebaseUid')!,
        email: mapValueOfType<String>(json, r'email'),
        authProvider: AuthProvider.fromJson(json[r'authProvider'])!,
        personId: mapValueOfType<String>(json, r'personId'),
        isAdmin: mapValueOfType<bool>(json, r'isAdmin')!,
        emailVerified: mapValueOfType<bool>(json, r'emailVerified')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<Account> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <Account>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = Account.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, Account> mapFromJson(dynamic json) {
    final map = <String, Account>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = Account.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of Account-objects as value to a dart map
  static Map<String, List<Account>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<Account>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = Account.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'firebaseUid',
    'email',
    'authProvider',
    'personId',
    'isAdmin',
    'emailVerified',
    'createdAt',
  };
}


//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;


class AuthProvider {
  /// Instantiate a new enum with the provided [value].
  const AuthProvider._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const password = AuthProvider._(r'password');
  static const google = AuthProvider._(r'google');
  static const apple = AuthProvider._(r'apple');

  /// List of all possible values in this [enum][AuthProvider].
  static const values = <AuthProvider>[
    password,
    google,
    apple,
  ];

  static AuthProvider? fromJson(dynamic value) => AuthProviderTypeTransformer().decode(value);

  static List<AuthProvider> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AuthProvider>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AuthProvider.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AuthProvider] to String,
/// and [decode] dynamic data back to [AuthProvider].
class AuthProviderTypeTransformer {
  factory AuthProviderTypeTransformer() => _instance ??= const AuthProviderTypeTransformer._();

  const AuthProviderTypeTransformer._();

  String encode(AuthProvider data) => data.value;

  /// Decodes a [dynamic value][data] to a AuthProvider.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AuthProvider? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'password': return AuthProvider.password;
        case r'google': return AuthProvider.google;
        case r'apple': return AuthProvider.apple;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AuthProviderTypeTransformer] instance.
  static AuthProviderTypeTransformer? _instance;
}


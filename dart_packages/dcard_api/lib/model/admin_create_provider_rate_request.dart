//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class AdminCreateProviderRateRequest {
  /// Returns a new [AdminCreateProviderRateRequest] instance.
  AdminCreateProviderRateRequest({
    required this.provider,
    required this.channel,
    required this.category,
    required this.market,
    required this.priceTzs,
    required this.effectiveFrom,
  });

  AdminCreateProviderRateRequestProviderEnum provider;

  AdminCreateProviderRateRequestChannelEnum channel;

  String category;

  String market;

  String priceTzs;

  DateTime effectiveFrom;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminCreateProviderRateRequest &&
    other.provider == provider &&
    other.channel == channel &&
    other.category == category &&
    other.market == market &&
    other.priceTzs == priceTzs &&
    other.effectiveFrom == effectiveFrom;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (provider.hashCode) +
    (channel.hashCode) +
    (category.hashCode) +
    (market.hashCode) +
    (priceTzs.hashCode) +
    (effectiveFrom.hashCode);

  @override
  String toString() => 'AdminCreateProviderRateRequest[provider=$provider, channel=$channel, category=$category, market=$market, priceTzs=$priceTzs, effectiveFrom=$effectiveFrom]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'provider'] = this.provider;
      json[r'channel'] = this.channel;
      json[r'category'] = this.category;
      json[r'market'] = this.market;
      json[r'priceTzs'] = this.priceTzs;
      json[r'effectiveFrom'] = this.effectiveFrom.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [AdminCreateProviderRateRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminCreateProviderRateRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AdminCreateProviderRateRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AdminCreateProviderRateRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AdminCreateProviderRateRequest(
        provider: AdminCreateProviderRateRequestProviderEnum.fromJson(json[r'provider'])!,
        channel: AdminCreateProviderRateRequestChannelEnum.fromJson(json[r'channel'])!,
        category: mapValueOfType<String>(json, r'category')!,
        market: mapValueOfType<String>(json, r'market')!,
        priceTzs: mapValueOfType<String>(json, r'priceTzs')!,
        effectiveFrom: mapDateTime(json, r'effectiveFrom', r'')!,
      );
    }
    return null;
  }

  static List<AdminCreateProviderRateRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminCreateProviderRateRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminCreateProviderRateRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminCreateProviderRateRequest> mapFromJson(dynamic json) {
    final map = <String, AdminCreateProviderRateRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminCreateProviderRateRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminCreateProviderRateRequest-objects as value to a dart map
  static Map<String, List<AdminCreateProviderRateRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminCreateProviderRateRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminCreateProviderRateRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'provider',
    'channel',
    'category',
    'market',
    'priceTzs',
    'effectiveFrom',
  };
}


class AdminCreateProviderRateRequestProviderEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminCreateProviderRateRequestProviderEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const meta = AdminCreateProviderRateRequestProviderEnum._(r'meta');
  static const nextsms = AdminCreateProviderRateRequestProviderEnum._(r'nextsms');

  /// List of all possible values in this [enum][AdminCreateProviderRateRequestProviderEnum].
  static const values = <AdminCreateProviderRateRequestProviderEnum>[
    meta,
    nextsms,
  ];

  static AdminCreateProviderRateRequestProviderEnum? fromJson(dynamic value) => AdminCreateProviderRateRequestProviderEnumTypeTransformer().decode(value);

  static List<AdminCreateProviderRateRequestProviderEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminCreateProviderRateRequestProviderEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminCreateProviderRateRequestProviderEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminCreateProviderRateRequestProviderEnum] to String,
/// and [decode] dynamic data back to [AdminCreateProviderRateRequestProviderEnum].
class AdminCreateProviderRateRequestProviderEnumTypeTransformer {
  factory AdminCreateProviderRateRequestProviderEnumTypeTransformer() => _instance ??= const AdminCreateProviderRateRequestProviderEnumTypeTransformer._();

  const AdminCreateProviderRateRequestProviderEnumTypeTransformer._();

  String encode(AdminCreateProviderRateRequestProviderEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminCreateProviderRateRequestProviderEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminCreateProviderRateRequestProviderEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'meta': return AdminCreateProviderRateRequestProviderEnum.meta;
        case r'nextsms': return AdminCreateProviderRateRequestProviderEnum.nextsms;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminCreateProviderRateRequestProviderEnumTypeTransformer] instance.
  static AdminCreateProviderRateRequestProviderEnumTypeTransformer? _instance;
}



class AdminCreateProviderRateRequestChannelEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminCreateProviderRateRequestChannelEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const whatsapp = AdminCreateProviderRateRequestChannelEnum._(r'whatsapp');
  static const sms = AdminCreateProviderRateRequestChannelEnum._(r'sms');

  /// List of all possible values in this [enum][AdminCreateProviderRateRequestChannelEnum].
  static const values = <AdminCreateProviderRateRequestChannelEnum>[
    whatsapp,
    sms,
  ];

  static AdminCreateProviderRateRequestChannelEnum? fromJson(dynamic value) => AdminCreateProviderRateRequestChannelEnumTypeTransformer().decode(value);

  static List<AdminCreateProviderRateRequestChannelEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminCreateProviderRateRequestChannelEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminCreateProviderRateRequestChannelEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminCreateProviderRateRequestChannelEnum] to String,
/// and [decode] dynamic data back to [AdminCreateProviderRateRequestChannelEnum].
class AdminCreateProviderRateRequestChannelEnumTypeTransformer {
  factory AdminCreateProviderRateRequestChannelEnumTypeTransformer() => _instance ??= const AdminCreateProviderRateRequestChannelEnumTypeTransformer._();

  const AdminCreateProviderRateRequestChannelEnumTypeTransformer._();

  String encode(AdminCreateProviderRateRequestChannelEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminCreateProviderRateRequestChannelEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminCreateProviderRateRequestChannelEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'whatsapp': return AdminCreateProviderRateRequestChannelEnum.whatsapp;
        case r'sms': return AdminCreateProviderRateRequestChannelEnum.sms;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminCreateProviderRateRequestChannelEnumTypeTransformer] instance.
  static AdminCreateProviderRateRequestChannelEnumTypeTransformer? _instance;
}



//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class AdminListProviderRates200ResponseRatesInner {
  /// Returns a new [AdminListProviderRates200ResponseRatesInner] instance.
  AdminListProviderRates200ResponseRatesInner({
    required this.provider,
    required this.channel,
    required this.category,
    required this.market,
    required this.priceTzs,
    required this.effectiveFrom,
    required this.id,
    required this.createdAt,
  });

  AdminListProviderRates200ResponseRatesInnerProviderEnum provider;

  AdminListProviderRates200ResponseRatesInnerChannelEnum channel;

  String category;

  String market;

  String priceTzs;

  DateTime effectiveFrom;

  String id;

  DateTime createdAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminListProviderRates200ResponseRatesInner &&
    other.provider == provider &&
    other.channel == channel &&
    other.category == category &&
    other.market == market &&
    other.priceTzs == priceTzs &&
    other.effectiveFrom == effectiveFrom &&
    other.id == id &&
    other.createdAt == createdAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (provider.hashCode) +
    (channel.hashCode) +
    (category.hashCode) +
    (market.hashCode) +
    (priceTzs.hashCode) +
    (effectiveFrom.hashCode) +
    (id.hashCode) +
    (createdAt.hashCode);

  @override
  String toString() => 'AdminListProviderRates200ResponseRatesInner[provider=$provider, channel=$channel, category=$category, market=$market, priceTzs=$priceTzs, effectiveFrom=$effectiveFrom, id=$id, createdAt=$createdAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'provider'] = this.provider;
      json[r'channel'] = this.channel;
      json[r'category'] = this.category;
      json[r'market'] = this.market;
      json[r'priceTzs'] = this.priceTzs;
      json[r'effectiveFrom'] = this.effectiveFrom.toUtc().toIso8601String();
      json[r'id'] = this.id;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [AdminListProviderRates200ResponseRatesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminListProviderRates200ResponseRatesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AdminListProviderRates200ResponseRatesInner[$key]" is missing from JSON.');
        });
        return true;
      }());

      return AdminListProviderRates200ResponseRatesInner(
        provider: AdminListProviderRates200ResponseRatesInnerProviderEnum.fromJson(json[r'provider'])!,
        channel: AdminListProviderRates200ResponseRatesInnerChannelEnum.fromJson(json[r'channel'])!,
        category: mapValueOfType<String>(json, r'category')!,
        market: mapValueOfType<String>(json, r'market')!,
        priceTzs: mapValueOfType<String>(json, r'priceTzs')!,
        effectiveFrom: mapDateTime(json, r'effectiveFrom', r'')!,
        id: mapValueOfType<String>(json, r'id')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
      );
    }
    return null;
  }

  static List<AdminListProviderRates200ResponseRatesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminListProviderRates200ResponseRatesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminListProviderRates200ResponseRatesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminListProviderRates200ResponseRatesInner> mapFromJson(dynamic json) {
    final map = <String, AdminListProviderRates200ResponseRatesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminListProviderRates200ResponseRatesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminListProviderRates200ResponseRatesInner-objects as value to a dart map
  static Map<String, List<AdminListProviderRates200ResponseRatesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminListProviderRates200ResponseRatesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminListProviderRates200ResponseRatesInner.listFromJson(entry.value, growable: growable,);
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
    'id',
    'createdAt',
  };
}


class AdminListProviderRates200ResponseRatesInnerProviderEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminListProviderRates200ResponseRatesInnerProviderEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const meta = AdminListProviderRates200ResponseRatesInnerProviderEnum._(r'meta');
  static const nextsms = AdminListProviderRates200ResponseRatesInnerProviderEnum._(r'nextsms');

  /// List of all possible values in this [enum][AdminListProviderRates200ResponseRatesInnerProviderEnum].
  static const values = <AdminListProviderRates200ResponseRatesInnerProviderEnum>[
    meta,
    nextsms,
  ];

  static AdminListProviderRates200ResponseRatesInnerProviderEnum? fromJson(dynamic value) => AdminListProviderRates200ResponseRatesInnerProviderEnumTypeTransformer().decode(value);

  static List<AdminListProviderRates200ResponseRatesInnerProviderEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminListProviderRates200ResponseRatesInnerProviderEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminListProviderRates200ResponseRatesInnerProviderEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminListProviderRates200ResponseRatesInnerProviderEnum] to String,
/// and [decode] dynamic data back to [AdminListProviderRates200ResponseRatesInnerProviderEnum].
class AdminListProviderRates200ResponseRatesInnerProviderEnumTypeTransformer {
  factory AdminListProviderRates200ResponseRatesInnerProviderEnumTypeTransformer() => _instance ??= const AdminListProviderRates200ResponseRatesInnerProviderEnumTypeTransformer._();

  const AdminListProviderRates200ResponseRatesInnerProviderEnumTypeTransformer._();

  String encode(AdminListProviderRates200ResponseRatesInnerProviderEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminListProviderRates200ResponseRatesInnerProviderEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminListProviderRates200ResponseRatesInnerProviderEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'meta': return AdminListProviderRates200ResponseRatesInnerProviderEnum.meta;
        case r'nextsms': return AdminListProviderRates200ResponseRatesInnerProviderEnum.nextsms;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminListProviderRates200ResponseRatesInnerProviderEnumTypeTransformer] instance.
  static AdminListProviderRates200ResponseRatesInnerProviderEnumTypeTransformer? _instance;
}



class AdminListProviderRates200ResponseRatesInnerChannelEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminListProviderRates200ResponseRatesInnerChannelEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const whatsapp = AdminListProviderRates200ResponseRatesInnerChannelEnum._(r'whatsapp');
  static const sms = AdminListProviderRates200ResponseRatesInnerChannelEnum._(r'sms');

  /// List of all possible values in this [enum][AdminListProviderRates200ResponseRatesInnerChannelEnum].
  static const values = <AdminListProviderRates200ResponseRatesInnerChannelEnum>[
    whatsapp,
    sms,
  ];

  static AdminListProviderRates200ResponseRatesInnerChannelEnum? fromJson(dynamic value) => AdminListProviderRates200ResponseRatesInnerChannelEnumTypeTransformer().decode(value);

  static List<AdminListProviderRates200ResponseRatesInnerChannelEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminListProviderRates200ResponseRatesInnerChannelEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminListProviderRates200ResponseRatesInnerChannelEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminListProviderRates200ResponseRatesInnerChannelEnum] to String,
/// and [decode] dynamic data back to [AdminListProviderRates200ResponseRatesInnerChannelEnum].
class AdminListProviderRates200ResponseRatesInnerChannelEnumTypeTransformer {
  factory AdminListProviderRates200ResponseRatesInnerChannelEnumTypeTransformer() => _instance ??= const AdminListProviderRates200ResponseRatesInnerChannelEnumTypeTransformer._();

  const AdminListProviderRates200ResponseRatesInnerChannelEnumTypeTransformer._();

  String encode(AdminListProviderRates200ResponseRatesInnerChannelEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminListProviderRates200ResponseRatesInnerChannelEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminListProviderRates200ResponseRatesInnerChannelEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'whatsapp': return AdminListProviderRates200ResponseRatesInnerChannelEnum.whatsapp;
        case r'sms': return AdminListProviderRates200ResponseRatesInnerChannelEnum.sms;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminListProviderRates200ResponseRatesInnerChannelEnumTypeTransformer] instance.
  static AdminListProviderRates200ResponseRatesInnerChannelEnumTypeTransformer? _instance;
}



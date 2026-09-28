//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class ListConfirmations200ResponseGuestsInner {
  /// Returns a new [ListConfirmations200ResponseGuestsInner] instance.
  ListConfirmations200ResponseGuestsInner({
    required this.id,
    required this.name,
    required this.phone,
    required this.partnerName,
    required this.cardType,
    required this.totalEntries,
    required this.confirmationStatus,
    required this.confirmationAt,
    required this.confirmationSource,
  });

  String id;

  String name;

  String phone;

  String? partnerName;

  ListConfirmations200ResponseGuestsInnerCardTypeEnum cardType;

  int totalEntries;

  ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum confirmationStatus;

  DateTime? confirmationAt;

  String? confirmationSource;

  @override
  bool operator ==(Object other) => identical(this, other) || other is ListConfirmations200ResponseGuestsInner &&
    other.id == id &&
    other.name == name &&
    other.phone == phone &&
    other.partnerName == partnerName &&
    other.cardType == cardType &&
    other.totalEntries == totalEntries &&
    other.confirmationStatus == confirmationStatus &&
    other.confirmationAt == confirmationAt &&
    other.confirmationSource == confirmationSource;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (id.hashCode) +
    (name.hashCode) +
    (phone.hashCode) +
    (partnerName == null ? 0 : partnerName!.hashCode) +
    (cardType.hashCode) +
    (totalEntries.hashCode) +
    (confirmationStatus.hashCode) +
    (confirmationAt == null ? 0 : confirmationAt!.hashCode) +
    (confirmationSource == null ? 0 : confirmationSource!.hashCode);

  @override
  String toString() => 'ListConfirmations200ResponseGuestsInner[id=$id, name=$name, phone=$phone, partnerName=$partnerName, cardType=$cardType, totalEntries=$totalEntries, confirmationStatus=$confirmationStatus, confirmationAt=$confirmationAt, confirmationSource=$confirmationSource]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'id'] = this.id;
      json[r'name'] = this.name;
      json[r'phone'] = this.phone;
    if (this.partnerName != null) {
      json[r'partnerName'] = this.partnerName;
    } else {
      json[r'partnerName'] = null;
    }
      json[r'cardType'] = this.cardType;
      json[r'totalEntries'] = this.totalEntries;
      json[r'confirmationStatus'] = this.confirmationStatus;
    if (this.confirmationAt != null) {
      json[r'confirmationAt'] = this.confirmationAt!.toUtc().toIso8601String();
    } else {
      json[r'confirmationAt'] = null;
    }
    if (this.confirmationSource != null) {
      json[r'confirmationSource'] = this.confirmationSource;
    } else {
      json[r'confirmationSource'] = null;
    }
    return json;
  }

  /// Returns a new [ListConfirmations200ResponseGuestsInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static ListConfirmations200ResponseGuestsInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "ListConfirmations200ResponseGuestsInner[$key]" is missing from JSON.');
        });
        return true;
      }());

      return ListConfirmations200ResponseGuestsInner(
        id: mapValueOfType<String>(json, r'id')!,
        name: mapValueOfType<String>(json, r'name')!,
        phone: mapValueOfType<String>(json, r'phone')!,
        partnerName: mapValueOfType<String>(json, r'partnerName'),
        cardType: ListConfirmations200ResponseGuestsInnerCardTypeEnum.fromJson(json[r'cardType'])!,
        totalEntries: mapValueOfType<int>(json, r'totalEntries')!,
        confirmationStatus: ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum.fromJson(json[r'confirmationStatus'])!,
        confirmationAt: mapDateTime(json, r'confirmationAt', r''),
        confirmationSource: mapValueOfType<String>(json, r'confirmationSource'),
      );
    }
    return null;
  }

  static List<ListConfirmations200ResponseGuestsInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ListConfirmations200ResponseGuestsInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ListConfirmations200ResponseGuestsInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, ListConfirmations200ResponseGuestsInner> mapFromJson(dynamic json) {
    final map = <String, ListConfirmations200ResponseGuestsInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = ListConfirmations200ResponseGuestsInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of ListConfirmations200ResponseGuestsInner-objects as value to a dart map
  static Map<String, List<ListConfirmations200ResponseGuestsInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<ListConfirmations200ResponseGuestsInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = ListConfirmations200ResponseGuestsInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'id',
    'name',
    'phone',
    'partnerName',
    'cardType',
    'totalEntries',
    'confirmationStatus',
    'confirmationAt',
    'confirmationSource',
  };
}


class ListConfirmations200ResponseGuestsInnerCardTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const ListConfirmations200ResponseGuestsInnerCardTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const single = ListConfirmations200ResponseGuestsInnerCardTypeEnum._(r'single');
  static const double_ = ListConfirmations200ResponseGuestsInnerCardTypeEnum._(r'double');

  /// List of all possible values in this [enum][ListConfirmations200ResponseGuestsInnerCardTypeEnum].
  static const values = <ListConfirmations200ResponseGuestsInnerCardTypeEnum>[
    single,
    double_,
  ];

  static ListConfirmations200ResponseGuestsInnerCardTypeEnum? fromJson(dynamic value) => ListConfirmations200ResponseGuestsInnerCardTypeEnumTypeTransformer().decode(value);

  static List<ListConfirmations200ResponseGuestsInnerCardTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ListConfirmations200ResponseGuestsInnerCardTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ListConfirmations200ResponseGuestsInnerCardTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ListConfirmations200ResponseGuestsInnerCardTypeEnum] to String,
/// and [decode] dynamic data back to [ListConfirmations200ResponseGuestsInnerCardTypeEnum].
class ListConfirmations200ResponseGuestsInnerCardTypeEnumTypeTransformer {
  factory ListConfirmations200ResponseGuestsInnerCardTypeEnumTypeTransformer() => _instance ??= const ListConfirmations200ResponseGuestsInnerCardTypeEnumTypeTransformer._();

  const ListConfirmations200ResponseGuestsInnerCardTypeEnumTypeTransformer._();

  String encode(ListConfirmations200ResponseGuestsInnerCardTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ListConfirmations200ResponseGuestsInnerCardTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ListConfirmations200ResponseGuestsInnerCardTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'single': return ListConfirmations200ResponseGuestsInnerCardTypeEnum.single;
        case r'double': return ListConfirmations200ResponseGuestsInnerCardTypeEnum.double_;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ListConfirmations200ResponseGuestsInnerCardTypeEnumTypeTransformer] instance.
  static ListConfirmations200ResponseGuestsInnerCardTypeEnumTypeTransformer? _instance;
}



class ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const none = ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum._(r'none');
  static const yes = ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum._(r'yes');
  static const no = ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum._(r'no');

  /// List of all possible values in this [enum][ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum].
  static const values = <ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum>[
    none,
    yes,
    no,
  ];

  static ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum? fromJson(dynamic value) => ListConfirmations200ResponseGuestsInnerConfirmationStatusEnumTypeTransformer().decode(value);

  static List<ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum] to String,
/// and [decode] dynamic data back to [ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum].
class ListConfirmations200ResponseGuestsInnerConfirmationStatusEnumTypeTransformer {
  factory ListConfirmations200ResponseGuestsInnerConfirmationStatusEnumTypeTransformer() => _instance ??= const ListConfirmations200ResponseGuestsInnerConfirmationStatusEnumTypeTransformer._();

  const ListConfirmations200ResponseGuestsInnerConfirmationStatusEnumTypeTransformer._();

  String encode(ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'none': return ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum.none;
        case r'yes': return ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum.yes;
        case r'no': return ListConfirmations200ResponseGuestsInnerConfirmationStatusEnum.no;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [ListConfirmations200ResponseGuestsInnerConfirmationStatusEnumTypeTransformer] instance.
  static ListConfirmations200ResponseGuestsInnerConfirmationStatusEnumTypeTransformer? _instance;
}



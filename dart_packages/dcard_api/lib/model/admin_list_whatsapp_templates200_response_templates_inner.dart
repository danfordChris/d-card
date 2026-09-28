//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class AdminListWhatsappTemplates200ResponseTemplatesInner {
  /// Returns a new [AdminListWhatsappTemplates200ResponseTemplatesInner] instance.
  AdminListWhatsappTemplates200ResponseTemplatesInner({
    required this.messageType,
    required this.variantName,
    required this.language,
    required this.metaTemplateName,
    required this.category,
    this.bodyParams = const [],
    this.editableParams = const [],
    required this.headerImage,
    required this.confirmButtons,
    required this.status,
    required this.active,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum messageType;

  String variantName;

  AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum language;

  String metaTemplateName;

  AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum category;

  List<String> bodyParams;

  List<String> editableParams;

  bool headerImage;

  bool confirmButtons;

  AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum status;

  bool active;

  String id;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminListWhatsappTemplates200ResponseTemplatesInner &&
    other.messageType == messageType &&
    other.variantName == variantName &&
    other.language == language &&
    other.metaTemplateName == metaTemplateName &&
    other.category == category &&
    _deepEquality.equals(other.bodyParams, bodyParams) &&
    _deepEquality.equals(other.editableParams, editableParams) &&
    other.headerImage == headerImage &&
    other.confirmButtons == confirmButtons &&
    other.status == status &&
    other.active == active &&
    other.id == id &&
    other.createdAt == createdAt &&
    other.updatedAt == updatedAt;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (messageType.hashCode) +
    (variantName.hashCode) +
    (language.hashCode) +
    (metaTemplateName.hashCode) +
    (category.hashCode) +
    (bodyParams.hashCode) +
    (editableParams.hashCode) +
    (headerImage.hashCode) +
    (confirmButtons.hashCode) +
    (status.hashCode) +
    (active.hashCode) +
    (id.hashCode) +
    (createdAt.hashCode) +
    (updatedAt.hashCode);

  @override
  String toString() => 'AdminListWhatsappTemplates200ResponseTemplatesInner[messageType=$messageType, variantName=$variantName, language=$language, metaTemplateName=$metaTemplateName, category=$category, bodyParams=$bodyParams, editableParams=$editableParams, headerImage=$headerImage, confirmButtons=$confirmButtons, status=$status, active=$active, id=$id, createdAt=$createdAt, updatedAt=$updatedAt]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'messageType'] = this.messageType;
      json[r'variantName'] = this.variantName;
      json[r'language'] = this.language;
      json[r'metaTemplateName'] = this.metaTemplateName;
      json[r'category'] = this.category;
      json[r'bodyParams'] = this.bodyParams;
      json[r'editableParams'] = this.editableParams;
      json[r'headerImage'] = this.headerImage;
      json[r'confirmButtons'] = this.confirmButtons;
      json[r'status'] = this.status;
      json[r'active'] = this.active;
      json[r'id'] = this.id;
      json[r'createdAt'] = this.createdAt.toUtc().toIso8601String();
      json[r'updatedAt'] = this.updatedAt.toUtc().toIso8601String();
    return json;
  }

  /// Returns a new [AdminListWhatsappTemplates200ResponseTemplatesInner] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminListWhatsappTemplates200ResponseTemplatesInner? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AdminListWhatsappTemplates200ResponseTemplatesInner[$key]" is missing from JSON.');
        });
        return true;
      }());

      return AdminListWhatsappTemplates200ResponseTemplatesInner(
        messageType: AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum.fromJson(json[r'messageType'])!,
        variantName: mapValueOfType<String>(json, r'variantName')!,
        language: AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum.fromJson(json[r'language'])!,
        metaTemplateName: mapValueOfType<String>(json, r'metaTemplateName')!,
        category: AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum.fromJson(json[r'category'])!,
        bodyParams: json[r'bodyParams'] is Iterable
            ? (json[r'bodyParams'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        editableParams: json[r'editableParams'] is Iterable
            ? (json[r'editableParams'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        headerImage: mapValueOfType<bool>(json, r'headerImage')!,
        confirmButtons: mapValueOfType<bool>(json, r'confirmButtons')!,
        status: AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum.fromJson(json[r'status'])!,
        active: mapValueOfType<bool>(json, r'active')!,
        id: mapValueOfType<String>(json, r'id')!,
        createdAt: mapDateTime(json, r'createdAt', r'')!,
        updatedAt: mapDateTime(json, r'updatedAt', r'')!,
      );
    }
    return null;
  }

  static List<AdminListWhatsappTemplates200ResponseTemplatesInner> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminListWhatsappTemplates200ResponseTemplatesInner>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminListWhatsappTemplates200ResponseTemplatesInner.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminListWhatsappTemplates200ResponseTemplatesInner> mapFromJson(dynamic json) {
    final map = <String, AdminListWhatsappTemplates200ResponseTemplatesInner>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminListWhatsappTemplates200ResponseTemplatesInner.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminListWhatsappTemplates200ResponseTemplatesInner-objects as value to a dart map
  static Map<String, List<AdminListWhatsappTemplates200ResponseTemplatesInner>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminListWhatsappTemplates200ResponseTemplatesInner>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminListWhatsappTemplates200ResponseTemplatesInner.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'messageType',
    'variantName',
    'language',
    'metaTemplateName',
    'category',
    'bodyParams',
    'editableParams',
    'headerImage',
    'confirmButtons',
    'status',
    'active',
    'id',
    'createdAt',
    'updatedAt',
  };
}


class AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const contributionRequest = AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum._(r'contribution_request');
  static const thankYou = AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum._(r'thank_you');
  static const contributionReminder = AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum._(r'contribution_reminder');
  static const invitationCard = AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum._(r'invitation_card');
  static const cardUpgraded = AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum._(r'card_upgraded');
  static const attendanceConfirmation = AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum._(r'attendance_confirmation');
  static const eventReminder = AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum._(r'event_reminder');
  static const postEventThanks = AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum._(r'post_event_thanks');

  /// List of all possible values in this [enum][AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum].
  static const values = <AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum>[
    contributionRequest,
    thankYou,
    contributionReminder,
    invitationCard,
    cardUpgraded,
    attendanceConfirmation,
    eventReminder,
    postEventThanks,
  ];

  static AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum? fromJson(dynamic value) => AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnumTypeTransformer().decode(value);

  static List<AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum] to String,
/// and [decode] dynamic data back to [AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum].
class AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnumTypeTransformer {
  factory AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnumTypeTransformer() => _instance ??= const AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnumTypeTransformer._();

  const AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnumTypeTransformer._();

  String encode(AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'contribution_request': return AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum.contributionRequest;
        case r'thank_you': return AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum.thankYou;
        case r'contribution_reminder': return AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum.contributionReminder;
        case r'invitation_card': return AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum.invitationCard;
        case r'card_upgraded': return AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum.cardUpgraded;
        case r'attendance_confirmation': return AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum.attendanceConfirmation;
        case r'event_reminder': return AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum.eventReminder;
        case r'post_event_thanks': return AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnum.postEventThanks;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnumTypeTransformer] instance.
  static AdminListWhatsappTemplates200ResponseTemplatesInnerMessageTypeEnumTypeTransformer? _instance;
}



class AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const sw = AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum._(r'sw');
  static const en = AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum._(r'en');

  /// List of all possible values in this [enum][AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum].
  static const values = <AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum>[
    sw,
    en,
  ];

  static AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum? fromJson(dynamic value) => AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnumTypeTransformer().decode(value);

  static List<AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum] to String,
/// and [decode] dynamic data back to [AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum].
class AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnumTypeTransformer {
  factory AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnumTypeTransformer() => _instance ??= const AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnumTypeTransformer._();

  const AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnumTypeTransformer._();

  String encode(AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'sw': return AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum.sw;
        case r'en': return AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnum.en;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnumTypeTransformer] instance.
  static AdminListWhatsappTemplates200ResponseTemplatesInnerLanguageEnumTypeTransformer? _instance;
}



class AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const utility = AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum._(r'utility');
  static const marketing = AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum._(r'marketing');
  static const authentication = AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum._(r'authentication');

  /// List of all possible values in this [enum][AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum].
  static const values = <AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum>[
    utility,
    marketing,
    authentication,
  ];

  static AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum? fromJson(dynamic value) => AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnumTypeTransformer().decode(value);

  static List<AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum] to String,
/// and [decode] dynamic data back to [AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum].
class AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnumTypeTransformer {
  factory AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnumTypeTransformer() => _instance ??= const AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnumTypeTransformer._();

  const AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnumTypeTransformer._();

  String encode(AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'utility': return AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum.utility;
        case r'marketing': return AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum.marketing;
        case r'authentication': return AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnum.authentication;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnumTypeTransformer] instance.
  static AdminListWhatsappTemplates200ResponseTemplatesInnerCategoryEnumTypeTransformer? _instance;
}



class AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const pending = AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum._(r'pending');
  static const approved = AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum._(r'approved');
  static const rejected = AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum._(r'rejected');
  static const paused = AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum._(r'paused');

  /// List of all possible values in this [enum][AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum].
  static const values = <AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum>[
    pending,
    approved,
    rejected,
    paused,
  ];

  static AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum? fromJson(dynamic value) => AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnumTypeTransformer().decode(value);

  static List<AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum] to String,
/// and [decode] dynamic data back to [AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum].
class AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnumTypeTransformer {
  factory AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnumTypeTransformer() => _instance ??= const AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnumTypeTransformer._();

  const AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnumTypeTransformer._();

  String encode(AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'pending': return AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum.pending;
        case r'approved': return AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum.approved;
        case r'rejected': return AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum.rejected;
        case r'paused': return AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnum.paused;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnumTypeTransformer] instance.
  static AdminListWhatsappTemplates200ResponseTemplatesInnerStatusEnumTypeTransformer? _instance;
}



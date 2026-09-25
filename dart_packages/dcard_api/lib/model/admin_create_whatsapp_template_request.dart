//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class AdminCreateWhatsappTemplateRequest {
  /// Returns a new [AdminCreateWhatsappTemplateRequest] instance.
  AdminCreateWhatsappTemplateRequest({
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
  });

  AdminCreateWhatsappTemplateRequestMessageTypeEnum messageType;

  String variantName;

  AdminCreateWhatsappTemplateRequestLanguageEnum language;

  String metaTemplateName;

  AdminCreateWhatsappTemplateRequestCategoryEnum category;

  List<String> bodyParams;

  List<String> editableParams;

  bool headerImage;

  bool confirmButtons;

  AdminCreateWhatsappTemplateRequestStatusEnum status;

  bool active;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminCreateWhatsappTemplateRequest &&
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
    other.active == active;

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
    (active.hashCode);

  @override
  String toString() => 'AdminCreateWhatsappTemplateRequest[messageType=$messageType, variantName=$variantName, language=$language, metaTemplateName=$metaTemplateName, category=$category, bodyParams=$bodyParams, editableParams=$editableParams, headerImage=$headerImage, confirmButtons=$confirmButtons, status=$status, active=$active]';

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
    return json;
  }

  /// Returns a new [AdminCreateWhatsappTemplateRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminCreateWhatsappTemplateRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AdminCreateWhatsappTemplateRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AdminCreateWhatsappTemplateRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AdminCreateWhatsappTemplateRequest(
        messageType: AdminCreateWhatsappTemplateRequestMessageTypeEnum.fromJson(json[r'messageType'])!,
        variantName: mapValueOfType<String>(json, r'variantName')!,
        language: AdminCreateWhatsappTemplateRequestLanguageEnum.fromJson(json[r'language'])!,
        metaTemplateName: mapValueOfType<String>(json, r'metaTemplateName')!,
        category: AdminCreateWhatsappTemplateRequestCategoryEnum.fromJson(json[r'category'])!,
        bodyParams: json[r'bodyParams'] is Iterable
            ? (json[r'bodyParams'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        editableParams: json[r'editableParams'] is Iterable
            ? (json[r'editableParams'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        headerImage: mapValueOfType<bool>(json, r'headerImage')!,
        confirmButtons: mapValueOfType<bool>(json, r'confirmButtons')!,
        status: AdminCreateWhatsappTemplateRequestStatusEnum.fromJson(json[r'status'])!,
        active: mapValueOfType<bool>(json, r'active')!,
      );
    }
    return null;
  }

  static List<AdminCreateWhatsappTemplateRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminCreateWhatsappTemplateRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminCreateWhatsappTemplateRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminCreateWhatsappTemplateRequest> mapFromJson(dynamic json) {
    final map = <String, AdminCreateWhatsappTemplateRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminCreateWhatsappTemplateRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminCreateWhatsappTemplateRequest-objects as value to a dart map
  static Map<String, List<AdminCreateWhatsappTemplateRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminCreateWhatsappTemplateRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminCreateWhatsappTemplateRequest.listFromJson(entry.value, growable: growable,);
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
  };
}


class AdminCreateWhatsappTemplateRequestMessageTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminCreateWhatsappTemplateRequestMessageTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const contributionRequest = AdminCreateWhatsappTemplateRequestMessageTypeEnum._(r'contribution_request');
  static const thankYou = AdminCreateWhatsappTemplateRequestMessageTypeEnum._(r'thank_you');
  static const contributionReminder = AdminCreateWhatsappTemplateRequestMessageTypeEnum._(r'contribution_reminder');
  static const invitationCard = AdminCreateWhatsappTemplateRequestMessageTypeEnum._(r'invitation_card');
  static const cardUpgraded = AdminCreateWhatsappTemplateRequestMessageTypeEnum._(r'card_upgraded');
  static const attendanceConfirmation = AdminCreateWhatsappTemplateRequestMessageTypeEnum._(r'attendance_confirmation');
  static const eventReminder = AdminCreateWhatsappTemplateRequestMessageTypeEnum._(r'event_reminder');
  static const postEventThanks = AdminCreateWhatsappTemplateRequestMessageTypeEnum._(r'post_event_thanks');

  /// List of all possible values in this [enum][AdminCreateWhatsappTemplateRequestMessageTypeEnum].
  static const values = <AdminCreateWhatsappTemplateRequestMessageTypeEnum>[
    contributionRequest,
    thankYou,
    contributionReminder,
    invitationCard,
    cardUpgraded,
    attendanceConfirmation,
    eventReminder,
    postEventThanks,
  ];

  static AdminCreateWhatsappTemplateRequestMessageTypeEnum? fromJson(dynamic value) => AdminCreateWhatsappTemplateRequestMessageTypeEnumTypeTransformer().decode(value);

  static List<AdminCreateWhatsappTemplateRequestMessageTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminCreateWhatsappTemplateRequestMessageTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminCreateWhatsappTemplateRequestMessageTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminCreateWhatsappTemplateRequestMessageTypeEnum] to String,
/// and [decode] dynamic data back to [AdminCreateWhatsappTemplateRequestMessageTypeEnum].
class AdminCreateWhatsappTemplateRequestMessageTypeEnumTypeTransformer {
  factory AdminCreateWhatsappTemplateRequestMessageTypeEnumTypeTransformer() => _instance ??= const AdminCreateWhatsappTemplateRequestMessageTypeEnumTypeTransformer._();

  const AdminCreateWhatsappTemplateRequestMessageTypeEnumTypeTransformer._();

  String encode(AdminCreateWhatsappTemplateRequestMessageTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminCreateWhatsappTemplateRequestMessageTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminCreateWhatsappTemplateRequestMessageTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'contribution_request': return AdminCreateWhatsappTemplateRequestMessageTypeEnum.contributionRequest;
        case r'thank_you': return AdminCreateWhatsappTemplateRequestMessageTypeEnum.thankYou;
        case r'contribution_reminder': return AdminCreateWhatsappTemplateRequestMessageTypeEnum.contributionReminder;
        case r'invitation_card': return AdminCreateWhatsappTemplateRequestMessageTypeEnum.invitationCard;
        case r'card_upgraded': return AdminCreateWhatsappTemplateRequestMessageTypeEnum.cardUpgraded;
        case r'attendance_confirmation': return AdminCreateWhatsappTemplateRequestMessageTypeEnum.attendanceConfirmation;
        case r'event_reminder': return AdminCreateWhatsappTemplateRequestMessageTypeEnum.eventReminder;
        case r'post_event_thanks': return AdminCreateWhatsappTemplateRequestMessageTypeEnum.postEventThanks;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminCreateWhatsappTemplateRequestMessageTypeEnumTypeTransformer] instance.
  static AdminCreateWhatsappTemplateRequestMessageTypeEnumTypeTransformer? _instance;
}



class AdminCreateWhatsappTemplateRequestLanguageEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminCreateWhatsappTemplateRequestLanguageEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const sw = AdminCreateWhatsappTemplateRequestLanguageEnum._(r'sw');
  static const en = AdminCreateWhatsappTemplateRequestLanguageEnum._(r'en');

  /// List of all possible values in this [enum][AdminCreateWhatsappTemplateRequestLanguageEnum].
  static const values = <AdminCreateWhatsappTemplateRequestLanguageEnum>[
    sw,
    en,
  ];

  static AdminCreateWhatsappTemplateRequestLanguageEnum? fromJson(dynamic value) => AdminCreateWhatsappTemplateRequestLanguageEnumTypeTransformer().decode(value);

  static List<AdminCreateWhatsappTemplateRequestLanguageEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminCreateWhatsappTemplateRequestLanguageEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminCreateWhatsappTemplateRequestLanguageEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminCreateWhatsappTemplateRequestLanguageEnum] to String,
/// and [decode] dynamic data back to [AdminCreateWhatsappTemplateRequestLanguageEnum].
class AdminCreateWhatsappTemplateRequestLanguageEnumTypeTransformer {
  factory AdminCreateWhatsappTemplateRequestLanguageEnumTypeTransformer() => _instance ??= const AdminCreateWhatsappTemplateRequestLanguageEnumTypeTransformer._();

  const AdminCreateWhatsappTemplateRequestLanguageEnumTypeTransformer._();

  String encode(AdminCreateWhatsappTemplateRequestLanguageEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminCreateWhatsappTemplateRequestLanguageEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminCreateWhatsappTemplateRequestLanguageEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'sw': return AdminCreateWhatsappTemplateRequestLanguageEnum.sw;
        case r'en': return AdminCreateWhatsappTemplateRequestLanguageEnum.en;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminCreateWhatsappTemplateRequestLanguageEnumTypeTransformer] instance.
  static AdminCreateWhatsappTemplateRequestLanguageEnumTypeTransformer? _instance;
}



class AdminCreateWhatsappTemplateRequestCategoryEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminCreateWhatsappTemplateRequestCategoryEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const utility = AdminCreateWhatsappTemplateRequestCategoryEnum._(r'utility');
  static const marketing = AdminCreateWhatsappTemplateRequestCategoryEnum._(r'marketing');
  static const authentication = AdminCreateWhatsappTemplateRequestCategoryEnum._(r'authentication');

  /// List of all possible values in this [enum][AdminCreateWhatsappTemplateRequestCategoryEnum].
  static const values = <AdminCreateWhatsappTemplateRequestCategoryEnum>[
    utility,
    marketing,
    authentication,
  ];

  static AdminCreateWhatsappTemplateRequestCategoryEnum? fromJson(dynamic value) => AdminCreateWhatsappTemplateRequestCategoryEnumTypeTransformer().decode(value);

  static List<AdminCreateWhatsappTemplateRequestCategoryEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminCreateWhatsappTemplateRequestCategoryEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminCreateWhatsappTemplateRequestCategoryEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminCreateWhatsappTemplateRequestCategoryEnum] to String,
/// and [decode] dynamic data back to [AdminCreateWhatsappTemplateRequestCategoryEnum].
class AdminCreateWhatsappTemplateRequestCategoryEnumTypeTransformer {
  factory AdminCreateWhatsappTemplateRequestCategoryEnumTypeTransformer() => _instance ??= const AdminCreateWhatsappTemplateRequestCategoryEnumTypeTransformer._();

  const AdminCreateWhatsappTemplateRequestCategoryEnumTypeTransformer._();

  String encode(AdminCreateWhatsappTemplateRequestCategoryEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminCreateWhatsappTemplateRequestCategoryEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminCreateWhatsappTemplateRequestCategoryEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'utility': return AdminCreateWhatsappTemplateRequestCategoryEnum.utility;
        case r'marketing': return AdminCreateWhatsappTemplateRequestCategoryEnum.marketing;
        case r'authentication': return AdminCreateWhatsappTemplateRequestCategoryEnum.authentication;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminCreateWhatsappTemplateRequestCategoryEnumTypeTransformer] instance.
  static AdminCreateWhatsappTemplateRequestCategoryEnumTypeTransformer? _instance;
}



class AdminCreateWhatsappTemplateRequestStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminCreateWhatsappTemplateRequestStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const pending = AdminCreateWhatsappTemplateRequestStatusEnum._(r'pending');
  static const approved = AdminCreateWhatsappTemplateRequestStatusEnum._(r'approved');
  static const rejected = AdminCreateWhatsappTemplateRequestStatusEnum._(r'rejected');
  static const paused = AdminCreateWhatsappTemplateRequestStatusEnum._(r'paused');

  /// List of all possible values in this [enum][AdminCreateWhatsappTemplateRequestStatusEnum].
  static const values = <AdminCreateWhatsappTemplateRequestStatusEnum>[
    pending,
    approved,
    rejected,
    paused,
  ];

  static AdminCreateWhatsappTemplateRequestStatusEnum? fromJson(dynamic value) => AdminCreateWhatsappTemplateRequestStatusEnumTypeTransformer().decode(value);

  static List<AdminCreateWhatsappTemplateRequestStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminCreateWhatsappTemplateRequestStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminCreateWhatsappTemplateRequestStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminCreateWhatsappTemplateRequestStatusEnum] to String,
/// and [decode] dynamic data back to [AdminCreateWhatsappTemplateRequestStatusEnum].
class AdminCreateWhatsappTemplateRequestStatusEnumTypeTransformer {
  factory AdminCreateWhatsappTemplateRequestStatusEnumTypeTransformer() => _instance ??= const AdminCreateWhatsappTemplateRequestStatusEnumTypeTransformer._();

  const AdminCreateWhatsappTemplateRequestStatusEnumTypeTransformer._();

  String encode(AdminCreateWhatsappTemplateRequestStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminCreateWhatsappTemplateRequestStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminCreateWhatsappTemplateRequestStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'pending': return AdminCreateWhatsappTemplateRequestStatusEnum.pending;
        case r'approved': return AdminCreateWhatsappTemplateRequestStatusEnum.approved;
        case r'rejected': return AdminCreateWhatsappTemplateRequestStatusEnum.rejected;
        case r'paused': return AdminCreateWhatsappTemplateRequestStatusEnum.paused;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminCreateWhatsappTemplateRequestStatusEnumTypeTransformer] instance.
  static AdminCreateWhatsappTemplateRequestStatusEnumTypeTransformer? _instance;
}



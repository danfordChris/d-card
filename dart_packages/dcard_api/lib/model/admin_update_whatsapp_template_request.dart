//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class AdminUpdateWhatsappTemplateRequest {
  /// Returns a new [AdminUpdateWhatsappTemplateRequest] instance.
  AdminUpdateWhatsappTemplateRequest({
    this.messageType,
    this.variantName,
    this.language,
    this.metaTemplateName,
    this.category,
    this.bodyParams = const [],
    this.editableParams = const [],
    this.headerImage,
    this.confirmButtons,
    this.status,
    this.active,
  });

  AdminUpdateWhatsappTemplateRequestMessageTypeEnum? messageType;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? variantName;

  AdminUpdateWhatsappTemplateRequestLanguageEnum? language;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  String? metaTemplateName;

  AdminUpdateWhatsappTemplateRequestCategoryEnum? category;

  List<String> bodyParams;

  List<String> editableParams;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? headerImage;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? confirmButtons;

  AdminUpdateWhatsappTemplateRequestStatusEnum? status;

  ///
  /// Please note: This property should have been non-nullable! Since the specification file
  /// does not include a default value (using the "default:" property), however, the generated
  /// source code must fall back to having a nullable type.
  /// Consider adding a "default:" property in the specification file to hide this note.
  ///
  bool? active;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminUpdateWhatsappTemplateRequest &&
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
    (messageType == null ? 0 : messageType!.hashCode) +
    (variantName == null ? 0 : variantName!.hashCode) +
    (language == null ? 0 : language!.hashCode) +
    (metaTemplateName == null ? 0 : metaTemplateName!.hashCode) +
    (category == null ? 0 : category!.hashCode) +
    (bodyParams.hashCode) +
    (editableParams.hashCode) +
    (headerImage == null ? 0 : headerImage!.hashCode) +
    (confirmButtons == null ? 0 : confirmButtons!.hashCode) +
    (status == null ? 0 : status!.hashCode) +
    (active == null ? 0 : active!.hashCode);

  @override
  String toString() => 'AdminUpdateWhatsappTemplateRequest[messageType=$messageType, variantName=$variantName, language=$language, metaTemplateName=$metaTemplateName, category=$category, bodyParams=$bodyParams, editableParams=$editableParams, headerImage=$headerImage, confirmButtons=$confirmButtons, status=$status, active=$active]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (this.messageType != null) {
      json[r'messageType'] = this.messageType;
    } else {
      json[r'messageType'] = null;
    }
    if (this.variantName != null) {
      json[r'variantName'] = this.variantName;
    } else {
      json[r'variantName'] = null;
    }
    if (this.language != null) {
      json[r'language'] = this.language;
    } else {
      json[r'language'] = null;
    }
    if (this.metaTemplateName != null) {
      json[r'metaTemplateName'] = this.metaTemplateName;
    } else {
      json[r'metaTemplateName'] = null;
    }
    if (this.category != null) {
      json[r'category'] = this.category;
    } else {
      json[r'category'] = null;
    }
      json[r'bodyParams'] = this.bodyParams;
      json[r'editableParams'] = this.editableParams;
    if (this.headerImage != null) {
      json[r'headerImage'] = this.headerImage;
    } else {
      json[r'headerImage'] = null;
    }
    if (this.confirmButtons != null) {
      json[r'confirmButtons'] = this.confirmButtons;
    } else {
      json[r'confirmButtons'] = null;
    }
    if (this.status != null) {
      json[r'status'] = this.status;
    } else {
      json[r'status'] = null;
    }
    if (this.active != null) {
      json[r'active'] = this.active;
    } else {
      json[r'active'] = null;
    }
    return json;
  }

  /// Returns a new [AdminUpdateWhatsappTemplateRequest] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminUpdateWhatsappTemplateRequest? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AdminUpdateWhatsappTemplateRequest[$key]" is missing from JSON.');
          assert(json[key] != null, 'Required key "AdminUpdateWhatsappTemplateRequest[$key]" has a null value in JSON.');
        });
        return true;
      }());

      return AdminUpdateWhatsappTemplateRequest(
        messageType: AdminUpdateWhatsappTemplateRequestMessageTypeEnum.fromJson(json[r'messageType']),
        variantName: mapValueOfType<String>(json, r'variantName'),
        language: AdminUpdateWhatsappTemplateRequestLanguageEnum.fromJson(json[r'language']),
        metaTemplateName: mapValueOfType<String>(json, r'metaTemplateName'),
        category: AdminUpdateWhatsappTemplateRequestCategoryEnum.fromJson(json[r'category']),
        bodyParams: json[r'bodyParams'] is Iterable
            ? (json[r'bodyParams'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        editableParams: json[r'editableParams'] is Iterable
            ? (json[r'editableParams'] as Iterable).cast<String>().toList(growable: false)
            : const [],
        headerImage: mapValueOfType<bool>(json, r'headerImage'),
        confirmButtons: mapValueOfType<bool>(json, r'confirmButtons'),
        status: AdminUpdateWhatsappTemplateRequestStatusEnum.fromJson(json[r'status']),
        active: mapValueOfType<bool>(json, r'active'),
      );
    }
    return null;
  }

  static List<AdminUpdateWhatsappTemplateRequest> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminUpdateWhatsappTemplateRequest>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminUpdateWhatsappTemplateRequest.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminUpdateWhatsappTemplateRequest> mapFromJson(dynamic json) {
    final map = <String, AdminUpdateWhatsappTemplateRequest>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminUpdateWhatsappTemplateRequest.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminUpdateWhatsappTemplateRequest-objects as value to a dart map
  static Map<String, List<AdminUpdateWhatsappTemplateRequest>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminUpdateWhatsappTemplateRequest>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminUpdateWhatsappTemplateRequest.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
  };
}


class AdminUpdateWhatsappTemplateRequestMessageTypeEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminUpdateWhatsappTemplateRequestMessageTypeEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const contributionRequest = AdminUpdateWhatsappTemplateRequestMessageTypeEnum._(r'contribution_request');
  static const thankYou = AdminUpdateWhatsappTemplateRequestMessageTypeEnum._(r'thank_you');
  static const contributionReminder = AdminUpdateWhatsappTemplateRequestMessageTypeEnum._(r'contribution_reminder');
  static const invitationCard = AdminUpdateWhatsappTemplateRequestMessageTypeEnum._(r'invitation_card');
  static const cardUpgraded = AdminUpdateWhatsappTemplateRequestMessageTypeEnum._(r'card_upgraded');
  static const attendanceConfirmation = AdminUpdateWhatsappTemplateRequestMessageTypeEnum._(r'attendance_confirmation');
  static const eventReminder = AdminUpdateWhatsappTemplateRequestMessageTypeEnum._(r'event_reminder');
  static const postEventThanks = AdminUpdateWhatsappTemplateRequestMessageTypeEnum._(r'post_event_thanks');

  /// List of all possible values in this [enum][AdminUpdateWhatsappTemplateRequestMessageTypeEnum].
  static const values = <AdminUpdateWhatsappTemplateRequestMessageTypeEnum>[
    contributionRequest,
    thankYou,
    contributionReminder,
    invitationCard,
    cardUpgraded,
    attendanceConfirmation,
    eventReminder,
    postEventThanks,
  ];

  static AdminUpdateWhatsappTemplateRequestMessageTypeEnum? fromJson(dynamic value) => AdminUpdateWhatsappTemplateRequestMessageTypeEnumTypeTransformer().decode(value);

  static List<AdminUpdateWhatsappTemplateRequestMessageTypeEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminUpdateWhatsappTemplateRequestMessageTypeEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminUpdateWhatsappTemplateRequestMessageTypeEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminUpdateWhatsappTemplateRequestMessageTypeEnum] to String,
/// and [decode] dynamic data back to [AdminUpdateWhatsappTemplateRequestMessageTypeEnum].
class AdminUpdateWhatsappTemplateRequestMessageTypeEnumTypeTransformer {
  factory AdminUpdateWhatsappTemplateRequestMessageTypeEnumTypeTransformer() => _instance ??= const AdminUpdateWhatsappTemplateRequestMessageTypeEnumTypeTransformer._();

  const AdminUpdateWhatsappTemplateRequestMessageTypeEnumTypeTransformer._();

  String encode(AdminUpdateWhatsappTemplateRequestMessageTypeEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminUpdateWhatsappTemplateRequestMessageTypeEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminUpdateWhatsappTemplateRequestMessageTypeEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'contribution_request': return AdminUpdateWhatsappTemplateRequestMessageTypeEnum.contributionRequest;
        case r'thank_you': return AdminUpdateWhatsappTemplateRequestMessageTypeEnum.thankYou;
        case r'contribution_reminder': return AdminUpdateWhatsappTemplateRequestMessageTypeEnum.contributionReminder;
        case r'invitation_card': return AdminUpdateWhatsappTemplateRequestMessageTypeEnum.invitationCard;
        case r'card_upgraded': return AdminUpdateWhatsappTemplateRequestMessageTypeEnum.cardUpgraded;
        case r'attendance_confirmation': return AdminUpdateWhatsappTemplateRequestMessageTypeEnum.attendanceConfirmation;
        case r'event_reminder': return AdminUpdateWhatsappTemplateRequestMessageTypeEnum.eventReminder;
        case r'post_event_thanks': return AdminUpdateWhatsappTemplateRequestMessageTypeEnum.postEventThanks;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminUpdateWhatsappTemplateRequestMessageTypeEnumTypeTransformer] instance.
  static AdminUpdateWhatsappTemplateRequestMessageTypeEnumTypeTransformer? _instance;
}



class AdminUpdateWhatsappTemplateRequestLanguageEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminUpdateWhatsappTemplateRequestLanguageEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const sw = AdminUpdateWhatsappTemplateRequestLanguageEnum._(r'sw');
  static const en = AdminUpdateWhatsappTemplateRequestLanguageEnum._(r'en');

  /// List of all possible values in this [enum][AdminUpdateWhatsappTemplateRequestLanguageEnum].
  static const values = <AdminUpdateWhatsappTemplateRequestLanguageEnum>[
    sw,
    en,
  ];

  static AdminUpdateWhatsappTemplateRequestLanguageEnum? fromJson(dynamic value) => AdminUpdateWhatsappTemplateRequestLanguageEnumTypeTransformer().decode(value);

  static List<AdminUpdateWhatsappTemplateRequestLanguageEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminUpdateWhatsappTemplateRequestLanguageEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminUpdateWhatsappTemplateRequestLanguageEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminUpdateWhatsappTemplateRequestLanguageEnum] to String,
/// and [decode] dynamic data back to [AdminUpdateWhatsappTemplateRequestLanguageEnum].
class AdminUpdateWhatsappTemplateRequestLanguageEnumTypeTransformer {
  factory AdminUpdateWhatsappTemplateRequestLanguageEnumTypeTransformer() => _instance ??= const AdminUpdateWhatsappTemplateRequestLanguageEnumTypeTransformer._();

  const AdminUpdateWhatsappTemplateRequestLanguageEnumTypeTransformer._();

  String encode(AdminUpdateWhatsappTemplateRequestLanguageEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminUpdateWhatsappTemplateRequestLanguageEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminUpdateWhatsappTemplateRequestLanguageEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'sw': return AdminUpdateWhatsappTemplateRequestLanguageEnum.sw;
        case r'en': return AdminUpdateWhatsappTemplateRequestLanguageEnum.en;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminUpdateWhatsappTemplateRequestLanguageEnumTypeTransformer] instance.
  static AdminUpdateWhatsappTemplateRequestLanguageEnumTypeTransformer? _instance;
}



class AdminUpdateWhatsappTemplateRequestCategoryEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminUpdateWhatsappTemplateRequestCategoryEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const utility = AdminUpdateWhatsappTemplateRequestCategoryEnum._(r'utility');
  static const marketing = AdminUpdateWhatsappTemplateRequestCategoryEnum._(r'marketing');
  static const authentication = AdminUpdateWhatsappTemplateRequestCategoryEnum._(r'authentication');

  /// List of all possible values in this [enum][AdminUpdateWhatsappTemplateRequestCategoryEnum].
  static const values = <AdminUpdateWhatsappTemplateRequestCategoryEnum>[
    utility,
    marketing,
    authentication,
  ];

  static AdminUpdateWhatsappTemplateRequestCategoryEnum? fromJson(dynamic value) => AdminUpdateWhatsappTemplateRequestCategoryEnumTypeTransformer().decode(value);

  static List<AdminUpdateWhatsappTemplateRequestCategoryEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminUpdateWhatsappTemplateRequestCategoryEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminUpdateWhatsappTemplateRequestCategoryEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminUpdateWhatsappTemplateRequestCategoryEnum] to String,
/// and [decode] dynamic data back to [AdminUpdateWhatsappTemplateRequestCategoryEnum].
class AdminUpdateWhatsappTemplateRequestCategoryEnumTypeTransformer {
  factory AdminUpdateWhatsappTemplateRequestCategoryEnumTypeTransformer() => _instance ??= const AdminUpdateWhatsappTemplateRequestCategoryEnumTypeTransformer._();

  const AdminUpdateWhatsappTemplateRequestCategoryEnumTypeTransformer._();

  String encode(AdminUpdateWhatsappTemplateRequestCategoryEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminUpdateWhatsappTemplateRequestCategoryEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminUpdateWhatsappTemplateRequestCategoryEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'utility': return AdminUpdateWhatsappTemplateRequestCategoryEnum.utility;
        case r'marketing': return AdminUpdateWhatsappTemplateRequestCategoryEnum.marketing;
        case r'authentication': return AdminUpdateWhatsappTemplateRequestCategoryEnum.authentication;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminUpdateWhatsappTemplateRequestCategoryEnumTypeTransformer] instance.
  static AdminUpdateWhatsappTemplateRequestCategoryEnumTypeTransformer? _instance;
}



class AdminUpdateWhatsappTemplateRequestStatusEnum {
  /// Instantiate a new enum with the provided [value].
  const AdminUpdateWhatsappTemplateRequestStatusEnum._(this.value);

  /// The underlying value of this enum member.
  final String value;

  @override
  String toString() => value;

  String toJson() => value;

  static const pending = AdminUpdateWhatsappTemplateRequestStatusEnum._(r'pending');
  static const approved = AdminUpdateWhatsappTemplateRequestStatusEnum._(r'approved');
  static const rejected = AdminUpdateWhatsappTemplateRequestStatusEnum._(r'rejected');
  static const paused = AdminUpdateWhatsappTemplateRequestStatusEnum._(r'paused');

  /// List of all possible values in this [enum][AdminUpdateWhatsappTemplateRequestStatusEnum].
  static const values = <AdminUpdateWhatsappTemplateRequestStatusEnum>[
    pending,
    approved,
    rejected,
    paused,
  ];

  static AdminUpdateWhatsappTemplateRequestStatusEnum? fromJson(dynamic value) => AdminUpdateWhatsappTemplateRequestStatusEnumTypeTransformer().decode(value);

  static List<AdminUpdateWhatsappTemplateRequestStatusEnum> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminUpdateWhatsappTemplateRequestStatusEnum>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminUpdateWhatsappTemplateRequestStatusEnum.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }
}

/// Transformation class that can [encode] an instance of [AdminUpdateWhatsappTemplateRequestStatusEnum] to String,
/// and [decode] dynamic data back to [AdminUpdateWhatsappTemplateRequestStatusEnum].
class AdminUpdateWhatsappTemplateRequestStatusEnumTypeTransformer {
  factory AdminUpdateWhatsappTemplateRequestStatusEnumTypeTransformer() => _instance ??= const AdminUpdateWhatsappTemplateRequestStatusEnumTypeTransformer._();

  const AdminUpdateWhatsappTemplateRequestStatusEnumTypeTransformer._();

  String encode(AdminUpdateWhatsappTemplateRequestStatusEnum data) => data.value;

  /// Decodes a [dynamic value][data] to a AdminUpdateWhatsappTemplateRequestStatusEnum.
  ///
  /// If [allowNull] is true and the [dynamic value][data] cannot be decoded successfully,
  /// then null is returned. However, if [allowNull] is false and the [dynamic value][data]
  /// cannot be decoded successfully, then an [UnimplementedError] is thrown.
  ///
  /// The [allowNull] is very handy when an API changes and a new enum value is added or removed,
  /// and users are still using an old app with the old code.
  AdminUpdateWhatsappTemplateRequestStatusEnum? decode(dynamic data, {bool allowNull = true}) {
    if (data != null) {
      switch (data) {
        case r'pending': return AdminUpdateWhatsappTemplateRequestStatusEnum.pending;
        case r'approved': return AdminUpdateWhatsappTemplateRequestStatusEnum.approved;
        case r'rejected': return AdminUpdateWhatsappTemplateRequestStatusEnum.rejected;
        case r'paused': return AdminUpdateWhatsappTemplateRequestStatusEnum.paused;
        default:
          if (!allowNull) {
            throw ArgumentError('Unknown enum value to decode: $data');
          }
      }
    }
    return null;
  }

  /// Singleton [AdminUpdateWhatsappTemplateRequestStatusEnumTypeTransformer] instance.
  static AdminUpdateWhatsappTemplateRequestStatusEnumTypeTransformer? _instance;
}



//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class AdminUserPage {
  /// Returns a new [AdminUserPage] instance.
  AdminUserPage({
    this.items = const [],
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  List<AdminUser> items;

  int page;

  int pageSize;

  bool hasMore;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminUserPage &&
    _deepEquality.equals(other.items, items) &&
    other.page == page &&
    other.pageSize == pageSize &&
    other.hasMore == hasMore;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (items.hashCode) +
    (page.hashCode) +
    (pageSize.hashCode) +
    (hasMore.hashCode);

  @override
  String toString() => 'AdminUserPage[items=$items, page=$page, pageSize=$pageSize, hasMore=$hasMore]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'items'] = this.items;
      json[r'page'] = this.page;
      json[r'pageSize'] = this.pageSize;
      json[r'hasMore'] = this.hasMore;
    return json;
  }

  /// Returns a new [AdminUserPage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminUserPage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AdminUserPage[$key]" is missing from JSON.');
        });
        return true;
      }());

      return AdminUserPage(
        items: AdminUser.listFromJson(json[r'items']),
        page: mapValueOfType<int>(json, r'page')!,
        pageSize: mapValueOfType<int>(json, r'pageSize')!,
        hasMore: mapValueOfType<bool>(json, r'hasMore')!,
      );
    }
    return null;
  }

  static List<AdminUserPage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminUserPage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminUserPage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminUserPage> mapFromJson(dynamic json) {
    final map = <String, AdminUserPage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminUserPage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminUserPage-objects as value to a dart map
  static Map<String, List<AdminUserPage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminUserPage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminUserPage.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'items',
    'page',
    'pageSize',
    'hasMore',
  };
}


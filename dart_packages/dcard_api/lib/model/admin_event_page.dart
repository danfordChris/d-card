//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class AdminEventPage {
  /// Returns a new [AdminEventPage] instance.
  AdminEventPage({
    this.items = const [],
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });

  List<AdminEvent> items;

  int page;

  int pageSize;

  bool hasMore;

  @override
  bool operator ==(Object other) => identical(this, other) || other is AdminEventPage &&
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
  String toString() => 'AdminEventPage[items=$items, page=$page, pageSize=$pageSize, hasMore=$hasMore]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'items'] = this.items;
      json[r'page'] = this.page;
      json[r'pageSize'] = this.pageSize;
      json[r'hasMore'] = this.hasMore;
    return json;
  }

  /// Returns a new [AdminEventPage] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static AdminEventPage? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "AdminEventPage[$key]" is missing from JSON.');
        });
        return true;
      }());

      return AdminEventPage(
        items: AdminEvent.listFromJson(json[r'items']),
        page: mapValueOfType<int>(json, r'page')!,
        pageSize: mapValueOfType<int>(json, r'pageSize')!,
        hasMore: mapValueOfType<bool>(json, r'hasMore')!,
      );
    }
    return null;
  }

  static List<AdminEventPage> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <AdminEventPage>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = AdminEventPage.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, AdminEventPage> mapFromJson(dynamic json) {
    final map = <String, AdminEventPage>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = AdminEventPage.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of AdminEventPage-objects as value to a dart map
  static Map<String, List<AdminEventPage>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<AdminEventPage>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = AdminEventPage.listFromJson(entry.value, growable: growable,);
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


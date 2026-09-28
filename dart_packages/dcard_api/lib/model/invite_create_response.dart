//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class InviteCreateResponse {
  /// Returns a new [InviteCreateResponse] instance.
  InviteCreateResponse({
    required this.invite,
    required this.link,
    required this.emailQueued,
  });

  Invite invite;

  String link;

  bool emailQueued;

  @override
  bool operator ==(Object other) => identical(this, other) || other is InviteCreateResponse &&
    other.invite == invite &&
    other.link == link &&
    other.emailQueued == emailQueued;

  @override
  int get hashCode =>
    // ignore: unnecessary_parenthesis
    (invite.hashCode) +
    (link.hashCode) +
    (emailQueued.hashCode);

  @override
  String toString() => 'InviteCreateResponse[invite=$invite, link=$link, emailQueued=$emailQueued]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'invite'] = this.invite;
      json[r'link'] = this.link;
      json[r'emailQueued'] = this.emailQueued;
    return json;
  }

  /// Returns a new [InviteCreateResponse] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static InviteCreateResponse? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      // Ensure that the map contains the required keys.
      // Note 1: the values aren't checked for validity beyond being non-null.
      // Note 2: this code is stripped in release mode!
      assert(() {
        requiredKeys.forEach((key) {
          assert(json.containsKey(key), 'Required key "InviteCreateResponse[$key]" is missing from JSON.');
        });
        return true;
      }());

      return InviteCreateResponse(
        invite: Invite.fromJson(json[r'invite'])!,
        link: mapValueOfType<String>(json, r'link')!,
        emailQueued: mapValueOfType<bool>(json, r'emailQueued')!,
      );
    }
    return null;
  }

  static List<InviteCreateResponse> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <InviteCreateResponse>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = InviteCreateResponse.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  static Map<String, InviteCreateResponse> mapFromJson(dynamic json) {
    final map = <String, InviteCreateResponse>{};
    if (json is Map && json.isNotEmpty) {
      json = json.cast<String, dynamic>(); // ignore: parameter_assignments
      for (final entry in json.entries) {
        final value = InviteCreateResponse.fromJson(entry.value);
        if (value != null) {
          map[entry.key] = value;
        }
      }
    }
    return map;
  }

  // maps a json object with a list of InviteCreateResponse-objects as value to a dart map
  static Map<String, List<InviteCreateResponse>> mapListFromJson(dynamic json, {bool growable = false,}) {
    final map = <String, List<InviteCreateResponse>>{};
    if (json is Map && json.isNotEmpty) {
      // ignore: parameter_assignments
      json = json.cast<String, dynamic>();
      for (final entry in json.entries) {
        map[entry.key] = InviteCreateResponse.listFromJson(entry.value, growable: growable,);
      }
    }
    return map;
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'invite',
    'link',
    'emailQueued',
  };
}


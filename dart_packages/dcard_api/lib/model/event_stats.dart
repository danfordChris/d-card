//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//
// @dart=2.18

// ignore_for_file: unused_element, unused_import
// ignore_for_file: always_put_required_named_parameters_first
// ignore_for_file: constant_identifier_names
// ignore_for_file: lines_longer_than_80_chars

part of dcard_api;

class EventStats {
  /// Returns a new [EventStats] instance.
  EventStats({
    required this.guestCount,
    required this.cardsSent,
    required this.collected,
    required this.confirmed,
  });

  int guestCount;

  int cardsSent;

  int collected;

  int confirmed;

  @override
  bool operator ==(Object other) => identical(this, other) || other is EventStats &&
    other.guestCount == guestCount &&
    other.cardsSent == cardsSent &&
    other.collected == collected &&
    other.confirmed == confirmed;

  @override
  int get hashCode =>
    (guestCount.hashCode) +
    (cardsSent.hashCode) +
    (collected.hashCode) +
    (confirmed.hashCode);

  @override
  String toString() => 'EventStats[guestCount=$guestCount, cardsSent=$cardsSent, collected=$collected, confirmed=$confirmed]';

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
      json[r'guestCount'] = this.guestCount;
      json[r'cardsSent'] = this.cardsSent;
      json[r'collected'] = this.collected;
      json[r'confirmed'] = this.confirmed;
    return json;
  }

  /// Returns a new [EventStats] instance and imports its values from
  /// [value] if it's a [Map], null otherwise.
  // ignore: prefer_constructors_over_static_methods
  static EventStats? fromJson(dynamic value) {
    if (value is Map) {
      final json = value.cast<String, dynamic>();

      return EventStats(
        guestCount: mapValueOfType<int>(json, r'guestCount')!,
        cardsSent: mapValueOfType<int>(json, r'cardsSent')!,
        collected: mapValueOfType<int>(json, r'collected')!,
        confirmed: mapValueOfType<int>(json, r'confirmed')!,
      );
    }
    return null;
  }

  static List<EventStats> listFromJson(dynamic json, {bool growable = false,}) {
    final result = <EventStats>[];
    if (json is List && json.isNotEmpty) {
      for (final row in json) {
        final value = EventStats.fromJson(row);
        if (value != null) {
          result.add(value);
        }
      }
    }
    return result.toList(growable: growable);
  }

  /// The list of required keys that must be present in a JSON.
  static const requiredKeys = <String>{
    'guestCount',
    'cardsSent',
    'collected',
    'confirmed',
  };
}

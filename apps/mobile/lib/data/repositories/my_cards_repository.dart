import 'dart:convert';
import 'dart:io';

import 'package:dcard_api/api.dart' as api;
import 'package:http/http.dart' as http;

import '../../domain/models/app_failure.dart';
import '../../domain/models/guest_card.dart';

/// A guest's cards (AUTH-4): list and link (`/api/v1/me/cards`, `/api/v1/me/cards/link`),
/// and the public card view and RSVP by link token (`/api/v1/cards/{token}`, `.../rsvp`, AUTH-5).
///
/// Reads raw JSON: several fields (venue, end time, QR token) are null on the server,
/// which the generated models do not allow.
class MyCardsRepository {
  MyCardsRepository(this._api);

  final api.DefaultApi _api;

  /// Newest event first.
  Future<List<MyCard>> list() async {
    final body = await _send(_api.listMyCardsWithHttpInfo);
    final items = [for (final j in (body['items'] as List? ?? const []).cast<Map<String, dynamic>>()) myCardFromJson(j)]
      ..sort((a, b) => b.startsAt.compareTo(a.startsAt));
    return items;
  }

  /// Links the card behind [token] to the signed-in account.
  /// Throws [LinkRefusedException] for an unknown card or a 409 refusal.
  Future<void> link(String token) async {
    await _send(
      () => _api.linkMyCardWithHttpInfo(linkCardInput: api.LinkCardInput(token: token)),
      refusal: (status, code) {
        if (status == 404) throw const LinkRefusedException(LinkRefusal.notFound);
        if (code == 'person_linked') throw const LinkRefusedException(LinkRefusal.personLinked);
        if (code == 'account_linked') throw const LinkRefusedException(LinkRefusal.accountLinked);
        if (status == 400 || status == 422) throw const LinkRefusedException(LinkRefusal.invalidLink);
      },
    );
  }

  Future<GuestCard> card(String token) async => guestCardFromJson(await _send(() => _api.getPublicCardWithHttpInfo(token)));

  /// Answers the RSVP. Throws [RsvpRefusedException] when RSVP is closed or rate-limited.
  Future<RsvpState> rsvp(String token, RsvpAnswer answer) async {
    final input = api.RsvpInput(
      answer: answer == RsvpAnswer.yes ? api.RsvpInputAnswerEnum.yes : api.RsvpInputAnswerEnum.no,
    );
    final body = await _send(
      () => _api.submitRsvpWithHttpInfo(token, rsvpInput: input),
      refusal: (status, _) {
        if (status == 409) throw const RsvpRefusedException(RsvpRefusal.closed);
        if (status == 429) throw const RsvpRefusedException(RsvpRefusal.tooMany);
      },
    );
    return rsvpFromJson(body);
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() call, {
    void Function(int status, String? code)? refusal,
  }) async {
    final http.Response response;
    try {
      response = await call();
    } on api.ApiException catch (e) {
      if (e.innerException is SocketException || e.innerException is HttpException) {
        throw const AppException(AppFailure.network);
      }
      throw const AppException(AppFailure.unknown);
    } on SocketException {
      throw const AppException(AppFailure.network);
    } on HttpException {
      throw const AppException(AppFailure.network);
    }
    Object? decoded;
    try {
      decoded = response.bodyBytes.isEmpty ? null : jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      decoded = null;
    }
    final body = decoded is Map ? decoded.cast<String, dynamic>() : <String, dynamic>{};
    final status = response.statusCode;
    if (status < 400) {
      if (decoded is! Map) throw const AppException(AppFailure.unknown);
      return body;
    }
    if (status == 401 || status == 403) throw const AppException(AppFailure.unauthorized);
    refusal?.call(status, (body['error'] as Map?)?['code'] as String?);
    if (status == 429) throw const AppException(AppFailure.tooManyRequests);
    throw const AppException(AppFailure.unknown);
  }

  static DateTime _date(Object? v) =>
      (v is String ? DateTime.tryParse(v) : null) ?? DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);

  static RsvpAnswer _answer(Object? v) => switch (v) {
    'yes' => RsvpAnswer.yes,
    'no' => RsvpAnswer.no,
    _ => RsvpAnswer.none,
  };

  static CardStatus _status(Object? v) => v == 'cancelled' ? CardStatus.cancelled : CardStatus.issued;

  static MyCard myCardFromJson(Map<String, dynamic> j) => MyCard(
    eventTitle: j['eventTitle'] as String? ?? '',
    startsAt: _date(j['startsAt']),
    endsAt: j['endsAt'] == null ? null : _date(j['endsAt']),
    timeZone: j['timeZone'] as String? ?? 'Africa/Dar_es_Salaam',
    venueName: j['venueName'] as String?,
    guestName: j['guestName'] as String? ?? '',
    isDouble: j['cardType'] == 'double',
    cardNumber: j['cardNumber'] as String? ?? '',
    status: _status(j['status']),
    rsvp: _answer(j['rsvpStatus']),
    linkToken: j['linkToken'] as String,
  );

  static RsvpState rsvpFromJson(Map<String, dynamic> j) =>
      RsvpState(answer: _answer(j['status']), open: j['open'] == true, dietaryNotes: j['dietaryNotes'] as String?);

  static GuestCard guestCardFromJson(Map<String, dynamic> j) {
    final e = (j['event'] as Map?)?.cast<String, dynamic>() ?? const <String, dynamic>{};
    final rsvp = j['rsvp'];
    return GuestCard(
      status: _status(j['status']),
      guestName: j['guestName'] as String? ?? '',
      partnerName: j['partnerName'] as String?,
      isDouble: j['cardType'] == 'double',
      cardNumber: j['cardNumber'] as String? ?? '',
      qrToken: j['qrToken'] as String?,
      rsvp: rsvp is Map
          ? rsvpFromJson(rsvp.cast<String, dynamic>())
          : const RsvpState(answer: RsvpAnswer.none, open: false),
      eventTitle: e['title'] as String? ?? '',
      eventTypeSw: e['typeNameSw'] as String? ?? '',
      eventTypeEn: e['typeNameEn'] as String? ?? '',
      startsAt: _date(e['startsAt']),
      endsAt: e['endsAt'] == null ? null : _date(e['endsAt']),
      venueName: e['venueName'] as String?,
      venueAddress: e['venueAddress'] as String?,
      venueMapUrl: e['venueMapUrl'] as String?,
      contactName: e['contactName'] as String? ?? '',
      contactPhone: e['contactPhone'] as String? ?? '',
      eventCancelled: e['status'] == 'cancelled',
    );
  }
}

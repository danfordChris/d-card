import 'dart:async';
import 'dart:convert';

import 'package:dcard_api/api.dart';
import 'package:http/http.dart' as http;
import 'package:dcard_mobile/data/services/auth_service.dart';
import 'package:dcard_mobile/data/services/contacts_source.dart';
import 'package:dcard_mobile/data/services/file_saver.dart';
import 'package:dcard_mobile/data/services/link_opener.dart';
import 'package:dcard_mobile/data/services/push_message_source.dart';
import 'package:dcard_mobile/domain/models/app_failure.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({this.failure});

  AppFailure? failure;
  AuthUser? _user;
  final signIns = <String>[];

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<AuthUser> signIn({required String email, required String password}) async {
    signIns.add(email);
    if (failure != null) throw AppException(failure!);
    return _user = AuthUser(uid: 'uid-$email', email: email);
  }

  /// Failure for the next Google/Apple sign-ins (e.g. `AppFailure.cancelled`).
  AppFailure? socialFailure;
  final socialSignIns = <SocialProvider>[];

  @override
  Future<AuthUser> signInWithProvider(SocialProvider provider) async {
    socialSignIns.add(provider);
    if (socialFailure != null) throw AppException(socialFailure!);
    return _user = AuthUser(uid: 'uid-${provider.name}', email: 'guest@gmail.com', provider: provider.name);
  }

  @override
  Future<void> signOut() async => _user = null;

  @override
  Future<String?> idToken() async => _user == null ? null : 'token';
}

class FakeFileSaver implements FileSaver {
  final saved = <String, List<int>>{};

  @override
  Future<String> save(String fileName, List<int> bytes) async {
    saved[fileName] = bytes;
    return '/docs/$fileName';
  }
}

/// A `GET /api/v1/me/cards` item.
Map<String, Object?> fakeMyCard({
  String token = 'tok_aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa1',
  String title = 'Harusi ya Asha',
  String startsAt = '2026-12-12T12:00:00.000Z',
  String cardNumber = '007-1234',
  String status = 'issued',
  String rsvp = 'none',
  String? venue = 'Diamond Jubilee',
}) => {
  'eventTitle': title,
  'startsAt': startsAt,
  'endsAt': null,
  'timeZone': 'Africa/Dar_es_Salaam',
  'venueName': venue,
  'guestName': 'Juma Hamisi',
  'cardType': 'single',
  'cardNumber': cardNumber,
  'status': status,
  'rsvpStatus': rsvp,
  'linkToken': token,
};

/// A `GET /api/v1/cards/{token}` body.
Map<String, Object?> fakePublicCard({
  String status = 'issued',
  String rsvp = 'none',
  bool open = true,
  String cardNumber = '007-1234',
}) => {
  'status': status,
  'guestName': 'Juma Hamisi',
  'partnerName': null,
  'cardType': 'single',
  'cardNumber': cardNumber,
  'qrToken': status == 'issued' ? 'qr-token-1' : null,
  'rsvp': {'status': rsvp, 'dietaryNotes': null, 'at': null, 'open': open},
  'event': {
    'title': 'Harusi ya Asha',
    'typeKey': 'wedding',
    'typeNameSw': 'Harusi',
    'typeNameEn': 'Wedding',
    'startsAt': '2026-12-12T12:00:00.000Z',
    'endsAt': null,
    'timeZone': 'Africa/Dar_es_Salaam',
    'venueName': 'Diamond Jubilee',
    'venueAddress': 'Upanga, Dar es Salaam',
    'venueMapUrl': null,
    'contactName': 'Asha',
    'contactPhone': '255754123456',
    'status': 'published',
  },
};

class FakeApi extends DefaultApi {
  FakeApi({this.events = const [], this.listError});

  List<Event> events;
  ApiException? listError;
  int provisionCalls = 0;
  int listCalls = 0;

  @override
  Future<Account?> provisionMe() async {
    provisionCalls++;
    return Account(
      id: 'a1',
      firebaseUid: 'uid',
      email: 'host@example.com',
      authProvider: AuthProvider.password,
      personId: null,
      isAdmin: false,
      emailVerified: true,
      createdAt: DateTime.utc(2026),
    );
  }

  GuestBulkInput? lastBulk;
  String? lastBulkEventId;

  /// Phones the fake treats as already invited.
  Set<String> invitedPhones = {};

  @override
  Future<GuestBulkResponse?> addGuestsBulk(String id, {GuestBulkInput? guestBulkInput}) async {
    lastBulkEventId = id;
    lastBulk = guestBulkInput;
    final guests = guestBulkInput!.guests;
    return GuestBulkResponse(
      added: [
        for (final g in guests)
          if (!invitedPhones.contains(g.phone)) fakeGuest(g.name, g.phone),
      ],
      existing: [
        for (final g in guests)
          if (invitedPhones.contains(g.phone)) fakeGuest(g.name, g.phone),
      ],
      invalid: [],
    );
  }

  List<Pledge> pledges = [];
  final payments = <PaymentCreateInput>[];

  @override
  Future<Contributions?> getContributions(String id, {String? status, String? q}) async {
    final paid = pledges.fold<int>(0, (a, p) => a + p.amountPaid);
    final pledged = pledges.fold<int>(0, (a, p) => a + p.amountPledged);
    return Contributions(
      summary: ContributionsSummary(
        pledged: pledged,
        collected: paid,
        outstanding: pledges.fold<int>(0, (a, p) => a + p.balance),
        extras: 0,
        refunds: 0,
        budget: null,
        counts: ContributionsSummaryCounts(notPaid: 0, partPaid: 0, fullyPaid: 0, cancelled: 0),
      ),
      contributors: pledges,
    );
  }

  @override
  Future<PaymentResult?> recordPayment(String id, String pledgeId, {PaymentCreateInput? paymentCreateInput}) async {
    final input = paymentCreateInput!;
    payments.add(input);
    final i = pledges.indexWhere((p) => p.id == pledgeId);
    final p = pledges[i];
    final paid = p.amountPaid + input.amount;
    final full = paid >= p.amountPledged;
    final next = fakePledge(
      id: p.id,
      name: p.name,
      phone: p.phone,
      pledged: p.amountPledged,
      paid: paid,
      cardNumber: full ? '007-1234' : null,
    );
    pledges[i] = next;
    return PaymentResult(
      pledge: next,
      payment: Payment(
        id: 'pay${payments.length}',
        kind: PaymentKindEnum.payment,
        amount: input.amount,
        method: input.method,
        reference: input.reference,
        paidOn: input.paidOn,
        recordedBy: null,
        recordedAt: DateTime.utc(2026, 10),
      ),
    );
  }

  @override
  Future<Event?> getEvent(String id) async {
    final match = events.where((e) => e.id == id);
    if (match.isEmpty) throw ApiException(404, '{"error":{"code":"not_found","message":"Event not found."}}');
    return match.first;
  }

  /// Walk-ins by id, as the server holds them.
  List<WalkIn> walkIns = [];
  int walkInListCalls = 0;
  final decisions = <(String, WalkInDecisionInputDecisionEnum)>[];

  /// Walk-ins another approver already decided: the next decision gets 409 with this state.
  final decidedElsewhere = <String, WalkIn>{};

  /// Status code to fail decisions with (e.g. 403 for committee).
  int? decideErrorCode;

  @override
  Future<ListWalkIns200Response?> listWalkIns(String id, {WalkInStatus? status}) async {
    walkInListCalls++;
    return ListWalkIns200Response(
      walkIns: [
        for (final w in walkIns)
          if (w.eventId == id) w,
      ],
    );
  }

  @override
  Future<WalkIn?> decideWalkIn(String id, String walkInId, {WalkInDecisionInput? walkInDecisionInput}) async {
    final decision = walkInDecisionInput!.decision;
    decisions.add((walkInId, decision));
    if (decideErrorCode != null) {
      throw ApiException(decideErrorCode!, '{"error":{"code":"forbidden","message":"Not allowed."}}');
    }
    final other = decidedElsewhere.remove(walkInId);
    if (other != null) {
      _put(other);
      throw ApiException(
        409,
        jsonEncode({
          'error': {'code': 'already_decided', 'message': 'Already decided.'},
          'walkIn': other.toJson(),
        }),
      );
    }
    final w = walkIns.firstWhere((x) => x.id == walkInId);
    final next = fakeWalkIn(
      id: w.id,
      description: w.description,
      admittedCount: w.admittedCount,
      offlineReason: w.offlineReason,
      guestName: w.guestName,
      status: switch (decision) {
        WalkInDecisionInputDecisionEnum.approve => WalkInStatus.approved,
        WalkInDecisionInputDecisionEnum.refuse => WalkInStatus.refused,
        WalkInDecisionInputDecisionEnum.accept => WalkInStatus.accepted,
        _ => WalkInStatus.flagged,
      },
      decidedBy: 'host@example.com',
    );
    _put(next);
    return next;
  }

  void _put(WalkIn w) => walkIns = [for (final x in walkIns) x.id == w.id ? w : x];

  // ---- Billing (T05-03): a small in-memory copy of the server's pricing rules. ----

  /// Plan the event is on, and cards already paid for (0 = unpaid).
  String billingPlanKey = 'kawaida';
  int billingGuestLimit = 0;
  int billingAmountPaid = 0;
  int billingGuestCount = 40;
  int billingIssuedCards = 0;
  int launchOfferPercent = 20;
  Map<String, Object?>? pendingAttempt;
  List<Map<String, Object?>> hostPayments = [];

  /// Added to every quote total (simulates a price change on the server).
  int priceDrift = 0;

  /// Codes to refuse the next checkouts with (e.g. `quote_changed`), in order.
  final checkoutErrors = <String>[];

  /// Statuses the next polls return, in order; the last one repeats.
  List<String> pollStatuses = ['completed'];
  String checkoutMethodSeen = '';

  final quoteRequests = <BillingQuoteInput>[];
  final checkouts = <CheckoutInput>[];
  int pollCalls = 0;

  static const planPrices = {'msingi': 1000, 'kawaida': 1500, 'premium': 2000};
  static const planNames = {'msingi': 'Msingi', 'kawaida': 'Kawaida', 'premium': 'Premium'};

  http.Response _json(Object body, [int status = 200]) =>
      http.Response.bytes(utf8.encode(jsonEncode(body)), status, headers: {'content-type': 'application/json'});

  http.Response _error(int status, String code) => _json({
    'error': {'code': code, 'message': code},
  }, status);

  Map<String, Object?> billingQuote(String? planKey, int guestCards) {
    final key = planKey ?? billingPlanKey;
    final current = planPrices[billingPlanKey]!;
    final target = planPrices[key]!;
    final lines = <Map<String, Object?>>[];
    int cards;
    if (billingGuestLimit == 0) {
      final minCards = (50000 + target - 1) ~/ target;
      cards = guestCards > minCards ? guestCards : minCards;
      lines.add({'code': 'new_cards', 'quantity': cards, 'unitPrice': target, 'amount': cards * target});
    } else {
      final extra = ((guestCards - billingGuestLimit + 9) ~/ 10) * 10;
      cards = billingGuestLimit + extra;
      final diff = target - current;
      if (diff > 0) {
        lines.add({'code': 'upgrade', 'quantity': billingGuestLimit, 'unitPrice': diff, 'amount': billingGuestLimit * diff});
      }
      if (extra > 0) lines.add({'code': 'extra_cards', 'quantity': extra, 'unitPrice': target, 'amount': extra * target});
    }
    final subtotal = lines.fold<int>(0, (a, l) => a + (l['amount']! as int)) + priceDrift;
    final discount = subtotal * launchOfferPercent ~/ 100;
    return {
      'planKey': key,
      'planName': planNames[key],
      'pricePerGuest': target,
      'currentGuestCards': billingGuestLimit,
      'guestCards': cards,
      'blockSize': 10,
      'minimumCharge': 50000,
      'lines': lines,
      'subtotal': subtotal,
      'discountPercent': subtotal > 0 ? launchOfferPercent : 0,
      'discountAmount': discount,
      'total': subtotal - discount,
      'payable': subtotal - discount > 0,
    };
  }

  Map<String, Object?> _attempt(String status, CheckoutInput input, int amount, int cards) => {
    'id': 'att1',
    'status': status,
    'method': input.method.value,
    'amount': amount,
    'planKey': input.planKey?.value ?? billingPlanKey,
    'guestCards': cards,
    'phone': input.phone,
    'checkoutUrl': input.method == HostPaymentMethod.session ? 'https://pay.example.com/s/att1' : null,
    'reference': status == 'completed' ? 'SNP-12345' : null,
    'failureReason': null,
    'createdAt': '2026-10-01T09:00:00.000Z',
    'completedAt': status == 'completed' ? '2026-10-01T09:01:00.000Z' : null,
  };

  Map<String, Object?>? _lastAttempt;

  @override
  Future<http.Response> getBillingWithHttpInfo(String id) async => _json({
    'planKey': billingPlanKey,
    'planName': planNames[billingPlanKey],
    'pricePerGuest': planPrices[billingPlanKey],
    'guestLimit': billingGuestLimit,
    'amountPaid': billingAmountPaid,
    'paid': billingGuestLimit > 0,
    'issuedCards': billingIssuedCards,
    'guestCount': billingGuestCount,
    'launchOfferPercent': launchOfferPercent,
    'launchOfferEligible': launchOfferPercent > 0,
    'pendingAttempt': pendingAttempt,
    'payments': hostPayments,
  });

  @override
  Future<http.Response> listPlansWithHttpInfo() async => _json({
    'plans': [
      for (final k in planPrices.keys) {'key': k, 'name': planNames[k], 'pricePerGuest': planPrices[k], 'entitlements': {}},
    ],
  });

  @override
  Future<http.Response> quoteBillingWithHttpInfo(String id, {BillingQuoteInput? billingQuoteInput}) async {
    final input = billingQuoteInput!;
    quoteRequests.add(input);
    return _json(billingQuote(input.planKey?.value, input.guestCards));
  }

  @override
  Future<http.Response> startCheckoutWithHttpInfo(String id, {CheckoutInput? checkoutInput}) async {
    final input = checkoutInput!;
    checkouts.add(input);
    if (checkoutErrors.isNotEmpty) {
      final code = checkoutErrors.removeAt(0);
      if (code == 'quote_changed') priceDrift = 0;
      return _error(code == 'provider_unavailable' ? 502 : 409, code);
    }
    final q = billingQuote(input.planKey?.value, input.guestCards);
    if (q['total'] != input.expectedTotal) return _error(409, 'quote_changed');
    _lastAttempt = _attempt('pending', input, q['total']! as int, q['guestCards']! as int);
    return _json(_lastAttempt!, 201);
  }

  @override
  Future<http.Response> getCheckoutWithHttpInfo(String id, String attemptId) async {
    pollCalls++;
    final status = pollStatuses.length > 1 ? pollStatuses.removeAt(0) : pollStatuses.first;
    final base = Map<String, Object?>.of(_lastAttempt ?? pendingAttempt!);
    base['status'] = status;
    if (status == 'completed') {
      base['reference'] = 'SNP-12345';
      base['completedAt'] = '2026-10-01T09:01:00.000Z';
    }
    return _json(base);
  }

  // ---- Guest cards (T06-02) ----

  List<Map<String, Object?>> myCards = [];
  int myCardsCalls = 0;
  final linkRequests = <String>[];

  /// Status and error code for the next link (e.g. `(409, 'person_linked')`); null links it.
  (int, String)? linkError;

  /// Cards linked by token when a link succeeds.
  Map<String, Map<String, Object?>> linkable = {};
  Map<String, Map<String, Object?>> publicCards = {};
  final rsvps = <(String, RsvpInputAnswerEnum)>[];
  int? rsvpErrorStatus;

  int? deleteMeStatus;
  int deleteMeCalls = 0;
  int exportCalls = 0;

  @override
  Future<http.Response> listMyCardsWithHttpInfo() async {
    myCardsCalls++;
    return _json({'items': myCards});
  }

  @override
  Future<http.Response> linkMyCardWithHttpInfo({LinkCardInput? linkCardInput}) async {
    final token = linkCardInput!.token;
    linkRequests.add(token);
    if (linkError != null) return _error(linkError!.$1, linkError!.$2);
    final card = linkable[token];
    if (card == null) return _error(404, 'not_found');
    if (!myCards.contains(card)) myCards = [...myCards, card];
    return _json({'linked': true});
  }

  @override
  Future<http.Response> getPublicCardWithHttpInfo(String token) async {
    final card = publicCards[token];
    return card == null ? _error(404, 'not_found') : _json(card);
  }

  @override
  Future<http.Response> submitRsvpWithHttpInfo(String token, {RsvpInput? rsvpInput}) async {
    rsvps.add((token, rsvpInput!.answer));
    if (rsvpErrorStatus != null) return _error(rsvpErrorStatus!, rsvpErrorStatus == 409 ? 'conflict' : 'rate_limited');
    final rsvp = {'status': rsvpInput.answer.value, 'dietaryNotes': null, 'at': '2026-10-01T09:00:00.000Z', 'open': true};
    final card = publicCards[token];
    if (card != null) publicCards[token] = {...card, 'rsvp': rsvp};
    return _json(rsvp);
  }

  @override
  Future<http.Response> exportMyDataWithHttpInfo() async {
    exportCalls++;
    return http.Response.bytes(
      utf8.encode(jsonEncode({'exportedAt': '2026-10-01T09:00:00.000Z', 'account': {}})),
      200,
      headers: {'content-type': 'application/json', 'content-disposition': 'attachment; filename="dcard-my-data-2026-10-01.json"'},
    );
  }

  @override
  Future<void> deleteMe() async {
    deleteMeCalls++;
    if (deleteMeStatus != null) {
      throw ApiException(deleteMeStatus!, '{"error":{"code":"conflict","message":"Delete your events first."}}');
    }
  }

  @override
  Future<EventList?> listEvents() async {
    listCalls++;
    if (listError != null) throw listError!;
    return EventList(events: events);
  }
}

Event fakeEvent({
  EventAccessEnum? access,
  String id = 'e1',
  String title = 'Harusi ya Asha',
  EventStatusEnum? status,
  String? venueName = 'Diamond Jubilee',
  bool planPaid = false,
}) => Event(
  id: id,
  title: title,
  status: status ?? EventStatusEnum.published,
  eventType: EventType(key: 'wedding', nameSw: 'Harusi', nameEn: 'Wedding'),
  plan: EventPlan(key: 'kawaida', name: 'Kawaida', pricePerGuest: 1500, guestLimit: 500, paid: planPaid),
  startsAt: DateTime.utc(2026, 12, 12, 12), // 15:00 in Dar es Salaam
  endsAt: null,
  timeZone: 'Africa/Dar_es_Salaam',
  venueName: venueName,
  venueAddress: 'Upanga, Dar es Salaam',
  venueMapUrl: null,
  contactName: 'Asha',
  contactPhone: '255754123456',
  contact2Name: null,
  contact2Phone: null,
  confirmationEnabled: true,
  confirmationOffsetDays: 2,
  headcountPct: 70,
  autoUpgradeEnabled: true,
  singleAmount: null,
  doubleAmount: null,
  budgetAmount: null,
  paymentDetails: null,
  reminderFrequencyDays: null,
  photoAlbumUrl: null,
  access: access ?? EventAccessEnum.host,
  createdAt: DateTime.utc(2026, 9, 1),
  updatedAt: DateTime.utc(2026, 9, 1),
);

class FakeContactsSource implements ContactsSource {
  FakeContactsSource({this.permission = ContactsPermission.granted, this.contacts = const []});

  ContactsPermission permission;
  List<PhoneContact> contacts;
  int permissionRequests = 0;
  int settingsOpened = 0;

  @override
  Future<ContactsPermission> requestPermission() async {
    permissionRequests++;
    return permission;
  }

  @override
  Future<List<PhoneContact>> loadContacts() async => contacts;

  @override
  Future<void> openSettings() async => settingsOpened++;
}

Guest fakeGuest(String name, String phone) => Guest(
  id: 'g-$phone',
  eventId: 'e1',
  personId: null,
  name: name,
  phone: phone,
  partnerName: null,
  cardType: CardType.single,
  totalEntries: 1,
  status: GuestStatusEnum.pending,
  cardNumber: null,
  issuedAt: null,
  createdAt: DateTime.utc(2026, 9, 24),
  updatedAt: DateTime.utc(2026, 9, 24),
);

Pledge fakePledge({
  required String id,
  required String name,
  String phone = '255713500001',
  int pledged = 50000,
  int paid = 0,
  String? cardNumber,
}) => Pledge(
  id: id,
  guestId: 'g-$id',
  name: name,
  phone: phone,
  partnerName: null,
  cardType: CardType.single,
  amountPledged: pledged,
  amountPaid: paid,
  amountExtra: paid > pledged ? paid - pledged : 0,
  balance: paid >= pledged ? 0 : pledged - paid,
  status: paid <= 0 ? PledgeStatus.notPaid : (paid < pledged ? PledgeStatus.partPaid : PledgeStatus.fullyPaid),
  upgradedAt: null,
  invitationStatus: cardNumber == null ? PledgeInvitationStatusEnum.pending : PledgeInvitationStatusEnum.issued,
  cardNumber: cardNumber,
);

WalkIn fakeWalkIn({
  required String id,
  String eventId = 'e1',
  String description = 'Mjomba wa bibi harusi',
  WalkInStatus? status,
  int admittedCount = 1,
  String? guestName,
  String? offlineReason,
  String? decidedBy,
}) {
  final s = status ?? (offlineReason != null ? WalkInStatus.admittedOffline : WalkInStatus.pending);
  final offline = offlineReason != null;
  return WalkIn(
    id: id,
    eventId: eventId,
    status: s,
    description: description,
    invitationId: guestName == null ? null : 'inv-$id',
    guestName: guestName,
    admittedCount: admittedCount,
    source_: offline ? WalkInSource_Enum.offline : WalkInSource_Enum.online,
    offlineReason: offlineReason,
    requestedBy: 'door@example.com',
    deviceName: 'Lango kuu',
    decidedBy: decidedBy,
    decidedAt: decidedBy == null ? null : DateTime.utc(2026, 12, 12, 14, 5),
    occurredAt: DateTime.utc(2026, 12, 12, 14), // 17:00 in Dar es Salaam
  );
}

/// Push messages the tests inject.
class FakePushMessageSource implements PushMessageSource {
  final foregroundController = StreamController<Map<String, Object?>>.broadcast();
  final openedController = StreamController<Map<String, Object?>>.broadcast();
  Map<String, Object?>? initialMessage;

  @override
  Stream<Map<String, Object?>> get foreground => foregroundController.stream;

  @override
  Stream<Map<String, Object?>> get opened => openedController.stream;

  @override
  Future<Map<String, Object?>?> initial() async => initialMessage;
}

class FakeLinkOpener implements LinkOpener {
  final opened = <Uri>[];

  @override
  Future<bool> open(Uri url) async {
    opened.add(url);
    return true;
  }
}

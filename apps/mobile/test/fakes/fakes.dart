import 'package:dcard_api/api.dart';
import 'package:dcard_mobile/data/services/auth_service.dart';
import 'package:dcard_mobile/data/services/contacts_source.dart';
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

  @override
  Future<void> signOut() async => _user = null;

  @override
  Future<String?> idToken() async => _user == null ? null : 'token';
}

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
}) => Event(
  id: id,
  title: title,
  status: status ?? EventStatusEnum.published,
  eventType: EventType(key: 'wedding', nameSw: 'Harusi', nameEn: 'Wedding'),
  plan: EventPlan(key: 'kawaida', name: 'Kawaida', pricePerGuest: 1500, guestLimit: 500, paid: false),
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

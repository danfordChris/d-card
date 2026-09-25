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

  @override
  Future<EventList?> listEvents() async {
    listCalls++;
    if (listError != null) throw listError!;
    return EventList(events: events);
  }
}

Event fakeEvent({
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
  reminderFrequencyDays: null,
  photoAlbumUrl: null,
  access: EventAccessEnum.host,
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
  createdAt: DateTime.utc(2026, 9, 24),
  updatedAt: DateTime.utc(2026, 9, 24),
);

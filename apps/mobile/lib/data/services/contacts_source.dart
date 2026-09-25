import 'package:flutter_contacts/flutter_contacts.dart';

enum ContactsPermission { granted, denied, permanentlyDenied }

/// A phone-book entry with its raw numbers.
class PhoneContact {
  const PhoneContact({required this.id, required this.name, required this.phones});

  final String id;
  final String name;
  final List<String> phones;
}

/// Device contacts boundary (flutter_contacts in the app, fakes in tests).
abstract interface class ContactsSource {
  /// Asks for read access. Called only when the host opens the picker (GST-6).
  Future<ContactsPermission> requestPermission();

  /// Contacts that have at least one phone number, sorted by name.
  Future<List<PhoneContact>> loadContacts();

  Future<void> openSettings();
}

class DeviceContactsSource implements ContactsSource {
  @override
  Future<ContactsPermission> requestPermission() async {
    final status = await FlutterContacts.permissions.request(PermissionType.read);
    return switch (status) {
      PermissionStatus.granted || PermissionStatus.limited => ContactsPermission.granted,
      PermissionStatus.permanentlyDenied || PermissionStatus.restricted => ContactsPermission.permanentlyDenied,
      _ => ContactsPermission.denied,
    };
  }

  @override
  Future<List<PhoneContact>> loadContacts() async {
    final contacts = await FlutterContacts.getAll(properties: {ContactProperty.phone});
    return [
      for (final c in contacts)
        if (c.phones.isNotEmpty)
          PhoneContact(
            id: c.id ?? c.displayName ?? '',
            name: (c.displayName ?? '').trim(),
            phones: [for (final p in c.phones) p.number],
          ),
    ]..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  @override
  Future<void> openSettings() => FlutterContacts.permissions.openSettings();
}

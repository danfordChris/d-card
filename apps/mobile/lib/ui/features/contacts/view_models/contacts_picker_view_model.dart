import 'package:dcard_core/dcard_core.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/repositories/guests_repository.dart';
import '../../../../data/services/contacts_source.dart';
import '../../../../domain/models/app_failure.dart';

/// One number of a contact; invalid numbers are shown but cannot be picked.
class ContactNumber {
  ContactNumber(this.raw) : normalised = isValidPhone(raw) ? normalisePhone(raw) : null;

  final String raw;
  final String? normalised;

  bool get valid => normalised != null;
}

class ContactEntry {
  ContactEntry(PhoneContact contact)
    : id = contact.id,
      name = contact.name,
      numbers = [for (final p in contact.phones) ContactNumber(p)];

  final String id;
  final String name;
  final List<ContactNumber> numbers;
}

enum PickerState { requesting, denied, permanentlyDenied, loading, ready, done }

/// GST-6: pick guests from phone contacts, confirm consent (MSG-14), add in one request.
class ContactsPickerViewModel extends ChangeNotifier {
  ContactsPickerViewModel({required this.eventId, required this._contacts, required this._guests});

  final String eventId;
  final ContactsSource _contacts;
  final GuestsRepository _guests;

  PickerState state = PickerState.requesting;
  List<ContactEntry> _all = const [];
  String query = '';

  /// Selected number per contact id (one guest per contact).
  final Map<String, String> selected = {};
  bool consent = false;
  bool consentMissing = false;
  bool submitting = false;
  AppFailure? failure;
  BulkAddResult? result;

  List<ContactEntry> get visible {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return _all;
    final digits = q.replaceAll(RegExp(r'\D'), '');
    return [
      for (final c in _all)
        if (c.name.toLowerCase().contains(q) ||
            (digits.length >= 3 && c.numbers.any((n) => n.raw.replaceAll(RegExp(r'\D'), '').contains(digits))))
          c,
    ];
  }

  Future<void> open() async {
    state = PickerState.requesting;
    notifyListeners();
    final permission = await _contacts.requestPermission();
    if (permission != ContactsPermission.granted) {
      state = permission == ContactsPermission.permanentlyDenied ? PickerState.permanentlyDenied : PickerState.denied;
      notifyListeners();
      return;
    }
    state = PickerState.loading;
    notifyListeners();
    _all = [for (final c in await _contacts.loadContacts()) ContactEntry(c)];
    state = PickerState.ready;
    notifyListeners();
  }

  Future<void> openSettings() => _contacts.openSettings();

  void search(String value) {
    query = value;
    notifyListeners();
  }

  void toggle(ContactEntry contact, ContactNumber number) {
    if (!number.valid) return;
    if (selected[contact.id] == number.normalised) {
      selected.remove(contact.id);
    } else {
      selected[contact.id] = number.normalised!;
    }
    notifyListeners();
  }

  void setConsent(bool value) {
    consent = value;
    if (value) consentMissing = false;
    notifyListeners();
  }

  Future<void> submit() async {
    if (selected.isEmpty) return;
    if (!consent) {
      consentMissing = true;
      notifyListeners();
      return;
    }
    submitting = true;
    failure = null;
    notifyListeners();
    final byId = {for (final c in _all) c.id: c};
    try {
      result = await _guests.addFromContacts(eventId, [
        for (final MapEntry(key: id, value: phone) in selected.entries)
          (name: byId[id]!.name.isEmpty ? phone : byId[id]!.name, phone: phone),
      ]);
      state = PickerState.done;
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      submitting = false;
      notifyListeners();
    }
  }
}

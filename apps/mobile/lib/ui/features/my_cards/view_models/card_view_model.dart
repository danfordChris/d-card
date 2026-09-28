import 'package:flutter/foundation.dart';

import '../../../../data/repositories/my_cards_repository.dart';
import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/guest_card.dart';

/// One card by its link token: QR, details and RSVP (the same public endpoints as the card page).
class CardViewModel extends ChangeNotifier {
  CardViewModel({required this.token, required this._repository});

  final String token;
  final MyCardsRepository _repository;

  GuestCard? card;
  AppFailure? failure;
  bool loading = false;

  /// The answer being sent, if any.
  RsvpAnswer? answering;
  RsvpRefusal? rsvpRefusal;
  AppFailure? rsvpFailure;

  /// True once the guest changed their RSVP here (the list refreshes on return).
  bool changed = false;

  bool get canAnswer {
    final c = card;
    return c != null && c.status == CardStatus.issued && !c.eventCancelled && c.rsvp.open && answering == null;
  }

  Future<void> load() async {
    loading = true;
    failure = null;
    notifyListeners();
    try {
      card = await _repository.card(token);
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> answer(RsvpAnswer value) async {
    if (!canAnswer || value == RsvpAnswer.none) return;
    answering = value;
    rsvpRefusal = null;
    rsvpFailure = null;
    notifyListeners();
    try {
      final next = await _repository.rsvp(token, value);
      card = card!.withRsvp(next);
      changed = true;
    } on RsvpRefusedException catch (e) {
      rsvpRefusal = e.refusal;
      if (e.refusal == RsvpRefusal.closed) {
        final c = card!;
        card = c.withRsvp(RsvpState(answer: c.rsvp.answer, open: false, dietaryNotes: c.rsvp.dietaryNotes));
      }
    } on AppException catch (e) {
      rsvpFailure = e.failure;
    } catch (_) {
      rsvpFailure = AppFailure.unknown;
    } finally {
      answering = null;
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/my_cards_repository.dart';
import '../../../../domain/models/app_failure.dart';
import '../../../../domain/models/guest_card.dart';

/// "My cards": the signed-in guest's cards across events, and linking a card by its link.
class MyCardsViewModel extends ChangeNotifier {
  MyCardsViewModel(this._repository);

  final MyCardsRepository _repository;

  List<MyCard> cards = const [];
  AppFailure? failure;
  bool loading = false;
  bool loaded = false;

  bool linking = false;
  LinkRefusal? linkRefusal;
  AppFailure? linkFailure;

  MyCardsRepository get repository => _repository;

  Future<void> load() async {
    loading = true;
    failure = null;
    notifyListeners();
    try {
      cards = await _repository.list();
      loaded = true;
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void clearLinkError() {
    if (linkRefusal == null && linkFailure == null) return;
    linkRefusal = null;
    linkFailure = null;
    notifyListeners();
  }

  /// Links a pasted card link or token; true when linked (the list is then reloaded).
  Future<bool> link(String input) async {
    linkRefusal = null;
    linkFailure = null;
    final token = parseCardToken(input);
    if (token == null) {
      linkRefusal = LinkRefusal.invalidLink;
      notifyListeners();
      return false;
    }
    linking = true;
    notifyListeners();
    try {
      await _repository.link(token);
    } on LinkRefusedException catch (e) {
      linkRefusal = e.refusal;
      return false;
    } on AppException catch (e) {
      linkFailure = e.failure;
      return false;
    } catch (_) {
      linkFailure = AppFailure.unknown;
      return false;
    } finally {
      linking = false;
      notifyListeners();
    }
    await load();
    return true;
  }
}

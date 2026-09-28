import 'package:flutter/foundation.dart';

import '../../../../data/repositories/account_repository.dart';
import '../../../../data/repositories/session_repository.dart';
import '../../../../domain/models/app_failure.dart';

/// Account screen: who is signed in, "Download my data", "Delete my account", sign out.
class AccountViewModel extends ChangeNotifier {
  AccountViewModel({required this._session, required this._account});

  final SessionRepository _session;
  final AccountRepository _account;

  String? get email => _session.user?.email;
  String get provider => _session.user?.provider ?? 'password';

  bool exporting = false;
  String? exportedPath;
  AppFailure? exportFailure;

  bool deleting = false;

  /// The user still hosts events, so the account cannot be deleted yet.
  bool deleteBlocked = false;
  AppFailure? deleteFailure;

  Future<void> exportData() async {
    if (exporting) return;
    exporting = true;
    exportedPath = null;
    exportFailure = null;
    notifyListeners();
    try {
      exportedPath = await _account.exportMyData();
    } on AppException catch (e) {
      exportFailure = e.failure;
    } catch (_) {
      exportFailure = AppFailure.unknown;
    } finally {
      exporting = false;
      notifyListeners();
    }
  }

  /// Deletes the account; on success the session ends and the app returns to sign-in.
  Future<bool> deleteAccount() async {
    if (deleting) return false;
    deleting = true;
    deleteBlocked = false;
    deleteFailure = null;
    notifyListeners();
    try {
      await _session.deleteAccount();
      return true;
    } on AccountDeletionBlockedException {
      deleteBlocked = true;
      return false;
    } on AppException catch (e) {
      deleteFailure = e.failure;
      return false;
    } catch (_) {
      deleteFailure = AppFailure.unknown;
      return false;
    } finally {
      deleting = false;
      notifyListeners();
    }
  }

  Future<void> signOut() => _session.signOut();
}

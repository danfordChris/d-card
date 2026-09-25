import 'package:flutter/foundation.dart';

import '../../../../data/repositories/session_repository.dart';
import '../../../../domain/models/app_failure.dart';

enum LoginFieldError { emailRequired, emailInvalid, passwordRequired }

final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Validates the sign-in form and signs in through [SessionRepository].
class LoginViewModel extends ChangeNotifier {
  LoginViewModel(this._session);

  final SessionRepository _session;

  LoginFieldError? emailError;
  LoginFieldError? passwordError;
  AppFailure? failure;
  bool busy = false;

  Future<void> signIn(String email, String password) async {
    emailError = email.trim().isEmpty
        ? LoginFieldError.emailRequired
        : (_email.hasMatch(email.trim()) ? null : LoginFieldError.emailInvalid);
    passwordError = password.isEmpty ? LoginFieldError.passwordRequired : null;
    failure = null;
    if (emailError != null || passwordError != null) {
      notifyListeners();
      return;
    }
    busy = true;
    notifyListeners();
    try {
      await _session.signIn(email: email, password: password);
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
}

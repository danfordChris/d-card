import '../../domain/models/app_failure.dart';
import '../../l10n/app_localizations.dart';

extension FailureText on AppLocalizations {
  String failure(AppFailure failure) => switch (failure) {
    AppFailure.invalidCredentials => errorInvalidCredentials,
    AppFailure.tooManyRequests => errorTooManyRequests,
    AppFailure.network => errorNetwork,
    AppFailure.unauthorized => errorUnauthorized,
    AppFailure.doorAccessDenied => errorDoorAccessDenied,
    AppFailure.doorPlanLimit => errorDoorPlanLimit,
    AppFailure.unknown => errorGeneric,
  };
}

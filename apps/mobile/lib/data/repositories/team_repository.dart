import 'package:dcard_api/api.dart';

import 'api_errors.dart';

class TeamRepository {
  TeamRepository(this._api);

  final DefaultApi _api;

  Future<Team> get(String eventId) async {
    return guardApi(() => _api.getTeam(eventId));
  }

  Future<InviteCreateResponse> createInvite(String eventId, {required TeamRole role, String? email}) async {
    return guardApi(
      () => _api.createInvite(eventId, inviteCreateInput: InviteCreateInput(role: role, email: email)),
    );
  }

  Future<void> removeMember(String eventId, {required String userId, required TeamRole role}) async {
    await guardApi(() => _api.removeMember(eventId, userId, role));
  }

  Future<void> revokeInvite(String eventId, {required String inviteId}) async {
    await guardApi(() => _api.revokeInvite(eventId, inviteId));
  }
}

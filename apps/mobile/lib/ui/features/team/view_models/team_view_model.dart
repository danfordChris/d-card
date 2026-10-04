import 'package:dcard_api/api.dart';
import 'package:flutter/foundation.dart';

import '../../../../data/repositories/team_repository.dart';
import '../../../../domain/models/app_failure.dart';

class TeamViewModel extends ChangeNotifier {
  TeamViewModel({required this.eventId, required this.repository});

  final String eventId;
  final TeamRepository repository;

  List<TeamMembersInner> members = const [];
  List<Invite> invites = const [];
  bool loading = false;
  AppFailure? failure;

  int get memberCount => members.length;
  int get inviteCount => invites.length;

  Future<void> load() async {
    loading = true;
    failure = null;
    notifyListeners();
    try {
      final team = await repository.get(eventId);
      members = team.members;
      invites = team.invites;
    } on AppException catch (e) {
      failure = e.failure;
    } catch (_) {
      failure = AppFailure.unknown;
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<InviteCreateResponse> createInvite({required TeamRole role, String? email}) async {
    final result = await repository.createInvite(eventId, role: role, email: email);
    invites = [...invites, result.invite];
    notifyListeners();
    return result;
  }

  Future<void> removeMember(TeamMembersInner member) async {
    await repository.removeMember(eventId, userId: member.userId, role: member.role);
    members = [for (final m in members) if (m.userId != member.userId) m];
    notifyListeners();
  }

  Future<void> revokeInvite(String inviteId) async {
    await repository.revokeInvite(eventId, inviteId: inviteId);
    invites = [for (final i in invites) if (i.id != inviteId) i];
    notifyListeners();
  }
}

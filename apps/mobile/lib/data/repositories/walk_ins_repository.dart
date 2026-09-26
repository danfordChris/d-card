import 'dart:convert';

import 'package:dcard_api/api.dart' as api;

import '../../domain/models/walk_in.dart';
import 'api_errors.dart';

/// Walk-in requests of an event for the host, committee (read-only) and walk-in approvers
/// (`GET /api/v1/events/{id}/walk-ins`, `POST .../walk-ins/{walkInId}/decision`).
class WalkInsRepository {
  WalkInsRepository(this._api);

  final api.DefaultApi _api;

  Future<List<WalkIn>> list(String eventId) async {
    final result = await guardApi(() => _api.listWalkIns(eventId));
    return result.walkIns.map(toWalkIn).toList();
  }

  /// Records [decision]. Throws [WalkInAlreadyDecided] when another approver answered first.
  Future<WalkIn> decide(String eventId, String walkInId, WalkInDecision decision) async {
    final input = api.WalkInDecisionInput(decision: _decisions[decision]!);
    final result = await guardApi(() async {
      try {
        return await _api.decideWalkIn(eventId, walkInId, walkInDecisionInput: input);
      } on api.ApiException catch (e) {
        final conflict = e.code == 409 ? _conflict(e.message) : null;
        if (conflict != null) throw WalkInAlreadyDecided(toWalkIn(conflict.walkIn));
        rethrow;
      }
    });
    return toWalkIn(result);
  }

  static api.WalkInConflict? _conflict(String? body) {
    if (body == null || body.isEmpty) return null;
    try {
      return api.WalkInConflict.fromJson(jsonDecode(body));
    } catch (_) {
      return null;
    }
  }

  static const _decisions = {
    WalkInDecision.approve: api.WalkInDecisionInputDecisionEnum.approve,
    WalkInDecision.refuse: api.WalkInDecisionInputDecisionEnum.refuse,
    WalkInDecision.accept: api.WalkInDecisionInputDecisionEnum.accept,
    WalkInDecision.flag: api.WalkInDecisionInputDecisionEnum.flag,
  };

  static WalkInStatus? statusFromWire(String? value) => switch (value) {
    'pending' => WalkInStatus.pending,
    'approved' => WalkInStatus.approved,
    'refused' => WalkInStatus.refused,
    'admitted_offline' => WalkInStatus.admittedOffline,
    'accepted' => WalkInStatus.accepted,
    'flagged' => WalkInStatus.flagged,
    _ => null,
  };

  static WalkIn toWalkIn(api.WalkIn w) => WalkIn(
    id: w.id,
    eventId: w.eventId,
    status: statusFromWire(w.status.value) ?? WalkInStatus.pending,
    description: w.description,
    admittedCount: w.admittedCount,
    offline: w.source_ == api.WalkInSource_Enum.offline,
    occurredAt: w.occurredAt,
    invitationId: w.invitationId,
    guestName: w.guestName,
    offlineReason: w.offlineReason,
    requestedBy: w.requestedBy,
    deviceName: w.deviceName,
    decidedBy: w.decidedBy,
    decidedAt: w.decidedAt,
  );
}

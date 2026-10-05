import 'package:dcard_api/api.dart';
import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../domain/models/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import '../view_models/team_view_model.dart';

class TeamScreen extends StatefulWidget {
  const TeamScreen({super.key, required this.viewModel});

  final TeamViewModel viewModel;

  @override
  State<TeamScreen> createState() => _TeamScreenState();
}

class _TeamScreenState extends State<TeamScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _invite() async {
    final l10n = AppLocalizations.of(context);
    final role = await _pickRole(l10n);
    if (role == null || !mounted) return;

    try {
      final result = await widget.viewModel.createInvite(role: role);
      if (!mounted) return;
      await Clipboard.setData(ClipboardData(text: result.link));
      if (mounted) {
        _snack(result.emailQueued ? l10n.teamInviteSentAndCopied : l10n.teamInviteLinkCopied);
      }
    } on AppException catch (e) {
      if (mounted) _snack(l10n.failure(e.failure));
    } catch (_) {
      if (mounted) _snack(l10n.errorGeneric);
    }
  }

  Future<TeamRole?> _pickRole(AppLocalizations l10n) {
    final c = context.dc;
    return showModalBottomSheet<TeamRole>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DcSpace.xxl, 0, DcSpace.xxl, DcSpace.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.teamPickRole, style: DcType.heading(22).copyWith(color: c.ink)),
              const SizedBox(height: DcSpace.lg),
              for (final role in TeamRole.values) ...[
                DcTile(
                  onTap: () => Navigator.of(context).pop(role),
                  child: Row(
                    children: [
                      DcIconDisc(icon: _roleIcon(role), background: c.tile),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_roleLabel(l10n, role), style: DcType.ui(15, weight: FontWeight.w600).copyWith(color: c.ink)),
                            Text(_roleDesc(l10n, role), style: DcType.ui(13).copyWith(color: c.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: DcSpace.sm),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmRemoveMember(TeamMembersInner member) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(l10n.teamRemoveMemberTitle, l10n.teamRemoveMemberBody(member.email ?? member.userId), l10n.teamRemoveAction);
    if (confirmed != true || !mounted) return;
    try {
      await widget.viewModel.removeMember(member);
      if (mounted) _snack(l10n.teamMemberRemoved);
    } on AppException catch (e) {
      if (mounted) _snack(l10n.failure(e.failure));
    } catch (_) {
      if (mounted) _snack(l10n.errorGeneric);
    }
  }

  Future<void> _confirmRevokeInvite(Invite invite) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(l10n.teamRevokeInviteTitle, l10n.teamRevokeInviteBody, l10n.teamRevokeAction);
    if (confirmed != true || !mounted) return;
    try {
      await widget.viewModel.revokeInvite(invite.id);
      if (mounted) _snack(l10n.teamInviteRevoked);
    } on AppException catch (e) {
      if (mounted) _snack(l10n.failure(e.failure));
    } catch (_) {
      if (mounted) _snack(l10n.errorGeneric);
    }
  }

  Future<bool?> _confirm(String title, String body, String action) {
    final c = context.dc;
    return showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DcSpace.xxl, 0, DcSpace.xxl, DcSpace.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: DcType.heading(22).copyWith(color: c.ink)),
              const SizedBox(height: DcSpace.sm),
              Text(body, style: DcType.ui(14).copyWith(color: c.muted)),
              const SizedBox(height: DcSpace.xxl),
              DcButton(variant: DcButtonVariant.danger, label: action, onPressed: () => Navigator.of(context).pop(true)),
              const SizedBox(height: DcSpace.sm),
              DcButton(
                variant: DcButtonVariant.tonal,
                label: AppLocalizations.of(context).cancel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: DcTopBar(title: l10n.teamTitle, backLabel: l10n.back),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          if (vm.loading && vm.memberCount == 0) return const DcStateView(kind: DcStateKind.loading);
          if (vm.failure != null && vm.memberCount == 0) {
            return DcStateView(
              kind: DcStateKind.error,
              title: l10n.failure(vm.failure!),
              actionLabel: l10n.retry,
              onAction: vm.load,
            );
          }
          final c = context.dc;
          return RefreshIndicator(
            onRefresh: vm.load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xxxl),
              children: [
                DcBento(
                  items: [
                    DcBentoItem(
                      DcTile(
                        variant: DcTileVariant.hero,
                        radius: DcRadius.hero,
                        padding: const EdgeInsets.all(DcSpace.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.teamMembers, style: DcType.ui(13).copyWith(color: c.heroMuted)),
                            const SizedBox(height: DcSpace.xs),
                            Text('${vm.memberCount}', style: DcType.number(32).copyWith(color: c.onHero)),
                          ],
                        ),
                      ),
                    ),
                    DcBentoItem(
                      DcStatTile(
                        variant: DcTileVariant.soft,
                        label: l10n.teamPendingInvites,
                        value: '${vm.inviteCount}',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: DcSpace.lg),
                DcButton(
                  label: l10n.teamInviteAction,
                  onPressed: _invite,
                ),
                if (vm.members.isNotEmpty) ...[
                  DcSectionHeader(title: l10n.teamMembersSection),
                  for (var i = 0; i < vm.members.length; i++)
                    DcListRow(
                      divider: i > 0,
                      title: vm.members[i].email ?? vm.members[i].userId,
                      subtitle: _roleLabel(l10n, vm.members[i].role),
                      trailing: IconButton(
                        icon: Icon(Icons.close, size: 18, color: c.muted),
                        onPressed: () => _confirmRemoveMember(vm.members[i]),
                      ),
                    ),
                ],
                if (vm.invites.isNotEmpty) ...[
                  DcSectionHeader(title: l10n.teamInvitesSection),
                  for (var i = 0; i < vm.invites.length; i++)
                    DcListRow(
                      divider: i > 0,
                      title: vm.invites[i].email ?? l10n.teamInviteLinkOnly,
                      subtitle: _roleLabel(l10n, vm.invites[i].role),
                      trailing: IconButton(
                        icon: Icon(Icons.close, size: 18, color: c.muted),
                        onPressed: () => _confirmRevokeInvite(vm.invites[i]),
                      ),
                    ),
                ],
                if (vm.members.isEmpty && vm.invites.isEmpty)
                  DcStateView(kind: DcStateKind.empty, message: l10n.teamEmpty),
              ],
            ),
          );
        },
      ),
    );
  }

  static String _roleLabel(AppLocalizations l10n, TeamRole role) => switch (role) {
    TeamRole.treasurer => l10n.roleTreasurer,
    TeamRole.committee => l10n.roleCommittee,
    TeamRole.doorStaff => l10n.roleDoorStaff,
    TeamRole.walkinApprover => l10n.roleWalkinApprover,
    _ => role.value,
  };

  static String _roleDesc(AppLocalizations l10n, TeamRole role) => switch (role) {
    TeamRole.treasurer => l10n.roleTreasurerDesc,
    TeamRole.committee => l10n.roleCommitteeDesc,
    TeamRole.doorStaff => l10n.roleDoorStaffDesc,
    TeamRole.walkinApprover => l10n.roleWalkinApproverDesc,
    _ => '',
  };

  static List<List<dynamic>> _roleIcon(TeamRole role) => switch (role) {
    TeamRole.treasurer => HugeIcons.strokeRoundedCoins01,
    TeamRole.committee => HugeIcons.strokeRoundedUserMultiple,
    TeamRole.doorStaff => HugeIcons.strokeRoundedDoor01,
    TeamRole.walkinApprover => HugeIcons.strokeRoundedUserCheck01,
    _ => HugeIcons.strokeRoundedUser,
  };
}

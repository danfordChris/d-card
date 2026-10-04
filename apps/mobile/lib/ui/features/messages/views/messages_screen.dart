import 'package:dcard_api/api.dart';
import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import '../view_models/messages_view_model.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key, required this.viewModel, this.isHost = false});

  final MessagesViewModel viewModel;
  final bool isHost;

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: DcTopBar(title: l10n.messagesTitle, backLabel: l10n.back),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          if (vm.loading) {
            return const DcStateView(kind: DcStateKind.loading);
          }
          if (vm.failure != null && vm.settings.isEmpty) {
            return DcStateView(
              kind: DcStateKind.error,
              title: l10n.failure(vm.failure!),
              actionLabel: l10n.retry,
              onAction: vm.load,
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xxxl),
            children: [
              _UsageTile(vm: vm),
              if (vm.failure != null)
                Padding(
                  padding: const EdgeInsets.only(top: DcSpace.md),
                  child: DcNoticeTile(tone: DcTone.danger, message: l10n.failure(vm.failure!)),
                ),
              DcSectionHeader(title: l10n.messagesSettingsSection),
              const SizedBox(height: DcSpace.xs),
              for (var i = 0; i < vm.settings.length; i++)
                _SettingRow(
                  setting: vm.settings[i],
                  canEdit: widget.isHost,
                  onToggle: widget.isHost ? () => vm.toggleSetting(i) : null,
                ),
              if (vm.logItems.isNotEmpty) ...[
                DcSectionHeader(title: l10n.messagesLogSection),
                const SizedBox(height: DcSpace.xs),
                for (final item in vm.logItems) _LogRow(item: item),
                if (vm.logHasMore)
                  Padding(
                    padding: const EdgeInsets.only(top: DcSpace.md),
                    child: vm.logLoading
                        ? const Center(child: CircularProgressIndicator.adaptive())
                        : Center(
                            child: DcButton(
                              label: l10n.messagesLoadMore,
                              variant: DcButtonVariant.tonal,
                              onPressed: vm.loadMoreLog,
                            ),
                          ),
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _UsageTile extends StatelessWidget {
  const _UsageTile({required this.vm});

  final MessagesViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final sent = vm.usage?.queuedOrSent ?? 0;
    return DcTile(
      variant: DcTileVariant.hero,
      radius: DcRadius.hero,
      padding: const EdgeInsets.all(DcSpace.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.messagesSent, style: DcType.ui(13).copyWith(color: c.heroMuted)),
          const SizedBox(height: 4),
          Text('$sent', style: DcType.heading(36).copyWith(color: c.onHero)),
          const SizedBox(height: 4),
          Text(l10n.messagesQueued, style: DcType.ui(13).copyWith(color: c.heroMuted)),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.setting, required this.canEdit, this.onToggle});

  final UpdateMessageSettingsRequestSettingsInner setting;
  final bool canEdit;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final label = _messageTypeLabel(l10n, setting.messageType.value);
    final channelLabel = _channelLabel(l10n, setting.channels.value);
    return DcTile(
      padding: const EdgeInsets.symmetric(horizontal: DcSpace.lg, vertical: DcSpace.md),
      child: Row(
        children: [
          DcIconDisc(
            icon: _messageTypeIcon(setting.messageType.value),
            background: setting.enabled ? c.soft : c.tile,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DcType.ui(14, weight: FontWeight.w600).copyWith(color: c.ink)),
                const SizedBox(height: 2),
                Text(channelLabel, style: DcType.ui(12).copyWith(color: c.muted)),
              ],
            ),
          ),
          Switch.adaptive(
            value: setting.enabled,
            onChanged: canEdit ? (_) => onToggle?.call() : null,
          ),
        ],
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.item});

  final MessageLogItemsInner item;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final name = item.guestName ?? item.toPhone ?? '—';
    final type = _messageTypeLabel(l10n, item.messageType?.value ?? '');
    final (tone, statusLabel) = _statusInfo(l10n, item.status);
    final channelIcon = item.channel == MessageLogItemsInnerChannelEnum.whatsapp
        ? HugeIcons.strokeRoundedWhatsapp
        : HugeIcons.strokeRoundedMessage01;
    return Container(
      decoration: BoxDecoration(border: Border(top: BorderSide(color: c.line))),
      padding: const EdgeInsets.symmetric(vertical: DcSpace.sm),
      child: Row(
        children: [
          HugeIcon(icon: channelIcon, size: 18, color: c.muted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: DcType.ui(14, weight: FontWeight.w600).copyWith(color: c.ink)),
                const SizedBox(height: 2),
                Text(type, style: DcType.ui(12).copyWith(color: c.muted)),
              ],
            ),
          ),
          DcBadge(tone: tone, label: statusLabel),
        ],
      ),
    );
  }
}

String _messageTypeLabel(AppLocalizations l10n, String value) => switch (value) {
      'contribution_request' => l10n.msgTypeContributionRequest,
      'thank_you' => l10n.msgTypeThankYou,
      'contribution_reminder' => l10n.msgTypeContributionReminder,
      'invitation_card' => l10n.msgTypeInvitationCard,
      'card_upgraded' => l10n.msgTypeCardUpgraded,
      'attendance_confirmation' => l10n.msgTypeAttendanceConfirmation,
      'event_reminder' => l10n.msgTypeEventReminder,
      'post_event_thanks' => l10n.msgTypePostEventThanks,
      _ => value,
    };

List<List<dynamic>> _messageTypeIcon(String value) => switch (value) {
      'invitation_card' => HugeIcons.strokeRoundedMail01,
      'contribution_request' => HugeIcons.strokeRoundedCoins01,
      'thank_you' => HugeIcons.strokeRoundedThumbsUp,
      'contribution_reminder' => HugeIcons.strokeRoundedAlarmClock,
      'card_upgraded' => HugeIcons.strokeRoundedArrowUpRight01,
      'attendance_confirmation' => HugeIcons.strokeRoundedCheckmarkCircle01,
      'event_reminder' => HugeIcons.strokeRoundedCalendar03,
      'post_event_thanks' => HugeIcons.strokeRoundedFavourite,
      _ => HugeIcons.strokeRoundedMessage01,
    };

String _channelLabel(AppLocalizations l10n, String value) => switch (value) {
      'sms' => l10n.channelSms,
      'whatsapp' => l10n.channelWhatsapp,
      'both' => l10n.channelBoth,
      _ => value,
    };

(DcTone, String) _statusInfo(AppLocalizations l10n, MessageLogItemsInnerStatusEnum status) =>
    switch (status) {
      MessageLogItemsInnerStatusEnum.queued => (DcTone.neutral, l10n.statusQueued),
      MessageLogItemsInnerStatusEnum.sent => (DcTone.neutral, l10n.statusSent),
      MessageLogItemsInnerStatusEnum.delivered => (DcTone.success, l10n.statusDelivered),
      MessageLogItemsInnerStatusEnum.read => (DcTone.success, l10n.statusRead),
      MessageLogItemsInnerStatusEnum.failed => (DcTone.danger, l10n.statusFailed),
      MessageLogItemsInnerStatusEnum.held => (DcTone.warning, l10n.statusHeld),
      _ => (DcTone.neutral, status.value),
    };

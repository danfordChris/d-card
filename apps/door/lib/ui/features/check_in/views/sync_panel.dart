import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/door_format.dart';
import '../view_models/check_in_view_model.dart';

/// Sync and offline status (offline-sync 9.4): online or offline, entries waiting to upload,
/// the last sync, what other gates see, and "try to sync now".
class SyncPanel extends StatelessWidget {
  const SyncPanel({super.key, required this.viewModel, required this.onClose});

  final CheckInViewModel viewModel;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final vm = viewModel;
    final offline = vm.isOffline;
    final last = vm.lastSyncAt;
    return Column(
      key: const Key('sync.panel'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DcTopBar(title: l10n.syncTitle, onBack: onClose, backLabel: l10n.back),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xl),
            children: [
              DcBento(
                items: [
                  DcBentoItem(
                    span: 2,
                    DcNoticeTile(
                      key: const Key('sync.status'),
                      tone: offline ? DcTone.warning : DcTone.success,
                      icon: offline ? HugeIcons.strokeRoundedWifiDisconnected02 : HugeIcons.strokeRoundedCloudSavingDone01,
                      title: offline ? l10n.offlineBadge : l10n.onlineBadge,
                      message: [
                        offline ? l10n.syncOfflineBody : l10n.syncOnlineBody,
                        if (offline && !vm.offlineReady) l10n.offlineUnavailable,
                      ].join(' '),
                    ),
                  ),
                  DcBentoItem(DcStatTile(label: l10n.syncPendingLabel, value: '${vm.pendingCount}')),
                  DcBentoItem(
                    DcStatTile(
                      label: l10n.syncLastLabel,
                      value: last == null ? l10n.syncNever : formatTime(context, last),
                    ),
                  ),
                  DcBentoItem(
                    span: 2,
                    DcTile(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.syncOtherGatesTitle, style: DcType.ui(14, weight: FontWeight.w700).copyWith(color: c.ink)),
                          const SizedBox(height: DcSpace.xs),
                          Text(l10n.syncOtherGatesBody, style: DcType.ui(13).copyWith(color: c.muted)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DcSpace.md),
              DcButton(
                key: const Key('sync.tryNow'),
                label: l10n.syncTryNow,
                icon: HugeIcons.strokeRoundedRefresh,
                loading: vm.syncing,
                onPressed: vm.syncNow,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

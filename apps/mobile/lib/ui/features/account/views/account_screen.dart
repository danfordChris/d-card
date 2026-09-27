import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import '../../billing/views/billing_widgets.dart';
import '../view_models/account_view_model.dart';

/// Account: sign-in method, "Download my data", "Delete my account", sign out.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.viewModel});

  final AccountViewModel viewModel;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        final scheme = Theme.of(context).colorScheme;
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.deleteAccountConfirmTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(l10n.deleteAccountConfirmBody),
              const SizedBox(height: 24),
              FilledButton(
                key: const Key('account.deleteConfirm'),
                style: FilledButton.styleFrom(backgroundColor: scheme.error, foregroundColor: scheme.onError),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.deleteAccountConfirm),
              ),
              const SizedBox(height: 8),
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l10n.cancel)),
            ],
          ),
        );
      },
    );
    if (confirmed == true) await viewModel.deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.accountTitle)),
      body: ListenableBuilder(
        listenable: viewModel,
        builder: (context, _) {
          final vm = viewModel;
          final method = switch (vm.provider) {
            'google' => 'Google',
            'apple' => 'Apple',
            _ => l10n.accountMethodPassword,
          };
          final muted = theme.textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FlatCard(
                child: Row(
                  children: [
                    const IconDisc(icon: HugeIcons.strokeRoundedUserCircle),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (vm.email != null) Text(vm.email!, style: theme.textTheme.titleMedium),
                          Text(l10n.accountSignedInWith(method), style: muted),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(l10n.accountYourData, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              ListTile(
                key: const Key('account.export'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: const HugeIcon(icon: HugeIcons.strokeRoundedDownload04),
                title: Text(l10n.downloadMyData),
                subtitle: Text(l10n.downloadMyDataHint),
                trailing: vm.exporting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
                onTap: vm.exporting ? null : vm.exportData,
              ),
              if (vm.exportedPath != null)
                Notice(key: const Key('account.exported'), text: l10n.downloadMyDataSaved(vm.exportedPath!)),
              if (vm.exportFailure != null) Notice(text: l10n.failure(vm.exportFailure!), error: true),
              ListTile(
                key: const Key('account.delete'),
                contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                leading: HugeIcon(icon: HugeIcons.strokeRoundedDelete02, color: scheme.error),
                title: Text(l10n.deleteMyAccount, style: TextStyle(color: scheme.error)),
                subtitle: Text(l10n.deleteMyAccountHint),
                trailing: vm.deleting
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : null,
                onTap: vm.deleting ? null : () => _confirmDelete(context),
              ),
              if (vm.deleteBlocked)
                Notice(key: const Key('account.deleteBlocked'), text: l10n.deleteAccountBlocked, error: true),
              if (vm.deleteFailure != null) Notice(text: l10n.failure(vm.deleteFailure!), error: true),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                key: const Key('account.signOut'),
                onPressed: vm.signOut,
                icon: const HugeIcon(icon: HugeIcons.strokeRoundedLogout01, size: 20),
                label: Text(l10n.signOut),
              ),
            ],
          );
        },
      ),
    );
  }
}

import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../data/repositories/theme_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import '../view_models/account_view_model.dart';

/// Account: sign-in method, theme (Light / Dark / System), "Download my data",
/// "Delete my account", sign out.
class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key, required this.viewModel, required this.theme});

  final AccountViewModel viewModel;
  final ThemeRepository theme;

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final l10n = AppLocalizations.of(context);
        final c = context.dc;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(DcSpace.xxl, 0, DcSpace.xxl, DcSpace.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.deleteAccountConfirmTitle, style: DcType.heading(22).copyWith(color: c.ink)),
                const SizedBox(height: DcSpace.sm),
                Text(l10n.deleteAccountConfirmBody, style: DcType.ui(14).copyWith(color: c.muted)),
                const SizedBox(height: DcSpace.xxl),
                DcButton(
                  key: const Key('account.deleteConfirm'),
                  variant: DcButtonVariant.danger,
                  label: l10n.deleteAccountConfirm,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
                const SizedBox(height: DcSpace.sm),
                DcButton(
                  variant: DcButtonVariant.tonal,
                  label: l10n.cancel,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (confirmed == true) await viewModel.deleteAccount();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: Listenable.merge([viewModel, theme]),
          builder: (context, _) {
            final vm = viewModel;
            final method = switch (vm.provider) {
              'google' => 'Google',
              'apple' => 'Apple',
              _ => l10n.accountMethodPassword,
            };
            Widget spinner() =>
                SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2, color: c.primary));
            return ListView(
              padding: const EdgeInsets.only(bottom: DcSpotlightNavBar.reservedHeight),
              children: [
                DcPageHeader(title: l10n.accountTitle),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: DcSpace.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: DcSpace.sm),
                      DcTile(
                        child: Row(
                          children: [
                            DcIconDisc(icon: HugeIcons.strokeRoundedUser, size: 48, background: c.bg),
                            const SizedBox(width: DcSpace.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (vm.email != null)
                                    Text(vm.email!, style: DcType.heading(18).copyWith(color: c.ink)),
                                  Text(l10n.accountSignedInWith(method), style: DcType.ui(13).copyWith(color: c.muted)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      DcSectionHeader(title: l10n.themeTitle),
                      const SizedBox(height: DcSpace.sm),
                      DcSegmented<ThemeMode>(
                        key: const Key('account.theme'),
                        selected: theme.mode,
                        onChanged: theme.setMode,
                        segments: [
                          DcSegment(value: ThemeMode.light, label: l10n.themeLight, icon: HugeIcons.strokeRoundedSun03),
                          DcSegment(value: ThemeMode.dark, label: l10n.themeDark, icon: HugeIcons.strokeRoundedMoon02),
                          DcSegment(
                            value: ThemeMode.system,
                            label: l10n.themeSystem,
                            icon: HugeIcons.strokeRoundedSmartPhone01,
                          ),
                        ],
                      ),
                      DcSectionHeader(title: l10n.accountYourData),
                      DcListRow(
                        key: const Key('account.export'),
                        divider: false,
                        leading: const DcIconDisc(icon: HugeIcons.strokeRoundedDownload04),
                        title: l10n.downloadMyData,
                        subtitle: l10n.downloadMyDataHint,
                        trailing: vm.exporting ? spinner() : null,
                        onTap: vm.exporting ? null : vm.exportData,
                      ),
                      if (vm.exportedPath != null)
                        DcNoticeTile(
                          key: const Key('account.exported'),
                          tone: DcTone.success,
                          message: l10n.downloadMyDataSaved(vm.exportedPath!),
                        ),
                      if (vm.exportFailure != null)
                        DcNoticeTile(tone: DcTone.danger, message: l10n.failure(vm.exportFailure!)),
                      DcListRow(
                        key: const Key('account.delete'),
                        leading: DcIconDisc(
                          icon: HugeIcons.strokeRoundedDelete02,
                          background: c.dangerBg,
                          foreground: c.dangerFg,
                        ),
                        title: l10n.deleteMyAccount,
                        titleStyle: DcType.ui(15, weight: FontWeight.w700).copyWith(color: c.dangerFg),
                        subtitle: l10n.deleteMyAccountHint,
                        trailing: vm.deleting ? spinner() : null,
                        onTap: vm.deleting ? null : () => _confirmDelete(context),
                      ),
                      if (vm.deleteBlocked)
                        DcNoticeTile(
                          key: const Key('account.deleteBlocked'),
                          tone: DcTone.danger,
                          message: l10n.deleteAccountBlocked,
                        ),
                      if (vm.deleteFailure != null)
                        DcNoticeTile(tone: DcTone.danger, message: l10n.failure(vm.deleteFailure!)),
                      const SizedBox(height: DcSpace.xxl),
                      DcButton(
                        key: const Key('account.signOut'),
                        variant: DcButtonVariant.tonal,
                        icon: HugeIcons.strokeRoundedLogout01,
                        label: l10n.signOut,
                        onPressed: vm.signOut,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

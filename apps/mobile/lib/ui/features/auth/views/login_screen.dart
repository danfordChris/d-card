import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../data/services/auth_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import '../view_models/login_view_model.dart';

/// Sign-in: Google/Apple for guests (Apple on iOS only, AUTH-3), email and password for hosts.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.viewModel, this.showApple});

  final LoginViewModel viewModel;

  /// Overrides the platform check (tests); by default Apple shows on iOS only.
  final bool? showApple;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() => widget.viewModel.signIn(_email.text, _password.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.xl, DcSpace.page, DcSpace.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) {
                  final vm = widget.viewModel;
                  final showApple = widget.showApple ?? (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      DcTile(
                        variant: DcTileVariant.hero,
                        radius: DcRadius.hero,
                        padding: const EdgeInsets.all(DcSpace.xl),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                DcIconDisc(
                                  icon: HugeIcons.strokeRoundedTicket01,
                                  background: c.onHero,
                                  foreground: c.hero,
                                ),
                                const SizedBox(width: DcSpace.md),
                                Text(l10n.appTitle, style: DcType.heading(22).copyWith(color: c.onHero)),
                              ],
                            ),
                            const SizedBox(height: DcSpace.xl),
                            Text(l10n.loginEyebrow.toUpperCase(), style: DcType.eyebrow().copyWith(color: c.heroMuted)),
                            const SizedBox(height: 6),
                            Text(l10n.loginTagline, style: DcType.heading(24).copyWith(color: c.onHero)),
                          ],
                        ),
                      ),
                      const SizedBox(height: DcSpace.xxl),
                      Text(l10n.loginTitle, style: DcType.heading(28).copyWith(color: c.ink)),
                      const SizedBox(height: DcSpace.xs),
                      Text(l10n.loginSubtitle, style: DcType.ui(14).copyWith(color: c.muted)),
                      const SizedBox(height: DcSpace.xl),
                      if (vm.failure != null) ...[
                        DcNoticeTile(tone: DcTone.danger, message: l10n.failure(vm.failure!)),
                        const SizedBox(height: DcSpace.lg),
                      ],
                      Text(l10n.loginGuestHint, style: DcType.ui(14).copyWith(color: c.muted)),
                      const SizedBox(height: DcSpace.md),
                      DcButton(
                        key: const Key('login.google'),
                        variant: DcButtonVariant.tonal,
                        icon: HugeIcons.strokeRoundedGoogle,
                        label: l10n.continueWithGoogle,
                        loading: vm.socialBusy == SocialProvider.google,
                        onPressed: vm.anyBusy ? null : () => vm.signInWith(SocialProvider.google),
                      ),
                      if (showApple) ...[
                        const SizedBox(height: DcSpace.sm),
                        DcButton(
                          key: const Key('login.apple'),
                          variant: DcButtonVariant.tonal,
                          icon: HugeIcons.strokeRoundedApple,
                          label: l10n.continueWithApple,
                          loading: vm.socialBusy == SocialProvider.apple,
                          onPressed: vm.anyBusy ? null : () => vm.signInWith(SocialProvider.apple),
                        ),
                      ],
                      const SizedBox(height: DcSpace.xxl),
                      Row(
                        children: [
                          Expanded(child: Divider(color: c.line)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: DcSpace.md),
                            child: Text(l10n.loginOr, style: DcType.ui(13).copyWith(color: c.muted)),
                          ),
                          Expanded(child: Divider(color: c.line)),
                        ],
                      ),
                      const SizedBox(height: DcSpace.lg),
                      Text(l10n.loginHostHint, style: DcType.ui(15, weight: FontWeight.w700).copyWith(color: c.ink)),
                      const SizedBox(height: DcSpace.md),
                      DcField(
                        key: const Key('login.email'),
                        controller: _email,
                        label: l10n.emailLabel,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        prefixIcon: HugeIcons.strokeRoundedMail01,
                        errorText: switch (vm.emailError) {
                          LoginFieldError.emailRequired => l10n.errorEmailRequired,
                          LoginFieldError.emailInvalid => l10n.errorEmailInvalid,
                          _ => null,
                        },
                      ),
                      const SizedBox(height: DcSpace.lg),
                      DcField(
                        key: const Key('login.password'),
                        controller: _password,
                        label: l10n.passwordLabel,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        prefixIcon: HugeIcons.strokeRoundedLockPassword,
                        onSubmitted: (_) => _submit(),
                        errorText: vm.passwordError == null ? null : l10n.errorPasswordRequired,
                      ),
                      const SizedBox(height: DcSpace.xxl),
                      DcButton(
                        key: const Key('login.submit'),
                        label: l10n.signIn,
                        loading: vm.busy,
                        onPressed: vm.anyBusy ? null : _submit,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

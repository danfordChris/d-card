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
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                      BrandHeader(title: l10n.loginTitle, subtitle: l10n.loginSubtitle),
                      const SizedBox(height: 32),
                      if (vm.failure != null) ...[
                        Card(
                          color: Theme.of(context).colorScheme.errorContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              l10n.failure(vm.failure!),
                              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      Text(l10n.loginGuestHint, style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 12),
                      _SocialButton(
                        key: const Key('login.google'),
                        icon: HugeIcons.strokeRoundedGoogle,
                        label: l10n.continueWithGoogle,
                        busy: vm.socialBusy == SocialProvider.google,
                        onPressed: vm.anyBusy ? null : () => vm.signInWith(SocialProvider.google),
                      ),
                      if (showApple) ...[
                        const SizedBox(height: 12),
                        _SocialButton(
                          key: const Key('login.apple'),
                          icon: HugeIcons.strokeRoundedApple,
                          label: l10n.continueWithApple,
                          busy: vm.socialBusy == SocialProvider.apple,
                          onPressed: vm.anyBusy ? null : () => vm.signInWith(SocialProvider.apple),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(l10n.loginOr, style: Theme.of(context).textTheme.bodySmall),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.loginHostHint, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 12),
                      TextField(
                        key: const Key('login.email'),
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          labelText: l10n.emailLabel,
                          errorText: switch (vm.emailError) {
                            LoginFieldError.emailRequired => l10n.errorEmailRequired,
                            LoginFieldError.emailInvalid => l10n.errorEmailInvalid,
                            _ => null,
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('login.password'),
                        controller: _password,
                        obscureText: true,
                        autofillHints: const [AutofillHints.password],
                        onSubmitted: (_) => _submit(),
                        decoration: InputDecoration(
                          labelText: l10n.passwordLabel,
                          errorText: vm.passwordError == null ? null : l10n.errorPasswordRequired,
                        ),
                      ),
                      const SizedBox(height: 24),
                      FilledButton(
                        key: const Key('login.submit'),
                        onPressed: vm.anyBusy ? null : _submit,
                        child: vm.busy
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(l10n.signIn),
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

class _SocialButton extends StatelessWidget {
  const _SocialButton({super.key, required this.icon, required this.label, required this.busy, this.onPressed});

  final List<List<dynamic>> icon;
  final String label;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onPressed,
    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
    icon: busy
        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
        : HugeIcon(icon: icon, size: 20),
    label: Text(label),
  );
}

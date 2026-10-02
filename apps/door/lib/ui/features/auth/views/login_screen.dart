import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/door_field.dart';
import '../../../core/failure_text.dart';
import '../../../core/message_card.dart';
import '../view_models/login_view_model.dart';

/// Sign in: brand row, a hero tile with what the app is for, then email and password.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.viewModel});

  final LoginViewModel viewModel;

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
            padding: const EdgeInsets.fromLTRB(DcSpace.page, 28, DcSpace.page, DcSpace.xxl),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: ListenableBuilder(
                listenable: widget.viewModel,
                builder: (context, _) {
                  final vm = widget.viewModel;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(12)),
                            child: ExcludeSemantics(child: Text('D', style: DcType.heading(20, weight: FontWeight.w800).copyWith(color: c.onPrimary))),
                          ),
                          const SizedBox(width: DcSpace.gap),
                          Text(l10n.loginTitle, style: DcType.heading(22).copyWith(color: c.ink)),
                        ],
                      ),
                      const SizedBox(height: DcSpace.lg),
                      DcTile(
                        variant: DcTileVariant.hero,
                        padding: const EdgeInsets.all(22),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.loginSubtitle, style: DcType.heading(30).copyWith(color: c.onHero)),
                            const SizedBox(height: DcSpace.sm),
                            Text(l10n.loginHint, style: DcType.ui(13).copyWith(color: c.heroMuted)),
                          ],
                        ),
                      ),
                      const SizedBox(height: DcSpace.lg),
                      if (vm.failure != null) ...[
                        MessageCard(text: l10n.failure(vm.failure!)),
                        const SizedBox(height: DcSpace.lg),
                      ],
                      AutofillGroup(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DoorField(
                              key: const Key('login.email'),
                              label: l10n.emailLabel,
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              textInputAction: TextInputAction.next,
                              errorText: switch (vm.emailError) {
                                LoginFieldError.emailRequired => l10n.errorEmailRequired,
                                LoginFieldError.emailInvalid => l10n.errorEmailInvalid,
                                _ => null,
                              },
                            ),
                            const SizedBox(height: DcSpace.lg),
                            DoorField(
                              key: const Key('login.password'),
                              label: l10n.passwordLabel,
                              controller: _password,
                              obscureText: true,
                              autofillHints: const [AutofillHints.password],
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _submit(),
                              errorText: vm.passwordError == null ? null : l10n.errorPasswordRequired,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DcSpace.xxl),
                      DcButton(
                        key: const Key('login.submit'),
                        label: l10n.signIn,
                        loading: vm.busy,
                        onPressed: _submit,
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

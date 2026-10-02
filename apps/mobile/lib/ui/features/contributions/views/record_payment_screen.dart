import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/contributor.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import '../view_models/record_payment_view_model.dart';
import '../../../core/money.dart';

class RecordPaymentScreen extends StatefulWidget {
  const RecordPaymentScreen({super.key, required this.viewModel});

  final RecordPaymentViewModel viewModel;

  @override
  State<RecordPaymentScreen> createState() => _RecordPaymentScreenState();
}

class _RecordPaymentScreenState extends State<RecordPaymentScreen> {
  final _amount = TextEditingController();
  final _reference = TextEditingController();
  bool _saved = false;

  @override
  void dispose() {
    _amount.dispose();
    _reference.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (await widget.viewModel.submit(_amount.text, _reference.text)) {
      _amount.clear();
      _reference.clear();
      setState(() => _saved = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return PopScope<Contributor>(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(_saved ? widget.viewModel.contributor : null);
      },
      child: Scaffold(
        appBar: DcTopBar(title: l10n.recordPaymentTitle, backLabel: l10n.back),
        body: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final vm = widget.viewModel;
            final c = vm.contributor;
            final colors = context.dc;
            return ListView(
              padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xxxl),
              children: [
                DcTile(
                  variant: DcTileVariant.hero,
                  radius: DcRadius.hero,
                  padding: const EdgeInsets.all(DcSpace.xl),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: DcType.heading(26).copyWith(color: colors.onHero)),
                      const SizedBox(height: DcSpace.sm),
                      Text(l10n.paidOf(tsh(c.paid), tsh(c.pledged)), style: DcType.ui(14).copyWith(color: colors.heroMuted)),
                      const SizedBox(height: DcSpace.xs),
                      Text(
                        l10n.balanceShort(tsh(c.balance)),
                        key: const Key('payment.balance'),
                        style: DcType.number(22).copyWith(color: colors.onHero),
                      ),
                      if (c.extra > 0)
                        Text(l10n.extraShort(tsh(c.extra)), style: DcType.ui(13).copyWith(color: colors.heroMuted)),
                    ],
                  ),
                ),
                const SizedBox(height: DcSpace.lg),
                if (_saved && vm.issuedNow == true)
                  _Banner(child: DcNoticeTile(tone: DcTone.success, message: l10n.cardIssuedNow(c.cardNumber ?? '')))
                else if (_saved)
                  _Banner(child: DcNoticeTile(tone: DcTone.success, message: l10n.paymentSaved)),
                if (vm.failure != null) _Banner(child: DcNoticeTile(tone: DcTone.danger, message: l10n.failure(vm.failure!))),
                DcField(
                  key: const Key('payment.amount'),
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  label: l10n.amountLabel,
                  errorText: switch (vm.amountError) {
                    AmountError.required => l10n.errorAmountRequired,
                    AmountError.invalid => l10n.errorAmountInvalid,
                    null => null,
                  },
                ),
                const SizedBox(height: DcSpace.lg),
                Text(l10n.methodLabel, style: DcType.ui(13, weight: FontWeight.w600).copyWith(color: colors.ink)),
                const SizedBox(height: 6),
                DropdownButtonFormField<PaymentMethod>(
                  key: const Key('payment.method'),
                  initialValue: vm.method,
                  icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01, size: 20, color: colors.muted),
                  borderRadius: BorderRadius.circular(DcRadius.input),
                  dropdownColor: colors.bg,
                  items: [
                    for (final m in PaymentMethod.values)
                      DropdownMenuItem(value: m, child: Text(_methodLabel(l10n, m))),
                  ],
                  onChanged: (m) => vm.setMethod(m ?? PaymentMethod.mpesa),
                ),
                const SizedBox(height: DcSpace.lg),
                DcField(key: const Key('payment.reference'), controller: _reference, label: l10n.referenceLabel),
                const SizedBox(height: DcSpace.lg),
                DcTile(
                  padding: const EdgeInsets.symmetric(horizontal: DcSpace.lg, vertical: DcSpace.md),
                  radius: DcRadius.input,
                  semanticLabel: l10n.paidOnLabel,
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: vm.paidOn,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (picked != null) vm.setDate(picked);
                  },
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.paidOnLabel, style: DcType.ui(13).copyWith(color: colors.muted)),
                            Text(
                              DateFormat.yMMMd(locale).format(vm.paidOn),
                              style: DcType.ui(15, weight: FontWeight.w600).copyWith(color: colors.ink),
                            ),
                          ],
                        ),
                      ),
                      HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, size: 22, color: colors.primary),
                    ],
                  ),
                ),
                const SizedBox(height: DcSpace.xxl),
                DcButton(label: l10n.recordPaymentButton, loading: vm.busy, onPressed: _submit),
              ],
            );
          },
        ),
      ),
    );
  }

  static String _methodLabel(AppLocalizations l10n, PaymentMethod m) => switch (m) {
    PaymentMethod.mpesa => 'M-Pesa',
    PaymentMethod.mixxByYas => 'Mixx by Yas',
    PaymentMethod.airtelMoney => 'Airtel Money',
    PaymentMethod.halopesa => 'HaloPesa',
    PaymentMethod.bank => l10n.methodBank,
    PaymentMethod.cash => l10n.methodCash,
    PaymentMethod.other => l10n.methodOther,
  };
}

class _Banner extends StatelessWidget {
  const _Banner({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: DcSpace.md), child: child);
}

import 'package:flutter/material.dart';
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
        appBar: AppBar(title: Text(l10n.recordPaymentTitle)),
        body: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final vm = widget.viewModel;
            final c = vm.contributor;
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(c.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(l10n.paidOf(tsh(c.paid), tsh(c.pledged))),
                Text(l10n.balanceShort(tsh(c.balance)), key: const Key('payment.balance')),
                if (c.extra > 0) Text(l10n.extraShort(tsh(c.extra))),
                const SizedBox(height: 16),
                if (_saved && vm.issuedNow == true)
                  _Banner(
                    text: l10n.cardIssuedNow(c.cardNumber ?? ''),
                    color: Theme.of(context).colorScheme.primaryContainer,
                  )
                else if (_saved)
                  _Banner(text: l10n.paymentSaved, color: Theme.of(context).colorScheme.secondaryContainer),
                if (vm.failure != null)
                  _Banner(text: l10n.failure(vm.failure!), color: Theme.of(context).colorScheme.errorContainer),
                TextField(
                  key: const Key('payment.amount'),
                  controller: _amount,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.amountLabel,
                    errorText: switch (vm.amountError) {
                      AmountError.required => l10n.errorAmountRequired,
                      AmountError.invalid => l10n.errorAmountInvalid,
                      null => null,
                    },
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<PaymentMethod>(
                  key: const Key('payment.method'),
                  initialValue: vm.method,
                  decoration: InputDecoration(labelText: l10n.methodLabel),
                  items: [
                    for (final m in PaymentMethod.values)
                      DropdownMenuItem(value: m, child: Text(_methodLabel(l10n, m))),
                  ],
                  onChanged: (m) => vm.setMethod(m ?? PaymentMethod.mpesa),
                ),
                const SizedBox(height: 12),
                TextField(
                  key: const Key('payment.reference'),
                  controller: _reference,
                  decoration: InputDecoration(labelText: l10n.referenceLabel),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.paidOnLabel),
                  subtitle: Text(DateFormat.yMMMd(locale).format(vm.paidOn)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: vm.paidOn,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now().add(const Duration(days: 1)),
                    );
                    if (picked != null) vm.setDate(picked);
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: vm.busy ? null : _submit, child: Text(l10n.recordPaymentButton)),
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
  const _Banner({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(text),
    ),
  );
}

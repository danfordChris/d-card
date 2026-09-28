import 'package:dcard_core/dcard_core.dart';
import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import '../view_models/contacts_picker_view_model.dart';

class ContactsPickerScreen extends StatefulWidget {
  const ContactsPickerScreen({super.key, required this.viewModel});

  final ContactsPickerViewModel viewModel;

  @override
  State<ContactsPickerScreen> createState() => _ContactsPickerScreenState();
}

class _ContactsPickerScreenState extends State<ContactsPickerScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.open();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.contactsTitle)),
          body: switch (vm.state) {
            PickerState.requesting || PickerState.loading => const Center(child: CircularProgressIndicator()),
            PickerState.denied || PickerState.permanentlyDenied => _PermissionDenied(viewModel: vm),
            PickerState.ready => _Picker(viewModel: vm),
            PickerState.done => _Done(viewModel: vm),
          },
          bottomNavigationBar: vm.state == PickerState.ready ? _SubmitBar(viewModel: vm) : null,
        );
      },
    );
  }
}

class _PermissionDenied extends StatelessWidget {
  const _PermissionDenied({required this.viewModel});

  final ContactsPickerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.contacts_outlined, size: 48),
            const SizedBox(height: 16),
            Text(
              l10n.contactsPermissionTitle,
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(l10n.contactsPermissionBody, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton(onPressed: viewModel.openSettings, child: Text(l10n.contactsOpenSettings)),
            if (viewModel.state == PickerState.denied) TextButton(onPressed: viewModel.open, child: Text(l10n.retry)),
          ],
        ),
      ),
    );
  }
}

class _Picker extends StatelessWidget {
  const _Picker({required this.viewModel});

  final ContactsPickerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contacts = viewModel.visible;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            key: const Key('contacts.search'),
            onChanged: viewModel.search,
            decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: l10n.contactsSearch),
          ),
        ),
        Expanded(
          child: contacts.isEmpty
              ? Center(child: Text(l10n.contactsEmpty))
              : ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, i) => _ContactTile(viewModel: viewModel, contact: contacts[i]),
                ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.viewModel, required this.contact});

  final ContactsPickerViewModel viewModel;
  final ContactEntry contact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(
            contact.name.isEmpty ? l10n.contactsNoName : contact.name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ),
        for (final n in contact.numbers)
          CheckboxListTile(
            dense: true,
            value: n.valid && viewModel.selected[contact.id] == n.normalised,
            onChanged: n.valid ? (_) => viewModel.toggle(contact, n) : null,
            title: Text(n.valid ? formatLocalPhone(n.normalised!) : n.raw),
            subtitle: n.valid ? null : Text(l10n.contactsInvalidNumber, style: TextStyle(color: scheme.error)),
          ),
      ],
    );
  }
}

class _SubmitBar extends StatelessWidget {
  const _SubmitBar({required this.viewModel});

  final ContactsPickerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final vm = viewModel;
    return SafeArea(
      child: Material(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (vm.failure != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                  child: Text(l10n.failure(vm.failure!), style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              CheckboxListTile(
                key: const Key('contacts.consent'),
                controlAffinity: ListTileControlAffinity.leading,
                value: vm.consent,
                onChanged: (v) => vm.setConsent(v ?? false),
                title: Text(l10n.contactsConsent),
                subtitle: vm.consentMissing
                    ? Text(l10n.contactsConsentRequired, style: TextStyle(color: Theme.of(context).colorScheme.error))
                    : null,
              ),
              FilledButton(
                onPressed: vm.selected.isEmpty || vm.submitting ? null : vm.submit,
                child: Text(l10n.contactsAdd(vm.selected.length)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Done extends StatelessWidget {
  const _Done({required this.viewModel});

  final ContactsPickerViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final r = viewModel.result!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline, size: 48, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text(l10n.contactsAdded(r.added), style: Theme.of(context).textTheme.titleMedium),
            if (r.existing > 0) Text(l10n.contactsExisting(r.existing)),
            if (r.invalid > 0) Text(l10n.contactsInvalid(r.invalid)),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => Navigator.of(context).pop(r), child: Text(l10n.done)),
          ],
        ),
      ),
    );
  }
}

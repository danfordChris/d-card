import 'package:dcard_core/dcard_core.dart';
import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

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
          appBar: DcTopBar(title: l10n.contactsTitle, backLabel: l10n.back),
          body: switch (vm.state) {
            PickerState.requesting || PickerState.loading => const DcStateView(kind: DcStateKind.loading),
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(DcSpace.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DcStateView(
              kind: DcStateKind.empty,
              icon: HugeIcons.strokeRoundedContactBook,
              title: l10n.contactsPermissionTitle,
              message: l10n.contactsPermissionBody,
            ),
            DcButton(label: l10n.contactsOpenSettings, onPressed: viewModel.openSettings),
            if (viewModel.state == PickerState.denied) ...[
              const SizedBox(height: DcSpace.sm),
              DcButton(variant: DcButtonVariant.tonal, label: l10n.retry, onPressed: viewModel.open),
            ],
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
          padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xs),
          child: DcField(
            key: const Key('contacts.search'),
            label: l10n.contactsSearch,
            prefixIcon: HugeIcons.strokeRoundedSearch01,
            onChanged: viewModel.search,
          ),
        ),
        Expanded(
          child: contacts.isEmpty
              ? DcStateView(kind: DcStateKind.noResults, message: l10n.contactsEmpty)
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: DcSpace.page - 4),
                  itemCount: contacts.length,
                  itemBuilder: (context, i) => _ContactTile(viewModel: viewModel, contact: contacts[i], first: i == 0),
                ),
        ),
      ],
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.viewModel, required this.contact, required this.first});

  final ContactsPickerViewModel viewModel;
  final ContactEntry contact;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    return Container(
      decoration: BoxDecoration(
        border: first ? null : Border(top: BorderSide(color: c.line)),
      ),
      padding: const EdgeInsets.only(top: DcSpace.md, bottom: DcSpace.xs),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              contact.name.isEmpty ? l10n.contactsNoName : contact.name,
              style: DcType.ui(15, weight: FontWeight.w700).copyWith(color: c.ink),
            ),
          ),
          for (final n in contact.numbers)
            CheckboxListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 4),
              activeColor: c.primary,
              checkColor: c.onPrimary,
              value: n.valid && viewModel.selected[contact.id] == n.normalised,
              onChanged: n.valid ? (_) => viewModel.toggle(contact, n) : null,
              title: Text(
                n.valid ? formatLocalPhone(n.normalised!) : n.raw,
                style: DcType.ui(14).copyWith(color: n.valid ? c.ink : c.muted),
              ),
              subtitle: n.valid
                  ? null
                  : Text(l10n.contactsInvalidNumber, style: DcType.ui(12).copyWith(color: c.dangerFg)),
            ),
        ],
      ),
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
    final c = context.dc;
    return Material(
      color: c.bg,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: c.line)),
          ),
          padding: const EdgeInsets.fromLTRB(DcSpace.page - 8, DcSpace.xs, DcSpace.page, DcSpace.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (vm.failure != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 8, 0, 0),
                  child: DcNoticeTile(tone: DcTone.danger, message: l10n.failure(vm.failure!)),
                ),
              CheckboxListTile(
                key: const Key('contacts.consent'),
                controlAffinity: ListTileControlAffinity.leading,
                activeColor: c.primary,
                checkColor: c.onPrimary,
                value: vm.consent,
                onChanged: (v) => vm.setConsent(v ?? false),
                title: Text(l10n.contactsConsent, style: DcType.ui(14).copyWith(color: c.ink)),
                subtitle: vm.consentMissing
                    ? Text(l10n.contactsConsentRequired, style: DcType.ui(12).copyWith(color: c.dangerFg))
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: DcButton(
                  label: l10n.contactsAdd(vm.selected.length),
                  loading: vm.submitting,
                  onPressed: vm.selected.isEmpty ? null : vm.submit,
                ),
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
    return ListView(
      padding: const EdgeInsets.all(DcSpace.page),
      children: [
        DcStatusTile(
          tone: DcTone.success,
          icon: HugeIcons.strokeRoundedCheckmarkCircle02,
          title: l10n.contactsAdded(r.added),
          titleSize: 26,
          children: [
            if (r.existing > 0) Text(l10n.contactsExisting(r.existing)),
            if (r.invalid > 0) Text(l10n.contactsInvalid(r.invalid)),
          ],
        ),
        const SizedBox(height: DcSpace.xxl),
        DcButton(label: l10n.done, onPressed: () => Navigator.of(context).pop(r)),
      ],
    );
  }
}

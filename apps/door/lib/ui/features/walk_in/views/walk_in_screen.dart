import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import '../../../core/message_card.dart';
import '../../check_in/views/result_view.dart';
import '../view_models/walk_in_view_model.dart';

/// Request a walk-in from the host (online) or admit with a reason (offline) (CHK-8, CHK-8a).
class WalkInScreen extends StatefulWidget {
  const WalkInScreen({super.key, required this.viewModel});

  final WalkInViewModel viewModel;

  @override
  State<WalkInScreen> createState() => _WalkInScreenState();
}

class _WalkInScreenState extends State<WalkInScreen> {
  late final _description = TextEditingController(text: widget.viewModel.description);
  late final _reason = TextEditingController(text: widget.viewModel.reason);

  @override
  void dispose() {
    _description.dispose();
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: widget.viewModel,
      builder: (context, _) {
        final vm = widget.viewModel;
        return Scaffold(
          appBar: AppBar(title: Text(l10n.walkInTitle)),
          body: switch (vm.step) {
            WalkInStep.form => _form(context, l10n, vm),
            WalkInStep.waiting => _Outcome(
              key: const Key('walkIn.waiting'),
              verdict: Verdict.warning,
              busy: true,
              title: l10n.walkInWaiting,
              body: [l10n.walkInWaitingBody, if (vm.failure != null) l10n.failure(vm.failure!)],
            ),
            WalkInStep.approved => _Outcome(
              key: const Key('walkIn.approved'),
              verdict: Verdict.ok,
              title: l10n.walkInApproved,
              body: [if (vm.request?.decidedBy != null) l10n.walkInApprovedBy(vm.request!.decidedBy!)],
            ),
            WalkInStep.refused => _Outcome(
              key: const Key('walkIn.refused'),
              verdict: Verdict.refused,
              title: l10n.walkInRefused,
              body: [if (vm.request?.decidedBy != null) l10n.walkInRefusedBy(vm.request!.decidedBy!)],
            ),
            WalkInStep.admittedOffline => _Outcome(
              key: const Key('walkIn.admittedOffline'),
              verdict: Verdict.ok,
              title: l10n.walkInAdmittedOffline(vm.count),
              body: [l10n.walkInAdmittedOfflineBody],
            ),
          },
          bottomNavigationBar: vm.step == WalkInStep.form
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: 56,
                      child: OutlinedButton(
                        key: const Key('walkIn.done'),
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: Text(l10n.walkInDone, style: const TextStyle(fontSize: 18)),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _form(BuildContext context, AppLocalizations l10n, WalkInViewModel vm) {
    final card = vm.linkedCard;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          key: const Key('walkIn.description'),
          controller: _description,
          maxLength: WalkInViewModel.maxDescription,
          minLines: 1,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          onChanged: vm.setDescription,
          decoration: InputDecoration(
            labelText: l10n.walkInDescriptionLabel,
            hintText: l10n.walkInDescriptionHint,
            errorText: vm.showErrors && !vm.descriptionValid ? l10n.walkInDescriptionError : null,
          ),
        ),
        if (card != null) ...[
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: InputChip(
              key: const Key('walkIn.linkedCard'),
              avatar: const Icon(Icons.credit_card),
              label: Text(l10n.walkInLinkedCard(cardNames(card))),
              onDeleted: vm.busy ? null : vm.unlinkCard,
            ),
          ),
        ],
        const SizedBox(height: 16),
        Text(l10n.walkInPeople, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: 1, label: Text('1', key: Key('walkIn.count1'))),
            ButtonSegment(value: 2, label: Text('2', key: Key('walkIn.count2'))),
          ],
          selected: {vm.count},
          onSelectionChanged: vm.busy ? null : (s) => vm.setCount(s.first),
        ),
        const SizedBox(height: 16),
        if (vm.canAdmitOffline && (vm.networkDown || vm.offlineMode))
          SwitchListTile(
            key: const Key('walkIn.offlineSwitch'),
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.walkInOfflineSwitch),
            subtitle: Text(l10n.walkInOfflineHint),
            value: vm.offlineMode,
            onChanged: vm.busy ? null : vm.setOfflineMode,
          ),
        if (vm.offlineMode)
          TextField(
            key: const Key('walkIn.reason'),
            controller: _reason,
            maxLength: 200,
            onChanged: vm.setReason,
            decoration: InputDecoration(
              labelText: l10n.walkInReasonLabel,
              hintText: l10n.walkInReasonHint,
              errorText: vm.showErrors && !vm.reasonValid ? l10n.walkInReasonError : null,
            ),
          ),
        if (vm.failure != null) MessageCard(text: l10n.failure(vm.failure!)),
        const SizedBox(height: 16),
        SizedBox(
          height: 64,
          child: FilledButton(
            key: const Key('walkIn.submit'),
            onPressed: vm.busy ? null : vm.submit,
            child: vm.busy
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                : Text(
                    vm.offlineMode ? l10n.walkInAdmitOffline : l10n.walkInSend,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                  ),
          ),
        ),
      ],
    );
  }
}

class _Outcome extends StatelessWidget {
  const _Outcome({super.key, required this.verdict, required this.title, required this.body, this.busy = false});

  final Verdict verdict;
  final String title;
  final List<String> body;
  final bool busy;

  @override
  Widget build(BuildContext context) => Container(
    color: verdict.color,
    width: double.infinity,
    child: ListView(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 16),
      children: [
        if (busy)
          const Center(
            child: SizedBox(width: 72, height: 72, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 6)),
          )
        else
          Icon(verdict.icon, size: 96, color: Colors.white),
        const SizedBox(height: 16),
        Text(
          title,
          key: const Key('walkIn.headline'),
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800),
        ),
        for (final line in body) ...[
          const SizedBox(height: 12),
          Text(
            line,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          ),
        ],
      ],
    ),
  );
}

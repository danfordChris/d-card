import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/door_field.dart';
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
          appBar: DcTopBar(title: l10n.walkInTitle, backLabel: l10n.back),
          body: switch (vm.step) {
            WalkInStep.form => _form(context, l10n, vm),
            WalkInStep.waiting => _Outcome(
              key: const Key('walkIn.waiting'),
              tone: DcTone.warning,
              icon: HugeIcons.strokeRoundedClock01,
              busy: true,
              title: l10n.walkInWaiting,
              body: [l10n.walkInWaitingBody, if (vm.failure != null) l10n.failure(vm.failure!)],
            ),
            WalkInStep.approved => _Outcome(
              key: const Key('walkIn.approved'),
              tone: DcTone.success,
              icon: Verdict.ok.icon,
              title: l10n.walkInApproved,
              body: [if (vm.request?.decidedBy != null) l10n.walkInApprovedBy(vm.request!.decidedBy!)],
            ),
            WalkInStep.refused => _Outcome(
              key: const Key('walkIn.refused'),
              tone: DcTone.danger,
              icon: Verdict.refused.icon,
              title: l10n.walkInRefused,
              body: [if (vm.request?.decidedBy != null) l10n.walkInRefusedBy(vm.request!.decidedBy!)],
            ),
            WalkInStep.admittedOffline => _Outcome(
              key: const Key('walkIn.admittedOffline'),
              tone: DcTone.success,
              icon: Verdict.ok.icon,
              title: l10n.walkInAdmittedOffline(vm.count),
              body: [l10n.walkInAdmittedOfflineBody],
            ),
          },
          bottomNavigationBar: vm.step == WalkInStep.form
              ? SafeArea(
                  minimum: const EdgeInsets.only(bottom: DcSpace.md),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.sm),
                    child: SizedBox(
                      height: 60,
                      child: DcButton(
                        key: const Key('walkIn.submit'),
                        label: vm.offlineMode ? l10n.walkInAdmitOffline : l10n.walkInSend,
                        loading: vm.busy,
                        onPressed: vm.submit,
                      ),
                    ),
                  ),
                )
              : SafeArea(
                  minimum: const EdgeInsets.only(bottom: DcSpace.md),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.sm),
                    child: DcButton(
                      key: const Key('walkIn.done'),
                      label: l10n.walkInDone,
                      variant: vm.step == WalkInStep.waiting ? DcButtonVariant.tonal : DcButtonVariant.primary,
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ),
                ),
        );
      },
    );
  }

  Widget _form(BuildContext context, AppLocalizations l10n, WalkInViewModel vm) {
    final c = context.dc;
    final card = vm.linkedCard;
    const gap = SizedBox(height: DcSpace.lg);
    return SafeArea(
      top: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xl),
        children: [
          Semantics(
            header: true,
            child: Text(l10n.walkInHeading, style: DcType.heading(30).copyWith(color: c.ink)),
          ),
          const SizedBox(height: DcSpace.sm),
          Text(l10n.walkInIntro, style: DcType.ui(14).copyWith(color: c.muted)),
          gap,
          DoorField(
            key: const Key('walkIn.description'),
            label: l10n.walkInDescriptionLabel,
            hint: l10n.walkInDescriptionHint,
            controller: _description,
            maxLength: WalkInViewModel.maxDescription,
            minLines: 1,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
            onChanged: vm.setDescription,
            errorText: vm.showErrors && !vm.descriptionValid ? l10n.walkInDescriptionError : null,
          ),
          if (card != null) ...[
            const SizedBox(height: DcSpace.sm),
            DcTile(
              key: const Key('walkIn.linkedCard'),
              padding: const EdgeInsets.fromLTRB(DcSpace.lg, DcSpace.sm, DcSpace.sm, DcSpace.sm),
              child: Row(
                children: [
                  HugeIcon(icon: HugeIcons.strokeRoundedCreditCard, color: c.primary, size: 22),
                  const SizedBox(width: DcSpace.md),
                  Expanded(
                    child: Text(
                      l10n.walkInLinkedCard(cardNames(card)),
                      style: DcType.ui(15, weight: FontWeight.w600).copyWith(color: c.ink),
                    ),
                  ),
                  DcCircleButton(
                    key: const Key('walkIn.unlinkCard'),
                    icon: HugeIcons.strokeRoundedCancel01,
                    label: l10n.walkInUnlinkCard,
                    onPressed: vm.busy ? null : vm.unlinkCard,
                  ),
                ],
              ),
            ),
          ],
          gap,
          Text(l10n.walkInPeople, style: DcType.ui(13, weight: FontWeight.w600).copyWith(color: c.ink)),
          const SizedBox(height: 6),
          DcSegmented<int>(
            key: const Key('walkIn.count'),
            segments: const [
              DcSegment(value: 1, label: '1'),
              DcSegment(value: 2, label: '2'),
            ],
            selected: vm.count,
            onChanged: (n) {
              if (!vm.busy) vm.setCount(n);
            },
          ),
          if (vm.canAdmitOffline && (vm.networkDown || vm.offlineMode)) ...[
            gap,
            DcTile(
              variant: DcTileVariant.soft,
              padding: const EdgeInsets.symmetric(horizontal: DcSpace.lg, vertical: DcSpace.xs),
              child: SwitchListTile(
                key: const Key('walkIn.offlineSwitch'),
                contentPadding: EdgeInsets.zero,
                activeThumbColor: c.onPrimary,
                activeTrackColor: c.primary,
                title: Text(
                  l10n.walkInOfflineSwitch,
                  style: DcType.ui(15, weight: FontWeight.w700).copyWith(color: c.onSoft),
                ),
                subtitle: Text(l10n.walkInOfflineHint, style: DcType.ui(13).copyWith(color: c.onSoft)),
                value: vm.offlineMode,
                onChanged: vm.busy ? null : vm.setOfflineMode,
              ),
            ),
          ],
          if (vm.offlineMode) ...[
            gap,
            DoorField(
              key: const Key('walkIn.reason'),
              label: l10n.walkInReasonLabel,
              hint: l10n.walkInReasonHint,
              controller: _reason,
              maxLength: 200,
              onChanged: vm.setReason,
              errorText: vm.showErrors && !vm.reasonValid ? l10n.walkInReasonError : null,
            ),
          ],
          if (vm.failure != null) ...[gap, MessageCard(text: l10n.failure(vm.failure!))],
        ],
      ),
    );
  }
}

/// Waiting for the answer, or the answer, as one large status tile.
class _Outcome extends StatelessWidget {
  const _Outcome({
    super.key,
    required this.tone,
    required this.icon,
    required this.title,
    required this.body,
    this.busy = false,
  });

  final DcTone tone;
  final List<List<dynamic>> icon;
  final String title;
  final List<String> body;
  final bool busy;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => ListView(
      padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.lg),
      children: [
        DcStatusTile(
          tone: tone,
          icon: icon,
          busy: busy,
          title: title,
          titleSize: 30,
          titleKey: const Key('walkIn.headline'),
          minHeight: (constraints.maxHeight - DcSpace.xxl).clamp(0, 520),
          children: [
            for (final line in body) Text(line, textAlign: TextAlign.center, style: DcType.ui(17, height: 1.45)),
          ],
        ),
      ],
    ),
  );
}

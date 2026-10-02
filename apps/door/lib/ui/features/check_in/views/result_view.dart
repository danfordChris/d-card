import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../domain/models/check_in.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/door_format.dart';
import '../../../core/door_tones.dart';
import '../../../core/failure_text.dart';
import '../../../core/message_card.dart';
import '../view_models/check_in_view_model.dart';

export '../../../core/door_tones.dart';

String cardNames(CheckInCard card) =>
    card.partnerName == null ? card.guestName : '${card.guestName} & ${card.partnerName}';

String cardTypeLabel(AppLocalizations l10n, CardType type) =>
    type == CardType.double ? l10n.cardDouble : l10n.cardSingle;

String refusalTitle(AppLocalizations l10n, RefusalReason reason) => switch (reason) {
  RefusalReason.fullyUsed => l10n.refusedFullyUsed,
  RefusalReason.cancelled => l10n.refusedCancelled,
  RefusalReason.notFound => l10n.refusedNotFound,
  RefusalReason.notIssued => l10n.refusedNotIssued,
  RefusalReason.tooMany => l10n.refusedTooMany,
  RefusalReason.locked => l10n.lockedTitle,
};

String statusLabel(AppLocalizations l10n, CardStatus status) => switch (status) {
  CardStatus.issued => l10n.statusIssued,
  CardStatus.pending => l10n.statusPending,
  CardStatus.cancelled => l10n.statusCancelled,
};

DcTone statusTone(CardStatus status) => switch (status) {
  CardStatus.issued => DcTone.success,
  CardStatus.pending => DcTone.warning,
  CardStatus.cancelled => DcTone.danger,
};

/// The verdict for the card on screen as one large status tile (valid / admitted in the
/// success tone, refusals in danger, not found / not issued / locked in warning), with the
/// card's details as 2×2 tiles and the actions below.
class ResultView extends StatelessWidget {
  const ResultView({super.key, required this.viewModel, this.onWalkIn});

  final CheckInViewModel viewModel;

  /// Opens a walk-in request, linked to the card on screen when there is one.
  final ValueChanged<CheckInCard?>? onWalkIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final vm = viewModel;
    final result = vm.result!;
    final (Verdict verdict, String headline, CheckInCard? card) = switch (result) {
      CardFound(:final card) when card.refusal != null => (
        verdictOf(card),
        card.overUsed ? l10n.overUsedTitle : refusalTitle(l10n, card.refusal!),
        card,
      ),
      CardFound(:final card) => (Verdict.ok, l10n.resultValid, card),
      Admitted(:final card, :final count) => (Verdict.ok, l10n.resultAdmitted(count), card),
      Refused(:final reason, :final card) => (
        verdictOfRefusal(reason),
        card != null && card.overUsed && reason == RefusalReason.fullyUsed
            ? l10n.overUsedTitle
            : refusalTitle(l10n, reason),
        card,
      ),
    };
    // Why, for refusals that staff must explain to the guest.
    final refusalReason = switch (result) {
      Refused(:final reason) => reason,
      CardFound(:final card) => card.refusal,
      Admitted() => null,
    };
    final String? detail = card != null && card.overUsed && refusalReason != null
        ? l10n.overUsedDetail
        : (refusalReason == RefusalReason.cancelled ? l10n.cancelledDetail : null);
    final admitCard = result is CardFound && result.card.refusal == null ? result.card : null;
    final showEntries =
        card != null &&
        card.entries.isNotEmpty &&
        (result is Refused || (result is CardFound && result.card.refusal == RefusalReason.fullyUsed));
    final offline = switch (result) {
      CardFound(:final offline) || Admitted(:final offline) || Refused(:final offline) => offline,
    };
    final refused = result is Refused || (result is CardFound && result.card.refusal != null);
    final (_, toneFg) = c.tone(verdict.tone);
    Widget fact(String label, String value, {Key? key}) => DcTile(
      padding: const EdgeInsets.all(DcSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: DcType.ui(12).copyWith(color: c.muted)),
          const SizedBox(height: 2),
          Text(value, key: key, style: DcType.heading(19).copyWith(color: c.ink)),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => ListView(
              padding: const EdgeInsets.fromLTRB(DcSpace.page, 0, DcSpace.page, DcSpace.md),
              children: [
                DcStatusTile(
                  key: const Key('result.panel'),
                  tone: verdict.tone,
                  icon: verdict.icon,
                  title: headline,
                  titleSize: 36,
                  message: detail,
                  titleKey: const Key('result.headline'),
                  messageKey: const Key('result.detail'),
                  minHeight: card == null ? constraints.maxHeight * 0.6 : (constraints.maxHeight * 0.4).clamp(0, 320),
                  children: [
                    if (offline)
                      Row(
                        key: const Key('result.offline'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          HugeIcon(icon: HugeIcons.strokeRoundedCloudOff, color: toneFg, size: 20),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              l10n.offlineDecision,
                              textAlign: TextAlign.center,
                              style: DcType.ui(14, weight: FontWeight.w600).copyWith(color: toneFg),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                if (card != null) ...[
                  const SizedBox(height: DcSpace.gap),
                  DcBento(
                    items: [
                      DcBentoItem(fact(l10n.detailGuest, cardNames(card), key: const Key('result.names'))),
                      DcBentoItem(fact(l10n.detailCard, card.cardNumber ?? '—')),
                      DcBentoItem(fact(l10n.detailEntries, l10n.entriesLeft(card.entriesLeft, card.totalEntries))),
                      DcBentoItem(fact(l10n.detailTable, card.table ?? l10n.noTable)),
                    ],
                  ),
                  const SizedBox(height: DcSpace.gap),
                  Wrap(
                    spacing: DcSpace.sm,
                    runSpacing: DcSpace.sm,
                    children: [
                      DcBadge(label: cardTypeLabel(l10n, card.cardType).toUpperCase()),
                      DcBadge(label: statusLabel(l10n, card.status), tone: statusTone(card.status)),
                      if (card.overUsed) DcBadge(label: l10n.overUsedWarning, tone: DcTone.danger),
                    ],
                  ),
                  if (showEntries) ...[
                    const SizedBox(height: DcSpace.gap),
                    DcTile(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.previousEntries, style: DcType.ui(14, weight: FontWeight.w700).copyWith(color: c.ink)),
                          for (final (i, e) in card.entries.indexed) ...[
                            const SizedBox(height: DcSpace.xs),
                            Text(
                              [
                                l10n.entryLine(formatEntryTime(context, e.occurredAt), e.admittedCount),
                                ?e.deviceName,
                                ?e.staffName,
                              ].join(' · '),
                              key: Key('result.entry.$i'),
                              style: DcType.ui(15).copyWith(color: c.ink),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
        if (vm.failure != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(DcSpace.page, 0, DcSpace.page, DcSpace.sm),
            child: MessageCard(key: const Key('result.failure'), text: l10n.failure(vm.failure!)),
          ),
        SafeArea(
          top: false,
          minimum: const EdgeInsets.only(bottom: DcSpace.md),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.xs, DcSpace.page, DcSpace.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (admitCard != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 64,
                          child: DcButton(
                            key: const Key('result.admit1'),
                            label: l10n.admitOne,
                            icon: HugeIcons.strokeRoundedTick02,
                            loading: vm.busy,
                            onPressed: () => vm.admit(1),
                          ),
                        ),
                      ),
                      if (admitCard.entriesLeft >= 2) ...[
                        const SizedBox(width: DcSpace.gap),
                        Expanded(
                          child: SizedBox(
                            height: 64,
                            child: DcButton(
                              key: const Key('result.admit2'),
                              label: l10n.admitTwo,
                              icon: HugeIcons.strokeRoundedTick02,
                              loading: vm.busy,
                              onPressed: () => vm.admit(2),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: DcSpace.gap),
                ],
                Row(
                  children: [
                    if (refused && onWalkIn != null) ...[
                      Expanded(
                        child: DcButton(
                          key: const Key('result.walkIn'),
                          label: l10n.walkInAction,
                          icon: HugeIcons.strokeRoundedUserAdd01,
                          variant: DcButtonVariant.tonal,
                          onPressed: vm.busy ? null : () => onWalkIn!(card),
                        ),
                      ),
                      const SizedBox(width: DcSpace.gap),
                    ],
                    Expanded(
                      child: DcButton(
                        key: const Key('result.next'),
                        label: l10n.nextGuest,
                        variant: admitCard != null ? DcButtonVariant.tonal : DcButtonVariant.primary,
                        onPressed: vm.busy ? null : vm.next,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

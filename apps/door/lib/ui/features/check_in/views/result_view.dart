import 'package:flutter/material.dart';

import '../../../../domain/models/check_in.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/door_format.dart';
import '../../../core/failure_text.dart';
import '../view_models/check_in_view_model.dart';

/// Colour + icon so a verdict reads at a glance at a noisy door.
class Verdict {
  const Verdict(this.color, this.icon);

  final Color color;
  final IconData icon;

  static const ok = Verdict(Color(0xFF1B7F3B), Icons.check_circle);
  static const refused = Verdict(Color(0xFFB3261E), Icons.cancel);
  static const warning = Verdict(Color(0xFF9A5B00), Icons.help);
}

Verdict verdictOf(CheckInCard card) => switch (card.refusal) {
  null => Verdict.ok,
  RefusalReason.notIssued || RefusalReason.notFound => Verdict.warning,
  _ => Verdict.refused,
};

Verdict verdictOfRefusal(RefusalReason reason) => switch (reason) {
  RefusalReason.notFound || RefusalReason.notIssued || RefusalReason.locked => Verdict.warning,
  _ => Verdict.refused,
};

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

/// Full-screen verdict for the card on screen: valid (Admit 1 / Admit 2), admitted, or refused.
class ResultView extends StatelessWidget {
  const ResultView({super.key, required this.viewModel, this.onWalkIn});

  final CheckInViewModel viewModel;

  /// Opens a walk-in request, linked to the card on screen when there is one.
  final ValueChanged<CheckInCard?>? onWalkIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
    const onVerdict = Colors.white;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Container(
            key: const Key('result.panel'),
            color: verdict.color,
            child: SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                children: [
                  Icon(verdict.icon, size: 96, color: onVerdict),
                  const SizedBox(height: 8),
                  Text(
                    headline,
                    key: const Key('result.headline'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: onVerdict, fontSize: 32, fontWeight: FontWeight.w800),
                  ),
                  if (detail != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      detail,
                      key: const Key('result.detail'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: onVerdict, fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                  ],
                  if (offline) ...[
                    const SizedBox(height: 8),
                    Row(
                      key: const Key('result.offline'),
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, color: onVerdict, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            l10n.offlineDecision,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: onVerdict, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (card != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      cardNames(card),
                      key: const Key('result.names'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: onVerdict, fontSize: 36, fontWeight: FontWeight.w700, height: 1.15),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Fact(cardTypeLabel(l10n, card.cardType).toUpperCase(), strong: true),
                        _Fact(l10n.entriesLeft(card.entriesLeft, card.totalEntries), strong: true),
                        _Fact(card.table == null ? l10n.noTable : l10n.tableLabel(card.table!)),
                        _Fact(statusLabel(l10n, card.status)),
                        if (card.cardNumber != null) _Fact(l10n.cardNumberLabel(card.cardNumber!)),
                      ],
                    ),
                    if (card.overUsed) ...[
                      const SizedBox(height: 12),
                      _Fact(l10n.overUsedWarning, strong: true),
                    ],
                    if (showEntries) ...[
                      const SizedBox(height: 20),
                      Text(
                        l10n.previousEntries,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: onVerdict, fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      for (final e in card.entries)
                        Text(
                          [
                            l10n.entryLine(formatEntryTime(context, e.occurredAt), e.admittedCount),
                            ?e.deviceName,
                            ?e.staffName,
                          ].join(' · '),
                          key: const Key('result.entry'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: onVerdict, fontSize: 18),
                        ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
        if (vm.failure != null)
          Container(
            color: Theme.of(context).colorScheme.errorContainer,
            padding: const EdgeInsets.all(12),
            child: Text(
              l10n.failure(vm.failure!),
              key: const Key('result.failure'),
              style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer, fontSize: 16),
            ),
          ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (admitCard != null)
                  Row(
                    children: [
                      Expanded(
                        child: _BigButton(
                          key: const Key('result.admit1'),
                          label: l10n.admitOne,
                          onPressed: vm.busy ? null : () => vm.admit(1),
                        ),
                      ),
                      if (admitCard.entriesLeft >= 2) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: _BigButton(
                            key: const Key('result.admit2'),
                            label: l10n.admitTwo,
                            onPressed: vm.busy ? null : () => vm.admit(2),
                          ),
                        ),
                      ],
                    ],
                  ),
                if (admitCard != null) const SizedBox(height: 8),
                if (refused && onWalkIn != null) ...[
                  SizedBox(
                    height: 56,
                    child: OutlinedButton.icon(
                      key: const Key('result.walkIn'),
                      icon: const Icon(Icons.person_add_alt),
                      onPressed: vm.busy ? null : () => onWalkIn!(card),
                      label: Text(l10n.walkInAction, style: const TextStyle(fontSize: 18)),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    key: const Key('result.next'),
                    onPressed: vm.busy ? null : vm.next,
                    child: Text(l10n.nextGuest, style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact(this.text, {this.strong = false});

  final String text;
  final bool strong;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: strong ? 0.28 : 0.16),
      borderRadius: BorderRadius.circular(24),
    ),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white, fontSize: strong ? 22 : 18, fontWeight: strong ? FontWeight.w800 : FontWeight.w500),
    ),
  );
}

class _BigButton extends StatelessWidget {
  const _BigButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 72,
    child: FilledButton(
      style: FilledButton.styleFrom(backgroundColor: Verdict.ok.color, foregroundColor: Colors.white),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
    ),
  );
}

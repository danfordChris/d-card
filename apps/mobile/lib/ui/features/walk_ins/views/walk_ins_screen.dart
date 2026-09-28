import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/walk_in.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/app_scope.dart';
import '../../../core/failure_text.dart';
import '../view_models/walk_ins_view_model.dart';

/// Opens the walk-ins screen of an event.
Future<void> openWalkIns(BuildContext context, {required String eventId, String? eventTitle, required bool canDecide}) {
  final scope = AppScope.of(context);
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      settings: RouteSettings(name: '/events/$eventId/walk-ins'),
      builder: (_) => WalkInsScreen(
        eventTitle: eventTitle,
        viewModel: WalkInsViewModel(
          eventId: eventId,
          repository: scope.walkIns,
          alerts: scope.walkInAlerts,
          canDecide: canDecide,
        ),
      ),
    ),
  );
}

/// Walk-in approvals for one event (CHK-8, CHK-8a): big Approve / Refuse for pending requests,
/// Accept / Flag for offline admissions, then who decided what.
class WalkInsScreen extends StatefulWidget {
  const WalkInsScreen({super.key, required this.viewModel, this.eventTitle});

  final WalkInsViewModel viewModel;
  final String? eventTitle;

  static final _visible = <String, int>{};

  /// Whether a walk-ins screen for [eventId] is currently open (push banners skip it).
  static bool isOpen(String eventId) => (_visible[eventId] ?? 0) > 0;

  @override
  State<WalkInsScreen> createState() => _WalkInsScreenState();
}

class _WalkInsScreenState extends State<WalkInsScreen> {
  late final AppLifecycleListener _lifecycle;

  WalkInsViewModel get _vm => widget.viewModel;

  @override
  void initState() {
    super.initState();
    final id = _vm.eventId;
    WalkInsScreen._visible[id] = (WalkInsScreen._visible[id] ?? 0) + 1;
    _vm.load();
    _vm.startPolling();
    // Poll only while the app is in front.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _vm.load(silent: true);
        _vm.startPolling();
      },
      onHide: _vm.stopPolling,
    );
  }

  @override
  void dispose() {
    final id = _vm.eventId;
    final n = (WalkInsScreen._visible[id] ?? 1) - 1;
    if (n <= 0) {
      WalkInsScreen._visible.remove(id);
    } else {
      WalkInsScreen._visible[id] = n;
    }
    _lifecycle.dispose();
    _vm.dispose();
    super.dispose();
  }

  Future<void> _decide(WalkIn walkIn, WalkInDecision decision) async {
    final l10n = AppLocalizations.of(context);
    final result = await _vm.decide(walkIn, decision);
    if (!mounted) return;
    final text = switch (result) {
      WalkInDecided(:final walkIn) => l10n.walkInSaved(statusKey(walkIn.status)),
      WalkInDecidedElsewhere(:final walkIn) => l10n.walkInAlreadyDecided(
        statusKey(walkIn.status),
        walkIn.decidedBy ?? l10n.walkInSomeone,
      ),
      WalkInDecisionFailed(:final failure) => l10n.failure(failure),
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.eventTitle;
    final c = context.dc;
    return Scaffold(
      appBar: DcTopBar(title: l10n.walkInsTitle, backLabel: l10n.back),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          if (!_vm.loaded && _vm.loading) return const DcStateView(kind: DcStateKind.loading);
          if (!_vm.loaded && _vm.failure != null) {
            return DcStateView(
              kind: DcStateKind.error,
              title: l10n.failure(_vm.failure!),
              actionLabel: l10n.retry,
              onAction: _vm.load,
            );
          }
          final pending = _vm.pending;
          final review = _vm.needsReview;
          final history = _vm.history;
          return RefreshIndicator(
            onRefresh: _vm.load,
            child: ListView(
              key: const Key('walkIns.list'),
              padding: const EdgeInsets.fromLTRB(DcSpace.page, 0, DcSpace.page, DcSpace.xxxl),
              children: [
                if (title != null && title.isNotEmpty)
                  Text(title, textAlign: TextAlign.center, style: DcType.ui(13).copyWith(color: c.muted)),
                if (!_vm.canDecide) ...[
                  const SizedBox(height: DcSpace.md),
                  DcNoticeTile(
                    key: const Key('walkIns.readOnly'),
                    tone: DcTone.neutral,
                    icon: HugeIcons.strokeRoundedView,
                    message: l10n.walkInsReadOnly,
                  ),
                ],
                if (_vm.failure != null) ...[
                  const SizedBox(height: DcSpace.md),
                  DcNoticeTile(tone: DcTone.danger, message: l10n.failure(_vm.failure!)),
                ],
                DcSectionHeader(title: '${l10n.walkInsPending} (${pending.length})'),
                if (pending.isEmpty)
                  Text(l10n.walkInsPendingEmpty, style: DcType.ui(14).copyWith(color: c.muted)),
                for (final w in pending)
                  _OpenCard(
                    walkIn: w,
                    busy: _vm.busy.contains(w.id),
                    canDecide: _vm.canDecide,
                    hero: w == pending.first,
                    positive: (key: 'approve', label: l10n.walkInApprove, decision: WalkInDecision.approve),
                    negative: (key: 'refuse', label: l10n.walkInRefuse, decision: WalkInDecision.refuse),
                    onDecide: _decide,
                  ),
                if (review.isNotEmpty) ...[
                  DcSectionHeader(title: '${l10n.walkInsNeedsReview} (${review.length})'),
                  for (final w in review)
                    _OpenCard(
                      walkIn: w,
                      busy: _vm.busy.contains(w.id),
                      canDecide: _vm.canDecide,
                      positive: (key: 'accept', label: l10n.walkInAccept, decision: WalkInDecision.accept),
                      negative: (key: 'flag', label: l10n.walkInFlag, decision: WalkInDecision.flag),
                      onDecide: _decide,
                    ),
                ],
                if (history.isNotEmpty) ...[
                  DcSectionHeader(title: l10n.walkInsHistory),
                  for (var i = 0; i < history.length; i++) _HistoryTile(walkIn: history[i], first: i == 0),
                ],
                if (_vm.isEmpty && _vm.loaded)
                  Padding(
                    padding: const EdgeInsets.only(top: DcSpace.lg),
                    child: Text(l10n.walkInsEmpty, style: DcType.ui(14).copyWith(color: c.muted)),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// ARB select key for a status.
String statusKey(WalkInStatus status) => switch (status) {
  WalkInStatus.pending => 'pending',
  WalkInStatus.approved => 'approved',
  WalkInStatus.refused => 'refused',
  WalkInStatus.admittedOffline => 'admitted_offline',
  WalkInStatus.accepted => 'accepted',
  WalkInStatus.flagged => 'flagged',
};

/// Walk-ins happen in Tanzania (UTC+03:00); show that wall-clock time.
String _time(BuildContext context, DateTime at) {
  final local = at.toUtc().add(const Duration(hours: 3));
  final locale = Localizations.localeOf(context).toLanguageTag();
  return '${DateFormat.MMMd(locale).format(local)} ${DateFormat.Hm(locale).format(local)}';
}

typedef _Action = ({String key, String label, WalkInDecision decision});

class _OpenCard extends StatelessWidget {
  const _OpenCard({
    required this.walkIn,
    required this.busy,
    required this.canDecide,
    required this.positive,
    required this.negative,
    required this.onDecide,
    this.hero = false,
  });

  final WalkIn walkIn;
  final bool busy;
  final bool canDecide;
  final _Action positive;
  final _Action negative;
  final Future<void> Function(WalkIn, WalkInDecision) onDecide;

  /// The first waiting request is the screen's hero tile.
  final bool hero;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final w = walkIn;
    final (fg, muted) = hero ? (c.onHero, c.heroMuted) : (c.ink, c.muted);
    final details = [
      l10n.walkInPeople(w.admittedCount),
      if (w.guestName != null) l10n.walkInCard(w.guestName!),
      if (w.deviceName != null) l10n.walkInGate(w.deviceName!),
      if (w.requestedBy != null) l10n.walkInRequestedBy(w.requestedBy!),
      l10n.walkInAt(_time(context, w.occurredAt)),
    ];
    return Padding(
      padding: const EdgeInsets.only(top: DcSpace.sm),
      child: DcTile(
        key: Key('walkIn.${w.id}'),
        variant: hero ? DcTileVariant.hero : DcTileVariant.tile,
        radius: hero ? DcRadius.hero : DcRadius.tile,
        padding: const EdgeInsets.all(DcSpace.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(w.description, style: DcType.heading(24).copyWith(color: fg)),
            const SizedBox(height: DcSpace.sm),
            for (final d in details) Text(d, style: DcType.ui(14).copyWith(color: muted)),
            if (w.offlineReason != null && w.offlineReason!.isNotEmpty) ...[
              const SizedBox(height: DcSpace.xs),
              Text(l10n.walkInReason(w.offlineReason!), style: DcType.ui(14, weight: FontWeight.w700).copyWith(color: fg)),
            ],
            if (canDecide) ...[
              const SizedBox(height: DcSpace.lg),
              Row(
                children: [
                  Expanded(
                    child: DcButton(
                      key: Key('walkIn.${negative.key}.${w.id}'),
                      variant: DcButtonVariant.danger,
                      label: negative.label,
                      onPressed: busy ? null : () => onDecide(w, negative.decision),
                    ),
                  ),
                  const SizedBox(width: DcSpace.md),
                  Expanded(
                    child: _PositiveButton(
                      key: Key('walkIn.${positive.key}.${w.id}'),
                      label: positive.label,
                      busy: busy,
                      onHero: hero,
                      onPressed: busy ? null : () => onDecide(w, positive.decision),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Approve / Accept: primary, or inverted on the hero tile so it stands out.
class _PositiveButton extends StatelessWidget {
  const _PositiveButton({super.key, required this.label, required this.busy, required this.onHero, this.onPressed});

  final String label;
  final bool busy;
  final bool onHero;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    final button = DcButton(label: label, loading: busy, onPressed: onPressed);
    if (!onHero) return button;
    // On the hero tile the button uses the page background with primary text.
    return Theme(
      data: Theme.of(context).copyWith(extensions: [c.copyWith(primary: c.bg, onPrimary: c.primary)]),
      child: button,
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.walkIn, required this.first});

  final WalkIn walkIn;
  final bool first;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final w = walkIn;
    final c = context.dc;
    final positive = w.status == WalkInStatus.approved || w.status == WalkInStatus.accepted;
    final status = l10n.walkInStatusLabel(statusKey(w.status));
    final decided = l10n.walkInDecidedBy(
      status,
      w.decidedBy ?? l10n.walkInSomeone,
      _time(context, w.decidedAt ?? w.occurredAt),
    );
    return DcListRow(
      key: Key('walkIn.${w.id}'),
      divider: !first,
      leading: DcIconDisc(
        icon: positive ? HugeIcons.strokeRoundedCheckmarkCircle02 : HugeIcons.strokeRoundedCancelCircle,
        background: positive ? c.successBg : c.dangerBg,
        foreground: positive ? c.successFg : c.dangerFg,
      ),
      title: '${w.description} · ${l10n.walkInPeople(w.admittedCount)}',
      subtitle: [
        decided,
        if (w.guestName != null) l10n.walkInCard(w.guestName!),
        if (w.offlineReason != null && w.offlineReason!.isNotEmpty) l10n.walkInReason(w.offlineReason!),
      ].join('\n'),
    );
  }
}

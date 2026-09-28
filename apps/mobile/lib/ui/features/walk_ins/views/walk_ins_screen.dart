import 'package:flutter/material.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.walkInsTitle),
            if (title != null && title.isNotEmpty) Text(title, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: _vm,
        builder: (context, _) {
          if (!_vm.loaded && _vm.loading) return const Center(child: CircularProgressIndicator());
          if (!_vm.loaded && _vm.failure != null) {
            return _Message(
              text: l10n.failure(_vm.failure!),
              action: TextButton(onPressed: _vm.load, child: Text(l10n.retry)),
            );
          }
          final pending = _vm.pending;
          final review = _vm.needsReview;
          final history = _vm.history;
          return RefreshIndicator(
            onRefresh: _vm.load,
            child: ListView(
              key: const Key('walkIns.list'),
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                if (!_vm.canDecide)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Card(
                      key: const Key('walkIns.readOnly'),
                      child: ListTile(
                        leading: const Icon(Icons.visibility_outlined),
                        title: Text(l10n.walkInsReadOnly),
                      ),
                    ),
                  ),
                if (_vm.failure != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(
                      l10n.failure(_vm.failure!),
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                _Header('${l10n.walkInsPending} (${pending.length})'),
                if (pending.isEmpty)
                  Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text(l10n.walkInsPendingEmpty)),
                for (final w in pending)
                  _OpenCard(
                    walkIn: w,
                    busy: _vm.busy.contains(w.id),
                    canDecide: _vm.canDecide,
                    positive: (key: 'approve', label: l10n.walkInApprove, decision: WalkInDecision.approve),
                    negative: (key: 'refuse', label: l10n.walkInRefuse, decision: WalkInDecision.refuse),
                    onDecide: _decide,
                  ),
                if (review.isNotEmpty) ...[
                  _Header('${l10n.walkInsNeedsReview} (${review.length})'),
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
                  _Header(l10n.walkInsHistory),
                  for (final w in history) _HistoryTile(walkIn: w),
                ],
                if (_vm.isEmpty && _vm.loaded)
                  Padding(padding: const EdgeInsets.all(16), child: Text(l10n.walkInsEmpty)),
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
  });

  final WalkIn walkIn;
  final bool busy;
  final bool canDecide;
  final _Action positive;
  final _Action negative;
  final Future<void> Function(WalkIn, WalkInDecision) onDecide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final w = walkIn;
    final details = [
      l10n.walkInPeople(w.admittedCount),
      if (w.guestName != null) l10n.walkInCard(w.guestName!),
      if (w.deviceName != null) l10n.walkInGate(w.deviceName!),
      if (w.requestedBy != null) l10n.walkInRequestedBy(w.requestedBy!),
      l10n.walkInAt(_time(context, w.occurredAt)),
    ];
    const buttonSize = Size.fromHeight(56);
    return Card(
      key: Key('walkIn.${w.id}'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(w.description, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            for (final d in details) Text(d, style: theme.textTheme.bodyMedium),
            if (w.offlineReason != null && w.offlineReason!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                l10n.walkInReason(w.offlineReason!),
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
            if (canDecide) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: Key('walkIn.${negative.key}.${w.id}'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: buttonSize,
                        foregroundColor: theme.colorScheme.error,
                        textStyle: theme.textTheme.titleMedium,
                      ),
                      onPressed: busy ? null : () => onDecide(w, negative.decision),
                      child: Text(negative.label),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: Key('walkIn.${positive.key}.${w.id}'),
                      style: FilledButton.styleFrom(minimumSize: buttonSize, textStyle: theme.textTheme.titleMedium),
                      onPressed: busy ? null : () => onDecide(w, positive.decision),
                      child: busy
                          ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(positive.label),
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

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.walkIn});

  final WalkIn walkIn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final w = walkIn;
    final scheme = Theme.of(context).colorScheme;
    final positive = w.status == WalkInStatus.approved || w.status == WalkInStatus.accepted;
    final status = l10n.walkInStatusLabel(statusKey(w.status));
    final decided = l10n.walkInDecidedBy(
      status,
      w.decidedBy ?? l10n.walkInSomeone,
      _time(context, w.decidedAt ?? w.occurredAt),
    );
    return ListTile(
      key: Key('walkIn.${w.id}'),
      leading: Icon(
        positive ? Icons.check_circle_outline : Icons.block,
        color: positive ? scheme.primary : scheme.error,
      ),
      title: Text('${w.description} · ${l10n.walkInPeople(w.admittedCount)}'),
      subtitle: Text(
        [
          decided,
          if (w.guestName != null) l10n.walkInCard(w.guestName!),
          if (w.offlineReason != null && w.offlineReason!.isNotEmpty) l10n.walkInReason(w.offlineReason!),
        ].join('\n'),
      ),
      isThreeLine: w.guestName != null || w.offlineReason != null,
    );
  }
}

class _Header extends StatelessWidget {
  const _Header(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, textAlign: TextAlign.center),
        ?action,
      ],
    ),
  );
}

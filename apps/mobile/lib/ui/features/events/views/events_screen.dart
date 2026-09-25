import 'package:flutter/material.dart';

import '../../../../domain/models/event_summary.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import '../view_models/events_view_model.dart';
import 'event_detail_screen.dart';
import 'event_format.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key, required this.viewModel, required this.onSignOut});

  final EventsViewModel viewModel;
  final VoidCallback onSignOut;

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.eventsTitle),
        actions: [IconButton(tooltip: l10n.signOut, icon: const Icon(Icons.logout), onPressed: widget.onSignOut)],
      ),
      body: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final vm = widget.viewModel;
          if (vm.loading && vm.events.isEmpty) return const Center(child: CircularProgressIndicator());
          if (vm.failure != null && vm.events.isEmpty) {
            return _Message(
              text: l10n.failure(vm.failure!),
              action: TextButton(onPressed: vm.load, child: Text(l10n.retry)),
            );
          }
          return RefreshIndicator(
            onRefresh: vm.load,
            child: vm.events.isEmpty
                ? ListView(children: [_Message(text: l10n.eventsEmpty)])
                : ListView.separated(
                    itemCount: vm.events.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, i) => _EventTile(event: vm.events[i]),
                  ),
          );
        },
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  const _EventTile({required this.event});

  final EventSummary event;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(event.title),
      subtitle: Text(formatEventDate(context, event.startsAt)),
      trailing: EventStatusChip(status: event.status),
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EventDetailScreen(event: event))),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, this.action});

  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
}

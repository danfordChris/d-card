import 'package:flutter/material.dart';

import '../../../../domain/models/door_event.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/door_format.dart';
import '../../../core/failure_text.dart';
import '../../../core/message_card.dart';
import '../view_models/event_select_view_model.dart';

/// Pick the event to check guests in for; registering the phone for it (AUTH-9).
class EventSelectScreen extends StatefulWidget {
  const EventSelectScreen({super.key, required this.viewModel, required this.onOpened, required this.onSignOut});

  final EventSelectViewModel viewModel;
  final ValueChanged<DoorSession> onOpened;
  final VoidCallback onSignOut;

  @override
  State<EventSelectScreen> createState() => _EventSelectScreenState();
}

class _EventSelectScreenState extends State<EventSelectScreen> {
  late final _deviceName = TextEditingController(text: widget.viewModel.deviceName);

  @override
  void initState() {
    super.initState();
    widget.viewModel.load();
  }

  @override
  void dispose() {
    _deviceName.dispose();
    super.dispose();
  }

  Future<void> _open(DoorEvent event) async {
    await widget.viewModel.setDeviceName(_deviceName.text);
    final session = await widget.viewModel.open(event);
    if (session != null && mounted) widget.onOpened(session);
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
          return RefreshIndicator(
            onRefresh: vm.load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextField(
                  key: const Key('events.deviceName'),
                  controller: _deviceName,
                  maxLength: 60,
                  decoration: InputDecoration(
                    labelText: l10n.deviceNameLabel,
                    hintText: l10n.deviceNameHint,
                    prefixIcon: const Icon(Icons.door_front_door_outlined),
                  ),
                ),
                if (vm.notice != null) MessageCard(text: l10n.failure(vm.notice!)),
                if (vm.offlineSession case final cached?)
                  Card(
                    child: ListTile(
                      key: const Key('events.offline'),
                      leading: const Icon(Icons.cloud_off),
                      title: Text(l10n.continueOffline(cached.event.title)),
                      subtitle: Text(l10n.continueOfflineBody),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => widget.onOpened(cached),
                    ),
                  ),
                if (vm.loading && vm.events.isEmpty)
                  const Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator()))
                else if (vm.failure != null)
                  MessageCard(
                    text: l10n.failure(vm.failure!),
                    action: TextButton(onPressed: vm.load, child: Text(l10n.retry)),
                  )
                else if (vm.events.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(l10n.eventsEmpty, textAlign: TextAlign.center),
                  )
                else
                  for (final event in vm.events)
                    Card(
                      child: ListTile(
                        key: Key('events.${event.id}'),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(event.title, style: Theme.of(context).textTheme.titleLarge),
                        subtitle: Text(
                          [
                            formatEventDate(context, event.startsAt),
                            ?event.venueName,
                            switch (event.role) {
                              DoorRole.host => l10n.roleHost,
                              DoorRole.committee => l10n.roleCommittee,
                              DoorRole.doorStaff => l10n.roleDoorStaff,
                            },
                          ].join('\n'),
                        ),
                        isThreeLine: true,
                        trailing: vm.openingEventId == event.id
                            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.chevron_right),
                        onTap: vm.openingEventId == null ? () => _open(event) : null,
                      ),
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

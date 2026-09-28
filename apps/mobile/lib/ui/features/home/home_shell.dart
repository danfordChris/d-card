import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/events_repository.dart';
import '../../../data/repositories/my_cards_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../account/view_models/account_view_model.dart';
import '../account/views/account_screen.dart';
import '../events/view_models/events_view_model.dart';
import '../events/views/events_screen.dart';
import '../my_cards/view_models/my_cards_view_model.dart';
import '../my_cards/views/my_cards_screen.dart';

/// Signed-in home: Events (hosts, committee), My cards (guests) and Account.
/// Guests who signed in with Google/Apple start on My cards.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.session,
    required this.events,
    required this.myCards,
    required this.account,
  });

  final SessionRepository session;
  final EventsRepository events;
  final MyCardsRepository myCards;
  final AccountRepository account;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _index = (widget.session.user?.isSocial ?? false) ? 1 : 0;

  /// Tabs are built on first visit so each loads only when opened.
  late final Set<int> _visited = {_index};

  late final _eventsVm = EventsViewModel(widget.events);
  late final _myCardsVm = MyCardsViewModel(widget.myCards);
  late final _accountVm = AccountViewModel(session: widget.session, account: widget.account);

  Widget _tab(int i) => switch (i) {
    0 => EventsScreen(viewModel: _eventsVm),
    1 => MyCardsScreen(viewModel: _myCardsVm),
    _ => AccountScreen(viewModel: _accountVm),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [for (var i = 0; i < 3; i++) _visited.contains(i) ? _tab(i) : const SizedBox.shrink()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() {
          _index = i;
          _visited.add(i);
        }),
        destinations: [
          NavigationDestination(
            key: const Key('nav.events'),
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedCalendar03),
            label: l10n.navEvents,
          ),
          NavigationDestination(
            key: const Key('nav.myCards'),
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedTicket01),
            label: l10n.navMyCards,
          ),
          NavigationDestination(
            key: const Key('nav.account'),
            icon: const HugeIcon(icon: HugeIcons.strokeRoundedUserCircle),
            label: l10n.navAccount,
          ),
        ],
      ),
    );
  }
}

import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../data/repositories/account_repository.dart';
import '../../../data/repositories/events_repository.dart';
import '../../../data/repositories/my_cards_repository.dart';
import '../../../data/repositories/session_repository.dart';
import '../../../data/repositories/theme_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../account/view_models/account_view_model.dart';
import '../account/views/account_screen.dart';
import '../events/view_models/events_view_model.dart';
import '../events/views/events_screen.dart';
import '../events/view_models/create_event_view_model.dart';
import '../events/views/new_event_screen.dart';
import '../my_cards/view_models/my_cards_view_model.dart';
import '../my_cards/views/my_cards_screen.dart';
import 'notifications_screen.dart';

/// The shell's tabs, in bar order.
enum HomeTab { home, myCards, newEvent, notifications, account }

/// Signed-in home with the floating spotlight bar: Home (events), My cards, New event,
/// Notifications and Account. Guests who signed in with Google/Apple start on My cards.
class HomeShell extends StatefulWidget {
  const HomeShell({
    super.key,
    required this.session,
    required this.events,
    required this.myCards,
    required this.account,
    required this.theme,
  });

  final SessionRepository session;
  final EventsRepository events;
  final MyCardsRepository myCards;
  final AccountRepository account;
  final ThemeRepository theme;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late HomeTab _tab = (widget.session.user?.isSocial ?? false) ? HomeTab.myCards : HomeTab.home;

  /// Tabs are built on first visit so each loads only when opened.
  late final Set<HomeTab> _visited = {_tab};

  late final _eventsVm = EventsViewModel(widget.events);
  late final _createEventVm = CreateEventViewModel(widget.events);
  late final _myCardsVm = MyCardsViewModel(widget.myCards);
  late final _accountVm = AccountViewModel(session: widget.session, account: widget.account);

  void _select(HomeTab tab) => setState(() {
    _tab = tab;
    _visited.add(tab);
  });

  Widget _build(HomeTab tab) => switch (tab) {
    HomeTab.home => EventsScreen(viewModel: _eventsVm, onNewEvent: () => _select(HomeTab.newEvent)),
    HomeTab.myCards => MyCardsScreen(viewModel: _myCardsVm),
    HomeTab.newEvent => NewEventScreen(
      viewModel: _createEventVm,
      onCreated: () {
        _eventsVm.load();
        _select(HomeTab.home);
      },
    ),
    HomeTab.notifications => const NotificationsScreen(),
    HomeTab.account => AccountScreen(viewModel: _accountVm, theme: widget.theme),
  };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = {
      HomeTab.home: DcNavItem(icon: HugeIcons.strokeRoundedHome01, label: l10n.navHome),
      HomeTab.myCards: DcNavItem(icon: HugeIcons.strokeRoundedTicket01, label: l10n.navMyCards),
      HomeTab.newEvent: DcNavItem(icon: HugeIcons.strokeRoundedAddCircle, label: l10n.navNewEvent),
      HomeTab.notifications: DcNavItem(icon: HugeIcons.strokeRoundedNotification01, label: l10n.navNotifications),
      HomeTab.account: DcNavItem(icon: HugeIcons.strokeRoundedUser, label: l10n.navAccount),
    };
    return Scaffold(
      // The bar floats over the content; each tab pads its scroll view by reservedHeight.
      extendBody: true,
      body: IndexedStack(
        index: _tab.index,
        children: [
          for (final tab in HomeTab.values) _visited.contains(tab) ? _build(tab) : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: Stack(
        children: [
          DcSpotlightNavBar(
            items: [for (final tab in HomeTab.values) items[tab]!],
            currentIndex: _tab.index,
            onTap: (i) => _select(HomeTab.values[i]),
          ),
          // Test and automation handles over each tab (the bar itself is icon-only).
          Positioned.fill(
            child: IgnorePointer(
              child: SafeArea(
                top: false,
                minimum: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                child: Row(
                  children: [
                    for (final tab in HomeTab.values) Expanded(child: SizedBox.expand(key: Key('nav.${tab.name}'))),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

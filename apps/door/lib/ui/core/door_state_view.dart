import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';

/// Tone of a full-screen door state: a problem that stops check-in, or a warning staff may pass.
enum DoorStateTone { blocked, warning, neutral }

extension on DoorStateTone {
  DcTone get dc => switch (this) {
    DoorStateTone.blocked => DcTone.danger,
    DoorStateTone.warning => DcTone.warning,
    DoorStateTone.neutral => DcTone.neutral,
  };
}

/// A full-screen state at the door (revoked phone, no network, event not started…): one large
/// status tile with the icon, title and explanation, then the actions (56 px or taller).
class DoorStateView extends StatelessWidget {
  const DoorStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.tone = DoorStateTone.blocked,
    this.details = const [],
    this.actions = const [],
    this.busy = false,
  });

  final List<List<dynamic>> icon;
  final String title;
  final String body;
  final DoorStateTone tone;

  /// Extra lines under the body (e.g. what was lost).
  final List<Widget> details;

  /// Buttons, first is the main action.
  final List<Widget> actions;

  /// Shows a progress indicator instead of the actions.
  final bool busy;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: LayoutBuilder(
        builder: (context, constraints) => ListView(
          padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.md, DcSpace.page, DcSpace.xl),
          children: [
            DcStatusTile(
              tone: tone.dc,
              icon: icon,
              title: title,
              titleSize: 30,
              message: body,
              titleKey: const Key('state.title'),
              messageKey: const Key('state.body'),
              minHeight: (constraints.maxHeight * 0.5).clamp(0, 460),
              children: details,
            ),
            const SizedBox(height: DcSpace.md),
            if (busy)
              Padding(
                padding: const EdgeInsets.all(DcSpace.lg),
                child: Center(child: CircularProgressIndicator(color: context.dc.primary)),
              )
            else
              for (final (i, a) in actions.indexed) ...[if (i > 0) const SizedBox(height: DcSpace.gap), a],
          ],
        ),
      ),
    );
  }
}

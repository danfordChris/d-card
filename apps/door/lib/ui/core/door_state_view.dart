import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

/// Tone of a full-screen door state: a problem that stops check-in, or a warning staff may pass.
enum DoorStateTone { blocked, warning, neutral }

/// A full-screen state at the door (revoked phone, no network, event not started…): a large
/// icon, a title, the explanation and the actions. Flat colours, no shadows or gradients.
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
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (Color background, Color foreground) = switch (tone) {
      DoorStateTone.blocked => (scheme.errorContainer, scheme.onErrorContainer),
      DoorStateTone.warning => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      DoorStateTone.neutral => (scheme.surfaceContainerHighest, scheme.onSurface),
    };
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const SizedBox(height: 24),
          Center(
            child: Container(
              width: 112,
              height: 112,
              decoration: BoxDecoration(color: background, shape: BoxShape.circle),
              alignment: Alignment.center,
              child: HugeIcon(icon: icon, color: foreground, size: 56),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            key: const Key('state.title'),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            key: const Key('state.body'),
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(color: scheme.onSurfaceVariant, height: 1.4),
          ),
          for (final d in details) ...[const SizedBox(height: 12), d],
          const SizedBox(height: 32),
          if (busy)
            const Center(child: CircularProgressIndicator())
          else
            for (final (i, a) in actions.indexed) ...[
              if (i > 0) const SizedBox(height: 12),
              SizedBox(height: 56, child: a),
            ],
        ],
      ),
    );
  }
}

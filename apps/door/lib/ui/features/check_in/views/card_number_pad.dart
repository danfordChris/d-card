import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Card numbers are `NNN-PPPP` (GST-10): 7 digits.
const cardNumberDigits = 7;

/// "0071234" → "007-1234" (partial input is formatted as far as it goes).
String formatCardNumber(String digits) =>
    digits.length <= 3 ? digits : '${digits.substring(0, 3)}-${digits.substring(3)}';

/// Big numeric keypad for typing a card number at the door.
class CardNumberPad extends StatefulWidget {
  const CardNumberPad({super.key, required this.enabled, required this.busy, required this.onSubmit});

  /// False while card-number entry is locked (CHK-5).
  final bool enabled;
  final bool busy;
  final ValueChanged<String> onSubmit;

  @override
  State<CardNumberPad> createState() => _CardNumberPadState();
}

class _CardNumberPadState extends State<CardNumberPad> {
  String _digits = '';

  void _press(String digit) {
    if (_digits.length >= cardNumberDigits) return;
    setState(() => _digits += digit);
  }

  void _backspace() {
    if (_digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  void _submit() {
    widget.onSubmit(formatCardNumber(_digits));
    setState(() => _digits = '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final enabled = widget.enabled && !widget.busy;
    Widget key(String label, {Key? k, VoidCallback? onPressed, Widget? child}) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SizedBox(
          height: 64,
          child: FilledButton.tonal(
            key: k ?? Key('pad.$label'),
            onPressed: enabled ? onPressed : null,
            child: child ?? Text(label, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600)),
          ),
        ),
      ),
    );
    Widget row(List<String> digits) => Row(children: [for (final d in digits) key(d, onPressed: () => _press(d))]);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            key: const Key('pad.display'),
            alignment: Alignment.center,
            height: 72,
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _digits.isEmpty ? l10n.cardNumberHint : formatCardNumber(_digits),
              style: _digits.isEmpty
                  ? theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)
                  : theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.w700, letterSpacing: 4),
            ),
          ),
          const SizedBox(height: 12),
          row(['1', '2', '3']),
          row(['4', '5', '6']),
          row(['7', '8', '9']),
          Row(
            children: [
              key(
                'back',
                onPressed: _backspace,
                child: Icon(Icons.backspace_outlined, semanticLabel: l10n.clear),
              ),
              key('0', onPressed: () => _press('0')),
              key(
                'find',
                onPressed: _digits.length == cardNumberDigits ? _submit : null,
                child: widget.busy
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text(l10n.find, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

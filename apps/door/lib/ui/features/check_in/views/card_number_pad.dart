import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../l10n/app_localizations.dart';

/// Card numbers are `NNN-PPPP` (GST-10): 7 digits.
const cardNumberDigits = 7;

/// "0071234" → "007-1234" (partial input is formatted as far as it goes).
String formatCardNumber(String digits) =>
    digits.length <= 3 ? digits : '${digits.substring(0, 3)}-${digits.substring(3)}';

/// Big numeric keypad in tiles for typing a card number at the door, with "Find card" below.
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

  void _clear() => setState(() => _digits = '');

  void _submit() {
    widget.onSubmit(formatCardNumber(_digits));
    setState(() => _digits = '');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final enabled = widget.enabled && !widget.busy;
    Widget key(String id, {required VoidCallback onPressed, Widget? child, String? semanticLabel}) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(DcSpace.xs),
        child: SizedBox(
          height: 60,
          child: Semantics(
            label: semanticLabel,
            child: FilledButton(
              key: Key('pad.$id'),
              onPressed: enabled ? onPressed : null,
              style: FilledButton.styleFrom(
                backgroundColor: c.tile,
                foregroundColor: c.ink,
                disabledBackgroundColor: c.tile.withValues(alpha: 0.6),
                disabledForegroundColor: c.muted,
                padding: EdgeInsets.zero,
                minimumSize: const Size(44, 60),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DcRadius.button)),
                elevation: 0,
              ),
              child: child ?? Text(id, style: DcType.number(24, weight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
    Widget row(List<String> digits) => Row(children: [for (final d in digits) key(d, onPressed: () => _press(d))]);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DcTile(
          key: const Key('pad.display'),
          padding: const EdgeInsets.all(DcSpace.xl),
          child: Semantics(
            liveRegion: true,
            child: Column(
              children: [
                Text(l10n.detailCard, style: DcType.ui(12).copyWith(color: c.muted)),
                const SizedBox(height: DcSpace.xs),
                if (_digits.isEmpty)
                  SizedBox(
                    height: 42,
                    child: Center(
                      child: Text(
                        l10n.cardNumberHint,
                        textAlign: TextAlign.center,
                        style: DcType.ui(15).copyWith(color: c.muted),
                      ),
                    ),
                  )
                else
                  Text(
                    formatCardNumber(_digits),
                    style: DcType.number(40).copyWith(color: c.ink, letterSpacing: 3),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DcSpace.sm),
        row(['1', '2', '3']),
        row(['4', '5', '6']),
        row(['7', '8', '9']),
        Row(
          children: [
            key('clear', onPressed: _clear, child: Text(l10n.clear, style: DcType.ui(16, weight: FontWeight.w700))),
            key('0', onPressed: () => _press('0')),
            key(
              'back',
              onPressed: _backspace,
              semanticLabel: l10n.padBackspace,
              child: HugeIcon(icon: HugeIcons.strokeRoundedDeletePutBack, color: enabled ? c.ink : c.muted, size: 26),
            ),
          ],
        ),
        const SizedBox(height: DcSpace.sm),
        SizedBox(
          height: 60,
          child: DcButton(
            key: const Key('pad.find'),
            label: l10n.findCard,
            icon: HugeIcons.strokeRoundedSearch01,
            loading: widget.busy,
            onPressed: enabled && _digits.length == cardNumberDigits ? _submit : null,
          ),
        ),
      ],
    );
  }
}

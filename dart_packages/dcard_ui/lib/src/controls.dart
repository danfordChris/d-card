import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import 'tokens.dart';
import 'typography.dart';

enum DcButtonVariant { primary, tonal, danger }

/// Full-width 56 px button with an optional Hugeicon and a loading state.
class DcButton extends StatelessWidget {
  const DcButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = DcButtonVariant.primary,
    this.icon,
    this.loading = false,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final DcButtonVariant variant;
  final List<List<dynamic>>? icon;
  final bool loading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    final (bg, fg) = switch (variant) {
      DcButtonVariant.primary => (c.primary, c.onPrimary),
      DcButtonVariant.tonal => (c.tile, c.ink),
      DcButtonVariant.danger => (c.dangerBg, c.dangerFg),
    };
    final enabled = onPressed != null && !loading;
    final child = loading
        ? SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: fg))
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[HugeIcon(icon: icon!, color: fg, size: 20), const SizedBox(width: DcSpace.sm)],
              Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
            ],
          );
    final button = FilledButton(
      onPressed: enabled ? onPressed : null,
      style: FilledButton.styleFrom(
        backgroundColor: bg,
        foregroundColor: fg,
        disabledBackgroundColor: bg.withValues(alpha: 0.5),
        disabledForegroundColor: fg.withValues(alpha: 0.7),
        minimumSize: const Size(44, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DcRadius.button)),
        textStyle: DcType.ui(16, weight: FontWeight.w700),
        elevation: 0,
      ),
      child: child,
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: loading ? label : null,
      child: expand ? SizedBox(width: double.infinity, child: button) : button,
    );
  }
}

/// Filled text field with the label above it (no outline).
class DcField extends StatelessWidget {
  const DcField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.textInputAction,
    this.inputFormatters,
    this.autofillHints,
    this.prefixIcon,
    this.enabled = true,
    this.validator,
    this.onSubmitted,
    this.suffix,
    this.autofocus = false,
    this.autocorrect = true,
    this.textAlign = TextAlign.start,
    this.style,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final List<List<dynamic>>? prefixIcon;
  final bool enabled;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onSubmitted;

  /// Trailing widget inside the field (e.g. a paste button).
  final Widget? suffix;
  final bool autofocus;
  final bool autocorrect;
  final TextAlign textAlign;

  /// Overrides the input text style (e.g. a big Playfair number).
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    // MergeSemantics: screen readers read the visible label together with the field.
    return MergeSemantics(
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: DcType.ui(13, weight: FontWeight.w600).copyWith(color: c.ink)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          enabled: enabled,
          validator: validator,
          onFieldSubmitted: onSubmitted,
          autofocus: autofocus,
          autocorrect: autocorrect,
          textAlign: textAlign,
          style: style ?? DcType.ui(15).copyWith(color: c.ink),
          decoration: InputDecoration(
            hintText: hint,
            errorText: errorText,
            errorMaxLines: 3,
            suffixIcon: suffix,
            prefixIcon: prefixIcon == null ? null : Padding(padding: const EdgeInsets.only(left: 14, right: 8), child: HugeIcon(icon: prefixIcon!, color: c.muted, size: 20)),
            prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
      ],
      ),
    );
  }
}

/// Status pill: tonal background, never outlined.
class DcBadge extends StatelessWidget {
  const DcBadge({super.key, required this.label, this.tone = DcTone.neutral});

  final String label;
  final DcTone tone;

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = context.dc.tone(tone);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(DcRadius.pill)),
      child: Text(label, style: DcType.ui(12, weight: FontWeight.w700).copyWith(color: fg)),
    );
  }
}

/// One option of a [DcSegmented] control.
class DcSegment<T> {
  const DcSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final List<List<dynamic>>? icon;
}

/// Segmented control on a tile background (door Scan / Number / Name, filters).
class DcSegmented<T> extends StatelessWidget {
  const DcSegmented({super.key, required this.segments, required this.selected, required this.onChanged});

  final List<DcSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: c.tile, borderRadius: BorderRadius.circular(DcRadius.action)),
      child: Row(
        children: [
          for (var i = 0; i < segments.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Semantics(
                button: true,
                selected: segments[i].value == selected,
                child: Material(
                  color: segments[i].value == selected ? c.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => onChanged(segments[i].value),
                    child: SizedBox(
                      height: 44,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (segments[i].icon != null) ...[
                            HugeIcon(icon: segments[i].icon!, size: 18, color: segments[i].value == selected ? c.onPrimary : c.ink),
                            const SizedBox(width: 6),
                          ],
                          Flexible(
                            child: Text(
                              segments[i].label,
                              overflow: TextOverflow.ellipsis,
                              style: DcType.ui(14, weight: FontWeight.w700).copyWith(color: segments[i].value == selected ? c.onPrimary : c.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

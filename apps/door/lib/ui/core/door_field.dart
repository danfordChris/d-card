import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

/// A filled text field with its label above, like `DcField`, for the inputs that need more
/// than `DcField` offers (submit on enter, capitalisation, several lines, a length counter).
class DoorField extends StatelessWidget {
  const DoorField({
    super.key,
    required this.label,
    this.controller,
    this.hint,
    this.errorText,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.maxLength,
    this.minLines,
    this.maxLines = 1,
    this.prefixIcon,
    this.large = false,
    this.showLabel = true,
  });

  final String label;
  final TextEditingController? controller;
  final String? hint;
  final String? errorText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final int? minLines;
  final int maxLines;
  final List<List<dynamic>>? prefixIcon;

  /// Bigger text for fields staff type into at a busy door (name search).
  final bool large;

  /// False keeps the label for screen readers only (the field has a visible icon and hint).
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    final field = TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      maxLengthEnforcement: MaxLengthEnforcement.enforced,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines,
      style: DcType.ui(large ? 18 : 15).copyWith(color: c.ink),
      decoration: InputDecoration(
        hintText: hint,
        errorText: errorText,
        labelText: showLabel ? null : label,
        floatingLabelBehavior: showLabel ? null : FloatingLabelBehavior.never,
        prefixIcon: prefixIcon == null
            ? null
            : Padding(
                padding: const EdgeInsets.only(left: 14, right: 8),
                child: HugeIcon(icon: prefixIcon!, color: c.muted, size: 20),
              ),
        prefixIconConstraints: const BoxConstraints(minWidth: 40, minHeight: 40),
      ),
    );
    if (!showLabel) return field;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: DcType.ui(13, weight: FontWeight.w600).copyWith(color: c.ink)),
          const SizedBox(height: 6),
          field,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';

import '../../../../domain/models/billing.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/money.dart';

/// Payments are in Tanzania (UTC+03:00, no daylight saving): show East Africa Time.
String formatEat(BuildContext context, DateTime at) {
  final eat = at.toUtc().add(const Duration(hours: 3));
  final locale = Localizations.localeOf(context).toLanguageTag();
  return '${DateFormat.yMMMd(locale).format(eat)} · ${DateFormat.Hm(locale).format(eat)} EAT';
}

/// Flat surface with a hairline border (no shadow).
class FlatCard extends StatelessWidget {
  const FlatCard({super.key, required this.child, this.color, this.padding = const EdgeInsets.all(16)});

  final Widget child;
  final Color? color;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? scheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: child,
    );
  }
}

/// Tinted circle with a Hugeicon (list rows, states).
class IconDisc extends StatelessWidget {
  const IconDisc({super.key, required this.icon, this.size = 40, this.background, this.foreground});

  final List<List<dynamic>> icon;
  final double size;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background ?? scheme.primaryContainer, shape: BoxShape.circle),
      child: HugeIcon(icon: icon, size: size / 2, color: foreground ?? scheme.onPrimaryContainer),
    );
  }
}

/// Label on the left, amount right-aligned with tabular figures.
class AmountRow extends StatelessWidget {
  const AmountRow({super.key, required this.label, required this.value, this.strong = false, this.valueKey});

  final String label;
  final String value;
  final bool strong;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final style = (strong ? text.titleMedium : text.bodyMedium)?.copyWith(
      fontWeight: strong ? FontWeight.w700 : null,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: strong ? style : text.bodyMedium)),
          const SizedBox(width: 12),
          Text(value, key: valueKey, style: style, textAlign: TextAlign.right),
        ],
      ),
    );
  }
}

String quoteLineLabel(AppLocalizations l10n, QuoteLine line) => switch (line.kind) {
  QuoteLineKind.newCards => l10n.checkoutLineNewCards(line.quantity, tsh(line.unitPrice)),
  QuoteLineKind.extraCards => l10n.checkoutLineExtraCards(line.quantity, tsh(line.unitPrice)),
  QuoteLineKind.upgrade => l10n.checkoutLineUpgrade(line.quantity, tsh(line.unitPrice)),
  QuoteLineKind.other => l10n.checkoutLineOther(line.quantity),
};

/// The server quote: lines, subtotal, launch offer and total.
class QuoteBreakdown extends StatelessWidget {
  const QuoteBreakdown({super.key, required this.quote});

  final BillingQuote quote;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        for (final line in quote.lines) AmountRow(label: quoteLineLabel(l10n, line), value: tsh(line.amount)),
        if (quote.discountAmount > 0) ...[
          const Divider(height: 16),
          AmountRow(label: l10n.checkoutSubtotal, value: tsh(quote.subtotal)),
          AmountRow(
            label: l10n.checkoutLaunchOffer(quote.discountPercent),
            value: '− ${tsh(quote.discountAmount)}',
            valueKey: const Key('checkout.discount'),
          ),
        ],
        const Divider(height: 16),
        AmountRow(
          label: l10n.checkoutTotal,
          value: tsh(quote.total),
          strong: true,
          valueKey: const Key('checkout.total'),
        ),
      ],
    );
  }
}

/// A payment receipt: reference, amount, cards, plan and date (EAT).
class ReceiptDetails extends StatelessWidget {
  const ReceiptDetails({
    super.key,
    required this.reference,
    required this.amount,
    required this.guestCards,
    required this.planName,
    required this.date,
    this.discount = 0,
  });

  final String? reference;
  final int amount;
  final int discount;
  final int guestCards;
  final String planName;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        if (reference != null && reference!.isNotEmpty)
          AmountRow(label: l10n.receiptReference, value: reference!, valueKey: const Key('receipt.reference')),
        AmountRow(label: l10n.receiptAmount, value: tsh(amount), strong: true),
        if (discount > 0) AmountRow(label: l10n.receiptDiscount, value: '− ${tsh(discount)}'),
        AmountRow(label: l10n.receiptCards, value: l10n.receiptCardsValue(guestCards)),
        AmountRow(label: l10n.receiptPlan, value: planName),
        if (date != null) AmountRow(label: l10n.receiptDate, value: formatEat(context, date!)),
      ],
    );
  }
}

/// Info (primary tint) or error notice.
class Notice extends StatelessWidget {
  const Notice({super.key, required this.text, this.error = false});

  final String text;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bg = error ? scheme.errorContainer : scheme.secondaryContainer;
    final fg = error ? scheme.onErrorContainer : scheme.onSecondaryContainer;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HugeIcon(icon: error ? HugeIcons.strokeRoundedAlert02 : HugeIcons.strokeRoundedAlertCircle, size: 20, color: fg),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: fg))),
        ],
      ),
    );
  }
}

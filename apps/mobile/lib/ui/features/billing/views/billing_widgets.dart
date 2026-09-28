import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
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

/// Label on the left, amount right-aligned with tabular figures.
class AmountRow extends StatelessWidget {
  const AmountRow({
    super.key,
    required this.label,
    required this.value,
    this.strong = false,
    this.valueKey,
    this.onHero = false,
  });

  final String label;
  final String value;
  final bool strong;
  final Key? valueKey;

  /// Text colours for a hero tile background.
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    final labelStyle = strong ? DcType.ui(15, weight: FontWeight.w700) : DcType.ui(14);
    final valueStyle = (strong ? DcType.number(20) : DcType.ui(14, weight: FontWeight.w600))
        .copyWith(fontFeatures: const [FontFeature.tabularFigures()]);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: labelStyle.copyWith(color: onHero ? (strong ? c.onHero : c.heroMuted) : (strong ? c.ink : c.muted)),
            ),
          ),
          const SizedBox(width: DcSpace.md),
          Text(
            value,
            key: valueKey,
            style: valueStyle.copyWith(color: onHero ? c.onHero : c.ink),
            textAlign: TextAlign.right,
          ),
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
  const QuoteBreakdown({super.key, required this.quote, this.onHero = false});

  final BillingQuote quote;

  /// Text colours for a hero tile background.
  final bool onHero;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final divider = Divider(height: 16, color: onHero ? c.heroMuted.withValues(alpha: 0.3) : c.line);
    return Column(
      children: [
        for (final line in quote.lines)
          AmountRow(label: quoteLineLabel(l10n, line), value: tsh(line.amount), onHero: onHero),
        if (quote.discountAmount > 0) ...[
          divider,
          AmountRow(label: l10n.checkoutSubtotal, value: tsh(quote.subtotal), onHero: onHero),
          AmountRow(
            label: l10n.checkoutLaunchOffer(quote.discountPercent),
            value: '− ${tsh(quote.discountAmount)}',
            valueKey: const Key('checkout.discount'),
            onHero: onHero,
          ),
        ],
        divider,
        AmountRow(
          label: l10n.checkoutTotal,
          value: tsh(quote.total),
          strong: true,
          valueKey: const Key('checkout.total'),
          onHero: onHero,
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

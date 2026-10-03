import 'package:dcard_api/api.dart';
import 'package:dcard_core/dcard_core.dart';
import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../data/repositories/guests_repository.dart';
import '../../../../domain/models/app_failure.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import 'guest_result.dart';

class GuestDetailScreen extends StatefulWidget {
  const GuestDetailScreen({
    super.key,
    required this.eventId,
    required this.guest,
    required this.repository,
    required this.canManage,
  });

  final String eventId;
  final Guest guest;
  final GuestsRepository repository;
  final bool canManage;

  @override
  State<GuestDetailScreen> createState() => _GuestDetailScreenState();
}

class _GuestDetailScreenState extends State<GuestDetailScreen> {
  late Guest _guest = widget.guest;
  bool _busy = false;

  void _snack(String text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _issueCard() async {
    setState(() => _busy = true);
    try {
      final card = await widget.repository.issueCard(widget.eventId, _guest.id);
      _guest = Guest(
        id: _guest.id,
        eventId: _guest.eventId,
        personId: _guest.personId,
        name: _guest.name,
        phone: _guest.phone,
        partnerName: _guest.partnerName,
        cardType: card.cardType,
        totalEntries: _guest.totalEntries,
        status: GuestStatusEnum.issued,
        cardNumber: card.cardNumber,
        issuedAt: card.issuedAt,
        createdAt: _guest.createdAt,
        updatedAt: DateTime.now(),
      );
      if (mounted) _snack(AppLocalizations.of(context).guestCardIssued);
    } on AppException catch (e) {
      if (mounted) _snack(AppLocalizations.of(context).failure(e.failure));
    } catch (_) {
      if (mounted) _snack(AppLocalizations.of(context).errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _cancelCard() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(l10n.guestCancelCardTitle, l10n.guestCancelCardBody, l10n.guestCancelCardAction);
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      await widget.repository.cancelCard(widget.eventId, _guest.id);
      _guest = Guest(
        id: _guest.id,
        eventId: _guest.eventId,
        personId: _guest.personId,
        name: _guest.name,
        phone: _guest.phone,
        partnerName: _guest.partnerName,
        cardType: _guest.cardType,
        totalEntries: _guest.totalEntries,
        status: GuestStatusEnum.cancelled,
        cardNumber: _guest.cardNumber,
        issuedAt: _guest.issuedAt,
        createdAt: _guest.createdAt,
        updatedAt: DateTime.now(),
      );
      if (mounted) _snack(l10n.guestCardCancelled);
    } on AppException catch (e) {
      if (mounted) _snack(l10n.failure(e.failure));
    } catch (_) {
      if (mounted) _snack(l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _reinstateCard() async {
    setState(() => _busy = true);
    try {
      final card = await widget.repository.reinstateCard(widget.eventId, _guest.id);
      _guest = Guest(
        id: _guest.id,
        eventId: _guest.eventId,
        personId: _guest.personId,
        name: _guest.name,
        phone: _guest.phone,
        partnerName: _guest.partnerName,
        cardType: card.cardType,
        totalEntries: _guest.totalEntries,
        status: GuestStatusEnum.issued,
        cardNumber: card.cardNumber,
        issuedAt: card.issuedAt,
        createdAt: _guest.createdAt,
        updatedAt: DateTime.now(),
      );
      if (mounted) _snack(AppLocalizations.of(context).guestCardReinstated);
    } on AppException catch (e) {
      if (mounted) _snack(AppLocalizations.of(context).failure(e.failure));
    } catch (_) {
      if (mounted) _snack(AppLocalizations.of(context).errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _copyCardLink() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _busy = true);
    try {
      final cardLink = await widget.repository.getCardLink(widget.eventId, _guest.id);
      await Clipboard.setData(ClipboardData(text: cardLink.link));
      if (mounted) _snack(l10n.guestLinkCopied);
    } on AppException catch (e) {
      if (mounted) _snack(l10n.failure(e.failure));
    } catch (_) {
      if (mounted) _snack(l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _removeGuest() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await _confirm(l10n.guestRemoveTitle, l10n.guestRemoveBody, l10n.guestRemoveAction);
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      await widget.repository.remove(widget.eventId, _guest.id);
      if (mounted) Navigator.of(context).pop(GuestRemoved(_guest.id));
      return;
    } on AppException catch (e) {
      if (mounted) _snack(l10n.failure(e.failure));
    } catch (_) {
      if (mounted) _snack(l10n.errorGeneric);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool?> _confirm(String title, String body, String action) {
    final c = context.dc;
    return showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(DcSpace.xxl, 0, DcSpace.xxl, DcSpace.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: DcType.heading(22).copyWith(color: c.ink)),
              const SizedBox(height: DcSpace.sm),
              Text(body, style: DcType.ui(14).copyWith(color: c.muted)),
              const SizedBox(height: DcSpace.xxl),
              DcButton(variant: DcButtonVariant.danger, label: action, onPressed: () => Navigator.of(context).pop(true)),
              const SizedBox(height: DcSpace.sm),
              DcButton(
                variant: DcButtonVariant.tonal,
                label: AppLocalizations.of(context).cancel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final c = context.dc;
    final isIssued = _guest.status == GuestStatusEnum.issued;
    final isCancelled = _guest.status == GuestStatusEnum.cancelled;
    final isPending = _guest.status == GuestStatusEnum.pending;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) Navigator.of(context).pop(GuestUpdated(_guest));
      },
      child: Scaffold(
        appBar: DcTopBar(title: l10n.guestDetailTitle, backLabel: l10n.back),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(DcSpace.page, DcSpace.sm, DcSpace.page, DcSpace.xxxl),
          children: [
            DcTile(
              variant: DcTileVariant.hero,
              radius: DcRadius.hero,
              padding: const EdgeInsets.all(DcSpace.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_guest.name, style: DcType.heading(24).copyWith(color: c.onHero)),
                  const SizedBox(height: 4),
                  Text(formatLocalPhone(_guest.phone), style: DcType.ui(14).copyWith(color: c.heroMuted)),
                  if (_guest.partnerName != null) ...[
                    const SizedBox(height: 2),
                    Text('+ ${_guest.partnerName}', style: DcType.ui(14).copyWith(color: c.heroMuted)),
                  ],
                ],
              ),
            ),
            const SizedBox(height: DcSpace.gap),
            DcBento(
              items: [
                DcBentoItem(
                  DcStatTile(
                    label: l10n.guestCardStatusLabel,
                    value: _statusLabel(l10n),
                  ),
                ),
                DcBentoItem(
                  DcStatTile(
                    variant: DcTileVariant.soft,
                    label: l10n.guestCardTypeLabel,
                    value: _guest.cardType == CardType.double_ ? l10n.cardTypeDouble : l10n.cardTypeSingle,
                  ),
                ),
              ],
            ),
            if (_guest.cardNumber != null) ...[
              const SizedBox(height: DcSpace.gap),
              _InfoRow(icon: HugeIcons.strokeRoundedTicket01, label: l10n.cardNumberLabel, value: _guest.cardNumber!),
            ],
            if (widget.canManage) ...[
              DcSectionHeader(title: l10n.guestActions),
              const SizedBox(height: DcSpace.xs),
              if (isPending)
                _ActionButton(
                  icon: HugeIcons.strokeRoundedTicket01,
                  label: l10n.guestIssueCard,
                  busy: _busy,
                  onTap: _issueCard,
                ),
              if (isIssued) ...[
                _ActionButton(
                  icon: HugeIcons.strokeRoundedLink01,
                  label: l10n.guestCopyLink,
                  busy: _busy,
                  onTap: _copyCardLink,
                ),
                const SizedBox(height: DcSpace.sm),
                _ActionButton(
                  icon: HugeIcons.strokeRoundedCancelCircle,
                  label: l10n.guestCancelCard,
                  busy: _busy,
                  onTap: _cancelCard,
                  danger: true,
                ),
              ],
              if (isCancelled)
                _ActionButton(
                  icon: HugeIcons.strokeRoundedRefresh,
                  label: l10n.guestReinstateCard,
                  busy: _busy,
                  onTap: _reinstateCard,
                ),
              const SizedBox(height: DcSpace.lg),
              _ActionButton(
                icon: HugeIcons.strokeRoundedDelete02,
                label: l10n.guestRemoveAction,
                busy: _busy,
                onTap: _removeGuest,
                danger: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _statusLabel(AppLocalizations l10n) => switch (_guest.status) {
    GuestStatusEnum.pending => l10n.guestStatusPending,
    GuestStatusEnum.issued => l10n.guestStatusIssued,
    GuestStatusEnum.cancelled => l10n.statusCancelled,
    _ => '',
  };
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final List<List<dynamic>> icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: DcSpace.sm),
      child: Row(
        children: [
          DcIconDisc(icon: icon, background: c.tile),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DcType.ui(13).copyWith(color: c.muted)),
                const SizedBox(height: 2),
                Text(value, style: DcType.ui(15, weight: FontWeight.w600).copyWith(color: c.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.busy,
    required this.onTap,
    this.danger = false,
  });

  final List<List<dynamic>> icon;
  final String label;
  final bool busy;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final c = context.dc;
    return DcTile(
      onTap: busy ? null : onTap,
      child: Row(
        children: [
          DcIconDisc(icon: icon, background: danger ? c.dangerBg : c.tile),
          const SizedBox(width: 14),
          Expanded(child: Text(label, style: DcType.ui(15, weight: FontWeight.w600).copyWith(color: danger ? c.dangerFg : c.ink))),
          if (busy) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
        ],
      ),
    );
  }
}


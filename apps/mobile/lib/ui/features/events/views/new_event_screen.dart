import 'package:dcard_api/api.dart';
import 'package:dcard_ui/dcard_ui.dart';
import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../core/failure_text.dart';
import '../../../core/money.dart';
import '../view_models/create_event_view_model.dart';

class NewEventScreen extends StatefulWidget {
  const NewEventScreen({super.key, required this.viewModel, this.onCreated});

  final CreateEventViewModel viewModel;
  final VoidCallback? onCreated;

  @override
  State<NewEventScreen> createState() => _NewEventScreenState();
}

class _NewEventScreenState extends State<NewEventScreen> {
  final _titleCtrl = TextEditingController();
  final _contactNameCtrl = TextEditingController();
  final _contactPhoneCtrl = TextEditingController();
  final _venueNameCtrl = TextEditingController();
  final _venueAddressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onVmChange);
    if (widget.viewModel.eventTypes.isEmpty) widget.viewModel.loadOptions();
  }

  void _onVmChange() {
    if (widget.viewModel.created) {
      widget.onCreated?.call();
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onVmChange);
    _titleCtrl.dispose();
    _contactNameCtrl.dispose();
    _contactPhoneCtrl.dispose();
    _venueNameCtrl.dispose();
    _venueAddressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: widget.viewModel,
          builder: (context, _) {
            final vm = widget.viewModel;
            if (vm.loading) {
              return Column(
                children: [
                  DcPageHeader(title: l10n.newEventTitle),
                  const Expanded(child: DcStateView(kind: DcStateKind.loading)),
                ],
              );
            }
            if (vm.failure != null && vm.eventTypes.isEmpty) {
              return Column(
                children: [
                  DcPageHeader(title: l10n.newEventTitle),
                  Expanded(
                    child: DcStateView(
                      kind: DcStateKind.error,
                      title: l10n.failure(vm.failure!),
                      actionLabel: l10n.retry,
                      onAction: vm.loadOptions,
                    ),
                  ),
                ],
              );
            }
            final c = context.dc;
            final lang = Localizations.localeOf(context).languageCode;
            return Column(
              children: [
                DcPageHeader(title: l10n.newEventTitle),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.fromLTRB(
                      DcSpace.page, DcSpace.sm, DcSpace.page,
                      DcSpace.xxxl + DcSpotlightNavBar.reservedHeight,
                    ),
                    children: [
                      if (vm.failure != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: DcSpace.lg),
                          child: DcNoticeTile(tone: DcTone.danger, message: l10n.failure(vm.failure!)),
                        ),

                      Text(l10n.createEventTypeLabel, style: DcType.ui(13, weight: FontWeight.w600).copyWith(color: c.ink)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<EventType>(
                        key: const Key('create.type'),
                        initialValue: vm.selectedType,
                        icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01, size: 20, color: c.muted),
                        borderRadius: BorderRadius.circular(DcRadius.input),
                        dropdownColor: c.bg,
                        hint: Text(l10n.createEventTypeHint),
                        items: [
                          for (final t in vm.eventTypes)
                            DropdownMenuItem(value: t, child: Text(lang == 'sw' ? t.nameSw : t.nameEn)),
                        ],
                        onChanged: vm.setType,
                      ),
                      const SizedBox(height: DcSpace.lg),

                      Text(l10n.createPlanLabel, style: DcType.ui(13, weight: FontWeight.w600).copyWith(color: c.ink)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<Plan>(
                        key: const Key('create.plan'),
                        initialValue: vm.selectedPlan,
                        icon: HugeIcon(icon: HugeIcons.strokeRoundedArrowDown01, size: 20, color: c.muted),
                        borderRadius: BorderRadius.circular(DcRadius.input),
                        dropdownColor: c.bg,
                        hint: Text(l10n.createPlanHint),
                        items: [
                          for (final p in vm.plans)
                            DropdownMenuItem(
                              value: p,
                              child: Text('${p.name} — ${tsh(p.pricePerGuest)}/guest'),
                            ),
                        ],
                        onChanged: vm.setPlan,
                      ),
                      const SizedBox(height: DcSpace.lg),

                      DcField(
                        key: const Key('create.title'),
                        controller: _titleCtrl,
                        label: l10n.createTitleLabel,
                        hint: l10n.createTitleHint,
                        onChanged: vm.setTitle,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: DcSpace.lg),

                      Text(l10n.createDateLabel, style: DcType.ui(13, weight: FontWeight.w600).copyWith(color: c.ink)),
                      const SizedBox(height: 6),
                      DcTile(
                        key: const Key('create.date'),
                        padding: const EdgeInsets.symmetric(horizontal: DcSpace.lg, vertical: DcSpace.md),
                        radius: DcRadius.input,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: vm.startsAt ?? DateTime.now().add(const Duration(days: 14)),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 730)),
                          );
                          if (picked != null) vm.setDate(picked);
                        },
                        child: Row(
                          children: [
                            HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, size: 20, color: c.muted),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                vm.startsAt != null
                                    ? MaterialLocalizations.of(context).formatMediumDate(vm.startsAt!)
                                    : l10n.createDateHint,
                                style: DcType.ui(15).copyWith(color: vm.startsAt != null ? c.ink : c.muted),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: DcSpace.lg),

                      DcSectionHeader(title: l10n.createContactSection),
                      const SizedBox(height: DcSpace.xs),
                      DcField(
                        key: const Key('create.contactName'),
                        controller: _contactNameCtrl,
                        label: l10n.createContactNameLabel,
                        hint: l10n.createContactNameHint,
                        onChanged: vm.setContactName,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: DcSpace.lg),
                      DcField(
                        key: const Key('create.contactPhone'),
                        controller: _contactPhoneCtrl,
                        label: l10n.createContactPhoneLabel,
                        hint: l10n.createContactPhoneHint,
                        keyboardType: TextInputType.phone,
                        onChanged: vm.setContactPhone,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: DcSpace.lg),

                      DcSectionHeader(title: l10n.createVenueSection),
                      const SizedBox(height: DcSpace.xs),
                      DcField(
                        key: const Key('create.venueName'),
                        controller: _venueNameCtrl,
                        label: l10n.createVenueNameLabel,
                        hint: l10n.createVenueNameHint,
                        onChanged: vm.setVenueName,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: DcSpace.lg),
                      DcField(
                        key: const Key('create.venueAddress'),
                        controller: _venueAddressCtrl,
                        label: l10n.createVenueAddressLabel,
                        hint: l10n.createVenueAddressHint,
                        onChanged: vm.setVenueAddress,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: DcSpace.xxl),

                      DcButton(
                        key: const Key('create.submit'),
                        label: vm.submitting ? l10n.createSubmitting : l10n.createSubmit,
                        onPressed: vm.canSubmit ? vm.submit : null,
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

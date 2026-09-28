import 'package:dcard_ui/dcard_ui.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../domain/models/check_in.dart';

/// Tone + icon so a verdict reads at a glance at a noisy door (colour is never the only signal:
/// each tone has its own icon and a written headline).
class Verdict {
  const Verdict(this.tone, this.icon);

  final DcTone tone;
  final List<List<dynamic>> icon;

  static const ok = Verdict(DcTone.success, HugeIcons.strokeRoundedTick02);
  static const refused = Verdict(DcTone.danger, HugeIcons.strokeRoundedCancel01);
  static const warning = Verdict(DcTone.warning, HugeIcons.strokeRoundedHelpCircle);
  static const locked = Verdict(DcTone.warning, HugeIcons.strokeRoundedSquareLock02);
}

Verdict verdictOf(CheckInCard card) => switch (card.refusal) {
  null => Verdict.ok,
  RefusalReason.notIssued || RefusalReason.notFound => Verdict.warning,
  _ => Verdict.refused,
};

Verdict verdictOfRefusal(RefusalReason reason) => switch (reason) {
  RefusalReason.locked => Verdict.locked,
  RefusalReason.notFound || RefusalReason.notIssued => Verdict.warning,
  _ => Verdict.refused,
};

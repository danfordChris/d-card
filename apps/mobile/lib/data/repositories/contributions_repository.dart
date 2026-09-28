import 'package:dcard_api/api.dart' as api;

import '../../domain/models/contributor.dart';
import 'api_errors.dart';

/// Contributions for treasurers and the host (`/api/v1/events/{id}/contributions`, payments).
class ContributionsRepository {
  ContributionsRepository(this._api);

  final api.DefaultApi _api;

  Future<(ContributionTotals, List<Contributor>)> list(String eventId) async {
    final result = await guardApi(() => _api.getContributions(eventId));
    final s = result.summary;
    return (
      ContributionTotals(pledged: s.pledged, collected: s.collected, outstanding: s.outstanding),
      result.contributors.map(_toContributor).toList(),
    );
  }

  Future<Contributor> recordPayment(
    String eventId,
    String pledgeId, {
    required int amount,
    required PaymentMethod method,
    String? reference,
    required DateTime paidOn,
  }) async {
    final input = api.PaymentCreateInput(
      amount: amount,
      method: _methods[method]!,
      reference: reference,
      paidOn: DateTime.utc(paidOn.year, paidOn.month, paidOn.day),
    );
    final result = await guardApi(() => _api.recordPayment(eventId, pledgeId, paymentCreateInput: input));
    return _toContributor(result.pledge);
  }

  static const _methods = {
    PaymentMethod.mpesa: api.PaymentMethod.mpesa,
    PaymentMethod.mixxByYas: api.PaymentMethod.mixxByYas,
    PaymentMethod.airtelMoney: api.PaymentMethod.airtelMoney,
    PaymentMethod.halopesa: api.PaymentMethod.halopesa,
    PaymentMethod.bank: api.PaymentMethod.bank,
    PaymentMethod.cash: api.PaymentMethod.cash,
    PaymentMethod.other: api.PaymentMethod.other,
  };

  static Contributor _toContributor(api.Pledge p) => Contributor(
    id: p.id,
    name: p.name,
    phone: p.phone,
    isDouble: p.cardType == api.CardType.double_,
    pledged: p.amountPledged,
    paid: p.amountPaid,
    balance: p.balance,
    extra: p.amountExtra,
    status: switch (p.status) {
      api.PledgeStatus.fullyPaid => PledgeStatus.fullyPaid,
      api.PledgeStatus.partPaid => PledgeStatus.partPaid,
      _ => PledgeStatus.notPaid,
    },
    cancelled: p.invitationStatus == api.PledgeInvitationStatusEnum.cancelled,
    cardNumber: p.cardNumber,
  );
}

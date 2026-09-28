import 'package:intl/intl.dart';

final _grouped = NumberFormat.decimalPattern('en');

/// The one money format in the app: whole Tanzanian shillings, e.g. `TSh 50,000`.
String tsh(int amount) => 'TSh ${_grouped.format(amount)}';

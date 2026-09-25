import 'package:intl/intl.dart';

final _grouped = NumberFormat.decimalPattern('en');

String tsh(int amount) => 'Tsh ${_grouped.format(amount)}';

// Mirrors packages/core/src/phone/phone.ts. Keep both implementations in sync.
// docs/design/features/guests-and-cards.md (GST-3): phones are stored as 255 + 9 digits.

/// Thrown when an input cannot be normalised to `255` + 9 digits.
class InvalidPhoneException implements Exception {
  InvalidPhoneException(this.input);

  final String input;

  @override
  String toString() =>
      'InvalidPhoneException: "$input" is not a Tanzanian number (255 followed by 9 digits).';
}

final _separators = RegExp(r'[\s\-().]');
final _digitsOnly = RegExp(r'^\d+$');

/// Normalises `0XXXXXXXXX`, `+255XXXXXXXXX`, `255XXXXXXXXX` or `XXXXXXXXX`
/// (spaces, dashes, dots and parentheses allowed) to `255XXXXXXXXX`.
String normalisePhone(String input) {
  final cleaned = input.trim().replaceAll(_separators, '');
  final hasPlus = cleaned.startsWith('+');
  final digits = hasPlus ? cleaned.substring(1) : cleaned;
  if (!_digitsOnly.hasMatch(digits)) {
    throw InvalidPhoneException(input);
  }
  final String national;
  if (digits.length == 12 && digits.startsWith('255')) {
    national = digits.substring(3);
  } else if (digits.length == 10 && digits.startsWith('0') && !hasPlus) {
    national = digits.substring(1);
  } else if (digits.length == 9 && !hasPlus) {
    national = digits;
  } else {
    throw InvalidPhoneException(input);
  }
  return '255$national';
}

/// Whether [input] can be normalised.
bool isValidPhone(String input) {
  try {
    normalisePhone(input);
    return true;
  } on InvalidPhoneException {
    return false;
  }
}

/// Formats a stored phone for display: `255754123456` → `0754 123 456`.
String formatLocalPhone(String stored) {
  final n = normalisePhone(stored).substring(3);
  return '0${n.substring(0, 3)} ${n.substring(3, 6)} ${n.substring(6)}';
}

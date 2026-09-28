import 'package:dcard_core/dcard_core.dart';
import 'package:test/test.dart';

void main() {
  group('normalisePhone', () {
    for (final input in [
      '0754123456',
      '+255754123456',
      '754123456',
      '255754123456',
      '0754 123 456',
      '+255 754-123-456',
    ]) {
      test('normalises "$input"', () {
        expect(normalisePhone(input), '255754123456');
      });
    }

    for (final input in [
      '12345',
      '2557541234567',
      '',
      '07541234ab',
      '+0754123456',
      '+754123456',
      '07541234567',
    ]) {
      test('rejects "$input"', () {
        expect(() => normalisePhone(input), throwsA(isA<InvalidPhoneException>()));
        expect(isValidPhone(input), isFalse);
      });
    }
  });

  test('formatLocalPhone', () {
    expect(formatLocalPhone('255754123456'), '0754 123 456');
  });
}

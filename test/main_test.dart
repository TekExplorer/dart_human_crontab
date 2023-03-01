import 'package:dart_human_crontab/dart_human_crontab.dart';
import 'package:test/test.dart';

void main() {
  group('strict parsing', () {
    test('throws on empty string', () {
      expect(() => HumanCrontab.parse(''), throwsA(isA<CrontabException>()));
    });

    test('throws on invalid format', () {
      expect(() => HumanCrontab.parse('this is clearly invalid format'),
          throwsA(isA<CrontabException>()));
    });

    test('throws on missing parts', () {
      expect(() => HumanCrontab.parse('*/5 * * 2'),
          throwsA(isA<CrontabException>()));
    });

    test('allows valid crontab format', () {
      final crontab = HumanCrontab.parse('30 4 */1 12 5');
      expect(crontab.toString(), equals('30 4 */1 12 5'));
      expect(
          crontab.toHuman(),
          equals(
              'At 4:30 on every 1st day of the month on Friday in December'));
    });

    test('allows all wildcards', () {
      final crontab = HumanCrontab.parse('* * * * *');
      expect(crontab.toString(), equals('* * * * *'));
      expect(crontab.toHuman(), equals('every minute'));
    });
  });

  group('relaxed parsing', () {
    test('returns null on empty string', () {
      expect(HumanCrontab.tryParse(''), isNull);
    });

    test('returns null on invalid format', () {
      expect(HumanCrontab.tryParse('this is clearly invalid format'), isNull);
    });

    test('returns null on missing parts', () {
      expect(HumanCrontab.tryParse('*/5 * * 2'), isNull);
    });

    test('allows valid crontab format', () {
      final crontab = HumanCrontab.tryParse('30 4 */1 12 5');
      expect(crontab, isNotNull);
      expect(crontab.toString(), equals('30 4 */1 12 5'));
      expect(
          crontab!.toHuman(),
          equals(
              'At 4:30 on every 1st day of the month on Friday in December'));
    });

    test('allows all wildcards', () {
      final crontab = HumanCrontab.tryParse('* * * * *');
      expect(crontab, isNotNull);
      expect(crontab.toString(), equals('* * * * *'));
      expect(crontab!.toHuman(), equals('every minute'));
    });
  });
}

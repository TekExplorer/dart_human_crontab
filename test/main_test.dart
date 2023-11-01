import 'package:human_crontab/human_crontab.dart';
import 'package:test/test.dart';

void main() {
  group('strict parsing', () {
    test('throws on empty string', () {
      expect(() => HumanCrontab.parse(''), throwsA(isA<ArgumentError>()));
    });

    test('throws on invalid format', () {
      expect(() => HumanCrontab.parse('this is clearly invalid format'),
          throwsA(isA<FormatException>()));
    });

    test('throws on missing parts', () {
      expect(
          () => HumanCrontab.parse('*/5 * * 2'), throwsA(isA<ArgumentError>()));
    });

    test('allows valid crontab format', () {
      final crontab = HumanCrontab.parse('30 4 */1 12 5');
      expect(crontab.toCrontab(), equals('30 4 */1 12 5'));
      expect(crontab.toHuman(),
          equals('at 4:30 on every day of the month on Friday in December'));
    });

    test('allows all wildcards', () {
      final crontab = HumanCrontab.parse('* * * * *');
      expect(crontab.toCrontab(), equals('* * * * *'));
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
      expect(crontab!.toCrontab(), equals('30 4 */1 12 5'));
      expect(crontab.toHuman(),
          equals('at 4:30 on every day of the month on Friday in December'));
    });

    test('allows all wildcards', () {
      final crontab = HumanCrontab.tryParse('* * * * *');
      expect(crontab, isNotNull);
      expect(crontab!.toCrontab(), equals('* * * * *'));
      expect(crontab.toHuman(), equals('every minute'));
    });
  });

  group('Obscure cron formats', () {
    // all unusual cron formats should be tested here
    group('dash format (x-y)', () {
      test('allows 0-5 for minutes', () {
        final crontab = HumanCrontab.tryParse('0-5 * * * *');
        expect(crontab, isNotNull);
        expect(crontab!.toCrontab(), equals('0-5 * * * *'));
        // expect(crontab!.toHuman(), equals('every minute between 0 and 5'));
      });

      test('allows 0-5 for hours', () {
        final crontab = HumanCrontab.tryParse('* 0-5 * * *');
        expect(crontab, isNotNull);
        expect(crontab!.toCrontab(), equals('* 0-5 * * *'));
        // expect(crontab!.toHuman(), equals('every hour between 0 and 5'));
      });

      test('allows 0-5 for days of month', () {
        final crontab = HumanCrontab.tryParse('* * 0-5 * *');
        expect(crontab, isNotNull);
        expect(crontab!.toCrontab(), equals('* * 0-5 * *'));
        // expect(crontab!.toHuman(),
        //     equals('every day of the month between 0 and 5'));
      });

      test('allows 1-5 for months', () {
        final crontab = HumanCrontab.tryParse('* * * 1-5 *');
        expect(crontab, isNotNull);
        expect(crontab!.toCrontab(), equals('* * * 1-5 *'));
        // expect(crontab!.toHuman(), equals('every month between 0 and 5'));
      });

      test('allows 0-5 for days of week', () {
        final crontab = HumanCrontab.tryParse('* * * * 0-5');
        expect(crontab, isNotNull);
        expect(crontab!.toCrontab(), equals('* * * * 0-5'));
        // expect(crontab!.toHuman(),
        //     equals('every day of the week between 0 and 5'));
      });

      test('allows 0-5 for minutes and hours', () {
        final crontab = HumanCrontab.tryParse('0-5 0-5 * * *');
        expect(crontab, isNotNull);
        expect(crontab!.toCrontab(), equals('0-5 0-5 * * *'));
        // expect(
        //     crontab!.toHuman(),
        //     equals(
        //         'every minute between 0 and 5 and every hour between 0 and 5'));
      });
    });
  });
}

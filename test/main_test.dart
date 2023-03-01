import 'package:human_crontab/human_crontab.dart';
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

  group('Obscure cron formats', () {
    // all unusual cron formats should be tested here
    group('slash format (x/y)', () {
      test('allows 0/5 for minutes', () {
        final crontab = HumanCrontab.tryParse('0/5 * * * *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('0/5 * * * *'));
        // expect(crontab!.toHuman(), equals('every 5 minutes'));
      });

      test('allows 0/5 for hours', () {
        final crontab = HumanCrontab.tryParse('* 0/5 * * *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('* 0/5 * * *'));
        // expect(crontab!.toHuman(), equals('every 5 hours'));
      });

      test('allows 0/5 for days of month', () {
        final crontab = HumanCrontab.tryParse('* * 0/5 * *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('* * 0/5 * *'));
        // expect(crontab!.toHuman(), equals('every 5 days of the month'));
      });

      test('allows 0/5 for months', () {
        final crontab = HumanCrontab.tryParse('* * * 0/5 *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('* * * 0/5 *'));
        // expect(crontab!.toHuman(), equals('every 5 months'));
      });

      test('allows 0/5 for days of week', () {
        final crontab = HumanCrontab.tryParse('* * * * 0/5');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('* * * * 0/5'));
        // expect(crontab!.toHuman(), equals('every 5 days of the week'));
      });

      test('allows 0/5 for minutes and hours', () {
        final crontab = HumanCrontab.tryParse('0/5 0/5 * * *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('0/5 0/5 * * *'));
        // expect(crontab!.toHuman(), equals('every 5 minutes and every 5 hours'));
      });

      test('allows 0/5 for minutes and days of month', () {
        final crontab = HumanCrontab.tryParse('0/5 * 0/5 * *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('0/5 * 0/5 * *'));
        // expect(crontab!.toHuman(),
        //     equals('every 5 minutes and every 5 days of the month'));
      });

      test('allows 0/5 for minutes and months', () {
        final crontab = HumanCrontab.tryParse('0/5 * * 0/5 *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('0/5 * * 0/5 *'));
        // expect(
        //     crontab!.toHuman(), equals('every 5 minutes and every 5 months'));
      });

      test('allows 0/5 for minutes and days of week', () {
        final crontab = HumanCrontab.tryParse('0/5 * * * 0/5');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('0/5 * * * 0/5'));
        // expect(crontab!.toHuman(),
        //     equals('every 5 minutes and every 5 days of the week'));
      });

      test('allows 0/5 for hours and days of month', () {
        final crontab = HumanCrontab.tryParse('* 0/5 0/5 * *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('* 0/5 0/5 * *'));
        // expect(crontab!.toHuman(),
        //     equals('every 5 hours and every 5 days of the month'));
      });

      test('allows 0/5 for hours and months', () {
        final crontab = HumanCrontab.tryParse('* 0/5 * 0/5 *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('* 0/5 * 0/5 *'));
        // expect(crontab!.toHuman(), equals('every 5 hours and every 5 months'));
      });

      test('allows 0/5 for hours and days of week', () {
        final crontab = HumanCrontab.tryParse('* 0/5 * * 0/5');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('* 0/5 * * 0/5'));
        // expect(crontab!.toHuman(),
        //     equals('every 5 hours and every 5 days of the week'));
      });

      test('allows 0/5 for days of month and months', () {
        final crontab = HumanCrontab.tryParse('* * 0/5 0/5 *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('* * 0/5 0/5 *'));
        // expect(crontab!.toHuman(),
        //     equals('every 5 days of the month and every 5 months'));
      });
    });

    group('dash format (x-y)', () {
      test('allows 0-5 for minutes', () {
        final crontab = HumanCrontab.tryParse('0-5 * * * *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('0-5 * * * *'));
        // expect(crontab!.toHuman(), equals('every minute between 0 and 5'));
      });

      test('allows 0-5 for hours', () {
        final crontab = HumanCrontab.tryParse('* 0-5 * * *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('* 0-5 * * *'));
        // expect(crontab!.toHuman(), equals('every hour between 0 and 5'));
      });

      test('allows 0-5 for days of month', () {
        final crontab = HumanCrontab.tryParse('* * 0-5 * *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('* * 0-5 * *'));
        // expect(crontab!.toHuman(),
        //     equals('every day of the month between 0 and 5'));
      });

      test('allows 0-5 for months', () {
        final crontab = HumanCrontab.tryParse('* * * 0-5 *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('* * * 0-5 *'));
        // expect(crontab!.toHuman(), equals('every month between 0 and 5'));
      });

      test('allows 0-5 for days of week', () {
        final crontab = HumanCrontab.tryParse('* * * * 0-5');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('* * * * 0-5'));
        // expect(crontab!.toHuman(),
        //     equals('every day of the week between 0 and 5'));
      });

      test('allows 0-5 for minutes and hours', () {
        final crontab = HumanCrontab.tryParse('0-5 0-5 * * *');
        expect(crontab, isNotNull);
        expect(crontab.toString(), equals('0-5 0-5 * * *'));
        // expect(
        //     crontab!.toHuman(),
        //     equals(
        //         'every minute between 0 and 5 and every hour between 0 and 5'));
      });
    });
  });
}

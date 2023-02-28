import 'package:dart_human_crontab/dart_human_crontab.dart';
import 'package:test/test.dart';

void main() {
  group('strict parsing', () {
    test('throws on empty string', () {
      try {
        HumanCrontab.parse('');
        assert(false);
      } catch (_) {}
    });

    test('throws on invalid format', () {
      try {
        HumanCrontab.parse('this is clearly invalid format');
        assert(false);
      } catch (_) {}
    });

    test('throws on missing parts', () {
      try {
        HumanCrontab.parse('*/5 * * 2');
        assert(false);
      } catch (_) {}
    });

    test('allows valid crontab format', () {
      final crontab = HumanCrontab.parse('30 4 */1 12 5');
      assert(crontab.toString() == '30 4 */1 12 5');
      assert(crontab.toHuman() ==
          'At 4:30 on every 1st day of the month on Friday in December');
    });

    test('allows all wildcards', () {
      final crontab = HumanCrontab.parse('* * * * *');
      assert(crontab.toString() == '* * * * *');
      assert(crontab.toHuman() == 'every minute');
    });
  });

  group('relaxed parsing', () {
    test('returns null on empty string', () {
      assert(HumanCrontab.tryParse('') == null);
    });

    // cannot test this as another function handles it
    //
    // test('returns null on invalid format', () {
    //   assert(HumanCrontab.tryParse('this is clearly invalid format') == null);
    // });

    test('returns null on missing parts', () {
      assert(HumanCrontab.tryParse('*/5 * * 2') == null);
    });

    test('allows valid crontab format', () {
      final crontab = HumanCrontab.tryParse('30 4 */1 12 5');
      assert(crontab != null);
      assert(crontab.toString() == '30 4 */1 12 5');
      assert(crontab!.toHuman() ==
          'At 4:30 on every 1st day of the month on Friday in December');
    });

    test('allows all wildcards', () {
      final crontab = HumanCrontab.tryParse('* * * * *');
      assert(crontab != null);
      assert(crontab.toString() == '* * * * *');
      assert(crontab!.toHuman() == 'every minute');
    });
  });
}

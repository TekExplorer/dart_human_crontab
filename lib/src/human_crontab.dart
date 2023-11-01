import 'cron_segments.dart';
import 'format_digital_clock.dart';

class HumanCrontab {
  final String minute;
  final String hour;
  final String dayOfMonth;
  final String month;
  final String dayOfWeek;
  String get weekday => dayOfWeek;
  final bool isMilitaryTime;

  static const annually = HumanCrontab('0', '0', '1', '1', '*');
  static const yearly = annually;
  static const monthly = HumanCrontab('0', '0', '1', '*', '*');
  static const weekly = HumanCrontab('0', '0', '*', '*', '0');
  static const daily = HumanCrontab('0', '0', '*', '*', '*');
  static const hourly = HumanCrontab('0', '*', '*', '*', '*');

  const HumanCrontab(
    this.minute,
    this.hour,
    this.dayOfMonth,
    this.month,
    this.dayOfWeek, {
    this.isMilitaryTime = true,
  });

  factory HumanCrontab.fromString(String value, {bool isMilitaryTime = true}) {
    final parts = value.split(' ');
    if (parts.length != 5) {
      throw ArgumentError.value(
        value,
        'value',
        'Input must contain exactly 5 segments.',
      );
    }

    var crontab = HumanCrontab(
      parts[0],
      parts[1],
      parts[2],
      parts[3],
      parts[4],
      isMilitaryTime: isMilitaryTime,
    );
    // Validate. Will throw if it fails.
    crontab.toHuman();
    return crontab;
  }

  factory HumanCrontab.parse(String value, {bool isMilitaryTime}) =
      HumanCrontab.fromString;

  static HumanCrontab? tryParse(String value, {bool isMilitaryTime = true}) {
    try {
      return HumanCrontab.parse(value, isMilitaryTime: isMilitaryTime);
    } catch (e) {
      return null;
    }
  }

  String toHuman() {
    final isDigitalClock =
        int.tryParse(minute) != null && int.tryParse(hour) != null;

    final items = <String>[
      if (isDigitalClock)
        formatDigitalClock(
          int.parse(minute),
          int.parse(hour),
          militaryTime: isMilitaryTime,
        )
      else ...[
        MinuteSegment().parse(minute),
        HourSegment().parse(hour, noParseIfAsterisk: true),
      ],
      DayOfMonthSegment().parse(dayOfMonth, noParseIfAsterisk: true),
      WeekdaySegment().parse(dayOfWeek, noParseIfAsterisk: true),
      MonthSegment().parse(month, noParseIfAsterisk: true),
    ];

    items.removeWhere((element) => element.isEmpty);

    if (items.isEmpty) return 'never';

    return items.join(' ');
  }

  String toCrontab() => '$minute $hour $dayOfMonth $month $dayOfWeek';

  @override
  String toString() {
    return 'Crontab(${toCrontab()})';
  }
}

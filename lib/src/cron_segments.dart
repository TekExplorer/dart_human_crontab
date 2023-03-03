import 'abstract_cron_segment.dart';

class MinuteSegment extends CronToHumanSegment {
  const MinuteSegment();
  @override
  String get unit => 'minute';
}

class HourSegment extends CronToHumanSegment {
  const HourSegment();
  @override
  String get unit => 'hour';

  @override
  String get prefix => 'past';
}

class DayOfMonthSegment extends CronToHumanSegment {
  const DayOfMonthSegment();
  @override
  String get unit => 'day of the month';

  @override
  String get prefix => 'on';
}

class MonthSegment extends CronToHumanSegment {
  const MonthSegment();

  @override
  String get unit => 'month';

  @override
  String get prefix => 'in';

  @override
  bool get includeUnit => false;

  static const _monthMap = {
    1: 'January',
    2: 'February',
    3: 'March',
    4: 'April',
    5: 'May',
    6: 'June',
    7: 'July',
    8: 'August',
    9: 'September',
    10: 'October',
    11: 'November',
    12: 'December',
  };

  @override
  String transformNumber(int numeral) {
    if (!_monthMap.containsKey(numeral)) {
      throw ArgumentError.value(numeral, 'numeral', 'Must be between 1 and 12');
    }

    return _monthMap[numeral]!;
  }
}

typedef WeekdaySegment = DayOfWeekSegment;

class DayOfWeekSegment extends CronToHumanSegment {
  const DayOfWeekSegment();
  @override
  String get unit => 'weekday';

  @override
  String get prefix => 'on';

  @override
  bool get includeUnit => false;

  static const _dayMap = {
    0: 'Sunday',
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday',
  };

  @override
  String transformNumber(int numeral) {
    if (!_dayMap.containsKey(numeral)) {
      throw ArgumentError.value(numeral, 'numeral', 'Must be between 0 and 7');
    }

    return _dayMap[numeral]!;
  }
}

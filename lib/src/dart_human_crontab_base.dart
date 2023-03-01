import 'crontab_exception.dart';

/// A class that translates crontab into something a human can understand.
class HumanCrontab {
  String minute = '*';
  String hour = '*';
  String dayOfMonth = '*';
  String month = '*';
  String weekday = '*';

  HumanCrontab({
    required this.minute,
    required this.hour,
    required this.dayOfMonth,
    required this.month,
    required this.weekday,
  }) {
    _validateCrontabValues();
  }

  factory HumanCrontab.parse(String value) {
    final parts = value.split(' ');
    if (parts.length != 5) {
      throw CrontabException(
          'expected 5 crontab expressions; got ${parts.length}');
    }

    return HumanCrontab(
        minute: parts[0],
        hour: parts[1],
        dayOfMonth: parts[2],
        month: parts[3],
        weekday: parts[4]);
  }

  static HumanCrontab? tryParse(String value) {
    try {
      return HumanCrontab.parse(value);
    } on CrontabException {
      return null;
    }
  }

  static const _weekdayList = <String>[
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  static const _monthList = <String>[
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  void _validateRange(String value, {int min = 0, required int max}) {
    if (value == '*') return;

    final val = int.tryParse(value);
    if (val != null) {
      if (val >= min && val <= max) return;
      throw CrontabException.invalid('must be between $min and $max');
    }

    if (value.contains('/')) {
      final parts = value.split('/');
      if (parts.length != 2) {
        throw CrontabException.invalid(
            'must be "*", "*/number" or "number/number"');
      }

      final left = int.tryParse(parts[0]);
      final right = int.tryParse(parts[1]);

      if (left == null) {
        if (parts[0] == '*') return;
        throw CrontabException.invalid('left value must be "*" or a number');
      }
      if (right == null) {
        throw CrontabException.invalid('right value must be a number');
      }

      if (left < min || left > max) {
        throw CrontabException.invalid(
            'left value must be between $min and $max');
      }
      if (right < min || right > max) {
        throw CrontabException.invalid(
            'right value must be between $min and $max');
      }

      return;
    }

    throw CrontabException(
        'value must be in a valid crontab format (like "* */8 */7 7 *)');
  }

  void _validateCrontabValues() {
    // regex for validating crontab values
    // num(upTo2)ORstar/num OR num(upTo2)ORstar
    // ^(?:[0-9]{1,2}|(?:\*|[0-9]{1,2})(?:\/[0-9]{1,2})?)$
    final regex =
        RegExp(r'^(?:[0-9]{1,2}|(?:\*|[0-9]{1,2})(?:\/[0-9]{1,2})?)$');
    for (String element in [minute, hour, dayOfMonth, month, weekday]) {
      if (!regex.hasMatch(element)) {
        throw CrontabException.invalid(element);
      }
    }

    // minute is between 0 and 59, or is '*', or is '*/n', where n is between 0
    // and 59, or is n/n where n is between 0 and 59
    _validateRange(minute, min: 0, max: 59);
    // hour is between 0 and 23
    _validateRange(hour, min: 0, max: 23);
    // dayOfMonth is between 1 and 31
    _validateRange(dayOfMonth, min: 1, max: 31);
    // month is between 1 and 12
    _validateRange(month, min: 1, max: 12);
    // weekday is between 0 and 6
    _validateRange(weekday, min: 0, max: 6);
  }

  /// crontab to human readable
  String toHuman() {
    final minuteHourString = _handleMinuteHour();
    final dayOfMonthString = _handleDayOfMonth();
    final weekdayString = _handleWeekday();
    final monthString = _handleMonth();

    // remove excess spaces from empty values
    return '$minuteHourString $dayOfMonthString $weekdayString $monthString'
        .trim();
  }

  String _handleMinuteHour() {
    int? tMin = int.tryParse(minute);
    int? tHr = int.tryParse(hour);

    if (tMin != null && tHr != null) {
      // correctly process single digit minute
      return 'At $hour:${minute.length == 1 ? '0$minute' : minute}';
    }

    String minuteString = '';
    String hourString = '';
    String minuteStartingPast = '';
    String hourStartingPast = '';

    // handle minute first; also handle steps '*/5'
    if (minute == '*' || minute == '*/1') {
      minuteString = 'every minute';
    } else if (minute.contains('/')) {
      // handle 5/7 and */7
      final minuteParts = minute.split('/');

      (minuteParts[1] == '1')
          ? minuteString = 'every minute'
          : minuteString = 'every ${minuteParts[1]} minutes';

      if (minuteParts[0] == '*') {
        // normal number
        minuteString = 'every ${minuteParts[1]} minutes';
      } else {
        // every 5 minutes starting from xx:05
        minuteStartingPast = 'starting from ${minuteParts[0]} past the hour';
      }
    }

    // handle hour
    if (hour != '*') {
      if (hour.contains('/')) {
        // handle 5/7 and */7
        final hourParts = hour.split('/');

        hourString = 'past every ' +
            (hourParts[1] == '1' ? 'hour' : '${hourParts[1]} hours');

        if (hourParts[0] != '*') {
          hourStartingPast = 'starting from ${hourParts[0]}:00';
        }
      } else {
        // normal number
        hourString = 'every $hour hours';
      }
    }

    if (minuteStartingPast.isEmpty && hourStartingPast.isEmpty) {
      final hr = hour.split('/')[0];
      var min = minute.split('/')[0];
      if (hr != '*' && min != '*') {
        if (min.length == 1) min = '0$min';

        return '$minuteString $hourString starting from $hr:$min';
      }
    }

    return '$minuteString $minuteStartingPast $hourString $hourStartingPast';
  }

  String _handleDayOfMonth() {
    if (dayOfMonth == '*') return '';

    if (dayOfMonth.contains('/')) {
      // handle 5/7 and */7
      final dayOfMonthParts = dayOfMonth.split('/');
      final th = _numberSuffix(dayOfMonthParts[1]);

      // handle */7
      if (dayOfMonthParts[0] == '*') {
        return 'on every ${dayOfMonthParts[1]}$th day of the month';
      } else {
        final th2 = _numberSuffix(dayOfMonthParts[0]);
        return 'on every ${dayOfMonthParts[1]}$th day of the month starting from the ${dayOfMonthParts[0]}$th2';
      }
    }

    // normal number
    final th = _numberSuffix(dayOfMonth);
    return 'on the $dayOfMonth$th';
  }

  String _handleWeekday() {
    if (weekday == '*') return '';

    if (weekday.contains('/')) {
      // handle 5/7 and */7
      final weekdayParts = weekday.split('/');
      final th = _numberSuffix(weekdayParts[1]);
      // handle */7
      if (weekdayParts[0] == '*') {
        return 'on every ${weekdayParts[1]}$th weekday';
      } else {
        final String weekdayStart = _weekdayList[int.parse(weekdayParts[0])];
        return 'on every ${weekdayParts[1]}$th weekday starting from $weekdayStart';
      }
    }

    // normal weekday
    return 'on ${_weekdayList[int.parse(weekday)]}';
  }

  String _handleMonth() {
    if (month == '*') return '';

    final monthOffset = -1;
    if (month.contains('/')) {
      // handle 5/7 and */7
      final monthParts = month.split('/');
      final th = _numberSuffix(monthParts[1]);
      // handle */7
      if (monthParts[0] == '*') {
        return 'in every ${monthParts[1]}$th month';
      } else {
        final monthStart = _monthList[int.parse(monthParts[0]) + monthOffset];
        return 'in every ${monthParts[1]}$th month starting from $monthStart';
      }
    }

    // match number to month
    return 'in ${_monthList[int.parse(month) + monthOffset]}';
  }

  String _numberSuffix(String number) {
    switch (number) {
      case '1':
        return 'st';
      case '2':
        return 'nd';
      case '3':
        return 'rd';
      default:
        return 'th';
    }
  }

  @override
  String toString() {
    return '$minute $hour $dayOfMonth $month $weekday';
  }
}

import 'dart:math';

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

  factory HumanCrontab.parse(String crontab) {
    List<String> crontabList = crontab.split(' ');
    if (crontabList.length != 5) {
      throw ArgumentError('Invalid crontab string: not 5 values');
    }

    return HumanCrontab(
      minute: crontabList[0],
      hour: crontabList[1],
      dayOfMonth: crontabList[2],
      month: crontabList[3],
      weekday: crontabList[4],
    );
  }

  void _validateRange(String val, {int min = 0, required int max}) {
    if (val != '*') {
      if (int.tryParse(val) != null) {
        assert(int.parse(val) >= min && int.parse(val) <= max,
            'Invalid crontab string: must be between $min and $max');
      } else if (minute.contains('/')) {
        var split = val.split('/');
        assert(split.length == 2,
            'Invalid crontab value: must be in the form of ["*", "*/8", "3/7", "7", "*"]');
        assert(
            split[0] == '*' ||
                (int.parse(split[0]) >= min && int.parse(split[0]) <= max),
            'Invalid crontab value: must be between $min and $max');
        assert(int.parse(split[1]) >= min && int.parse(split[1]) <= max,
            'Invalid crontab value: must be between $min and $max');
      } else {
        assert(false,
            'Invalid crontab string: must be in the form of "* */8 3/7 7 *"');
      }
    }
  }

  void _validateCrontabValues() {
    // regex for validating crontab values
    // num(upTo2)ORstar/num OR num(upTo2)ORstar
    // ^([0-9]{1,2}|[\*]\/[0-9])$|^([0-9]{1,2}|[\*])$
    for (String element in [minute, hour, dayOfMonth, month, weekday]) {
      RegExp regex = RegExp(r'^([0-9]{1,2}|[\*]\/[0-9])$|^([0-9]{1,2}|[\*])$');
      assert(regex.hasMatch(element), "Invalid crontab value: $element");
    }
    // minute is between 0 and 59, or is '*', or is '*/n', where n is between 0 and 59, or is n/n where n is between 0 and 59
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
    final String minuteHourString = _handleMinuteHour();
    final String dayOfMonthString = _handleDayOfMonth();
    final String weekdayString = _handleWeekday();
    final String monthString = _handleMonth();

    final String finalString =
        "$minuteHourString $dayOfMonthString $weekdayString $monthString";

    // remove excess spaces from empty values
    return finalString.replaceAll(RegExp(r"\s+"), " ");
  }

  String _handleMinuteHour() {
    int? tMin = int.tryParse(minute);
    int? tHr = int.tryParse(hour);

    if (tMin != null && tHr != null) {
      return 'At $hour:${minute.length == 1 ? '0$minute' : minute}'; // correctly process single digit minute
    }

    String minuteString = '';
    String hourString = '';
    String? minuteStartingPast;
    String? hourStartingPast;

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

    if (minuteStartingPast != null && hourStartingPast != null) {
      final String hr = hour.split('/')[0];
      String min = minute.split('/')[0];
      min.length == 1 ? min = '0$min' : min;

      return '$minuteString $hourString starting from $hr:$min';
    } else {
      return '$minuteString $minuteStartingPast $hourString $hourStartingPast';
    }
  }

  String _handleDayOfMonth() {
    if (dayOfMonth == '*') {
      return '';
    } else if (dayOfMonth.contains('/')) {
      // handle 5/7 and */7
      final dayOfMonthParts = dayOfMonth.split('/');
      final String th = _numberSuffix(dayOfMonthParts[1]);

      // handle */7
      if (dayOfMonthParts[0] == '*') {
        return 'on every ${dayOfMonthParts[1]}$th day of the month';
      } else {
        final String th2 = _numberSuffix(dayOfMonthParts[0]);
        return 'on every ${dayOfMonthParts[1]}$th day of the month starting from the ${dayOfMonthParts[0]}$th2';
      }
    } else {
      // normal number
      final String th = _numberSuffix(dayOfMonth);
      return 'on the $dayOfMonth$th';
    }
  }

  String _handleWeekday() {
    // on
    if (weekday == '*') {
      return '';
    } else if (weekday.contains('/')) {
      // handle 5/7 and */7
      final weekdayParts = weekday.split('/');
      final String th = _numberSuffix(weekdayParts[1]);
      // handle */7
      if (weekdayParts[0] == '*') {
        return 'on every ${weekdayParts[1]}$th weekday';
      } else {
        final String weekdayStart = _weekdayList[int.parse(weekdayParts[0])];
        return 'on every ${weekdayParts[1]}$th weekday starting from $weekdayStart';
      }
    } else {
      // normal weekday
      return 'on ${_weekdayList[int.parse(weekday)]}';
    }
  }

  final List<String> _weekdayList = [
    'Sunday',
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
  ];

  String _handleMonth() {
    final int monthOffset = -1;
    if (month == '*') {
      return '';
    } else if (month.contains('/')) {
      // handle 5/7 and */7
      final monthParts = month.split('/');
      final String th = _numberSuffix(monthParts[1]);
      // handle */7
      if (monthParts[0] == '*') {
        return 'in every ${monthParts[1]}$th month';
      } else {
        final String monthStart =
            _monthList[int.parse(monthParts[0]) + monthOffset];
        return 'in every ${monthParts[1]}$th month starting from $monthStart';
      }
    } else {
      // match number to month
      return 'in ${_monthList[int.parse(month) + monthOffset]}';
    }
  }

  final List<String> _monthList = [
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
    return '$minute $hour $dayOfMonth $month $weekday)';
  }
}

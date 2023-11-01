String formatDigitalClock(int minute, int hour, {bool militaryTime = true}) {
  // should be in the format of 00:00
  String minuteString = minute.toString().padLeft(2, '0');
  String hourString = hour.toString();
  if (!militaryTime) {
    final isAm = hour < 12;
    if (hour > 12) hourString = (hour - 12).toString();
    if (hour == 0) hourString = '12';
    minuteString += isAm ? 'am' : 'pm';
  }
  return 'at $hourString:$minuteString';
}

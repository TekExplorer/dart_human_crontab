abstract class CronToHumanSegment {
  const CronToHumanSegment();
  String get unit;
  String get prefix => 'at';
  bool get includeUnit => true;

  String transformNumber(int numeral) => numeral.toString();

  String transformAsterisk() => 'every $unit';

  String transformItem(String item, {String? numPrefix}) {
    if (item == '*') return transformAsterisk();

    if (numPrefix != null) {
      final number = int.parse(item);
      return '$numPrefix ${transformNumber(number)}';
    }
    return transformNumber(int.parse(item));
  }

  String transformIncrement(int increment) {
    if (increment == 1) return 'every $unit';
    if (increment == 2) return 'every other $unit';
    return 'every ${nth(increment)} $unit';
  }

  String transformRange(int start, int end) =>
      'every $unit from ${transformNumber(start)} to ${transformNumber(end)}';

  String transformList(List<int> list) {
    final buffer = StringBuffer();
    buffer.write('$prefix ');
    if (includeUnit) buffer.write('$unit ');

    for (var i = 0; i < list.length; i++) {
      final numeral = list[i];
      buffer.write(transformNumber(numeral));
      if (i < list.length - 1) buffer.write(', ');
    }
    return buffer.toString();
  }

  String parse(String input, {bool noParseIfAsterisk = false}) {
    if (input == '*' && noParseIfAsterisk) return '';
    if (input == '*') return 'every $unit';

    final parts = input.split('/');

    if (parts.length == 1) return parseCommaSeparated(parts.first);

    if (parts.length > 2) {
      throw ArgumentError.value(
        input,
        'input',
        'Input must not contain more than one slash.',
      );
    }

    if (parts.first == '*') return parseIncrement(parts.last);

    // TODO: implement parsing 3/5 * * * *
    throw ArgumentError.value(
      input,
      'input',
      'Input must contain a wildcard before the slash.',
    );
    // final StringBuffer buffer = StringBuffer();
    // buffer.write(parseIncrement(parts.last));
    // buffer.write(' from ');
    // buffer.write(parseBeforeSlash(parts.first));
    // return buffer.toString();
  }

  String parseCommaSeparated(String input) {
    if (input == '*') return 'every $unit';

    final parts = input.split(',');

    if (parts.length == 1) {
      final part = parts.first;
      if (part.contains('-')) return parseRange(part);
      String _prefix = prefix;
      if (includeUnit) {
        _prefix = '$_prefix $unit';
      }
      return transformItem(part, numPrefix: _prefix);
    }

    final StringBuffer buffer = StringBuffer();
    buffer.write('$prefix ');
    if (includeUnit) buffer.write('$unit ');
    for (var i = 0; i < parts.length; i++) {
      bool isLast = i == parts.length - 1;
      if (i > 0 && !isLast) buffer.write(', ');
      if (isLast) buffer.write(' and ');

      if (parts[i].contains('-')) {
        buffer.write(parseRange(parts[i]));
      } else {
        buffer.write(transformItem(parts[i]));
      }
    }
    return buffer.toString();
  }

  String parseRange(String range) {
    final rangeParts = range.split('-');
    final start = int.tryParse(rangeParts.first);
    final end = int.tryParse(rangeParts.last);
    if (start == null || end == null) return '';
    // return 'every $unit from $start through $end';
    return transformRange(start, end);
  }

  String parseIncrement(String increment) {
    if (increment.isEmpty) return '';

    if (increment.contains('/')) {
      throw ArgumentError.value(
        increment,
        'increment',
        'Increment must not contain a slash. Use parse instead',
      );
    }

    if (increment.contains('*')) {
      throw ArgumentError.value(
        increment,
        'increment',
        'Increment must not contain a wildcard',
      );
    }

    if (increment == '0') {
      throw ArgumentError.value(
        increment,
        'increment',
        'Increment must not be zero',
      );
    }

    final incrementInt = int.tryParse(increment);
    if (incrementInt == null) return '';

    return '$prefix ${transformIncrement(incrementInt)}';
  }

  String nth(int number) {
    if (number > 10 && number < 14) return '${number}th';
    final lastDigit = number % 10;
    switch (lastDigit) {
      case 1:
        return '${number}st';
      case 2:
        return '${number}nd';
      case 3:
        return '${number}rd';
      default:
        return '${number}th';
    }
  }
}

/// Thrown when there is an issue with parsing or validating a crontab
/// expression.
class CrontabException implements Exception {
  final String message;

  const CrontabException(this.message);

  factory CrontabException.failed(String message) {
    return CrontabException('failed to parse crontab: $message');
  }

  factory CrontabException.invalid(String message) {
    return CrontabException('invalid crontab value: $message');
  }

  @override
  String toString() => 'CrontabException: $message';
}

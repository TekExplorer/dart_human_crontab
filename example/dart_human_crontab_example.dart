import 'package:dart_human_crontab/dart_human_crontab.dart';

void main() {
  final cron = '30 4 */1 12 5';
  print(HumanCrontab.parse(cron).toHuman());
}

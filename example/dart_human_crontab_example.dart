import 'package:dart_human_crontab/dart_human_crontab.dart';

void main() {
  String cron = '30 4 1/2 12 5';

  print(HumanCrontab.parse(cron).toHuman());
}

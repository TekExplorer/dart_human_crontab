A package to convert crontabs to a human readable format much like crontab.guru

## Getting started

Add it to `pubspec.yaml`:

```yaml
dependencies:
  dart_human_crontab:
    git: https://github.com/TekExplorer/dart_human_crontab
```

or install via pub:

```sh
dart pub add --git-url https://github.com/TekExplorer/dart_human_crontab dart_human_crontab
```

## Usage

```dart
import 'package:dart_human_crontab/dart_human_crontab.dart';

void main() {
  String cron = '30 4 1/2 12 5';

  print(HumanCrontab.parse(cron).toHuman());
  // At 4:30 on every 2nd day of the month starting from the 1st on Friday in December
}
```

A package to convert crontabs to a human readable format much like crontab.guru

## Getting started

Add it to `pubspec.yaml`:

```yaml
dependencies:
  human_crontab:
    git: https://github.com/TekExplorer/dart_human_crontab
```

or install via pub:

```sh
dart pub add --git-url https://github.com/TekExplorer/dart_human_crontab human_crontab
```

## Usage

```dart
import 'package:human_crontab/human_crontab.dart';

void main() {
  final cron = '30 4 */1 12 5';
  print(HumanCrontab.parse(cron).toHuman());
  // At 4:30 on every 1st day of the month on Friday in December
}
```

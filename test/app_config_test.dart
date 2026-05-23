import 'package:flutter_test/flutter_test.dart';
import 'package:v2box/models/app_config.dart';
import 'package:v2box/models/build_config.dart';

import '../setup.dart' as setup;

void main() {
  test('runtime config does not own build-time fields', () {
    final config = AppConfig.fromJson({
      'appName': 'RemoteName',
      'logoUrl': 'https://example.com/logo.png',
      'ossUrl': 'https://example.com/config.json',
      'version': '1.2.3+4',
      'serverUrl': 'https://example.com/api/v1',
    });

    expect(config.toJson(), isNot(contains('appName')));
    expect(config.toJson(), isNot(contains('logoUrl')));
    expect(config.toJson(), isNot(contains('ossUrl')));
    expect(config.toJson(), isNot(contains('version')));
  });

  test('build config owns application version', () {
    final config = BuildConfig.fromJson({
      'appName': 'RemoteName',
      'version': '1.2.3+4',
    });

    expect(config.version, '1.2.3+4');
  });

  test('build version is converted to flutter build arguments', () {
    expect(
      setup.Build.flutterBuildArgsForVersion(
        'verbose,dart-define-from-file=env.json',
        '1.2.3+4',
      ),
      'verbose,dart-define-from-file=env.json,build-name=1.2.3,build-number=4',
    );
  });
}

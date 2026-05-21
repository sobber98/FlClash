import 'package:flutter_test/flutter_test.dart';
import 'package:v2box/models/app_config.dart';

void main() {
  test('runtime config does not own appName or ossUrl', () {
    final config = AppConfig.fromJson({
      'appName': 'RemoteName',
      'ossUrl': 'https://example.com/config.json',
      'serverUrl': 'https://example.com/api/v1',
    });

    expect(config.toJson(), isNot(contains('appName')));
    expect(config.toJson(), isNot(contains('ossUrl')));
  });
}

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:v2box/common/updater.dart';

void main() {
  test(
    'verified update package is reusable until the file disappears',
    () async {
      final file = File('${Directory.systemTemp.path}/flclash-cache-test.apk');
      await file.writeAsBytes([1, 2, 3]);
      addTearDown(() async {
        if (await file.exists()) {
          await file.delete();
        }
      });

      final cache = AppUpdatePackageCache()..rememberVerified(file);

      expect(cache.reusableFile, file);
      expect(cache.reusableFile, file);

      await file.delete();

      expect(cache.reusableFile, isNull);
      expect(cache.reusableFile, isNull);
    },
  );
}

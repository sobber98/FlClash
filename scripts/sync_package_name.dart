// ignore_for_file: avoid_print
// Reads appName from build.config.json and syncs it to:
//   - pubspec.yaml (Dart package name, lowercase_with_underscores)
//   - all Dart import statements under lib/
//   - Android: applicationId, strings.xml, AndroidManifest.xml (main & debug)
//   - macOS: bundle identifier, Runner/Configs/AppInfo.xcconfig
//   - Windows: CMakeLists.txt, runner/main.cpp, runner/Runner.rc,
//     packaging/exe/make_config.yaml, packaging/exe/inno_setup.iss
//   - Linux: application ID, CMakeLists.txt, runner/my_application.cc,
//     packaging/deb|appimage|rpm/make_config.yaml
//   - distribute_options.yaml
//
// Usage: dart scripts/sync_package_name.dart

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:path/path.dart' as p;

Future<void> main() async {
  final root = p.dirname(p.dirname(Platform.script.toFilePath()));

  // 1. Read appName from build.config.json
  final configFile = File(p.join(root, 'build.config.json'));
  if (!configFile.existsSync()) {
    stderr.writeln('Error: build.config.json not found.');
    exit(1);
  }
  final config = json.decode(configFile.readAsStringSync()) as Map;
  final appName = (config['appName'] as String?)?.trim();
  if (appName == null || appName.isEmpty) {
    stderr.writeln('Error: appName is missing or empty in build.config.json.');
    exit(1);
  }
  final logoUrl = (config['logoUrl'] ?? config['logo_url'])?.toString().trim();

  // Dart package names must be lowercase_with_underscores
  final packageName = appName
      .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
      .toLowerCase();
  final appIdentifier = _buildAppIdentifier(appName);
  final coreExecutableName = '${appName}Core';
  final helperServiceName = '${appName}HelperService';

  // 2. Read current package name from pubspec.yaml
  final pubspecFile = File(p.join(root, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) {
    stderr.writeln('Error: pubspec.yaml not found.');
    exit(1);
  }
  final pubspecContent = pubspecFile.readAsStringSync();
  final nameMatch = RegExp(
    r'^name:\s*(\S+)',
    multiLine: true,
  ).firstMatch(pubspecContent);
  if (nameMatch == null) {
    stderr.writeln('Error: Could not find name: field in pubspec.yaml.');
    exit(1);
  }
  final oldPackageName = nameMatch.group(1)!;

  int changes = 0;

  // 3. Update pubspec.yaml (package name)
  if (oldPackageName != packageName) {
    final updatedPubspec = pubspecContent.replaceFirst(
      RegExp(r'^name:\s*\S+', multiLine: true),
      'name: $packageName',
    );
    pubspecFile.writeAsStringSync(updatedPubspec);
    print('  pubspec.yaml: "$oldPackageName" → "$packageName"');
    changes++;

    // 4. Update all .dart files under lib/
    int fileCount = 0;
    final libDir = Directory(p.join(root, 'lib'));
    await for (final entity in libDir.list(recursive: true)) {
      if (entity is! File || !entity.path.endsWith('.dart')) continue;
      final original = entity.readAsStringSync();
      final updated = original.replaceAll(
        'package:$oldPackageName/',
        'package:$packageName/',
      );
      if (updated != original) {
        entity.writeAsStringSync(updated);
        fileCount++;
      }
    }
    if (fileCount > 0) {
      print('  lib/: updated $fileCount dart file(s)');
      changes++;
    }
  }

  // Helper: replace in file using regex, returns true if changed
  bool replaceInFile(String filePath, Map<Pattern, String> replacements) {
    final file = File(p.join(root, filePath));
    if (!file.existsSync()) return false;
    var content = file.readAsStringSync();
    var changed = false;
    for (final entry in replacements.entries) {
      final updated = content.replaceAll(entry.key, entry.value);
      if (updated != content) {
        content = updated;
        changed = true;
      }
    }
    if (changed) file.writeAsStringSync(content);
    return changed;
  }

  bool replaceInFileMapped(
    String filePath,
    Map<RegExp, String Function(Match)> replacements,
  ) {
    final file = File(p.join(root, filePath));
    if (!file.existsSync()) return false;
    var content = file.readAsStringSync();
    var changed = false;
    for (final entry in replacements.entries) {
      final updated = content.replaceAllMapped(entry.key, entry.value);
      if (updated != content) {
        content = updated;
        changed = true;
      }
    }
    if (changed) file.writeAsStringSync(content);
    return changed;
  }

  // 5. Android strings.xml
  if (replaceInFile('android/common/src/main/res/values/strings.xml', {
    RegExp(r'>([^<]+)</string>'): '>$appName</string>',
  })) {
    print('  android/common/src/main/res/values/strings.xml: updated');
    changes++;
  }

  // 6. Android application identifier
  if (replaceInFile('android/app/build.gradle.kts', {
    RegExp(r'applicationId = "[^"]+"'): 'applicationId = "$appIdentifier"',
  })) {
    print('  android/app/build.gradle.kts: applicationId updated');
    changes++;
  }

  if (replaceInFileMapped('android/app/google-services.json', {
    RegExp(r'("package_name":\s*")[^"]+(")'): (match) {
      final original = match.group(0)!;
      if (original.endsWith('.debug"')) {
        return '${match.group(1)}$appIdentifier.debug${match.group(2)}';
      }
      if (original.endsWith('.dev"')) {
        return '${match.group(1)}$appIdentifier.dev${match.group(2)}';
      }
      return '${match.group(1)}$appIdentifier${match.group(2)}';
    },
  })) {
    print('  android/app/google-services.json: package names updated');
    changes++;
  }

  // 7. Android main AndroidManifest.xml - label attributes
  if (replaceInFile('android/app/src/main/AndroidManifest.xml', {
    RegExp(r'android:label="[^"]+"'): 'android:label="$appName"',
  })) {
    print('  android/app/src/main/AndroidManifest.xml: updated');
    changes++;
  }

  // 8. Android debug AndroidManifest.xml
  if (replaceInFile('android/app/src/debug/AndroidManifest.xml', {
    RegExp(r'android:label="[^"]+"'): 'android:label="$appName Debug"',
  })) {
    print('  android/app/src/debug/AndroidManifest.xml: updated');
    changes++;
  }

  // 9. macOS AppInfo.xcconfig
  if (replaceInFile('macos/Runner/Configs/AppInfo.xcconfig', {
    RegExp(r'^PRODUCT_NAME\s*=.*$', multiLine: true): 'PRODUCT_NAME = $appName',
    RegExp(r'^PRODUCT_BUNDLE_IDENTIFIER\s*=.*$', multiLine: true):
        'PRODUCT_BUNDLE_IDENTIFIER = $appIdentifier',
  })) {
    print('  macos/Runner/Configs/AppInfo.xcconfig: updated');
    changes++;
  }

  // 10. macOS project display name and bundle identifier overrides
  if (replaceInFile('macos/Runner.xcodeproj/project.pbxproj', {
    RegExp(r'INFOPLIST_KEY_CFBundleDisplayName = [^;]+;'):
        'INFOPLIST_KEY_CFBundleDisplayName = $appName;',
    RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+\.RunnerTests;'):
        'PRODUCT_BUNDLE_IDENTIFIER = $appIdentifier.RunnerTests;',
    RegExp(r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+\.debug;'):
        'PRODUCT_BUNDLE_IDENTIFIER = $appIdentifier.debug;',
  })) {
    print('  macos/Runner.xcodeproj/project.pbxproj: updated');
    changes++;
  }

  if (replaceInFileMapped('macos/Runner.xcodeproj/project.pbxproj', {
    RegExp(r'(/\* )[^*]+\.app( \*/)'): (match) =>
        '${match.group(1)}$appName.app${match.group(2)}',
    RegExp(r'(path = )[^;]+\.app(;)'): (match) =>
        '${match.group(1)}$appName.app${match.group(2)}',
    RegExp(r'(TEST_HOST = "\$\(BUILT_PRODUCTS_DIR\)/)[^/]+\.app(/)'): (match) =>
        '${match.group(1)}$appName.app${match.group(2)}',
  })) {
    print('  macos/Runner.xcodeproj/project.pbxproj: app bundle updated');
    changes++;
  }

  // 11. Windows executable and window title
  if (replaceInFile('windows/CMakeLists.txt', {
    RegExp(r'^project\([^ ]+ LANGUAGES CXX\)$', multiLine: true):
        'project($packageName LANGUAGES CXX)',
    RegExp(r'^set\(BINARY_NAME "[^"]+"\)$', multiLine: true):
        'set(BINARY_NAME "$appName")',
    RegExp(r'\$\{CLASH_DIR\}/[^"/]+Core\.exe'):
        '\${CLASH_DIR}/$coreExecutableName.exe',
    RegExp(r'\$\{CLASH_DIR\}/[^"/]+HelperService\.exe'):
        '\${CLASH_DIR}/$helperServiceName.exe',
  })) {
    print('  windows/CMakeLists.txt: updated');
    changes++;
  }

  if (replaceInFile('windows/runner/main.cpp', {
    RegExp(r'window\.Create\(L"[^"]+", origin, size\)'):
        'window.Create(L"$appName", origin, size)',
  })) {
    print('  windows/runner/main.cpp: updated');
    changes++;
  }

  // 12. Linux executable, application ID, and window title
  if (replaceInFile('linux/CMakeLists.txt', {
    RegExp(r'^set\(BINARY_NAME "[^"]+"\)$', multiLine: true):
        'set(BINARY_NAME "$appName")',
    RegExp(r'^set\(APPLICATION_ID "[^"]+"\)$', multiLine: true):
        'set(APPLICATION_ID "$appIdentifier")',
    RegExp(r'\$\{CLASH_DIR\}/[^"/]+Core'): '\${CLASH_DIR}/$coreExecutableName',
  })) {
    print('  linux/CMakeLists.txt: updated');
    changes++;
  }

  if (replaceInFile('linux/runner/my_application.cc', {
    RegExp(r'gtk_header_bar_set_title\(header_bar, "[^"]+"\)'):
        'gtk_header_bar_set_title(header_bar, "$appName")',
    RegExp(r'gtk_window_set_title\(window, "[^"]+"\)'):
        'gtk_window_set_title(window, "$appName")',
  })) {
    print('  linux/runner/my_application.cc: updated');
    changes++;
  }

  // 13. Windows Runner.rc
  if (replaceInFile('windows/runner/Runner.rc', {
    RegExp(r'VALUE "FileDescription", "[^"]*" "\\0"'):
        'VALUE "FileDescription", "$appName" "\\0"',
    RegExp(r'VALUE "OriginalFilename", "[^"]*" "\\0"'):
        'VALUE "OriginalFilename", "$appName.exe" "\\0"',
  })) {
    print('  windows/runner/Runner.rc: updated');
    changes++;
  }

  // 14. Runtime process names
  if (replaceInFile('lib/common/constant.dart', {
    RegExp(r"^const appName = '[^']+';$", multiLine: true):
        "const appName = '$appName';",
    RegExp(r"^const coreExecutableName = '[^']+';$", multiLine: true):
        "const coreExecutableName = '$coreExecutableName';",
    RegExp(r"^const appHelperService = '[^']+';$", multiLine: true):
        "const appHelperService = '$helperServiceName';",
  })) {
    print('  lib/common/constant.dart: updated');
    changes++;
  }

  if (replaceInFile('lib/common/path.dart', {
    RegExp(r"'[^']*Core\$executableExtension'"):
        "'\$coreExecutableName\$executableExtension'",
  })) {
    print('  lib/common/path.dart: updated');
    changes++;
  }

  if (replaceInFile('services/helper/build.rs', {
    RegExp(r'"[^"]*HelperService"\.to_string\(\)'):
        '"$helperServiceName".to_string()',
  })) {
    print('  services/helper/build.rs: updated');
    changes++;
  }

  if (replaceInFile('core/tun/tun.go', {
    RegExp(r'Device:\s+"[^"]+"'): 'Device:              "$appName"',
  })) {
    print('  core/tun/tun.go: updated');
    changes++;
  }

  // 15. Windows packaging exe make_config.yaml
  if (replaceInFile('windows/packaging/exe/make_config.yaml', {
    RegExp(r'^app_name:.*$', multiLine: true): 'app_name: $appName',
    RegExp(r'^display_name:.*$', multiLine: true): 'display_name: $appName',
    RegExp(r'^executable_name:.*\.exe$', multiLine: true):
        'executable_name: $appName.exe',
    RegExp(r'^output_base_file_name:.*\.exe$', multiLine: true):
        'output_base_file_name: $appName.exe',
  })) {
    print('  windows/packaging/exe/make_config.yaml: updated');
    changes++;
  }

  // 16. Windows inno_setup.iss - kill process list
  if (replaceInFile('windows/packaging/exe/inno_setup.iss', {
    RegExp(
      r'Processes := \[[^\]]+\];',
    ): "Processes := ['$appName.exe', '$coreExecutableName.exe', '$helperServiceName.exe'];",
  })) {
    print('  windows/packaging/exe/inno_setup.iss: updated');
    changes++;
  }

  // 17. Linux packaging configs (deb, appimage, rpm)
  for (final linuxConfig in [
    'linux/packaging/deb/make_config.yaml',
    'linux/packaging/appimage/make_config.yaml',
    'linux/packaging/rpm/make_config.yaml',
  ]) {
    if (replaceInFile(linuxConfig, {
      RegExp(r'^display_name:.*$', multiLine: true): 'display_name: $appName',
      RegExp(r'^package_name:.*$', multiLine: true): 'package_name: $appName',
      RegExp(r'^generic_name:.*$', multiLine: true): 'generic_name: $appName',
      RegExp(r'^\s+-\s+\w+Clash\w*$', multiLine: true): '  - $appName',
    })) {
      print('  $linuxConfig: updated');
      changes++;
    }
  }

  // 18. macOS packaging dmg make_config.yaml
  if (replaceInFile('macos/packaging/dmg/make_config.yaml', {
    RegExp(r'^title:.*$', multiLine: true): 'title: $appName',
    RegExp(r'path:\s+\S+\.app'): 'path: $appName.app',
  })) {
    print('  macos/packaging/dmg/make_config.yaml: updated');
    changes++;
  }

  // 19. macOS core executable reference
  if (replaceInFile('macos/Runner.xcodeproj/project.pbxproj', {
    RegExp(r'\b[A-Za-z0-9_]+Core\b'): coreExecutableName,
  })) {
    print('  macos/Runner.xcodeproj/project.pbxproj: updated');
    changes++;
  }

  if (replaceInFile(
    'macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme',
    {RegExp(r'BuildableName = "[^"]+\.app"'): 'BuildableName = "$appName.app"'},
  )) {
    print(
      '  macos/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme: updated',
    );
    changes++;
  }

  // 20. distribute_options.yaml
  if (replaceInFile('distribute_options.yaml', {
    RegExp(r'^app_name:.*$', multiLine: true): 'app_name: \'$appName\'',
  })) {
    print('  distribute_options.yaml: updated');
    changes++;
  }

  if (changes == 0) {
    print(
      'App name is already \'$appName\' across all configs. Nothing to do.',
    );
  } else {
    print(
      '\nDone ($changes update(s)). Run "dart run build_runner build --delete-conflicting-outputs" to regenerate code.',
    );
  }

  if (logoUrl != null && logoUrl.isNotEmpty) {
    final logoChanged = await _syncLogo(root: root, logoUrl: logoUrl);
    if (logoChanged) {
      print('  logo: generated platform icon assets from logoUrl');
    }
  }
}

String _buildAppIdentifier(String appName) {
  final base = appName.trim().toLowerCase();
  final normalized = base.replaceAll(RegExp(r'[^a-z0-9]+'), '.');
  final rawParts = normalized
      .split('.')
      .map((part) => part.startsWith(RegExp(r'[a-z]')) ? part : 'app$part')
      .where((part) => part.isNotEmpty)
      .toList();
  final parts = rawParts.isEmpty ? ['app'] : rawParts;
  return 'com.${parts.join('.')}';
}

Future<bool> _syncLogo({required String root, required String logoUrl}) async {
  final bytes = await _loadLogoBytes(root: root, logoUrl: logoUrl);
  final source = img.decodeImage(Uint8List.fromList(bytes));
  if (source == null) {
    throw FormatException(
      'logoUrl must point to a decodable PNG, WebP, JPEG, ICO, BMP, GIF, TIFF, or PSD image: $logoUrl',
    );
  }

  if (source.width < 1024 || source.height < 1024) {
    stderr.writeln(
      'Warning: logo source is ${source.width}x${source.height}. Recommended source size is at least 1024x1024.',
    );
  }

  var changed = false;

  void writePng(String relativePath, img.Image image) {
    final file = File(p.join(root, relativePath));
    file.parent.createSync(recursive: true);
    final bytes = img.encodePng(image);
    if (!file.existsSync() || !_sameBytes(file.readAsBytesSync(), bytes)) {
      file.writeAsBytesSync(bytes);
      changed = true;
    }
  }

  void writeIco(String relativePath, img.Image image) {
    final file = File(p.join(root, relativePath));
    file.parent.createSync(recursive: true);
    final bytes = img.encodeIco(image);
    if (!file.existsSync() || !_sameBytes(file.readAsBytesSync(), bytes)) {
      file.writeAsBytesSync(bytes);
      changed = true;
    }
  }

  void deleteIfExists(String relativePath) {
    final file = File(p.join(root, relativePath));
    if (file.existsSync()) {
      file.deleteSync();
      changed = true;
    }
  }

  img.Image square(int size) => img.copyResizeCropSquare(
    source,
    size: size,
    interpolation: img.Interpolation.cubic,
  );

  writePng('assets/images/icon.png', square(1024));

  final androidIcons = {
    'mipmap-mdpi': 48,
    'mipmap-hdpi': 72,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };
  for (final entry in androidIcons.entries) {
    final dir = 'android/app/src/main/res/${entry.key}';
    writePng('$dir/ic_launcher.png', square(entry.value));
    writePng('$dir/ic_launcher_round.png', square(entry.value));
    deleteIfExists('$dir/ic_launcher.webp');
    deleteIfExists('$dir/ic_launcher_round.webp');
  }
  deleteIfExists(
    'android/app/src/main/res/drawable/ic_launcher_foreground.xml',
  );
  writePng(
    'android/app/src/main/res/drawable/ic_launcher_foreground.png',
    _centered(source, canvasWidth: 432, canvasHeight: 432, maxIconSize: 288),
  );
  writePng(
    'android/app/src/main/res/mipmap-xhdpi/ic_banner.png',
    _centered(source, canvasWidth: 320, canvasHeight: 180, maxIconSize: 144),
  );

  for (final size in [16, 32, 64, 128, 256, 512, 1024]) {
    writePng(
      'macos/Runner/Assets.xcassets/AppIcon.appiconset/app_icon_$size.png',
      square(size),
    );
  }

  writeIco('windows/runner/resources/app_icon.ico', square(256));

  return changed;
}

Future<List<int>> _loadLogoBytes({
  required String root,
  required String logoUrl,
}) async {
  final uri = Uri.tryParse(logoUrl);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw HttpException(
          'Failed to download logoUrl ($logoUrl): HTTP ${response.statusCode}',
        );
      }
      return response.expand((chunk) => chunk).toList();
    } finally {
      client.close(force: true);
    }
  }

  final file = File(p.isAbsolute(logoUrl) ? logoUrl : p.join(root, logoUrl));
  if (!file.existsSync()) {
    throw FileSystemException('logoUrl file not found', file.path);
  }
  return file.readAsBytesSync();
}

img.Image _centered(
  img.Image source, {
  required int canvasWidth,
  required int canvasHeight,
  required int maxIconSize,
}) {
  final canvas = img.Image(
    width: canvasWidth,
    height: canvasHeight,
    numChannels: 4,
  );
  img.fill(canvas, color: img.ColorRgba8(0, 0, 0, 0));
  final icon = img.copyResizeCropSquare(
    source,
    size: maxIconSize,
    interpolation: img.Interpolation.cubic,
  );
  img.compositeImage(
    canvas,
    icon,
    dstX: (canvasWidth - maxIconSize) ~/ 2,
    dstY: (canvasHeight - maxIconSize) ~/ 2,
  );
  return canvas;
}

bool _sameBytes(List<int> left, List<int> right) {
  if (left.length != right.length) return false;
  for (var i = 0; i < left.length; i++) {
    if (left[i] != right[i]) return false;
  }
  return true;
}

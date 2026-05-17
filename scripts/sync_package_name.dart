// ignore_for_file: avoid_print
// Reads appName from assets/config.json and syncs it to:
//   - pubspec.yaml (Dart package name, lowercase_with_underscores)
//   - all Dart import statements under lib/
//   - Android: strings.xml, AndroidManifest.xml (main & debug)
//   - macOS: Runner/Configs/AppInfo.xcconfig
//   - Windows: CMakeLists.txt, runner/main.cpp, runner/Runner.rc,
//     packaging/exe/make_config.yaml, packaging/exe/inno_setup.iss
//   - Linux: CMakeLists.txt, runner/my_application.cc, packaging/deb|appimage|rpm/make_config.yaml
//   - distribute_options.yaml
//
// Usage: dart scripts/sync_package_name.dart

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

Future<void> main() async {
  final root = p.dirname(p.dirname(Platform.script.toFilePath()));

  // 1. Read appName from assets/config.json
  final configFile = File(p.join(root, 'assets', 'config.json'));
  if (!configFile.existsSync()) {
    stderr.writeln('Error: assets/config.json not found.');
    exit(1);
  }
  final config = json.decode(configFile.readAsStringSync()) as Map;
  final appName = (config['appName'] as String?)?.trim();
  if (appName == null || appName.isEmpty) {
    stderr.writeln('Error: appName is missing or empty in assets/config.json.');
    exit(1);
  }

  // Dart package names must be lowercase_with_underscores
  final packageName = appName
      .replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_')
      .toLowerCase();
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

  // 5. Android strings.xml
  // We keep the attribute name "FlClash" but update display value
  if (replaceInFile('android/common/src/main/res/values/strings.xml', {
    RegExp(r'>([^<]+)</string>'): '>$appName</string>',
  })) {
    print('  android/common/src/main/res/values/strings.xml: updated');
    changes++;
  }

  // 6. Android main AndroidManifest.xml — label attributes
  if (replaceInFile('android/app/src/main/AndroidManifest.xml', {
    RegExp(r'android:label="(?!.*Debug)[^"]*FlClash[^"]*"'):
        'android:label="$appName"',
  })) {
    print('  android/app/src/main/AndroidManifest.xml: updated');
    changes++;
  }

  // 7. Android debug AndroidManifest.xml
  if (replaceInFile('android/app/src/debug/AndroidManifest.xml', {
    RegExp(r'android:label="[^"]*FlClash[^"]*"'):
        'android:label="$appName Debug"',
  })) {
    print('  android/app/src/debug/AndroidManifest.xml: updated');
    changes++;
  }

  // 8. macOS AppInfo.xcconfig
  if (replaceInFile('macos/Runner/Configs/AppInfo.xcconfig', {
    RegExp(r'^PRODUCT_NAME\s*=.*$', multiLine: true): 'PRODUCT_NAME = $appName',
  })) {
    print('  macos/Runner/Configs/AppInfo.xcconfig: updated');
    changes++;
  }

  // 9. macOS project display name overrides
  if (replaceInFile('macos/Runner.xcodeproj/project.pbxproj', {
    RegExp(r'INFOPLIST_KEY_CFBundleDisplayName = [^;]+;'):
        'INFOPLIST_KEY_CFBundleDisplayName = $appName;',
  })) {
    print('  macos/Runner.xcodeproj/project.pbxproj: updated');
    changes++;
  }

  // 10. Windows executable and window title
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

  // 11. Linux executable and window title
  if (replaceInFile('linux/CMakeLists.txt', {
    RegExp(r'^set\(BINARY_NAME "[^"]+"\)$', multiLine: true):
        'set(BINARY_NAME "$appName")',
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

  // 12. Windows Runner.rc
  if (replaceInFile('windows/runner/Runner.rc', {
    RegExp(r'VALUE "FileDescription", "[^"]*" "\\0"'):
        'VALUE "FileDescription", "$appName" "\\0"',
    RegExp(r'VALUE "OriginalFilename", "[^"]*" "\\0"'):
        'VALUE "OriginalFilename", "$appName.exe" "\\0"',
  })) {
    print('  windows/runner/Runner.rc: updated');
    changes++;
  }

  // 13. Runtime process names
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

  // 14. Windows packaging exe make_config.yaml
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

  // 15. Windows inno_setup.iss — kill process list
  if (replaceInFile('windows/packaging/exe/inno_setup.iss', {
    RegExp(
      r'Processes := \[[^\]]+\];',
    ): "Processes := ['$appName.exe', '$coreExecutableName.exe', '$helperServiceName.exe'];",
  })) {
    print('  windows/packaging/exe/inno_setup.iss: updated');
    changes++;
  }

  // 16. Linux packaging configs (deb, appimage, rpm)
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

  // 17. macOS packaging dmg make_config.yaml
  if (replaceInFile('macos/packaging/dmg/make_config.yaml', {
    RegExp(r'^title:.*$', multiLine: true): 'title: $appName',
    RegExp(r'path:\s+\S+\.app'): 'path: $appName.app',
  })) {
    print('  macos/packaging/dmg/make_config.yaml: updated');
    changes++;
  }

  // 18. macOS core executable reference
  if (replaceInFile('macos/Runner.xcodeproj/project.pbxproj', {
    RegExp(r'\b[A-Za-z0-9_]+Core\b'): coreExecutableName,
  })) {
    print('  macos/Runner.xcodeproj/project.pbxproj: updated');
    changes++;
  }

  // 19. distribute_options.yaml
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
}

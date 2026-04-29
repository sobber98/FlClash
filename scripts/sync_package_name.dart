// ignore_for_file: avoid_print
// Reads appName from assets/config.json and syncs it to pubspec.yaml and
// all Dart import statements under lib/.
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
  final newName = (config['appName'] as String?)?.trim();
  if (newName == null || newName.isEmpty) {
    stderr.writeln('Error: appName is missing or empty in assets/config.json.');
    exit(1);
  }

  // Dart package names must be lowercase_with_underscores
  final packageName = newName.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '_').toLowerCase();

  // 2. Read current package name from pubspec.yaml
  final pubspecFile = File(p.join(root, 'pubspec.yaml'));
  if (!pubspecFile.existsSync()) {
    stderr.writeln('Error: pubspec.yaml not found.');
    exit(1);
  }
  final pubspecContent = pubspecFile.readAsStringSync();
  final nameMatch = RegExp(r'^name:\s*(\S+)', multiLine: true).firstMatch(pubspecContent);
  if (nameMatch == null) {
    stderr.writeln('Error: Could not find name: field in pubspec.yaml.');
    exit(1);
  }
  final oldName = nameMatch.group(1)!;

  if (oldName == packageName) {
    print('Package name is already "$packageName". Nothing to do.');
    return;
  }

  print('Syncing package name: "$oldName" → "$packageName"');

  // 3. Update pubspec.yaml
  final updatedPubspec = pubspecContent.replaceFirst(
    RegExp(r'^name:\s*\S+', multiLine: true),
    'name: $packageName',
  );
  pubspecFile.writeAsStringSync(updatedPubspec);
  print('  Updated pubspec.yaml');

  // 4. Update all .dart files under lib/
  int fileCount = 0;
  final libDir = Directory(p.join(root, 'lib'));
  await for (final entity in libDir.list(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;
    final original = entity.readAsStringSync();
    final updated = original.replaceAll('package:$oldName/', 'package:$packageName/');
    if (updated != original) {
      entity.writeAsStringSync(updated);
      fileCount++;
    }
  }
  print('  Updated $fileCount dart file(s) under lib/');

  print('Done. Run "dart run build_runner build --delete-conflicting-outputs" to regenerate code.');
}

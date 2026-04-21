import 'package:fl_clash/common/constant.dart' as constants;
import 'package:fl_clash/enum/enum.dart';

class AppConfig {
  final String serverUrl;
  final String ossUrl;
  final String appName;
  final Mode? defaultMode;
  final bool? enableRegistration;
  final String supportEmail;
  final String officialWebsite;
  final String telegramGroup;
  final List<String> blockedNodeKeywords;
  final Map<String, dynamic> extras;

  const AppConfig({
    this.serverUrl = '',
    this.ossUrl = '',
    this.appName = '',
    this.defaultMode,
    this.enableRegistration,
    this.supportEmail = '',
    this.officialWebsite = '',
    this.telegramGroup = '',
    this.blockedNodeKeywords = const [],
    this.extras = const {},
  });

  factory AppConfig.defaults() {
    return const AppConfig(
      appName: constants.appName,
      enableRegistration: true,
    );
  }

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    final extras = Map<String, dynamic>.from(json)
      ..removeWhere((key, _) => _knownKeys.contains(key));
    return AppConfig(
      serverUrl: _readString(json['serverUrl'] ?? json['server_url']),
      ossUrl: _readString(json['ossUrl'] ?? json['oss_url']),
      appName: _readString(json['appName'] ?? json['app_name']),
      defaultMode: _parseMode(json['defaultMode'] ?? json['default_mode']),
      enableRegistration: _readBoolNullable(
        json['enableRegistration'] ?? json['enable_registration'],
      ),
      supportEmail: _readString(json['supportEmail'] ?? json['support_email']),
      officialWebsite: _readString(
        json['officialWebsite'] ?? json['official_website'],
      ),
      telegramGroup: _readString(
        json['telegramGroup'] ?? json['telegram_group'],
      ),
      blockedNodeKeywords: _readStringList(
        json['blockedNodeKeywords'] ?? json['blocked_node_keywords'],
      ),
      extras: extras,
    );
  }

  AppConfig copyWith({
    String? serverUrl,
    String? ossUrl,
    String? appName,
    Mode? defaultMode,
    bool? enableRegistration,
    bool clearEnableRegistration = false,
    String? supportEmail,
    String? officialWebsite,
    String? telegramGroup,
    List<String>? blockedNodeKeywords,
    Map<String, dynamic>? extras,
  }) {
    return AppConfig(
      serverUrl: serverUrl ?? this.serverUrl,
      ossUrl: ossUrl ?? this.ossUrl,
      appName: appName ?? this.appName,
      defaultMode: defaultMode ?? this.defaultMode,
      enableRegistration: clearEnableRegistration
          ? null
          : enableRegistration ?? this.enableRegistration,
      supportEmail: supportEmail ?? this.supportEmail,
      officialWebsite: officialWebsite ?? this.officialWebsite,
      telegramGroup: telegramGroup ?? this.telegramGroup,
      blockedNodeKeywords: blockedNodeKeywords ?? this.blockedNodeKeywords,
      extras: extras ?? this.extras,
    );
  }

  AppConfig merge(AppConfig other) {
    return AppConfig(
      serverUrl: other.serverUrl.trim().isNotEmpty
          ? other.serverUrl
          : serverUrl,
      ossUrl: other.ossUrl.trim().isNotEmpty ? other.ossUrl : ossUrl,
      appName: other.appName.trim().isNotEmpty ? other.appName : appName,
      defaultMode: other.defaultMode ?? defaultMode,
      enableRegistration: other.enableRegistration ?? enableRegistration,
      supportEmail: other.supportEmail.trim().isNotEmpty
          ? other.supportEmail
          : supportEmail,
      officialWebsite: other.officialWebsite.trim().isNotEmpty
          ? other.officialWebsite
          : officialWebsite,
      telegramGroup: other.telegramGroup.trim().isNotEmpty
          ? other.telegramGroup
          : telegramGroup,
      blockedNodeKeywords: other.blockedNodeKeywords.isNotEmpty
          ? other.blockedNodeKeywords
          : blockedNodeKeywords,
      extras: {...extras, ...other.extras},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'serverUrl': serverUrl,
      'ossUrl': ossUrl,
      'appName': appName,
      'defaultMode': defaultMode?.name,
      'enableRegistration': enableRegistration,
      'supportEmail': supportEmail,
      'officialWebsite': officialWebsite,
      'telegramGroup': telegramGroup,
      'blockedNodeKeywords': blockedNodeKeywords,
      ...extras,
    };
  }

  String get resolvedServerUrl => serverUrl.trim();

  String get resolvedOssUrl => ossUrl.trim();

  String get resolvedAppName {
    final value = appName.trim();
    return value.isEmpty ? constants.appName : value;
  }

  String get resolvedOfficialWebsite => officialWebsite.trim();

  bool get resolvedEnableRegistration => enableRegistration ?? true;

  static const Set<String> _knownKeys = {
    'serverUrl',
    'server_url',
    'ossUrl',
    'oss_url',
    'appName',
    'app_name',
    'defaultMode',
    'default_mode',
    'enableRegistration',
    'enable_registration',
    'supportEmail',
    'support_email',
    'officialWebsite',
    'official_website',
    'telegramGroup',
    'telegram_group',
    'blockedNodeKeywords',
    'blocked_node_keywords',
  };
}

String _readString(Object? value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  return value.toString().trim();
}

List<String> _readStringList(Object? value) {
  if (value == null) return const [];
  if (value is List) {
    return value.map((e) => _readString(e)).where((s) => s.isNotEmpty).toList();
  }
  return const [];
}

bool? _readBoolNullable(Object? value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return null;
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    final number = num.tryParse(normalized);
    if (number != null) return number != 0;
  }
  return null;
}

Mode? _parseMode(Object? value) {
  final raw = _readString(value).toLowerCase();
  if (raw.isEmpty) return null;
  return Mode.values.where((item) => item.name == raw).firstOrNull;
}

extension _FirstOrNullExtension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

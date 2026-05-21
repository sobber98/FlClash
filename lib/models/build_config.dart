class BuildConfig {
  final String appName;
  final String logoUrl;
  final String ossUrl;

  const BuildConfig({this.appName = '', this.logoUrl = '', this.ossUrl = ''});

  factory BuildConfig.fromJson(Map<String, dynamic> json) {
    return BuildConfig(
      appName: _readString(json['appName'] ?? json['app_name']),
      logoUrl: _readString(json['logoUrl'] ?? json['logo_url']),
      ossUrl: _readString(json['ossUrl'] ?? json['oss_url']),
    );
  }
}

String _readString(Object? value) {
  if (value == null) return '';
  if (value is String) return value.trim();
  return value.toString().trim();
}

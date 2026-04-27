// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../update.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UpdateManifest _$UpdateManifestFromJson(Map<String, dynamic> json) =>
    _UpdateManifest(
      version: json['version'] as String,
      releaseDate: json['releaseDate'] as String?,
      forceUpdate: json['forceUpdate'] as bool? ?? false,
      changelog:
          (json['changelog'] as Map<String, dynamic>?)?.map(
            (k, e) => MapEntry(
              k,
              (e as List<dynamic>).map((e) => e as String).toList(),
            ),
          ) ??
          const {},
      assets:
          (json['assets'] as Map<String, dynamic>?)?.map(
            (k, e) =>
                MapEntry(k, UpdateAsset.fromJson(e as Map<String, dynamic>)),
          ) ??
          const {},
    );

Map<String, dynamic> _$UpdateManifestToJson(_UpdateManifest instance) =>
    <String, dynamic>{
      'version': instance.version,
      'releaseDate': instance.releaseDate,
      'forceUpdate': instance.forceUpdate,
      'changelog': instance.changelog,
      'assets': instance.assets,
    };

_UpdateAsset _$UpdateAssetFromJson(Map<String, dynamic> json) => _UpdateAsset(
  url: json['url'] as String,
  sha256: json['sha256'] as String,
  size: (json['size'] as num).toInt(),
);

Map<String, dynamic> _$UpdateAssetToJson(_UpdateAsset instance) =>
    <String, dynamic>{
      'url': instance.url,
      'sha256': instance.sha256,
      'size': instance.size,
    };

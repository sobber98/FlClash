import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/update.freezed.dart';
part 'generated/update.g.dart';

@freezed
abstract class UpdateManifest with _$UpdateManifest {
  const factory UpdateManifest({
    required String version,
    String? releaseDate,
    @Default(false) bool forceUpdate,
    @Default({}) Map<String, List<String>> changelog,
    @Default({}) Map<String, UpdateAsset> assets,
  }) = _UpdateManifest;

  factory UpdateManifest.fromJson(Map<String, dynamic> json) =>
      _$UpdateManifestFromJson(json);
}

@freezed
abstract class UpdateAsset with _$UpdateAsset {
  const factory UpdateAsset({
    required String url,
    required String sha256,
    required int size,
  }) = _UpdateAsset;

  factory UpdateAsset.fromJson(Map<String, dynamic> json) =>
      _$UpdateAssetFromJson(json);
}
// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../update.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UpdateManifest {

 String get version; String? get releaseDate; bool get forceUpdate; Map<String, List<String>> get changelog; Map<String, UpdateAsset> get assets;
/// Create a copy of UpdateManifest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateManifestCopyWith<UpdateManifest> get copyWith => _$UpdateManifestCopyWithImpl<UpdateManifest>(this as UpdateManifest, _$identity);

  /// Serializes this UpdateManifest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateManifest&&(identical(other.version, version) || other.version == version)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.forceUpdate, forceUpdate) || other.forceUpdate == forceUpdate)&&const DeepCollectionEquality().equals(other.changelog, changelog)&&const DeepCollectionEquality().equals(other.assets, assets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,releaseDate,forceUpdate,const DeepCollectionEquality().hash(changelog),const DeepCollectionEquality().hash(assets));

@override
String toString() {
  return 'UpdateManifest(version: $version, releaseDate: $releaseDate, forceUpdate: $forceUpdate, changelog: $changelog, assets: $assets)';
}


}

/// @nodoc
abstract mixin class $UpdateManifestCopyWith<$Res>  {
  factory $UpdateManifestCopyWith(UpdateManifest value, $Res Function(UpdateManifest) _then) = _$UpdateManifestCopyWithImpl;
@useResult
$Res call({
 String version, String? releaseDate, bool forceUpdate, Map<String, List<String>> changelog, Map<String, UpdateAsset> assets
});




}
/// @nodoc
class _$UpdateManifestCopyWithImpl<$Res>
    implements $UpdateManifestCopyWith<$Res> {
  _$UpdateManifestCopyWithImpl(this._self, this._then);

  final UpdateManifest _self;
  final $Res Function(UpdateManifest) _then;

/// Create a copy of UpdateManifest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? version = null,Object? releaseDate = freezed,Object? forceUpdate = null,Object? changelog = null,Object? assets = null,}) {
  return _then(_self.copyWith(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,forceUpdate: null == forceUpdate ? _self.forceUpdate : forceUpdate // ignore: cast_nullable_to_non_nullable
as bool,changelog: null == changelog ? _self.changelog : changelog // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,assets: null == assets ? _self.assets : assets // ignore: cast_nullable_to_non_nullable
as Map<String, UpdateAsset>,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateManifest].
extension UpdateManifestPatterns on UpdateManifest {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateManifest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateManifest() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateManifest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateManifest():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateManifest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateManifest() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String version,  String? releaseDate,  bool forceUpdate,  Map<String, List<String>> changelog,  Map<String, UpdateAsset> assets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateManifest() when $default != null:
return $default(_that.version,_that.releaseDate,_that.forceUpdate,_that.changelog,_that.assets);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String version,  String? releaseDate,  bool forceUpdate,  Map<String, List<String>> changelog,  Map<String, UpdateAsset> assets)  $default,) {final _that = this;
switch (_that) {
case _UpdateManifest():
return $default(_that.version,_that.releaseDate,_that.forceUpdate,_that.changelog,_that.assets);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String version,  String? releaseDate,  bool forceUpdate,  Map<String, List<String>> changelog,  Map<String, UpdateAsset> assets)?  $default,) {final _that = this;
switch (_that) {
case _UpdateManifest() when $default != null:
return $default(_that.version,_that.releaseDate,_that.forceUpdate,_that.changelog,_that.assets);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateManifest implements UpdateManifest {
  const _UpdateManifest({required this.version, this.releaseDate, this.forceUpdate = false, final  Map<String, List<String>> changelog = const {}, final  Map<String, UpdateAsset> assets = const {}}): _changelog = changelog,_assets = assets;
  factory _UpdateManifest.fromJson(Map<String, dynamic> json) => _$UpdateManifestFromJson(json);

@override final  String version;
@override final  String? releaseDate;
@override@JsonKey() final  bool forceUpdate;
 final  Map<String, List<String>> _changelog;
@override@JsonKey() Map<String, List<String>> get changelog {
  if (_changelog is EqualUnmodifiableMapView) return _changelog;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_changelog);
}

 final  Map<String, UpdateAsset> _assets;
@override@JsonKey() Map<String, UpdateAsset> get assets {
  if (_assets is EqualUnmodifiableMapView) return _assets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_assets);
}


/// Create a copy of UpdateManifest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateManifestCopyWith<_UpdateManifest> get copyWith => __$UpdateManifestCopyWithImpl<_UpdateManifest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateManifestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateManifest&&(identical(other.version, version) || other.version == version)&&(identical(other.releaseDate, releaseDate) || other.releaseDate == releaseDate)&&(identical(other.forceUpdate, forceUpdate) || other.forceUpdate == forceUpdate)&&const DeepCollectionEquality().equals(other._changelog, _changelog)&&const DeepCollectionEquality().equals(other._assets, _assets));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,version,releaseDate,forceUpdate,const DeepCollectionEquality().hash(_changelog),const DeepCollectionEquality().hash(_assets));

@override
String toString() {
  return 'UpdateManifest(version: $version, releaseDate: $releaseDate, forceUpdate: $forceUpdate, changelog: $changelog, assets: $assets)';
}


}

/// @nodoc
abstract mixin class _$UpdateManifestCopyWith<$Res> implements $UpdateManifestCopyWith<$Res> {
  factory _$UpdateManifestCopyWith(_UpdateManifest value, $Res Function(_UpdateManifest) _then) = __$UpdateManifestCopyWithImpl;
@override @useResult
$Res call({
 String version, String? releaseDate, bool forceUpdate, Map<String, List<String>> changelog, Map<String, UpdateAsset> assets
});




}
/// @nodoc
class __$UpdateManifestCopyWithImpl<$Res>
    implements _$UpdateManifestCopyWith<$Res> {
  __$UpdateManifestCopyWithImpl(this._self, this._then);

  final _UpdateManifest _self;
  final $Res Function(_UpdateManifest) _then;

/// Create a copy of UpdateManifest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? version = null,Object? releaseDate = freezed,Object? forceUpdate = null,Object? changelog = null,Object? assets = null,}) {
  return _then(_UpdateManifest(
version: null == version ? _self.version : version // ignore: cast_nullable_to_non_nullable
as String,releaseDate: freezed == releaseDate ? _self.releaseDate : releaseDate // ignore: cast_nullable_to_non_nullable
as String?,forceUpdate: null == forceUpdate ? _self.forceUpdate : forceUpdate // ignore: cast_nullable_to_non_nullable
as bool,changelog: null == changelog ? _self._changelog : changelog // ignore: cast_nullable_to_non_nullable
as Map<String, List<String>>,assets: null == assets ? _self._assets : assets // ignore: cast_nullable_to_non_nullable
as Map<String, UpdateAsset>,
  ));
}


}


/// @nodoc
mixin _$UpdateAsset {

 String get url; String get sha256; int get size;
/// Create a copy of UpdateAsset
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateAssetCopyWith<UpdateAsset> get copyWith => _$UpdateAssetCopyWithImpl<UpdateAsset>(this as UpdateAsset, _$identity);

  /// Serializes this UpdateAsset to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateAsset&&(identical(other.url, url) || other.url == url)&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,sha256,size);

@override
String toString() {
  return 'UpdateAsset(url: $url, sha256: $sha256, size: $size)';
}


}

/// @nodoc
abstract mixin class $UpdateAssetCopyWith<$Res>  {
  factory $UpdateAssetCopyWith(UpdateAsset value, $Res Function(UpdateAsset) _then) = _$UpdateAssetCopyWithImpl;
@useResult
$Res call({
 String url, String sha256, int size
});




}
/// @nodoc
class _$UpdateAssetCopyWithImpl<$Res>
    implements $UpdateAssetCopyWith<$Res> {
  _$UpdateAssetCopyWithImpl(this._self, this._then);

  final UpdateAsset _self;
  final $Res Function(UpdateAsset) _then;

/// Create a copy of UpdateAsset
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? sha256 = null,Object? size = null,}) {
  return _then(_self.copyWith(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateAsset].
extension UpdateAssetPatterns on UpdateAsset {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateAsset value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateAsset() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateAsset value)  $default,){
final _that = this;
switch (_that) {
case _UpdateAsset():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateAsset value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateAsset() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  String sha256,  int size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateAsset() when $default != null:
return $default(_that.url,_that.sha256,_that.size);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  String sha256,  int size)  $default,) {final _that = this;
switch (_that) {
case _UpdateAsset():
return $default(_that.url,_that.sha256,_that.size);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  String sha256,  int size)?  $default,) {final _that = this;
switch (_that) {
case _UpdateAsset() when $default != null:
return $default(_that.url,_that.sha256,_that.size);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateAsset implements UpdateAsset {
  const _UpdateAsset({required this.url, required this.sha256, required this.size});
  factory _UpdateAsset.fromJson(Map<String, dynamic> json) => _$UpdateAssetFromJson(json);

@override final  String url;
@override final  String sha256;
@override final  int size;

/// Create a copy of UpdateAsset
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateAssetCopyWith<_UpdateAsset> get copyWith => __$UpdateAssetCopyWithImpl<_UpdateAsset>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateAssetToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateAsset&&(identical(other.url, url) || other.url == url)&&(identical(other.sha256, sha256) || other.sha256 == sha256)&&(identical(other.size, size) || other.size == size));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,url,sha256,size);

@override
String toString() {
  return 'UpdateAsset(url: $url, sha256: $sha256, size: $size)';
}


}

/// @nodoc
abstract mixin class _$UpdateAssetCopyWith<$Res> implements $UpdateAssetCopyWith<$Res> {
  factory _$UpdateAssetCopyWith(_UpdateAsset value, $Res Function(_UpdateAsset) _then) = __$UpdateAssetCopyWithImpl;
@override @useResult
$Res call({
 String url, String sha256, int size
});




}
/// @nodoc
class __$UpdateAssetCopyWithImpl<$Res>
    implements _$UpdateAssetCopyWith<$Res> {
  __$UpdateAssetCopyWithImpl(this._self, this._then);

  final _UpdateAsset _self;
  final $Res Function(_UpdateAsset) _then;

/// Create a copy of UpdateAsset
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? sha256 = null,Object? size = null,}) {
  return _then(_UpdateAsset(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,sha256: null == sha256 ? _self.sha256 : sha256 // ignore: cast_nullable_to_non_nullable
as String,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

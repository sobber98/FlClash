// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of '../v2board_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$V2BoardAuth {

 String get token;@JsonKey(name: 'is_admin') bool get isAdmin;@JsonKey(name: 'auth_data') String get authData;
/// Create a copy of V2BoardAuth
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$V2BoardAuthCopyWith<V2BoardAuth> get copyWith => _$V2BoardAuthCopyWithImpl<V2BoardAuth>(this as V2BoardAuth, _$identity);

  /// Serializes this V2BoardAuth to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is V2BoardAuth&&(identical(other.token, token) || other.token == token)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.authData, authData) || other.authData == authData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,isAdmin,authData);

@override
String toString() {
  return 'V2BoardAuth(token: $token, isAdmin: $isAdmin, authData: $authData)';
}


}

/// @nodoc
abstract mixin class $V2BoardAuthCopyWith<$Res>  {
  factory $V2BoardAuthCopyWith(V2BoardAuth value, $Res Function(V2BoardAuth) _then) = _$V2BoardAuthCopyWithImpl;
@useResult
$Res call({
 String token,@JsonKey(name: 'is_admin') bool isAdmin,@JsonKey(name: 'auth_data') String authData
});




}
/// @nodoc
class _$V2BoardAuthCopyWithImpl<$Res>
    implements $V2BoardAuthCopyWith<$Res> {
  _$V2BoardAuthCopyWithImpl(this._self, this._then);

  final V2BoardAuth _self;
  final $Res Function(V2BoardAuth) _then;

/// Create a copy of V2BoardAuth
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? token = null,Object? isAdmin = null,Object? authData = null,}) {
  return _then(_self.copyWith(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,authData: null == authData ? _self.authData : authData // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [V2BoardAuth].
extension V2BoardAuthPatterns on V2BoardAuth {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _V2BoardAuth value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _V2BoardAuth() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _V2BoardAuth value)  $default,){
final _that = this;
switch (_that) {
case _V2BoardAuth():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _V2BoardAuth value)?  $default,){
final _that = this;
switch (_that) {
case _V2BoardAuth() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String token, @JsonKey(name: 'is_admin')  bool isAdmin, @JsonKey(name: 'auth_data')  String authData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _V2BoardAuth() when $default != null:
return $default(_that.token,_that.isAdmin,_that.authData);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String token, @JsonKey(name: 'is_admin')  bool isAdmin, @JsonKey(name: 'auth_data')  String authData)  $default,) {final _that = this;
switch (_that) {
case _V2BoardAuth():
return $default(_that.token,_that.isAdmin,_that.authData);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String token, @JsonKey(name: 'is_admin')  bool isAdmin, @JsonKey(name: 'auth_data')  String authData)?  $default,) {final _that = this;
switch (_that) {
case _V2BoardAuth() when $default != null:
return $default(_that.token,_that.isAdmin,_that.authData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _V2BoardAuth implements V2BoardAuth {
  const _V2BoardAuth({this.token = '', @JsonKey(name: 'is_admin') this.isAdmin = false, @JsonKey(name: 'auth_data') this.authData = ''});
  factory _V2BoardAuth.fromJson(Map<String, dynamic> json) => _$V2BoardAuthFromJson(json);

@override@JsonKey() final  String token;
@override@JsonKey(name: 'is_admin') final  bool isAdmin;
@override@JsonKey(name: 'auth_data') final  String authData;

/// Create a copy of V2BoardAuth
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$V2BoardAuthCopyWith<_V2BoardAuth> get copyWith => __$V2BoardAuthCopyWithImpl<_V2BoardAuth>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$V2BoardAuthToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _V2BoardAuth&&(identical(other.token, token) || other.token == token)&&(identical(other.isAdmin, isAdmin) || other.isAdmin == isAdmin)&&(identical(other.authData, authData) || other.authData == authData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,token,isAdmin,authData);

@override
String toString() {
  return 'V2BoardAuth(token: $token, isAdmin: $isAdmin, authData: $authData)';
}


}

/// @nodoc
abstract mixin class _$V2BoardAuthCopyWith<$Res> implements $V2BoardAuthCopyWith<$Res> {
  factory _$V2BoardAuthCopyWith(_V2BoardAuth value, $Res Function(_V2BoardAuth) _then) = __$V2BoardAuthCopyWithImpl;
@override @useResult
$Res call({
 String token,@JsonKey(name: 'is_admin') bool isAdmin,@JsonKey(name: 'auth_data') String authData
});




}
/// @nodoc
class __$V2BoardAuthCopyWithImpl<$Res>
    implements _$V2BoardAuthCopyWith<$Res> {
  __$V2BoardAuthCopyWithImpl(this._self, this._then);

  final _V2BoardAuth _self;
  final $Res Function(_V2BoardAuth) _then;

/// Create a copy of V2BoardAuth
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? token = null,Object? isAdmin = null,Object? authData = null,}) {
  return _then(_V2BoardAuth(
token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,isAdmin: null == isAdmin ? _self.isAdmin : isAdmin // ignore: cast_nullable_to_non_nullable
as bool,authData: null == authData ? _self.authData : authData // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$V2BoardUser {

 int get id; String get email;@JsonKey(name: 'transfer_enable') int get transferEnable;@JsonKey(name: 'plan_id') int? get planId;@JsonKey(name: 'u') int get upload;@JsonKey(name: 'd') int get download;@JsonKey(name: 'expired_at') int? get expiredAt; String get uuid; int get balance;@JsonKey(name: 'commission_balance') int get commissionBalance;@JsonKey(name: 'created_at') int? get createdAt;@JsonKey(name: 'updated_at') int? get updatedAt;@JsonKey(name: 'remind_expire') bool get remindExpire;@JsonKey(name: 'remind_traffic') bool get remindTraffic;
/// Create a copy of V2BoardUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$V2BoardUserCopyWith<V2BoardUser> get copyWith => _$V2BoardUserCopyWithImpl<V2BoardUser>(this as V2BoardUser, _$identity);

  /// Serializes this V2BoardUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is V2BoardUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.transferEnable, transferEnable) || other.transferEnable == transferEnable)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.commissionBalance, commissionBalance) || other.commissionBalance == commissionBalance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.remindExpire, remindExpire) || other.remindExpire == remindExpire)&&(identical(other.remindTraffic, remindTraffic) || other.remindTraffic == remindTraffic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,transferEnable,planId,upload,download,expiredAt,uuid,balance,commissionBalance,createdAt,updatedAt,remindExpire,remindTraffic);

@override
String toString() {
  return 'V2BoardUser(id: $id, email: $email, transferEnable: $transferEnable, planId: $planId, upload: $upload, download: $download, expiredAt: $expiredAt, uuid: $uuid, balance: $balance, commissionBalance: $commissionBalance, createdAt: $createdAt, updatedAt: $updatedAt, remindExpire: $remindExpire, remindTraffic: $remindTraffic)';
}


}

/// @nodoc
abstract mixin class $V2BoardUserCopyWith<$Res>  {
  factory $V2BoardUserCopyWith(V2BoardUser value, $Res Function(V2BoardUser) _then) = _$V2BoardUserCopyWithImpl;
@useResult
$Res call({
 int id, String email,@JsonKey(name: 'transfer_enable') int transferEnable,@JsonKey(name: 'plan_id') int? planId,@JsonKey(name: 'u') int upload,@JsonKey(name: 'd') int download,@JsonKey(name: 'expired_at') int? expiredAt, String uuid, int balance,@JsonKey(name: 'commission_balance') int commissionBalance,@JsonKey(name: 'created_at') int? createdAt,@JsonKey(name: 'updated_at') int? updatedAt,@JsonKey(name: 'remind_expire') bool remindExpire,@JsonKey(name: 'remind_traffic') bool remindTraffic
});




}
/// @nodoc
class _$V2BoardUserCopyWithImpl<$Res>
    implements $V2BoardUserCopyWith<$Res> {
  _$V2BoardUserCopyWithImpl(this._self, this._then);

  final V2BoardUser _self;
  final $Res Function(V2BoardUser) _then;

/// Create a copy of V2BoardUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? email = null,Object? transferEnable = null,Object? planId = freezed,Object? upload = null,Object? download = null,Object? expiredAt = freezed,Object? uuid = null,Object? balance = null,Object? commissionBalance = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? remindExpire = null,Object? remindTraffic = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,transferEnable: null == transferEnable ? _self.transferEnable : transferEnable // ignore: cast_nullable_to_non_nullable
as int,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as int?,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as int?,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,commissionBalance: null == commissionBalance ? _self.commissionBalance : commissionBalance // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int?,remindExpire: null == remindExpire ? _self.remindExpire : remindExpire // ignore: cast_nullable_to_non_nullable
as bool,remindTraffic: null == remindTraffic ? _self.remindTraffic : remindTraffic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [V2BoardUser].
extension V2BoardUserPatterns on V2BoardUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _V2BoardUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _V2BoardUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _V2BoardUser value)  $default,){
final _that = this;
switch (_that) {
case _V2BoardUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _V2BoardUser value)?  $default,){
final _that = this;
switch (_that) {
case _V2BoardUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String email, @JsonKey(name: 'transfer_enable')  int transferEnable, @JsonKey(name: 'plan_id')  int? planId, @JsonKey(name: 'u')  int upload, @JsonKey(name: 'd')  int download, @JsonKey(name: 'expired_at')  int? expiredAt,  String uuid,  int balance, @JsonKey(name: 'commission_balance')  int commissionBalance, @JsonKey(name: 'created_at')  int? createdAt, @JsonKey(name: 'updated_at')  int? updatedAt, @JsonKey(name: 'remind_expire')  bool remindExpire, @JsonKey(name: 'remind_traffic')  bool remindTraffic)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _V2BoardUser() when $default != null:
return $default(_that.id,_that.email,_that.transferEnable,_that.planId,_that.upload,_that.download,_that.expiredAt,_that.uuid,_that.balance,_that.commissionBalance,_that.createdAt,_that.updatedAt,_that.remindExpire,_that.remindTraffic);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String email, @JsonKey(name: 'transfer_enable')  int transferEnable, @JsonKey(name: 'plan_id')  int? planId, @JsonKey(name: 'u')  int upload, @JsonKey(name: 'd')  int download, @JsonKey(name: 'expired_at')  int? expiredAt,  String uuid,  int balance, @JsonKey(name: 'commission_balance')  int commissionBalance, @JsonKey(name: 'created_at')  int? createdAt, @JsonKey(name: 'updated_at')  int? updatedAt, @JsonKey(name: 'remind_expire')  bool remindExpire, @JsonKey(name: 'remind_traffic')  bool remindTraffic)  $default,) {final _that = this;
switch (_that) {
case _V2BoardUser():
return $default(_that.id,_that.email,_that.transferEnable,_that.planId,_that.upload,_that.download,_that.expiredAt,_that.uuid,_that.balance,_that.commissionBalance,_that.createdAt,_that.updatedAt,_that.remindExpire,_that.remindTraffic);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String email, @JsonKey(name: 'transfer_enable')  int transferEnable, @JsonKey(name: 'plan_id')  int? planId, @JsonKey(name: 'u')  int upload, @JsonKey(name: 'd')  int download, @JsonKey(name: 'expired_at')  int? expiredAt,  String uuid,  int balance, @JsonKey(name: 'commission_balance')  int commissionBalance, @JsonKey(name: 'created_at')  int? createdAt, @JsonKey(name: 'updated_at')  int? updatedAt, @JsonKey(name: 'remind_expire')  bool remindExpire, @JsonKey(name: 'remind_traffic')  bool remindTraffic)?  $default,) {final _that = this;
switch (_that) {
case _V2BoardUser() when $default != null:
return $default(_that.id,_that.email,_that.transferEnable,_that.planId,_that.upload,_that.download,_that.expiredAt,_that.uuid,_that.balance,_that.commissionBalance,_that.createdAt,_that.updatedAt,_that.remindExpire,_that.remindTraffic);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _V2BoardUser implements V2BoardUser {
  const _V2BoardUser({this.id = 0, this.email = '', @JsonKey(name: 'transfer_enable') this.transferEnable = 0, @JsonKey(name: 'plan_id') this.planId, @JsonKey(name: 'u') this.upload = 0, @JsonKey(name: 'd') this.download = 0, @JsonKey(name: 'expired_at') this.expiredAt, this.uuid = '', this.balance = 0, @JsonKey(name: 'commission_balance') this.commissionBalance = 0, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'remind_expire') this.remindExpire = false, @JsonKey(name: 'remind_traffic') this.remindTraffic = false});
  factory _V2BoardUser.fromJson(Map<String, dynamic> json) => _$V2BoardUserFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String email;
@override@JsonKey(name: 'transfer_enable') final  int transferEnable;
@override@JsonKey(name: 'plan_id') final  int? planId;
@override@JsonKey(name: 'u') final  int upload;
@override@JsonKey(name: 'd') final  int download;
@override@JsonKey(name: 'expired_at') final  int? expiredAt;
@override@JsonKey() final  String uuid;
@override@JsonKey() final  int balance;
@override@JsonKey(name: 'commission_balance') final  int commissionBalance;
@override@JsonKey(name: 'created_at') final  int? createdAt;
@override@JsonKey(name: 'updated_at') final  int? updatedAt;
@override@JsonKey(name: 'remind_expire') final  bool remindExpire;
@override@JsonKey(name: 'remind_traffic') final  bool remindTraffic;

/// Create a copy of V2BoardUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$V2BoardUserCopyWith<_V2BoardUser> get copyWith => __$V2BoardUserCopyWithImpl<_V2BoardUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$V2BoardUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _V2BoardUser&&(identical(other.id, id) || other.id == id)&&(identical(other.email, email) || other.email == email)&&(identical(other.transferEnable, transferEnable) || other.transferEnable == transferEnable)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.uuid, uuid) || other.uuid == uuid)&&(identical(other.balance, balance) || other.balance == balance)&&(identical(other.commissionBalance, commissionBalance) || other.commissionBalance == commissionBalance)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.remindExpire, remindExpire) || other.remindExpire == remindExpire)&&(identical(other.remindTraffic, remindTraffic) || other.remindTraffic == remindTraffic));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,email,transferEnable,planId,upload,download,expiredAt,uuid,balance,commissionBalance,createdAt,updatedAt,remindExpire,remindTraffic);

@override
String toString() {
  return 'V2BoardUser(id: $id, email: $email, transferEnable: $transferEnable, planId: $planId, upload: $upload, download: $download, expiredAt: $expiredAt, uuid: $uuid, balance: $balance, commissionBalance: $commissionBalance, createdAt: $createdAt, updatedAt: $updatedAt, remindExpire: $remindExpire, remindTraffic: $remindTraffic)';
}


}

/// @nodoc
abstract mixin class _$V2BoardUserCopyWith<$Res> implements $V2BoardUserCopyWith<$Res> {
  factory _$V2BoardUserCopyWith(_V2BoardUser value, $Res Function(_V2BoardUser) _then) = __$V2BoardUserCopyWithImpl;
@override @useResult
$Res call({
 int id, String email,@JsonKey(name: 'transfer_enable') int transferEnable,@JsonKey(name: 'plan_id') int? planId,@JsonKey(name: 'u') int upload,@JsonKey(name: 'd') int download,@JsonKey(name: 'expired_at') int? expiredAt, String uuid, int balance,@JsonKey(name: 'commission_balance') int commissionBalance,@JsonKey(name: 'created_at') int? createdAt,@JsonKey(name: 'updated_at') int? updatedAt,@JsonKey(name: 'remind_expire') bool remindExpire,@JsonKey(name: 'remind_traffic') bool remindTraffic
});




}
/// @nodoc
class __$V2BoardUserCopyWithImpl<$Res>
    implements _$V2BoardUserCopyWith<$Res> {
  __$V2BoardUserCopyWithImpl(this._self, this._then);

  final _V2BoardUser _self;
  final $Res Function(_V2BoardUser) _then;

/// Create a copy of V2BoardUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? email = null,Object? transferEnable = null,Object? planId = freezed,Object? upload = null,Object? download = null,Object? expiredAt = freezed,Object? uuid = null,Object? balance = null,Object? commissionBalance = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? remindExpire = null,Object? remindTraffic = null,}) {
  return _then(_V2BoardUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,transferEnable: null == transferEnable ? _self.transferEnable : transferEnable // ignore: cast_nullable_to_non_nullable
as int,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as int?,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as int?,uuid: null == uuid ? _self.uuid : uuid // ignore: cast_nullable_to_non_nullable
as String,balance: null == balance ? _self.balance : balance // ignore: cast_nullable_to_non_nullable
as int,commissionBalance: null == commissionBalance ? _self.commissionBalance : commissionBalance // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int?,remindExpire: null == remindExpire ? _self.remindExpire : remindExpire // ignore: cast_nullable_to_non_nullable
as bool,remindTraffic: null == remindTraffic ? _self.remindTraffic : remindTraffic // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$V2BoardPlan {

 int get id; String get name; String? get content;@JsonKey(name: 'group_id') int? get groupId;@JsonKey(name: 'transfer_enable') int? get transferEnable;@JsonKey(name: 'month_price') int? get monthPrice;@JsonKey(name: 'quarter_price') int? get quarterPrice;@JsonKey(name: 'half_year_price') int? get halfYearPrice;@JsonKey(name: 'year_price') int? get yearPrice;@JsonKey(name: 'two_year_price') int? get twoYearPrice;@JsonKey(name: 'three_year_price') int? get threeYearPrice;@JsonKey(name: 'onetime_price') int? get onetimePrice;@JsonKey(name: 'reset_price') int? get resetPrice;
/// Create a copy of V2BoardPlan
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$V2BoardPlanCopyWith<V2BoardPlan> get copyWith => _$V2BoardPlanCopyWithImpl<V2BoardPlan>(this as V2BoardPlan, _$identity);

  /// Serializes this V2BoardPlan to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is V2BoardPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.content, content) || other.content == content)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.transferEnable, transferEnable) || other.transferEnable == transferEnable)&&(identical(other.monthPrice, monthPrice) || other.monthPrice == monthPrice)&&(identical(other.quarterPrice, quarterPrice) || other.quarterPrice == quarterPrice)&&(identical(other.halfYearPrice, halfYearPrice) || other.halfYearPrice == halfYearPrice)&&(identical(other.yearPrice, yearPrice) || other.yearPrice == yearPrice)&&(identical(other.twoYearPrice, twoYearPrice) || other.twoYearPrice == twoYearPrice)&&(identical(other.threeYearPrice, threeYearPrice) || other.threeYearPrice == threeYearPrice)&&(identical(other.onetimePrice, onetimePrice) || other.onetimePrice == onetimePrice)&&(identical(other.resetPrice, resetPrice) || other.resetPrice == resetPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,content,groupId,transferEnable,monthPrice,quarterPrice,halfYearPrice,yearPrice,twoYearPrice,threeYearPrice,onetimePrice,resetPrice);

@override
String toString() {
  return 'V2BoardPlan(id: $id, name: $name, content: $content, groupId: $groupId, transferEnable: $transferEnable, monthPrice: $monthPrice, quarterPrice: $quarterPrice, halfYearPrice: $halfYearPrice, yearPrice: $yearPrice, twoYearPrice: $twoYearPrice, threeYearPrice: $threeYearPrice, onetimePrice: $onetimePrice, resetPrice: $resetPrice)';
}


}

/// @nodoc
abstract mixin class $V2BoardPlanCopyWith<$Res>  {
  factory $V2BoardPlanCopyWith(V2BoardPlan value, $Res Function(V2BoardPlan) _then) = _$V2BoardPlanCopyWithImpl;
@useResult
$Res call({
 int id, String name, String? content,@JsonKey(name: 'group_id') int? groupId,@JsonKey(name: 'transfer_enable') int? transferEnable,@JsonKey(name: 'month_price') int? monthPrice,@JsonKey(name: 'quarter_price') int? quarterPrice,@JsonKey(name: 'half_year_price') int? halfYearPrice,@JsonKey(name: 'year_price') int? yearPrice,@JsonKey(name: 'two_year_price') int? twoYearPrice,@JsonKey(name: 'three_year_price') int? threeYearPrice,@JsonKey(name: 'onetime_price') int? onetimePrice,@JsonKey(name: 'reset_price') int? resetPrice
});




}
/// @nodoc
class _$V2BoardPlanCopyWithImpl<$Res>
    implements $V2BoardPlanCopyWith<$Res> {
  _$V2BoardPlanCopyWithImpl(this._self, this._then);

  final V2BoardPlan _self;
  final $Res Function(V2BoardPlan) _then;

/// Create a copy of V2BoardPlan
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? content = freezed,Object? groupId = freezed,Object? transferEnable = freezed,Object? monthPrice = freezed,Object? quarterPrice = freezed,Object? halfYearPrice = freezed,Object? yearPrice = freezed,Object? twoYearPrice = freezed,Object? threeYearPrice = freezed,Object? onetimePrice = freezed,Object? resetPrice = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as int?,transferEnable: freezed == transferEnable ? _self.transferEnable : transferEnable // ignore: cast_nullable_to_non_nullable
as int?,monthPrice: freezed == monthPrice ? _self.monthPrice : monthPrice // ignore: cast_nullable_to_non_nullable
as int?,quarterPrice: freezed == quarterPrice ? _self.quarterPrice : quarterPrice // ignore: cast_nullable_to_non_nullable
as int?,halfYearPrice: freezed == halfYearPrice ? _self.halfYearPrice : halfYearPrice // ignore: cast_nullable_to_non_nullable
as int?,yearPrice: freezed == yearPrice ? _self.yearPrice : yearPrice // ignore: cast_nullable_to_non_nullable
as int?,twoYearPrice: freezed == twoYearPrice ? _self.twoYearPrice : twoYearPrice // ignore: cast_nullable_to_non_nullable
as int?,threeYearPrice: freezed == threeYearPrice ? _self.threeYearPrice : threeYearPrice // ignore: cast_nullable_to_non_nullable
as int?,onetimePrice: freezed == onetimePrice ? _self.onetimePrice : onetimePrice // ignore: cast_nullable_to_non_nullable
as int?,resetPrice: freezed == resetPrice ? _self.resetPrice : resetPrice // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [V2BoardPlan].
extension V2BoardPlanPatterns on V2BoardPlan {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _V2BoardPlan value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _V2BoardPlan() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _V2BoardPlan value)  $default,){
final _that = this;
switch (_that) {
case _V2BoardPlan():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _V2BoardPlan value)?  $default,){
final _that = this;
switch (_that) {
case _V2BoardPlan() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String name,  String? content, @JsonKey(name: 'group_id')  int? groupId, @JsonKey(name: 'transfer_enable')  int? transferEnable, @JsonKey(name: 'month_price')  int? monthPrice, @JsonKey(name: 'quarter_price')  int? quarterPrice, @JsonKey(name: 'half_year_price')  int? halfYearPrice, @JsonKey(name: 'year_price')  int? yearPrice, @JsonKey(name: 'two_year_price')  int? twoYearPrice, @JsonKey(name: 'three_year_price')  int? threeYearPrice, @JsonKey(name: 'onetime_price')  int? onetimePrice, @JsonKey(name: 'reset_price')  int? resetPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _V2BoardPlan() when $default != null:
return $default(_that.id,_that.name,_that.content,_that.groupId,_that.transferEnable,_that.monthPrice,_that.quarterPrice,_that.halfYearPrice,_that.yearPrice,_that.twoYearPrice,_that.threeYearPrice,_that.onetimePrice,_that.resetPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String name,  String? content, @JsonKey(name: 'group_id')  int? groupId, @JsonKey(name: 'transfer_enable')  int? transferEnable, @JsonKey(name: 'month_price')  int? monthPrice, @JsonKey(name: 'quarter_price')  int? quarterPrice, @JsonKey(name: 'half_year_price')  int? halfYearPrice, @JsonKey(name: 'year_price')  int? yearPrice, @JsonKey(name: 'two_year_price')  int? twoYearPrice, @JsonKey(name: 'three_year_price')  int? threeYearPrice, @JsonKey(name: 'onetime_price')  int? onetimePrice, @JsonKey(name: 'reset_price')  int? resetPrice)  $default,) {final _that = this;
switch (_that) {
case _V2BoardPlan():
return $default(_that.id,_that.name,_that.content,_that.groupId,_that.transferEnable,_that.monthPrice,_that.quarterPrice,_that.halfYearPrice,_that.yearPrice,_that.twoYearPrice,_that.threeYearPrice,_that.onetimePrice,_that.resetPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String name,  String? content, @JsonKey(name: 'group_id')  int? groupId, @JsonKey(name: 'transfer_enable')  int? transferEnable, @JsonKey(name: 'month_price')  int? monthPrice, @JsonKey(name: 'quarter_price')  int? quarterPrice, @JsonKey(name: 'half_year_price')  int? halfYearPrice, @JsonKey(name: 'year_price')  int? yearPrice, @JsonKey(name: 'two_year_price')  int? twoYearPrice, @JsonKey(name: 'three_year_price')  int? threeYearPrice, @JsonKey(name: 'onetime_price')  int? onetimePrice, @JsonKey(name: 'reset_price')  int? resetPrice)?  $default,) {final _that = this;
switch (_that) {
case _V2BoardPlan() when $default != null:
return $default(_that.id,_that.name,_that.content,_that.groupId,_that.transferEnable,_that.monthPrice,_that.quarterPrice,_that.halfYearPrice,_that.yearPrice,_that.twoYearPrice,_that.threeYearPrice,_that.onetimePrice,_that.resetPrice);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _V2BoardPlan implements V2BoardPlan {
  const _V2BoardPlan({this.id = 0, this.name = '', this.content, @JsonKey(name: 'group_id') this.groupId, @JsonKey(name: 'transfer_enable') this.transferEnable, @JsonKey(name: 'month_price') this.monthPrice, @JsonKey(name: 'quarter_price') this.quarterPrice, @JsonKey(name: 'half_year_price') this.halfYearPrice, @JsonKey(name: 'year_price') this.yearPrice, @JsonKey(name: 'two_year_price') this.twoYearPrice, @JsonKey(name: 'three_year_price') this.threeYearPrice, @JsonKey(name: 'onetime_price') this.onetimePrice, @JsonKey(name: 'reset_price') this.resetPrice});
  factory _V2BoardPlan.fromJson(Map<String, dynamic> json) => _$V2BoardPlanFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String name;
@override final  String? content;
@override@JsonKey(name: 'group_id') final  int? groupId;
@override@JsonKey(name: 'transfer_enable') final  int? transferEnable;
@override@JsonKey(name: 'month_price') final  int? monthPrice;
@override@JsonKey(name: 'quarter_price') final  int? quarterPrice;
@override@JsonKey(name: 'half_year_price') final  int? halfYearPrice;
@override@JsonKey(name: 'year_price') final  int? yearPrice;
@override@JsonKey(name: 'two_year_price') final  int? twoYearPrice;
@override@JsonKey(name: 'three_year_price') final  int? threeYearPrice;
@override@JsonKey(name: 'onetime_price') final  int? onetimePrice;
@override@JsonKey(name: 'reset_price') final  int? resetPrice;

/// Create a copy of V2BoardPlan
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$V2BoardPlanCopyWith<_V2BoardPlan> get copyWith => __$V2BoardPlanCopyWithImpl<_V2BoardPlan>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$V2BoardPlanToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _V2BoardPlan&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.content, content) || other.content == content)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.transferEnable, transferEnable) || other.transferEnable == transferEnable)&&(identical(other.monthPrice, monthPrice) || other.monthPrice == monthPrice)&&(identical(other.quarterPrice, quarterPrice) || other.quarterPrice == quarterPrice)&&(identical(other.halfYearPrice, halfYearPrice) || other.halfYearPrice == halfYearPrice)&&(identical(other.yearPrice, yearPrice) || other.yearPrice == yearPrice)&&(identical(other.twoYearPrice, twoYearPrice) || other.twoYearPrice == twoYearPrice)&&(identical(other.threeYearPrice, threeYearPrice) || other.threeYearPrice == threeYearPrice)&&(identical(other.onetimePrice, onetimePrice) || other.onetimePrice == onetimePrice)&&(identical(other.resetPrice, resetPrice) || other.resetPrice == resetPrice));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,content,groupId,transferEnable,monthPrice,quarterPrice,halfYearPrice,yearPrice,twoYearPrice,threeYearPrice,onetimePrice,resetPrice);

@override
String toString() {
  return 'V2BoardPlan(id: $id, name: $name, content: $content, groupId: $groupId, transferEnable: $transferEnable, monthPrice: $monthPrice, quarterPrice: $quarterPrice, halfYearPrice: $halfYearPrice, yearPrice: $yearPrice, twoYearPrice: $twoYearPrice, threeYearPrice: $threeYearPrice, onetimePrice: $onetimePrice, resetPrice: $resetPrice)';
}


}

/// @nodoc
abstract mixin class _$V2BoardPlanCopyWith<$Res> implements $V2BoardPlanCopyWith<$Res> {
  factory _$V2BoardPlanCopyWith(_V2BoardPlan value, $Res Function(_V2BoardPlan) _then) = __$V2BoardPlanCopyWithImpl;
@override @useResult
$Res call({
 int id, String name, String? content,@JsonKey(name: 'group_id') int? groupId,@JsonKey(name: 'transfer_enable') int? transferEnable,@JsonKey(name: 'month_price') int? monthPrice,@JsonKey(name: 'quarter_price') int? quarterPrice,@JsonKey(name: 'half_year_price') int? halfYearPrice,@JsonKey(name: 'year_price') int? yearPrice,@JsonKey(name: 'two_year_price') int? twoYearPrice,@JsonKey(name: 'three_year_price') int? threeYearPrice,@JsonKey(name: 'onetime_price') int? onetimePrice,@JsonKey(name: 'reset_price') int? resetPrice
});




}
/// @nodoc
class __$V2BoardPlanCopyWithImpl<$Res>
    implements _$V2BoardPlanCopyWith<$Res> {
  __$V2BoardPlanCopyWithImpl(this._self, this._then);

  final _V2BoardPlan _self;
  final $Res Function(_V2BoardPlan) _then;

/// Create a copy of V2BoardPlan
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? content = freezed,Object? groupId = freezed,Object? transferEnable = freezed,Object? monthPrice = freezed,Object? quarterPrice = freezed,Object? halfYearPrice = freezed,Object? yearPrice = freezed,Object? twoYearPrice = freezed,Object? threeYearPrice = freezed,Object? onetimePrice = freezed,Object? resetPrice = freezed,}) {
  return _then(_V2BoardPlan(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,content: freezed == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String?,groupId: freezed == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as int?,transferEnable: freezed == transferEnable ? _self.transferEnable : transferEnable // ignore: cast_nullable_to_non_nullable
as int?,monthPrice: freezed == monthPrice ? _self.monthPrice : monthPrice // ignore: cast_nullable_to_non_nullable
as int?,quarterPrice: freezed == quarterPrice ? _self.quarterPrice : quarterPrice // ignore: cast_nullable_to_non_nullable
as int?,halfYearPrice: freezed == halfYearPrice ? _self.halfYearPrice : halfYearPrice // ignore: cast_nullable_to_non_nullable
as int?,yearPrice: freezed == yearPrice ? _self.yearPrice : yearPrice // ignore: cast_nullable_to_non_nullable
as int?,twoYearPrice: freezed == twoYearPrice ? _self.twoYearPrice : twoYearPrice // ignore: cast_nullable_to_non_nullable
as int?,threeYearPrice: freezed == threeYearPrice ? _self.threeYearPrice : threeYearPrice // ignore: cast_nullable_to_non_nullable
as int?,onetimePrice: freezed == onetimePrice ? _self.onetimePrice : onetimePrice // ignore: cast_nullable_to_non_nullable
as int?,resetPrice: freezed == resetPrice ? _self.resetPrice : resetPrice // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$V2BoardSubscription {

@JsonKey(name: 'plan_id') String get planId; String get token;@JsonKey(name: 'expired_at') int? get expiredAt;@JsonKey(name: 'u') int get upload;@JsonKey(name: 'd') int get download;@JsonKey(name: 'transfer_enable') int get transferEnable;@JsonKey(name: 'subscribe_url') String? get subscribeUrl;@JsonKey(name: 'reset_day') int? get resetDay;
/// Create a copy of V2BoardSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$V2BoardSubscriptionCopyWith<V2BoardSubscription> get copyWith => _$V2BoardSubscriptionCopyWithImpl<V2BoardSubscription>(this as V2BoardSubscription, _$identity);

  /// Serializes this V2BoardSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is V2BoardSubscription&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.token, token) || other.token == token)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.transferEnable, transferEnable) || other.transferEnable == transferEnable)&&(identical(other.subscribeUrl, subscribeUrl) || other.subscribeUrl == subscribeUrl)&&(identical(other.resetDay, resetDay) || other.resetDay == resetDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,planId,token,expiredAt,upload,download,transferEnable,subscribeUrl,resetDay);

@override
String toString() {
  return 'V2BoardSubscription(planId: $planId, token: $token, expiredAt: $expiredAt, upload: $upload, download: $download, transferEnable: $transferEnable, subscribeUrl: $subscribeUrl, resetDay: $resetDay)';
}


}

/// @nodoc
abstract mixin class $V2BoardSubscriptionCopyWith<$Res>  {
  factory $V2BoardSubscriptionCopyWith(V2BoardSubscription value, $Res Function(V2BoardSubscription) _then) = _$V2BoardSubscriptionCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'plan_id') String planId, String token,@JsonKey(name: 'expired_at') int? expiredAt,@JsonKey(name: 'u') int upload,@JsonKey(name: 'd') int download,@JsonKey(name: 'transfer_enable') int transferEnable,@JsonKey(name: 'subscribe_url') String? subscribeUrl,@JsonKey(name: 'reset_day') int? resetDay
});




}
/// @nodoc
class _$V2BoardSubscriptionCopyWithImpl<$Res>
    implements $V2BoardSubscriptionCopyWith<$Res> {
  _$V2BoardSubscriptionCopyWithImpl(this._self, this._then);

  final V2BoardSubscription _self;
  final $Res Function(V2BoardSubscription) _then;

/// Create a copy of V2BoardSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? planId = null,Object? token = null,Object? expiredAt = freezed,Object? upload = null,Object? download = null,Object? transferEnable = null,Object? subscribeUrl = freezed,Object? resetDay = freezed,}) {
  return _then(_self.copyWith(
planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as int?,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,transferEnable: null == transferEnable ? _self.transferEnable : transferEnable // ignore: cast_nullable_to_non_nullable
as int,subscribeUrl: freezed == subscribeUrl ? _self.subscribeUrl : subscribeUrl // ignore: cast_nullable_to_non_nullable
as String?,resetDay: freezed == resetDay ? _self.resetDay : resetDay // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [V2BoardSubscription].
extension V2BoardSubscriptionPatterns on V2BoardSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _V2BoardSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _V2BoardSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _V2BoardSubscription value)  $default,){
final _that = this;
switch (_that) {
case _V2BoardSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _V2BoardSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _V2BoardSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'plan_id')  String planId,  String token, @JsonKey(name: 'expired_at')  int? expiredAt, @JsonKey(name: 'u')  int upload, @JsonKey(name: 'd')  int download, @JsonKey(name: 'transfer_enable')  int transferEnable, @JsonKey(name: 'subscribe_url')  String? subscribeUrl, @JsonKey(name: 'reset_day')  int? resetDay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _V2BoardSubscription() when $default != null:
return $default(_that.planId,_that.token,_that.expiredAt,_that.upload,_that.download,_that.transferEnable,_that.subscribeUrl,_that.resetDay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'plan_id')  String planId,  String token, @JsonKey(name: 'expired_at')  int? expiredAt, @JsonKey(name: 'u')  int upload, @JsonKey(name: 'd')  int download, @JsonKey(name: 'transfer_enable')  int transferEnable, @JsonKey(name: 'subscribe_url')  String? subscribeUrl, @JsonKey(name: 'reset_day')  int? resetDay)  $default,) {final _that = this;
switch (_that) {
case _V2BoardSubscription():
return $default(_that.planId,_that.token,_that.expiredAt,_that.upload,_that.download,_that.transferEnable,_that.subscribeUrl,_that.resetDay);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'plan_id')  String planId,  String token, @JsonKey(name: 'expired_at')  int? expiredAt, @JsonKey(name: 'u')  int upload, @JsonKey(name: 'd')  int download, @JsonKey(name: 'transfer_enable')  int transferEnable, @JsonKey(name: 'subscribe_url')  String? subscribeUrl, @JsonKey(name: 'reset_day')  int? resetDay)?  $default,) {final _that = this;
switch (_that) {
case _V2BoardSubscription() when $default != null:
return $default(_that.planId,_that.token,_that.expiredAt,_that.upload,_that.download,_that.transferEnable,_that.subscribeUrl,_that.resetDay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _V2BoardSubscription implements V2BoardSubscription {
  const _V2BoardSubscription({@JsonKey(name: 'plan_id') this.planId = '', this.token = '', @JsonKey(name: 'expired_at') this.expiredAt, @JsonKey(name: 'u') this.upload = 0, @JsonKey(name: 'd') this.download = 0, @JsonKey(name: 'transfer_enable') this.transferEnable = 0, @JsonKey(name: 'subscribe_url') this.subscribeUrl, @JsonKey(name: 'reset_day') this.resetDay});
  factory _V2BoardSubscription.fromJson(Map<String, dynamic> json) => _$V2BoardSubscriptionFromJson(json);

@override@JsonKey(name: 'plan_id') final  String planId;
@override@JsonKey() final  String token;
@override@JsonKey(name: 'expired_at') final  int? expiredAt;
@override@JsonKey(name: 'u') final  int upload;
@override@JsonKey(name: 'd') final  int download;
@override@JsonKey(name: 'transfer_enable') final  int transferEnable;
@override@JsonKey(name: 'subscribe_url') final  String? subscribeUrl;
@override@JsonKey(name: 'reset_day') final  int? resetDay;

/// Create a copy of V2BoardSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$V2BoardSubscriptionCopyWith<_V2BoardSubscription> get copyWith => __$V2BoardSubscriptionCopyWithImpl<_V2BoardSubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$V2BoardSubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _V2BoardSubscription&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.token, token) || other.token == token)&&(identical(other.expiredAt, expiredAt) || other.expiredAt == expiredAt)&&(identical(other.upload, upload) || other.upload == upload)&&(identical(other.download, download) || other.download == download)&&(identical(other.transferEnable, transferEnable) || other.transferEnable == transferEnable)&&(identical(other.subscribeUrl, subscribeUrl) || other.subscribeUrl == subscribeUrl)&&(identical(other.resetDay, resetDay) || other.resetDay == resetDay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,planId,token,expiredAt,upload,download,transferEnable,subscribeUrl,resetDay);

@override
String toString() {
  return 'V2BoardSubscription(planId: $planId, token: $token, expiredAt: $expiredAt, upload: $upload, download: $download, transferEnable: $transferEnable, subscribeUrl: $subscribeUrl, resetDay: $resetDay)';
}


}

/// @nodoc
abstract mixin class _$V2BoardSubscriptionCopyWith<$Res> implements $V2BoardSubscriptionCopyWith<$Res> {
  factory _$V2BoardSubscriptionCopyWith(_V2BoardSubscription value, $Res Function(_V2BoardSubscription) _then) = __$V2BoardSubscriptionCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'plan_id') String planId, String token,@JsonKey(name: 'expired_at') int? expiredAt,@JsonKey(name: 'u') int upload,@JsonKey(name: 'd') int download,@JsonKey(name: 'transfer_enable') int transferEnable,@JsonKey(name: 'subscribe_url') String? subscribeUrl,@JsonKey(name: 'reset_day') int? resetDay
});




}
/// @nodoc
class __$V2BoardSubscriptionCopyWithImpl<$Res>
    implements _$V2BoardSubscriptionCopyWith<$Res> {
  __$V2BoardSubscriptionCopyWithImpl(this._self, this._then);

  final _V2BoardSubscription _self;
  final $Res Function(_V2BoardSubscription) _then;

/// Create a copy of V2BoardSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? planId = null,Object? token = null,Object? expiredAt = freezed,Object? upload = null,Object? download = null,Object? transferEnable = null,Object? subscribeUrl = freezed,Object? resetDay = freezed,}) {
  return _then(_V2BoardSubscription(
planId: null == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as String,token: null == token ? _self.token : token // ignore: cast_nullable_to_non_nullable
as String,expiredAt: freezed == expiredAt ? _self.expiredAt : expiredAt // ignore: cast_nullable_to_non_nullable
as int?,upload: null == upload ? _self.upload : upload // ignore: cast_nullable_to_non_nullable
as int,download: null == download ? _self.download : download // ignore: cast_nullable_to_non_nullable
as int,transferEnable: null == transferEnable ? _self.transferEnable : transferEnable // ignore: cast_nullable_to_non_nullable
as int,subscribeUrl: freezed == subscribeUrl ? _self.subscribeUrl : subscribeUrl // ignore: cast_nullable_to_non_nullable
as String?,resetDay: freezed == resetDay ? _self.resetDay : resetDay // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$V2BoardNotice {

 int get id; String get title; String get content;@JsonKey(name: 'created_at') int? get createdAt;@JsonKey(name: 'updated_at') int? get updatedAt;
/// Create a copy of V2BoardNotice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$V2BoardNoticeCopyWith<V2BoardNotice> get copyWith => _$V2BoardNoticeCopyWithImpl<V2BoardNotice>(this as V2BoardNotice, _$identity);

  /// Serializes this V2BoardNotice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is V2BoardNotice&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,content,createdAt,updatedAt);

@override
String toString() {
  return 'V2BoardNotice(id: $id, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $V2BoardNoticeCopyWith<$Res>  {
  factory $V2BoardNoticeCopyWith(V2BoardNotice value, $Res Function(V2BoardNotice) _then) = _$V2BoardNoticeCopyWithImpl;
@useResult
$Res call({
 int id, String title, String content,@JsonKey(name: 'created_at') int? createdAt,@JsonKey(name: 'updated_at') int? updatedAt
});




}
/// @nodoc
class _$V2BoardNoticeCopyWithImpl<$Res>
    implements $V2BoardNoticeCopyWith<$Res> {
  _$V2BoardNoticeCopyWithImpl(this._self, this._then);

  final V2BoardNotice _self;
  final $Res Function(V2BoardNotice) _then;

/// Create a copy of V2BoardNotice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? content = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [V2BoardNotice].
extension V2BoardNoticePatterns on V2BoardNotice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _V2BoardNotice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _V2BoardNotice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _V2BoardNotice value)  $default,){
final _that = this;
switch (_that) {
case _V2BoardNotice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _V2BoardNotice value)?  $default,){
final _that = this;
switch (_that) {
case _V2BoardNotice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String content, @JsonKey(name: 'created_at')  int? createdAt, @JsonKey(name: 'updated_at')  int? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _V2BoardNotice() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String content, @JsonKey(name: 'created_at')  int? createdAt, @JsonKey(name: 'updated_at')  int? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _V2BoardNotice():
return $default(_that.id,_that.title,_that.content,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String content, @JsonKey(name: 'created_at')  int? createdAt, @JsonKey(name: 'updated_at')  int? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _V2BoardNotice() when $default != null:
return $default(_that.id,_that.title,_that.content,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _V2BoardNotice implements V2BoardNotice {
  const _V2BoardNotice({this.id = 0, this.title = '', this.content = '', @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _V2BoardNotice.fromJson(Map<String, dynamic> json) => _$V2BoardNoticeFromJson(json);

@override@JsonKey() final  int id;
@override@JsonKey() final  String title;
@override@JsonKey() final  String content;
@override@JsonKey(name: 'created_at') final  int? createdAt;
@override@JsonKey(name: 'updated_at') final  int? updatedAt;

/// Create a copy of V2BoardNotice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$V2BoardNoticeCopyWith<_V2BoardNotice> get copyWith => __$V2BoardNoticeCopyWithImpl<_V2BoardNotice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$V2BoardNoticeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _V2BoardNotice&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.content, content) || other.content == content)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,content,createdAt,updatedAt);

@override
String toString() {
  return 'V2BoardNotice(id: $id, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$V2BoardNoticeCopyWith<$Res> implements $V2BoardNoticeCopyWith<$Res> {
  factory _$V2BoardNoticeCopyWith(_V2BoardNotice value, $Res Function(_V2BoardNotice) _then) = __$V2BoardNoticeCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String content,@JsonKey(name: 'created_at') int? createdAt,@JsonKey(name: 'updated_at') int? updatedAt
});




}
/// @nodoc
class __$V2BoardNoticeCopyWithImpl<$Res>
    implements _$V2BoardNoticeCopyWith<$Res> {
  __$V2BoardNoticeCopyWithImpl(this._self, this._then);

  final _V2BoardNotice _self;
  final $Res Function(_V2BoardNotice) _then;

/// Create a copy of V2BoardNotice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? content = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_V2BoardNotice(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$V2BoardCommConfig {

@JsonKey(name: 'tos_url') String? get tosUrl;@JsonKey(name: 'is_email_verify') bool get isEmailVerify;@JsonKey(name: 'is_invite_force') bool get isInviteForce;@JsonKey(name: 'email_whitelist_suffix') List<String>? get emailWhitelistSuffix;@JsonKey(name: 'is_recaptcha') bool get isRecaptcha;@JsonKey(name: 'recaptcha_site_key') String? get recaptchaSiteKey;@JsonKey(name: 'app_description') String? get appDescription;@JsonKey(name: 'app_url') String? get appUrl; String? get logo;
/// Create a copy of V2BoardCommConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$V2BoardCommConfigCopyWith<V2BoardCommConfig> get copyWith => _$V2BoardCommConfigCopyWithImpl<V2BoardCommConfig>(this as V2BoardCommConfig, _$identity);

  /// Serializes this V2BoardCommConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is V2BoardCommConfig&&(identical(other.tosUrl, tosUrl) || other.tosUrl == tosUrl)&&(identical(other.isEmailVerify, isEmailVerify) || other.isEmailVerify == isEmailVerify)&&(identical(other.isInviteForce, isInviteForce) || other.isInviteForce == isInviteForce)&&const DeepCollectionEquality().equals(other.emailWhitelistSuffix, emailWhitelistSuffix)&&(identical(other.isRecaptcha, isRecaptcha) || other.isRecaptcha == isRecaptcha)&&(identical(other.recaptchaSiteKey, recaptchaSiteKey) || other.recaptchaSiteKey == recaptchaSiteKey)&&(identical(other.appDescription, appDescription) || other.appDescription == appDescription)&&(identical(other.appUrl, appUrl) || other.appUrl == appUrl)&&(identical(other.logo, logo) || other.logo == logo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tosUrl,isEmailVerify,isInviteForce,const DeepCollectionEquality().hash(emailWhitelistSuffix),isRecaptcha,recaptchaSiteKey,appDescription,appUrl,logo);

@override
String toString() {
  return 'V2BoardCommConfig(tosUrl: $tosUrl, isEmailVerify: $isEmailVerify, isInviteForce: $isInviteForce, emailWhitelistSuffix: $emailWhitelistSuffix, isRecaptcha: $isRecaptcha, recaptchaSiteKey: $recaptchaSiteKey, appDescription: $appDescription, appUrl: $appUrl, logo: $logo)';
}


}

/// @nodoc
abstract mixin class $V2BoardCommConfigCopyWith<$Res>  {
  factory $V2BoardCommConfigCopyWith(V2BoardCommConfig value, $Res Function(V2BoardCommConfig) _then) = _$V2BoardCommConfigCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'tos_url') String? tosUrl,@JsonKey(name: 'is_email_verify') bool isEmailVerify,@JsonKey(name: 'is_invite_force') bool isInviteForce,@JsonKey(name: 'email_whitelist_suffix') List<String>? emailWhitelistSuffix,@JsonKey(name: 'is_recaptcha') bool isRecaptcha,@JsonKey(name: 'recaptcha_site_key') String? recaptchaSiteKey,@JsonKey(name: 'app_description') String? appDescription,@JsonKey(name: 'app_url') String? appUrl, String? logo
});




}
/// @nodoc
class _$V2BoardCommConfigCopyWithImpl<$Res>
    implements $V2BoardCommConfigCopyWith<$Res> {
  _$V2BoardCommConfigCopyWithImpl(this._self, this._then);

  final V2BoardCommConfig _self;
  final $Res Function(V2BoardCommConfig) _then;

/// Create a copy of V2BoardCommConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tosUrl = freezed,Object? isEmailVerify = null,Object? isInviteForce = null,Object? emailWhitelistSuffix = freezed,Object? isRecaptcha = null,Object? recaptchaSiteKey = freezed,Object? appDescription = freezed,Object? appUrl = freezed,Object? logo = freezed,}) {
  return _then(_self.copyWith(
tosUrl: freezed == tosUrl ? _self.tosUrl : tosUrl // ignore: cast_nullable_to_non_nullable
as String?,isEmailVerify: null == isEmailVerify ? _self.isEmailVerify : isEmailVerify // ignore: cast_nullable_to_non_nullable
as bool,isInviteForce: null == isInviteForce ? _self.isInviteForce : isInviteForce // ignore: cast_nullable_to_non_nullable
as bool,emailWhitelistSuffix: freezed == emailWhitelistSuffix ? _self.emailWhitelistSuffix : emailWhitelistSuffix // ignore: cast_nullable_to_non_nullable
as List<String>?,isRecaptcha: null == isRecaptcha ? _self.isRecaptcha : isRecaptcha // ignore: cast_nullable_to_non_nullable
as bool,recaptchaSiteKey: freezed == recaptchaSiteKey ? _self.recaptchaSiteKey : recaptchaSiteKey // ignore: cast_nullable_to_non_nullable
as String?,appDescription: freezed == appDescription ? _self.appDescription : appDescription // ignore: cast_nullable_to_non_nullable
as String?,appUrl: freezed == appUrl ? _self.appUrl : appUrl // ignore: cast_nullable_to_non_nullable
as String?,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [V2BoardCommConfig].
extension V2BoardCommConfigPatterns on V2BoardCommConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _V2BoardCommConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _V2BoardCommConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _V2BoardCommConfig value)  $default,){
final _that = this;
switch (_that) {
case _V2BoardCommConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _V2BoardCommConfig value)?  $default,){
final _that = this;
switch (_that) {
case _V2BoardCommConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'tos_url')  String? tosUrl, @JsonKey(name: 'is_email_verify')  bool isEmailVerify, @JsonKey(name: 'is_invite_force')  bool isInviteForce, @JsonKey(name: 'email_whitelist_suffix')  List<String>? emailWhitelistSuffix, @JsonKey(name: 'is_recaptcha')  bool isRecaptcha, @JsonKey(name: 'recaptcha_site_key')  String? recaptchaSiteKey, @JsonKey(name: 'app_description')  String? appDescription, @JsonKey(name: 'app_url')  String? appUrl,  String? logo)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _V2BoardCommConfig() when $default != null:
return $default(_that.tosUrl,_that.isEmailVerify,_that.isInviteForce,_that.emailWhitelistSuffix,_that.isRecaptcha,_that.recaptchaSiteKey,_that.appDescription,_that.appUrl,_that.logo);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'tos_url')  String? tosUrl, @JsonKey(name: 'is_email_verify')  bool isEmailVerify, @JsonKey(name: 'is_invite_force')  bool isInviteForce, @JsonKey(name: 'email_whitelist_suffix')  List<String>? emailWhitelistSuffix, @JsonKey(name: 'is_recaptcha')  bool isRecaptcha, @JsonKey(name: 'recaptcha_site_key')  String? recaptchaSiteKey, @JsonKey(name: 'app_description')  String? appDescription, @JsonKey(name: 'app_url')  String? appUrl,  String? logo)  $default,) {final _that = this;
switch (_that) {
case _V2BoardCommConfig():
return $default(_that.tosUrl,_that.isEmailVerify,_that.isInviteForce,_that.emailWhitelistSuffix,_that.isRecaptcha,_that.recaptchaSiteKey,_that.appDescription,_that.appUrl,_that.logo);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'tos_url')  String? tosUrl, @JsonKey(name: 'is_email_verify')  bool isEmailVerify, @JsonKey(name: 'is_invite_force')  bool isInviteForce, @JsonKey(name: 'email_whitelist_suffix')  List<String>? emailWhitelistSuffix, @JsonKey(name: 'is_recaptcha')  bool isRecaptcha, @JsonKey(name: 'recaptcha_site_key')  String? recaptchaSiteKey, @JsonKey(name: 'app_description')  String? appDescription, @JsonKey(name: 'app_url')  String? appUrl,  String? logo)?  $default,) {final _that = this;
switch (_that) {
case _V2BoardCommConfig() when $default != null:
return $default(_that.tosUrl,_that.isEmailVerify,_that.isInviteForce,_that.emailWhitelistSuffix,_that.isRecaptcha,_that.recaptchaSiteKey,_that.appDescription,_that.appUrl,_that.logo);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _V2BoardCommConfig implements V2BoardCommConfig {
  const _V2BoardCommConfig({@JsonKey(name: 'tos_url') this.tosUrl, @JsonKey(name: 'is_email_verify') this.isEmailVerify = false, @JsonKey(name: 'is_invite_force') this.isInviteForce = false, @JsonKey(name: 'email_whitelist_suffix') final  List<String>? emailWhitelistSuffix, @JsonKey(name: 'is_recaptcha') this.isRecaptcha = false, @JsonKey(name: 'recaptcha_site_key') this.recaptchaSiteKey, @JsonKey(name: 'app_description') this.appDescription, @JsonKey(name: 'app_url') this.appUrl, this.logo}): _emailWhitelistSuffix = emailWhitelistSuffix;
  factory _V2BoardCommConfig.fromJson(Map<String, dynamic> json) => _$V2BoardCommConfigFromJson(json);

@override@JsonKey(name: 'tos_url') final  String? tosUrl;
@override@JsonKey(name: 'is_email_verify') final  bool isEmailVerify;
@override@JsonKey(name: 'is_invite_force') final  bool isInviteForce;
 final  List<String>? _emailWhitelistSuffix;
@override@JsonKey(name: 'email_whitelist_suffix') List<String>? get emailWhitelistSuffix {
  final value = _emailWhitelistSuffix;
  if (value == null) return null;
  if (_emailWhitelistSuffix is EqualUnmodifiableListView) return _emailWhitelistSuffix;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'is_recaptcha') final  bool isRecaptcha;
@override@JsonKey(name: 'recaptcha_site_key') final  String? recaptchaSiteKey;
@override@JsonKey(name: 'app_description') final  String? appDescription;
@override@JsonKey(name: 'app_url') final  String? appUrl;
@override final  String? logo;

/// Create a copy of V2BoardCommConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$V2BoardCommConfigCopyWith<_V2BoardCommConfig> get copyWith => __$V2BoardCommConfigCopyWithImpl<_V2BoardCommConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$V2BoardCommConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _V2BoardCommConfig&&(identical(other.tosUrl, tosUrl) || other.tosUrl == tosUrl)&&(identical(other.isEmailVerify, isEmailVerify) || other.isEmailVerify == isEmailVerify)&&(identical(other.isInviteForce, isInviteForce) || other.isInviteForce == isInviteForce)&&const DeepCollectionEquality().equals(other._emailWhitelistSuffix, _emailWhitelistSuffix)&&(identical(other.isRecaptcha, isRecaptcha) || other.isRecaptcha == isRecaptcha)&&(identical(other.recaptchaSiteKey, recaptchaSiteKey) || other.recaptchaSiteKey == recaptchaSiteKey)&&(identical(other.appDescription, appDescription) || other.appDescription == appDescription)&&(identical(other.appUrl, appUrl) || other.appUrl == appUrl)&&(identical(other.logo, logo) || other.logo == logo));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tosUrl,isEmailVerify,isInviteForce,const DeepCollectionEquality().hash(_emailWhitelistSuffix),isRecaptcha,recaptchaSiteKey,appDescription,appUrl,logo);

@override
String toString() {
  return 'V2BoardCommConfig(tosUrl: $tosUrl, isEmailVerify: $isEmailVerify, isInviteForce: $isInviteForce, emailWhitelistSuffix: $emailWhitelistSuffix, isRecaptcha: $isRecaptcha, recaptchaSiteKey: $recaptchaSiteKey, appDescription: $appDescription, appUrl: $appUrl, logo: $logo)';
}


}

/// @nodoc
abstract mixin class _$V2BoardCommConfigCopyWith<$Res> implements $V2BoardCommConfigCopyWith<$Res> {
  factory _$V2BoardCommConfigCopyWith(_V2BoardCommConfig value, $Res Function(_V2BoardCommConfig) _then) = __$V2BoardCommConfigCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'tos_url') String? tosUrl,@JsonKey(name: 'is_email_verify') bool isEmailVerify,@JsonKey(name: 'is_invite_force') bool isInviteForce,@JsonKey(name: 'email_whitelist_suffix') List<String>? emailWhitelistSuffix,@JsonKey(name: 'is_recaptcha') bool isRecaptcha,@JsonKey(name: 'recaptcha_site_key') String? recaptchaSiteKey,@JsonKey(name: 'app_description') String? appDescription,@JsonKey(name: 'app_url') String? appUrl, String? logo
});




}
/// @nodoc
class __$V2BoardCommConfigCopyWithImpl<$Res>
    implements _$V2BoardCommConfigCopyWith<$Res> {
  __$V2BoardCommConfigCopyWithImpl(this._self, this._then);

  final _V2BoardCommConfig _self;
  final $Res Function(_V2BoardCommConfig) _then;

/// Create a copy of V2BoardCommConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tosUrl = freezed,Object? isEmailVerify = null,Object? isInviteForce = null,Object? emailWhitelistSuffix = freezed,Object? isRecaptcha = null,Object? recaptchaSiteKey = freezed,Object? appDescription = freezed,Object? appUrl = freezed,Object? logo = freezed,}) {
  return _then(_V2BoardCommConfig(
tosUrl: freezed == tosUrl ? _self.tosUrl : tosUrl // ignore: cast_nullable_to_non_nullable
as String?,isEmailVerify: null == isEmailVerify ? _self.isEmailVerify : isEmailVerify // ignore: cast_nullable_to_non_nullable
as bool,isInviteForce: null == isInviteForce ? _self.isInviteForce : isInviteForce // ignore: cast_nullable_to_non_nullable
as bool,emailWhitelistSuffix: freezed == emailWhitelistSuffix ? _self._emailWhitelistSuffix : emailWhitelistSuffix // ignore: cast_nullable_to_non_nullable
as List<String>?,isRecaptcha: null == isRecaptcha ? _self.isRecaptcha : isRecaptcha // ignore: cast_nullable_to_non_nullable
as bool,recaptchaSiteKey: freezed == recaptchaSiteKey ? _self.recaptchaSiteKey : recaptchaSiteKey // ignore: cast_nullable_to_non_nullable
as String?,appDescription: freezed == appDescription ? _self.appDescription : appDescription // ignore: cast_nullable_to_non_nullable
as String?,appUrl: freezed == appUrl ? _self.appUrl : appUrl // ignore: cast_nullable_to_non_nullable
as String?,logo: freezed == logo ? _self.logo : logo // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$V2BoardOrder {

@JsonKey(name: 'trade_no') String get tradeNo; int get type; int get status;@JsonKey(name: 'total_amount') int get totalAmount;@JsonKey(name: 'plan_id') int? get planId;@JsonKey(name: 'created_at') int? get createdAt;
/// Create a copy of V2BoardOrder
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$V2BoardOrderCopyWith<V2BoardOrder> get copyWith => _$V2BoardOrderCopyWithImpl<V2BoardOrder>(this as V2BoardOrder, _$identity);

  /// Serializes this V2BoardOrder to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is V2BoardOrder&&(identical(other.tradeNo, tradeNo) || other.tradeNo == tradeNo)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tradeNo,type,status,totalAmount,planId,createdAt);

@override
String toString() {
  return 'V2BoardOrder(tradeNo: $tradeNo, type: $type, status: $status, totalAmount: $totalAmount, planId: $planId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $V2BoardOrderCopyWith<$Res>  {
  factory $V2BoardOrderCopyWith(V2BoardOrder value, $Res Function(V2BoardOrder) _then) = _$V2BoardOrderCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'trade_no') String tradeNo, int type, int status,@JsonKey(name: 'total_amount') int totalAmount,@JsonKey(name: 'plan_id') int? planId,@JsonKey(name: 'created_at') int? createdAt
});




}
/// @nodoc
class _$V2BoardOrderCopyWithImpl<$Res>
    implements $V2BoardOrderCopyWith<$Res> {
  _$V2BoardOrderCopyWithImpl(this._self, this._then);

  final V2BoardOrder _self;
  final $Res Function(V2BoardOrder) _then;

/// Create a copy of V2BoardOrder
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? tradeNo = null,Object? type = null,Object? status = null,Object? totalAmount = null,Object? planId = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
tradeNo: null == tradeNo ? _self.tradeNo : tradeNo // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [V2BoardOrder].
extension V2BoardOrderPatterns on V2BoardOrder {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _V2BoardOrder value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _V2BoardOrder() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _V2BoardOrder value)  $default,){
final _that = this;
switch (_that) {
case _V2BoardOrder():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _V2BoardOrder value)?  $default,){
final _that = this;
switch (_that) {
case _V2BoardOrder() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'trade_no')  String tradeNo,  int type,  int status, @JsonKey(name: 'total_amount')  int totalAmount, @JsonKey(name: 'plan_id')  int? planId, @JsonKey(name: 'created_at')  int? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _V2BoardOrder() when $default != null:
return $default(_that.tradeNo,_that.type,_that.status,_that.totalAmount,_that.planId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'trade_no')  String tradeNo,  int type,  int status, @JsonKey(name: 'total_amount')  int totalAmount, @JsonKey(name: 'plan_id')  int? planId, @JsonKey(name: 'created_at')  int? createdAt)  $default,) {final _that = this;
switch (_that) {
case _V2BoardOrder():
return $default(_that.tradeNo,_that.type,_that.status,_that.totalAmount,_that.planId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'trade_no')  String tradeNo,  int type,  int status, @JsonKey(name: 'total_amount')  int totalAmount, @JsonKey(name: 'plan_id')  int? planId, @JsonKey(name: 'created_at')  int? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _V2BoardOrder() when $default != null:
return $default(_that.tradeNo,_that.type,_that.status,_that.totalAmount,_that.planId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _V2BoardOrder implements V2BoardOrder {
  const _V2BoardOrder({@JsonKey(name: 'trade_no') this.tradeNo = '', this.type = 0, this.status = 0, @JsonKey(name: 'total_amount') this.totalAmount = 0, @JsonKey(name: 'plan_id') this.planId, @JsonKey(name: 'created_at') this.createdAt});
  factory _V2BoardOrder.fromJson(Map<String, dynamic> json) => _$V2BoardOrderFromJson(json);

@override@JsonKey(name: 'trade_no') final  String tradeNo;
@override@JsonKey() final  int type;
@override@JsonKey() final  int status;
@override@JsonKey(name: 'total_amount') final  int totalAmount;
@override@JsonKey(name: 'plan_id') final  int? planId;
@override@JsonKey(name: 'created_at') final  int? createdAt;

/// Create a copy of V2BoardOrder
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$V2BoardOrderCopyWith<_V2BoardOrder> get copyWith => __$V2BoardOrderCopyWithImpl<_V2BoardOrder>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$V2BoardOrderToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _V2BoardOrder&&(identical(other.tradeNo, tradeNo) || other.tradeNo == tradeNo)&&(identical(other.type, type) || other.type == type)&&(identical(other.status, status) || other.status == status)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.planId, planId) || other.planId == planId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,tradeNo,type,status,totalAmount,planId,createdAt);

@override
String toString() {
  return 'V2BoardOrder(tradeNo: $tradeNo, type: $type, status: $status, totalAmount: $totalAmount, planId: $planId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$V2BoardOrderCopyWith<$Res> implements $V2BoardOrderCopyWith<$Res> {
  factory _$V2BoardOrderCopyWith(_V2BoardOrder value, $Res Function(_V2BoardOrder) _then) = __$V2BoardOrderCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'trade_no') String tradeNo, int type, int status,@JsonKey(name: 'total_amount') int totalAmount,@JsonKey(name: 'plan_id') int? planId,@JsonKey(name: 'created_at') int? createdAt
});




}
/// @nodoc
class __$V2BoardOrderCopyWithImpl<$Res>
    implements _$V2BoardOrderCopyWith<$Res> {
  __$V2BoardOrderCopyWithImpl(this._self, this._then);

  final _V2BoardOrder _self;
  final $Res Function(_V2BoardOrder) _then;

/// Create a copy of V2BoardOrder
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? tradeNo = null,Object? type = null,Object? status = null,Object? totalAmount = null,Object? planId = freezed,Object? createdAt = freezed,}) {
  return _then(_V2BoardOrder(
tradeNo: null == tradeNo ? _self.tradeNo : tradeNo // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as int,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as int,planId: freezed == planId ? _self.planId : planId // ignore: cast_nullable_to_non_nullable
as int?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}


/// @nodoc
mixin _$V2BoardProps {

 String get serverUrl; String get authData; String get subscribeToken; String get email; DateTime? get lastLoginDate; bool get autoSync;
/// Create a copy of V2BoardProps
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$V2BoardPropsCopyWith<V2BoardProps> get copyWith => _$V2BoardPropsCopyWithImpl<V2BoardProps>(this as V2BoardProps, _$identity);

  /// Serializes this V2BoardProps to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is V2BoardProps&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.authData, authData) || other.authData == authData)&&(identical(other.subscribeToken, subscribeToken) || other.subscribeToken == subscribeToken)&&(identical(other.email, email) || other.email == email)&&(identical(other.lastLoginDate, lastLoginDate) || other.lastLoginDate == lastLoginDate)&&(identical(other.autoSync, autoSync) || other.autoSync == autoSync));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serverUrl,authData,subscribeToken,email,lastLoginDate,autoSync);

@override
String toString() {
  return 'V2BoardProps(serverUrl: $serverUrl, authData: $authData, subscribeToken: $subscribeToken, email: $email, lastLoginDate: $lastLoginDate, autoSync: $autoSync)';
}


}

/// @nodoc
abstract mixin class $V2BoardPropsCopyWith<$Res>  {
  factory $V2BoardPropsCopyWith(V2BoardProps value, $Res Function(V2BoardProps) _then) = _$V2BoardPropsCopyWithImpl;
@useResult
$Res call({
 String serverUrl, String authData, String subscribeToken, String email, DateTime? lastLoginDate, bool autoSync
});




}
/// @nodoc
class _$V2BoardPropsCopyWithImpl<$Res>
    implements $V2BoardPropsCopyWith<$Res> {
  _$V2BoardPropsCopyWithImpl(this._self, this._then);

  final V2BoardProps _self;
  final $Res Function(V2BoardProps) _then;

/// Create a copy of V2BoardProps
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? serverUrl = null,Object? authData = null,Object? subscribeToken = null,Object? email = null,Object? lastLoginDate = freezed,Object? autoSync = null,}) {
  return _then(_self.copyWith(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,authData: null == authData ? _self.authData : authData // ignore: cast_nullable_to_non_nullable
as String,subscribeToken: null == subscribeToken ? _self.subscribeToken : subscribeToken // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,lastLoginDate: freezed == lastLoginDate ? _self.lastLoginDate : lastLoginDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoSync: null == autoSync ? _self.autoSync : autoSync // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [V2BoardProps].
extension V2BoardPropsPatterns on V2BoardProps {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _V2BoardProps value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _V2BoardProps() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _V2BoardProps value)  $default,){
final _that = this;
switch (_that) {
case _V2BoardProps():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _V2BoardProps value)?  $default,){
final _that = this;
switch (_that) {
case _V2BoardProps() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String serverUrl,  String authData,  String subscribeToken,  String email,  DateTime? lastLoginDate,  bool autoSync)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _V2BoardProps() when $default != null:
return $default(_that.serverUrl,_that.authData,_that.subscribeToken,_that.email,_that.lastLoginDate,_that.autoSync);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String serverUrl,  String authData,  String subscribeToken,  String email,  DateTime? lastLoginDate,  bool autoSync)  $default,) {final _that = this;
switch (_that) {
case _V2BoardProps():
return $default(_that.serverUrl,_that.authData,_that.subscribeToken,_that.email,_that.lastLoginDate,_that.autoSync);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String serverUrl,  String authData,  String subscribeToken,  String email,  DateTime? lastLoginDate,  bool autoSync)?  $default,) {final _that = this;
switch (_that) {
case _V2BoardProps() when $default != null:
return $default(_that.serverUrl,_that.authData,_that.subscribeToken,_that.email,_that.lastLoginDate,_that.autoSync);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _V2BoardProps implements V2BoardProps {
  const _V2BoardProps({this.serverUrl = '', this.authData = '', this.subscribeToken = '', this.email = '', this.lastLoginDate, this.autoSync = true});
  factory _V2BoardProps.fromJson(Map<String, dynamic> json) => _$V2BoardPropsFromJson(json);

@override@JsonKey() final  String serverUrl;
@override@JsonKey() final  String authData;
@override@JsonKey() final  String subscribeToken;
@override@JsonKey() final  String email;
@override final  DateTime? lastLoginDate;
@override@JsonKey() final  bool autoSync;

/// Create a copy of V2BoardProps
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$V2BoardPropsCopyWith<_V2BoardProps> get copyWith => __$V2BoardPropsCopyWithImpl<_V2BoardProps>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$V2BoardPropsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _V2BoardProps&&(identical(other.serverUrl, serverUrl) || other.serverUrl == serverUrl)&&(identical(other.authData, authData) || other.authData == authData)&&(identical(other.subscribeToken, subscribeToken) || other.subscribeToken == subscribeToken)&&(identical(other.email, email) || other.email == email)&&(identical(other.lastLoginDate, lastLoginDate) || other.lastLoginDate == lastLoginDate)&&(identical(other.autoSync, autoSync) || other.autoSync == autoSync));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,serverUrl,authData,subscribeToken,email,lastLoginDate,autoSync);

@override
String toString() {
  return 'V2BoardProps(serverUrl: $serverUrl, authData: $authData, subscribeToken: $subscribeToken, email: $email, lastLoginDate: $lastLoginDate, autoSync: $autoSync)';
}


}

/// @nodoc
abstract mixin class _$V2BoardPropsCopyWith<$Res> implements $V2BoardPropsCopyWith<$Res> {
  factory _$V2BoardPropsCopyWith(_V2BoardProps value, $Res Function(_V2BoardProps) _then) = __$V2BoardPropsCopyWithImpl;
@override @useResult
$Res call({
 String serverUrl, String authData, String subscribeToken, String email, DateTime? lastLoginDate, bool autoSync
});




}
/// @nodoc
class __$V2BoardPropsCopyWithImpl<$Res>
    implements _$V2BoardPropsCopyWith<$Res> {
  __$V2BoardPropsCopyWithImpl(this._self, this._then);

  final _V2BoardProps _self;
  final $Res Function(_V2BoardProps) _then;

/// Create a copy of V2BoardProps
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? serverUrl = null,Object? authData = null,Object? subscribeToken = null,Object? email = null,Object? lastLoginDate = freezed,Object? autoSync = null,}) {
  return _then(_V2BoardProps(
serverUrl: null == serverUrl ? _self.serverUrl : serverUrl // ignore: cast_nullable_to_non_nullable
as String,authData: null == authData ? _self.authData : authData // ignore: cast_nullable_to_non_nullable
as String,subscribeToken: null == subscribeToken ? _self.subscribeToken : subscribeToken // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,lastLoginDate: freezed == lastLoginDate ? _self.lastLoginDate : lastLoginDate // ignore: cast_nullable_to_non_nullable
as DateTime?,autoSync: null == autoSync ? _self.autoSync : autoSync // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

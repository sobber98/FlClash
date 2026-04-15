import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/v2board_models.freezed.dart';
part 'generated/v2board_models.g.dart';

/// Login/Register response
@freezed
abstract class V2BoardAuth with _$V2BoardAuth {
  const factory V2BoardAuth({
    @Default('') String token,
    @Default(false) @JsonKey(name: 'is_admin') bool isAdmin,
    @Default('') @JsonKey(name: 'auth_data') String authData,
  }) = _V2BoardAuth;

  factory V2BoardAuth.fromJson(Map<String, Object?> json) =>
      _$V2BoardAuthFromJson(json);
}

/// GET /user/info
@freezed
abstract class V2BoardUser with _$V2BoardUser {
  const factory V2BoardUser({
    @Default(0) int id,
    @Default('') String email,
    @Default(0) @JsonKey(name: 'transfer_enable') int transferEnable,
    @JsonKey(name: 'plan_id') int? planId,
    @Default(0) @JsonKey(name: 'u') int upload,
    @Default(0) @JsonKey(name: 'd') int download,
    @JsonKey(name: 'expired_at') int? expiredAt,
    @Default('') String uuid,
    @Default(0) int balance,
    @Default(0) @JsonKey(name: 'commission_balance') int commissionBalance,
    @JsonKey(name: 'created_at') int? createdAt,
    @JsonKey(name: 'updated_at') int? updatedAt,
    @Default(false) @JsonKey(name: 'remind_expire') bool remindExpire,
    @Default(false) @JsonKey(name: 'remind_traffic') bool remindTraffic,
  }) = _V2BoardUser;

  factory V2BoardUser.fromJson(Map<String, Object?> json) =>
      _$V2BoardUserFromJson(json);
}

/// GET /user/plan/fetch item
@freezed
abstract class V2BoardPlan with _$V2BoardPlan {
  const factory V2BoardPlan({
    @Default(0) int id,
    @Default('') String name,
    String? content,
    @JsonKey(name: 'group_id') int? groupId,
    @JsonKey(name: 'transfer_enable') int? transferEnable,
    @JsonKey(name: 'month_price') int? monthPrice,
    @JsonKey(name: 'quarter_price') int? quarterPrice,
    @JsonKey(name: 'half_year_price') int? halfYearPrice,
    @JsonKey(name: 'year_price') int? yearPrice,
    @JsonKey(name: 'two_year_price') int? twoYearPrice,
    @JsonKey(name: 'three_year_price') int? threeYearPrice,
    @JsonKey(name: 'onetime_price') int? onetimePrice,
    @JsonKey(name: 'reset_price') int? resetPrice,
  }) = _V2BoardPlan;

  factory V2BoardPlan.fromJson(Map<String, Object?> json) =>
      _$V2BoardPlanFromJson(json);
}

/// GET /user/getSubscribe
@freezed
abstract class V2BoardSubscription with _$V2BoardSubscription {
  const factory V2BoardSubscription({
    @Default('') @JsonKey(name: 'plan_id') String planId,
    @Default('') String token,
    @JsonKey(name: 'expired_at') int? expiredAt,
    @Default(0) @JsonKey(name: 'u') int upload,
    @Default(0) @JsonKey(name: 'd') int download,
    @Default(0) @JsonKey(name: 'transfer_enable') int transferEnable,
    @JsonKey(name: 'subscribe_url') String? subscribeUrl,
    @JsonKey(name: 'reset_day') int? resetDay,
  }) = _V2BoardSubscription;

  factory V2BoardSubscription.fromJson(Map<String, Object?> json) =>
      _$V2BoardSubscriptionFromJson(json);
}

/// GET /user/notice/fetch item
@freezed
abstract class V2BoardNotice with _$V2BoardNotice {
  const factory V2BoardNotice({
    @Default(0) int id,
    @Default('') String title,
    @Default('') String content,
    @JsonKey(name: 'created_at') int? createdAt,
    @JsonKey(name: 'updated_at') int? updatedAt,
  }) = _V2BoardNotice;

  factory V2BoardNotice.fromJson(Map<String, Object?> json) =>
      _$V2BoardNoticeFromJson(json);
}

/// GET /guest/comm/config
@freezed
abstract class V2BoardCommConfig with _$V2BoardCommConfig {
  const factory V2BoardCommConfig({
    @JsonKey(name: 'tos_url') String? tosUrl,
    @Default(false) @JsonKey(name: 'is_email_verify') bool isEmailVerify,
    @Default(false) @JsonKey(name: 'is_invite_force') bool isInviteForce,
    @JsonKey(name: 'email_whitelist_suffix') List<String>?
        emailWhitelistSuffix,
    @Default(false) @JsonKey(name: 'is_recaptcha') bool isRecaptcha,
    @JsonKey(name: 'recaptcha_site_key') String? recaptchaSiteKey,
    @JsonKey(name: 'app_description') String? appDescription,
    @JsonKey(name: 'app_url') String? appUrl,
    String? logo,
  }) = _V2BoardCommConfig;

  factory V2BoardCommConfig.fromJson(Map<String, Object?> json) =>
      _$V2BoardCommConfigFromJson(json);
}

/// GET /user/order/fetch item
@freezed
abstract class V2BoardOrder with _$V2BoardOrder {
  const factory V2BoardOrder({
    @Default('') @JsonKey(name: 'trade_no') String tradeNo,
    @Default(0) int type,
    @Default(0) int status,
    @Default(0) @JsonKey(name: 'total_amount') int totalAmount,
    @JsonKey(name: 'plan_id') int? planId,
    @JsonKey(name: 'created_at') int? createdAt,
  }) = _V2BoardOrder;

  factory V2BoardOrder.fromJson(Map<String, Object?> json) =>
      _$V2BoardOrderFromJson(json);
}

/// V2Board connection props (persisted in Config)
@freezed
abstract class V2BoardProps with _$V2BoardProps {
  const factory V2BoardProps({
    @Default('') String serverUrl,
    @Default('') String authData,
    @Default('') String subscribeToken,
    @Default('') String email,
    DateTime? lastLoginDate,
    @Default(true) bool autoSync,
  }) = _V2BoardProps;

  factory V2BoardProps.fromJson(Map<String, Object?> json) =>
      _$V2BoardPropsFromJson(json);
}

extension V2BoardPropsExt on V2BoardProps {
  bool get isLoggedIn => authData.isNotEmpty && serverUrl.isNotEmpty;

  String get subscribeUrl {
    if (!isLoggedIn || subscribeToken.isEmpty) return '';
    return '$serverUrl/client/subscribe?token=$subscribeToken';
  }
}

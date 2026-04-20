import 'package:freezed_annotation/freezed_annotation.dart';

part 'generated/v2board_models.freezed.dart';
part 'generated/v2board_models.g.dart';

bool v2boardBoolFromJson(Object? value) {
  if (value is bool) return value;
  if (value is num) return value != 0;
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty) return false;
    if (normalized == 'true') return true;
    if (normalized == 'false') return false;
    final numericValue = num.tryParse(normalized);
    if (numericValue != null) return numericValue != 0;
  }
  return false;
}

Object? v2boardBoolToJson(bool value) => value;

String v2boardStringFromJson(Object? value) {
  if (value == null) return '';
  if (value is String) return value;
  return value.toString();
}

Object? v2boardStringToJson(String value) => value;

/// Login/Register response
@freezed
abstract class V2BoardAuth with _$V2BoardAuth {
  const factory V2BoardAuth({
    @Default('') String token,
    @Default(false)
    @JsonKey(
      name: 'is_admin',
      fromJson: v2boardBoolFromJson,
      toJson: v2boardBoolToJson,
    )
    bool isAdmin,
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
    @Default(false)
    @JsonKey(
      name: 'remind_expire',
      fromJson: v2boardBoolFromJson,
      toJson: v2boardBoolToJson,
    )
    bool remindExpire,
    @Default(false)
    @JsonKey(
      name: 'remind_traffic',
      fromJson: v2boardBoolFromJson,
      toJson: v2boardBoolToJson,
    )
    bool remindTraffic,
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
    @Default('')
    @JsonKey(
      name: 'plan_id',
      fromJson: v2boardStringFromJson,
      toJson: v2boardStringToJson,
    )
    String planId,
    @Default('') String token,
    @JsonKey(name: 'expired_at') int? expiredAt,
    @Default(0) @JsonKey(name: 'u') int upload,
    @Default(0) @JsonKey(name: 'd') int download,
    @Default(0) @JsonKey(name: 'transfer_enable') int transferEnable,
    @JsonKey(name: 'plan') V2BoardPlan? plan,
    @JsonKey(name: 'subscribe_url') String? subscribeUrl,
    @JsonKey(name: 'reset_day') int? resetDay,
  }) = _V2BoardSubscription;

  factory V2BoardSubscription.fromJson(Map<String, Object?> json) =>
      _$V2BoardSubscriptionFromJson(json);
}

bool v2boardHasSubscriptionSnapshot(V2BoardSubscription? subscription) {
  if (subscription == null) return false;
  return subscription.transferEnable > 0 ||
      subscription.upload > 0 ||
      subscription.download > 0 ||
      (subscription.expiredAt ?? 0) > 0 ||
      (subscription.resetDay ?? 0) > 0 ||
      subscription.planId.isNotEmpty ||
      subscription.token.isNotEmpty ||
      (subscription.subscribeUrl?.isNotEmpty ?? false);
}

int v2boardResolvedUpload(
  V2BoardUser? user,
  V2BoardSubscription? subscription,
) {
  if (v2boardHasSubscriptionSnapshot(subscription)) {
    return subscription!.upload;
  }
  return user?.upload ?? 0;
}

int v2boardResolvedDownload(
  V2BoardUser? user,
  V2BoardSubscription? subscription,
) {
  if (v2boardHasSubscriptionSnapshot(subscription)) {
    return subscription!.download;
  }
  return user?.download ?? 0;
}

int v2boardResolvedUsedTraffic(
  V2BoardUser? user,
  V2BoardSubscription? subscription,
) {
  return v2boardResolvedUpload(user, subscription) +
      v2boardResolvedDownload(user, subscription);
}

int v2boardResolvedTotalTraffic(
  V2BoardUser? user,
  V2BoardSubscription? subscription,
) {
  if (v2boardHasSubscriptionSnapshot(subscription)) {
    return subscription!.transferEnable;
  }
  return user?.transferEnable ?? 0;
}

int v2boardResolvedRemainingTraffic(
  V2BoardUser? user,
  V2BoardSubscription? subscription,
) {
  final remaining =
      v2boardResolvedTotalTraffic(user, subscription) -
      v2boardResolvedUsedTraffic(user, subscription);
  return remaining < 0 ? 0 : remaining;
}

int? v2boardResolvedExpiredAt(
  V2BoardUser? user,
  V2BoardSubscription? subscription,
) {
  final subscriptionExpiredAt = subscription?.expiredAt;
  if (subscriptionExpiredAt != null) {
    return subscriptionExpiredAt;
  }
  return user?.expiredAt;
}

V2BoardPlan? v2boardResolvedPlan({
  V2BoardUser? user,
  V2BoardSubscription? subscription,
  Iterable<V2BoardPlan> plans = const [],
}) {
  final embeddedPlan = subscription?.plan;
  if ((embeddedPlan?.name.trim().isNotEmpty ?? false)) {
    return embeddedPlan;
  }

  final planId = user?.planId ?? int.tryParse(subscription?.planId ?? '');
  if (planId == null) {
    return null;
  }

  for (final plan in plans) {
    if (plan.id == planId) {
      return plan;
    }
  }

  return null;
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
    @Default(false)
    @JsonKey(
      name: 'is_email_verify',
      fromJson: v2boardBoolFromJson,
      toJson: v2boardBoolToJson,
    )
    bool isEmailVerify,
    @Default(false)
    @JsonKey(
      name: 'is_invite_force',
      fromJson: v2boardBoolFromJson,
      toJson: v2boardBoolToJson,
    )
    bool isInviteForce,
    @JsonKey(name: 'email_whitelist_suffix') List<String>? emailWhitelistSuffix,
    @Default(false)
    @JsonKey(
      name: 'is_recaptcha',
      fromJson: v2boardBoolFromJson,
      toJson: v2boardBoolToJson,
    )
    bool isRecaptcha,
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
    @Default(true)
    @JsonKey(fromJson: v2boardBoolFromJson, toJson: v2boardBoolToJson)
    bool autoSync,
  }) = _V2BoardProps;

  factory V2BoardProps.fromJson(Map<String, Object?> json) =>
      _$V2BoardPropsFromJson(json);
}

extension V2BoardPropsExt on V2BoardProps {
  bool get isLoggedIn =>
      authData.isNotEmpty &&
      (serverUrl.isNotEmpty || subscribeToken.isNotEmpty);

  String get subscribeUrl {
    if (!isLoggedIn || subscribeToken.isEmpty) return '';
    final normalizedServerUrl = serverUrl.trim().replaceFirst(RegExp(r'/+$'), '');
    if (normalizedServerUrl.endsWith('/api/v1')) {
      return '$normalizedServerUrl/client/subscribe?token=$subscribeToken';
    }
    return '$normalizedServerUrl/api/v1/client/subscribe?token=$subscribeToken';
  }
}

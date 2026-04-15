// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../v2board_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_V2BoardAuth _$V2BoardAuthFromJson(Map<String, dynamic> json) => _V2BoardAuth(
  token: json['token'] as String? ?? '',
  isAdmin: json['is_admin'] == null
      ? false
      : v2boardBoolFromJson(json['is_admin']),
  authData: json['auth_data'] as String? ?? '',
);

Map<String, dynamic> _$V2BoardAuthToJson(_V2BoardAuth instance) =>
    <String, dynamic>{
      'token': instance.token,
      'is_admin': v2boardBoolToJson(instance.isAdmin),
      'auth_data': instance.authData,
    };

_V2BoardUser _$V2BoardUserFromJson(Map<String, dynamic> json) => _V2BoardUser(
  id: (json['id'] as num?)?.toInt() ?? 0,
  email: json['email'] as String? ?? '',
  transferEnable: (json['transfer_enable'] as num?)?.toInt() ?? 0,
  planId: (json['plan_id'] as num?)?.toInt(),
  upload: (json['u'] as num?)?.toInt() ?? 0,
  download: (json['d'] as num?)?.toInt() ?? 0,
  expiredAt: (json['expired_at'] as num?)?.toInt(),
  uuid: json['uuid'] as String? ?? '',
  balance: (json['balance'] as num?)?.toInt() ?? 0,
  commissionBalance: (json['commission_balance'] as num?)?.toInt() ?? 0,
  createdAt: (json['created_at'] as num?)?.toInt(),
  updatedAt: (json['updated_at'] as num?)?.toInt(),
  remindExpire: json['remind_expire'] == null
      ? false
      : v2boardBoolFromJson(json['remind_expire']),
  remindTraffic: json['remind_traffic'] == null
      ? false
      : v2boardBoolFromJson(json['remind_traffic']),
);

Map<String, dynamic> _$V2BoardUserToJson(_V2BoardUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'transfer_enable': instance.transferEnable,
      'plan_id': instance.planId,
      'u': instance.upload,
      'd': instance.download,
      'expired_at': instance.expiredAt,
      'uuid': instance.uuid,
      'balance': instance.balance,
      'commission_balance': instance.commissionBalance,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'remind_expire': v2boardBoolToJson(instance.remindExpire),
      'remind_traffic': v2boardBoolToJson(instance.remindTraffic),
    };

_V2BoardPlan _$V2BoardPlanFromJson(Map<String, dynamic> json) => _V2BoardPlan(
  id: (json['id'] as num?)?.toInt() ?? 0,
  name: json['name'] as String? ?? '',
  content: json['content'] as String?,
  groupId: (json['group_id'] as num?)?.toInt(),
  transferEnable: (json['transfer_enable'] as num?)?.toInt(),
  monthPrice: (json['month_price'] as num?)?.toInt(),
  quarterPrice: (json['quarter_price'] as num?)?.toInt(),
  halfYearPrice: (json['half_year_price'] as num?)?.toInt(),
  yearPrice: (json['year_price'] as num?)?.toInt(),
  twoYearPrice: (json['two_year_price'] as num?)?.toInt(),
  threeYearPrice: (json['three_year_price'] as num?)?.toInt(),
  onetimePrice: (json['onetime_price'] as num?)?.toInt(),
  resetPrice: (json['reset_price'] as num?)?.toInt(),
);

Map<String, dynamic> _$V2BoardPlanToJson(_V2BoardPlan instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'content': instance.content,
      'group_id': instance.groupId,
      'transfer_enable': instance.transferEnable,
      'month_price': instance.monthPrice,
      'quarter_price': instance.quarterPrice,
      'half_year_price': instance.halfYearPrice,
      'year_price': instance.yearPrice,
      'two_year_price': instance.twoYearPrice,
      'three_year_price': instance.threeYearPrice,
      'onetime_price': instance.onetimePrice,
      'reset_price': instance.resetPrice,
    };

_V2BoardSubscription _$V2BoardSubscriptionFromJson(Map<String, dynamic> json) =>
    _V2BoardSubscription(
      planId: json['plan_id'] == null
          ? ''
          : v2boardStringFromJson(json['plan_id']),
      token: json['token'] as String? ?? '',
      expiredAt: (json['expired_at'] as num?)?.toInt(),
      upload: (json['u'] as num?)?.toInt() ?? 0,
      download: (json['d'] as num?)?.toInt() ?? 0,
      transferEnable: (json['transfer_enable'] as num?)?.toInt() ?? 0,
      subscribeUrl: json['subscribe_url'] as String?,
      resetDay: (json['reset_day'] as num?)?.toInt(),
    );

Map<String, dynamic> _$V2BoardSubscriptionToJson(
  _V2BoardSubscription instance,
) => <String, dynamic>{
  'plan_id': v2boardStringToJson(instance.planId),
  'token': instance.token,
  'expired_at': instance.expiredAt,
  'u': instance.upload,
  'd': instance.download,
  'transfer_enable': instance.transferEnable,
  'subscribe_url': instance.subscribeUrl,
  'reset_day': instance.resetDay,
};

_V2BoardNotice _$V2BoardNoticeFromJson(Map<String, dynamic> json) =>
    _V2BoardNotice(
      id: (json['id'] as num?)?.toInt() ?? 0,
      title: json['title'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt: (json['created_at'] as num?)?.toInt(),
      updatedAt: (json['updated_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$V2BoardNoticeToJson(_V2BoardNotice instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_V2BoardCommConfig _$V2BoardCommConfigFromJson(Map<String, dynamic> json) =>
    _V2BoardCommConfig(
      tosUrl: json['tos_url'] as String?,
      isEmailVerify: json['is_email_verify'] == null
          ? false
          : v2boardBoolFromJson(json['is_email_verify']),
      isInviteForce: json['is_invite_force'] == null
          ? false
          : v2boardBoolFromJson(json['is_invite_force']),
      emailWhitelistSuffix: (json['email_whitelist_suffix'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      isRecaptcha: json['is_recaptcha'] == null
          ? false
          : v2boardBoolFromJson(json['is_recaptcha']),
      recaptchaSiteKey: json['recaptcha_site_key'] as String?,
      appDescription: json['app_description'] as String?,
      appUrl: json['app_url'] as String?,
      logo: json['logo'] as String?,
    );

Map<String, dynamic> _$V2BoardCommConfigToJson(_V2BoardCommConfig instance) =>
    <String, dynamic>{
      'tos_url': instance.tosUrl,
      'is_email_verify': v2boardBoolToJson(instance.isEmailVerify),
      'is_invite_force': v2boardBoolToJson(instance.isInviteForce),
      'email_whitelist_suffix': instance.emailWhitelistSuffix,
      'is_recaptcha': v2boardBoolToJson(instance.isRecaptcha),
      'recaptcha_site_key': instance.recaptchaSiteKey,
      'app_description': instance.appDescription,
      'app_url': instance.appUrl,
      'logo': instance.logo,
    };

_V2BoardOrder _$V2BoardOrderFromJson(Map<String, dynamic> json) =>
    _V2BoardOrder(
      tradeNo: json['trade_no'] as String? ?? '',
      type: (json['type'] as num?)?.toInt() ?? 0,
      status: (json['status'] as num?)?.toInt() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toInt() ?? 0,
      planId: (json['plan_id'] as num?)?.toInt(),
      createdAt: (json['created_at'] as num?)?.toInt(),
    );

Map<String, dynamic> _$V2BoardOrderToJson(_V2BoardOrder instance) =>
    <String, dynamic>{
      'trade_no': instance.tradeNo,
      'type': instance.type,
      'status': instance.status,
      'total_amount': instance.totalAmount,
      'plan_id': instance.planId,
      'created_at': instance.createdAt,
    };

_V2BoardProps _$V2BoardPropsFromJson(Map<String, dynamic> json) =>
    _V2BoardProps(
      serverUrl: json['serverUrl'] as String? ?? '',
      authData: json['authData'] as String? ?? '',
      subscribeToken: json['subscribeToken'] as String? ?? '',
      email: json['email'] as String? ?? '',
      lastLoginDate: json['lastLoginDate'] == null
          ? null
          : DateTime.parse(json['lastLoginDate'] as String),
      autoSync: json['autoSync'] == null
          ? true
          : v2boardBoolFromJson(json['autoSync']),
    );

Map<String, dynamic> _$V2BoardPropsToJson(_V2BoardProps instance) =>
    <String, dynamic>{
      'serverUrl': instance.serverUrl,
      'authData': instance.authData,
      'subscribeToken': instance.subscribeToken,
      'email': instance.email,
      'lastLoginDate': instance.lastLoginDate?.toIso8601String(),
      'autoSync': v2boardBoolToJson(instance.autoSync),
    };

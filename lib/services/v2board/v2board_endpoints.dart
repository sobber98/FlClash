class V2BoardEndpoints {
  final String baseUrl;

  const V2BoardEndpoints(this.baseUrl);

  // Passport (no auth)
  String get login => '$baseUrl/passport/auth/login';

  String get register => '$baseUrl/passport/auth/register';

  String get forget => '$baseUrl/passport/auth/forget';

  String get sendEmailVerify => '$baseUrl/passport/comm/sendEmailVerify';

  // Guest (no auth)
  String get guestCommConfig => '$baseUrl/guest/comm/config';

  // User (auth required)
  String get userInfo => '$baseUrl/user/info';

  String get userSubscribe => '$baseUrl/user/getSubscribe';

  String get userCheckLogin => '$baseUrl/user/checkLogin';

  String get userChangePassword => '$baseUrl/user/changePassword';

  String get userUpdate => '$baseUrl/user/update';

  String get userStat => '$baseUrl/user/getStat';

  // User - Comm
  String get userCommConfig => '$baseUrl/user/comm/config';

  // User - Plan
  String get planFetch => '$baseUrl/user/plan/fetch';

  // User - Notice
  String get noticeFetch => '$baseUrl/user/notice/fetch';

  // User - Server
  String get serverFetch => '$baseUrl/user/server/fetch';

  // User - Order
  String get orderSave => '$baseUrl/user/order/save';

  String get orderFetch => '$baseUrl/user/order/fetch';

  String get orderDetail => '$baseUrl/user/order/detail';

  String get orderCheckout => '$baseUrl/user/order/checkout';

  String get orderCancel => '$baseUrl/user/order/cancel';

  String get orderCheck => '$baseUrl/user/order/check';

  String get orderPaymentMethod => '$baseUrl/user/order/getPaymentMethod';

  // User - Ticket
  String get ticketFetch => '$baseUrl/user/ticket/fetch';

  String get ticketSave => '$baseUrl/user/ticket/save';

  String get ticketReply => '$baseUrl/user/ticket/reply';

  String get ticketClose => '$baseUrl/user/ticket/close';

  // Client (token auth)
  String get clientSubscribe => '$baseUrl/client/subscribe';
}

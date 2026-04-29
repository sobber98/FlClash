import 'package:dio/dio.dart';
import 'package:v2box/services/v2board/v2board_endpoints.dart';
import 'package:v2box/services/v2board/v2board_models.dart';
import 'package:v2box/services/v2board/v2board_ticket_models.dart';

class V2BoardApiException implements Exception {
  final String message;
  final int? statusCode;

  const V2BoardApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class V2BoardApi {
  late final Dio _dio;
  late V2BoardEndpoints _endpoints;
  String _authData = '';

  V2BoardApi({required String baseUrl}) {
    _endpoints = V2BoardEndpoints(_normalizeBaseUrl(baseUrl));
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_authData.isNotEmpty) {
            options.headers['Authorization'] = _authData;
          }
          handler.next(options);
        },
      ),
    );
  }

  V2BoardEndpoints get endpoints => _endpoints;

  void updateBaseUrl(String baseUrl) {
    _endpoints = V2BoardEndpoints(_normalizeBaseUrl(baseUrl));
  }

  void setAuthData(String authData) {
    _authData = authData;
  }

  void clearAuth() {
    _authData = '';
  }

  Map<String, dynamic> _extractData(Response response) {
    final body = response.data;
    if (body is Map<String, dynamic>) {
      if (body.containsKey('message') && !body.containsKey('data')) {
        throw V2BoardApiException(
          _extractErrorMessage(body),
          statusCode: response.statusCode,
        );
      }
      return body;
    }
    throw V2BoardApiException('Invalid response format');
  }

  bool _extractBooleanResult(
    Response response, {
    required String fallbackMessage,
  }) {
    final body = _extractData(response);
    final data = body['data'];
    if (_isTruthyData(data)) {
      return true;
    }
    final message = body['message']?.toString().trim() ?? '';
    throw V2BoardApiException(
      message.isNotEmpty ? message : fallbackMessage,
      statusCode: response.statusCode,
    );
  }

  bool _isTruthyData(dynamic data) {
    if (data == null || data == false) {
      return false;
    }
    if (data is num) {
      return data != 0;
    }
    if (data is String) {
      final normalized = data.trim().toLowerCase();
      return normalized.isNotEmpty &&
          normalized != '0' &&
          normalized != 'false' &&
          normalized != 'null';
    }
    return true;
  }

  // --- Guest ---

  Future<V2BoardCommConfig> getGuestCommConfig() async {
    final response = await _request(() => _dio.get(_endpoints.guestCommConfig));
    final body = _extractData(response);
    return V2BoardCommConfig.fromJson(
      body['data'] as Map<String, dynamic>? ?? {},
    );
  }

  // --- Passport ---

  Future<V2BoardAuth> login({
    required String email,
    required String password,
  }) async {
    final response = await _request(
      () => _dio.post(
        _endpoints.login,
        data: {'email': email, 'password': password},
      ),
    );
    final body = _extractData(response);
    final auth = V2BoardAuth.fromJson(
      body['data'] as Map<String, dynamic>? ?? {},
    );
    _authData = auth.authData;
    return auth;
  }

  Future<V2BoardAuth> register({
    required String email,
    required String password,
    String? inviteCode,
    String? emailCode,
  }) async {
    final data = <String, dynamic>{'email': email, 'password': password};
    if (inviteCode != null && inviteCode.isNotEmpty) {
      data['invite_code'] = inviteCode;
    }
    if (emailCode != null && emailCode.isNotEmpty) {
      data['email_code'] = emailCode;
    }
    final response = await _request(
      () => _dio.post(_endpoints.register, data: data),
    );
    final body = _extractData(response);
    final auth = V2BoardAuth.fromJson(
      body['data'] as Map<String, dynamic>? ?? {},
    );
    _authData = auth.authData;
    return auth;
  }

  Future<bool> sendEmailVerify({
    required String email,
    bool isForget = false,
  }) async {
    final response = await _request(
      () => _dio.post(
        _endpoints.sendEmailVerify,
        data: {'email': email, 'isforget': isForget ? '1' : '0'},
      ),
    );
    return _extractBooleanResult(
      response,
      fallbackMessage: 'Failed to send email verification',
    );
  }

  Future<bool> forgetPassword({
    required String email,
    required String password,
    required String emailCode,
  }) async {
    final response = await _request(
      () => _dio.post(
        _endpoints.forget,
        data: {'email': email, 'password': password, 'email_code': emailCode},
      ),
    );
    return _extractBooleanResult(
      response,
      fallbackMessage: 'Failed to reset password',
    );
  }

  // --- User ---

  Future<V2BoardUser> getUserInfo() async {
    final response = await _request(() => _dio.get(_endpoints.userInfo));
    final body = _extractData(response);
    return V2BoardUser.fromJson(body['data'] as Map<String, dynamic>? ?? {});
  }

  Future<V2BoardSubscription> getSubscribe() async {
    final response = await _request(() => _dio.get(_endpoints.userSubscribe));
    final body = _extractData(response);
    return V2BoardSubscription.fromJson(
      body['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Future<bool> checkLogin() async {
    try {
      final response = await _request(
        () => _dio.get(_endpoints.userCheckLogin),
      );
      final body = _extractData(response);
      final data = body['data'] as Map<String, dynamic>?;
      return data?['is_login'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<List<V2BoardPlan>> getPlans() async {
    final response = await _request(() => _dio.get(_endpoints.planFetch));
    final body = _extractData(response);
    final list = body['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => V2BoardPlan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<V2BoardNotice>> getNotices() async {
    final response = await _request(() => _dio.get(_endpoints.noticeFetch));
    final body = _extractData(response);
    final list = body['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => V2BoardNotice.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<V2BoardTicket>> fetchTickets() async {
    final response = await _request(() => _dio.get(_endpoints.ticketFetch));
    final body = _extractData(response);
    final list = body['data'] as List<dynamic>? ?? [];
    return list
        .whereType<Map>()
        .map((item) => V2BoardTicket.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<V2BoardTicket> getTicketDetail(int id) async {
    final response = await _request(
      () => _dio.get(_endpoints.ticketFetch, queryParameters: {'id': id}),
    );
    final body = _extractData(response);
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return V2BoardTicket.fromJson(data);
    }
    if (data is Map) {
      return V2BoardTicket.fromJson(Map<String, dynamic>.from(data));
    }
    throw const V2BoardApiException('Invalid ticket detail response');
  }

  Future<bool> createTicket({
    required String subject,
    required int level,
    required String message,
  }) async {
    final response = await _request(
      () => _dio.post(
        _endpoints.ticketSave,
        data: {'subject': subject, 'level': level, 'message': message},
      ),
    );
    return _extractBooleanResult(
      response,
      fallbackMessage: 'Failed to create ticket',
    );
  }

  Future<bool> replyTicket({required int id, required String message}) async {
    final response = await _request(
      () => _dio.post(
        _endpoints.ticketReply,
        data: {'id': id, 'message': message},
      ),
    );
    return _extractBooleanResult(
      response,
      fallbackMessage: 'Failed to reply ticket',
    );
  }

  Future<bool> closeTicket(int id) async {
    final response = await _request(
      () => _dio.post(_endpoints.ticketClose, data: {'id': id}),
    );
    return _extractBooleanResult(
      response,
      fallbackMessage: 'Failed to close ticket',
    );
  }

  Future<Map<String, dynamic>> createOrder({
    required int planId,
    required String period,
    String? couponCode,
  }) async {
    final payload = <String, dynamic>{'plan_id': planId, 'period': period};
    if (couponCode != null && couponCode.isNotEmpty) {
      payload['coupon_code'] = couponCode;
    }
    final response = await _request(
      () => _dio.post(_endpoints.orderSave, data: payload),
    );
    return _extractDynamicData(response);
  }

  Future<List<V2BoardOrder>> fetchOrders() async {
    final response = await _request(() => _dio.get(_endpoints.orderFetch));
    final body = _extractData(response);
    final list = body['data'] as List<dynamic>? ?? [];
    return list
        .map((item) => V2BoardOrder.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Map<String, dynamic>> getOrderDetail(String tradeNo) async {
    final response = await _request(
      () => _dio.get(
        _endpoints.orderDetail,
        queryParameters: {'trade_no': tradeNo},
      ),
    );
    return _extractDynamicData(response);
  }

  Future<Map<String, dynamic>> checkoutOrder(
    String tradeNo,
    String paymentMethod, {
    String? callbackUrl,
  }) async {
    final payload = <String, dynamic>{
      'trade_no': tradeNo,
      if (paymentMethod.isNotEmpty) 'method': paymentMethod,
    };
    if (callbackUrl != null && callbackUrl.isNotEmpty) {
      payload['return_url'] = callbackUrl;
      payload['redirect_url'] = callbackUrl;
      payload['success_url'] = callbackUrl;
    }
    final response = await _request(
      () => _dio.post(_endpoints.orderCheckout, data: payload),
    );
    return _extractDynamicData(response);
  }

  Future<bool> checkOrderStatus(String tradeNo) async {
    final response = await _request(
      () => _dio.get(
        _endpoints.orderCheck,
        queryParameters: {'trade_no': tradeNo},
      ),
    );
    final body = _extractData(response);
    final data = body['data'];
    if (data is bool) {
      return data;
    }
    if (data is num) {
      return data == 3;
    }
    if (data is Map<String, dynamic>) {
      final status = data['status'];
      if (status is num) {
        return status == 3;
      }
      final paid = data['paid'];
      if (paid is bool) {
        return paid;
      }
    }
    return false;
  }

  Future<bool> cancelOrder(String tradeNo) async {
    final response = await _request(
      () => _dio.post(_endpoints.orderCancel, data: {'trade_no': tradeNo}),
    );
    final body = _extractData(response);
    final data = body['data'];
    return data == true || data != null;
  }

  Future<List<dynamic>> getPaymentMethods() async {
    final response = await _request(
      () => _dio.get(_endpoints.orderPaymentMethod),
    );
    final body = _extractData(response);
    final data = body['data'];
    if (data is List<dynamic>) {
      return data;
    }
    return const [];
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final response = await _request(
      () => _dio.post(
        _endpoints.userChangePassword,
        data: {'old_password': oldPassword, 'new_password': newPassword},
      ),
    );
    final body = _extractData(response);
    return body['data'] == true;
  }

  Map<String, dynamic> _extractDynamicData(Response response) {
    final body = _extractData(response);
    final data = body['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {'data': data};
  }

  String _normalizeBaseUrl(String baseUrl) {
    return baseUrl.trim().replaceFirst(RegExp(r'/+$'), '');
  }

  Future<Response> _request(Future<Response> Function() fn) async {
    try {
      return await fn();
    } on DioException catch (e) {
      if (e.response?.statusCode == 403) {
        throw V2BoardApiException(
          'Session expired, please login again',
          statusCode: 403,
        );
      }
      if (e.response?.statusCode == 429) {
        throw V2BoardApiException(
          'Too many requests, please try later',
          statusCode: 429,
        );
      }
      if (e.response?.data is Map<String, dynamic>) {
        final body = e.response!.data as Map<String, dynamic>;
        final msg = _extractErrorMessage(body);
        if (msg.isNotEmpty) {
          throw V2BoardApiException(msg, statusCode: e.response?.statusCode);
        }
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        throw const V2BoardApiException('Connection timeout');
      }
      throw V2BoardApiException(
        e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  String _extractErrorMessage(Map<String, dynamic> body) {
    final errors = body['errors'];
    if (errors is Map) {
      final parts = <String>[];
      for (final value in errors.values) {
        if (value is List) {
          for (final item in value) {
            final text = item?.toString().trim() ?? '';
            if (text.isNotEmpty) {
              parts.add(text);
            }
          }
          continue;
        }
        final text = value?.toString().trim() ?? '';
        if (text.isNotEmpty) {
          parts.add(text);
        }
      }
      if (parts.isNotEmpty) {
        return parts.join('\n');
      }
    }
    final message = body['message']?.toString().trim() ?? '';
    if (message.isNotEmpty) {
      return message;
    }
    return 'Unknown error';
  }
}

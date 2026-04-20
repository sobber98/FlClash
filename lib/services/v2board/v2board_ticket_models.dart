class V2BoardTicket {
  final int id;
  final int userId;
  final String subject;
  final int level;
  final int status;
  final int replyStatus;
  final int? createdAt;
  final int? updatedAt;
  final List<V2BoardTicketMessage> messages;

  const V2BoardTicket({
    required this.id,
    required this.userId,
    required this.subject,
    required this.level,
    required this.status,
    required this.replyStatus,
    required this.createdAt,
    required this.updatedAt,
    required this.messages,
  });

  factory V2BoardTicket.fromJson(Map<String, dynamic> json) {
    final userId = _asInt(json['user_id']);
    final messageList = (json['message'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (item) => V2BoardTicketMessage.fromJson(
            Map<String, dynamic>.from(item),
            ownerUserId: userId,
          ),
        )
        .toList(growable: false);

    return V2BoardTicket(
      id: _asInt(json['id']),
      userId: userId,
      subject: _asString(json['subject']),
      level: _asInt(json['level']),
      status: _asInt(json['status']),
      replyStatus: _asInt(json['reply_status']),
      createdAt: _asNullableInt(json['created_at']),
      updatedAt: _asNullableInt(json['updated_at']),
      messages: messageList,
    );
  }

  bool get isClosed => status == 1;

  V2BoardTicketMessage? get latestTicketMessage {
    if (messages.isEmpty) {
      return null;
    }
    return messages.last;
  }

  bool get hasPendingStaffReply {
    final latestMessage = latestTicketMessage;
    if (latestMessage != null) {
      return !isClosed && !latestMessage.isMe;
    }
    return !isClosed && replyStatus == 1;
  }

  String get latestMessage {
    if (messages.isEmpty) {
      return '';
    }
    return messages.last.message.trim();
  }
}

class V2BoardTicketMessage {
  final int id;
  final int userId;
  final int ticketId;
  final String message;
  final int? createdAt;
  final int? updatedAt;
  final bool isMe;

  const V2BoardTicketMessage({
    required this.id,
    required this.userId,
    required this.ticketId,
    required this.message,
    required this.createdAt,
    required this.updatedAt,
    required this.isMe,
  });

  factory V2BoardTicketMessage.fromJson(
    Map<String, dynamic> json, {
    int? ownerUserId,
  }) {
    final userId = _asInt(json['user_id']);
    final explicitIsMe = json['is_me'];
    return V2BoardTicketMessage(
      id: _asInt(json['id']),
      userId: userId,
      ticketId: _asInt(json['ticket_id']),
      message: _asString(json['message']),
      createdAt: _asNullableInt(json['created_at']),
      updatedAt: _asNullableInt(json['updated_at']),
      isMe: explicitIsMe == null
          ? ownerUserId != null && ownerUserId == userId
          : _asBool(explicitIsMe),
    );
  }
}

int _asInt(Object? value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value.trim()) ?? 0;
  }
  return 0;
}

int? _asNullableInt(Object? value) {
  final parsed = _asInt(value);
  if (parsed == 0 && value == null) {
    return null;
  }
  if (value is String && value.trim().isEmpty) {
    return null;
  }
  return parsed;
}

String _asString(Object? value) {
  if (value == null) {
    return '';
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}

bool _asBool(Object? value) {
  if (value is bool) {
    return value;
  }
  if (value is num) {
    return value != 0;
  }
  if (value is String) {
    final normalized = value.trim().toLowerCase();
    if (normalized == 'true') {
      return true;
    }
    if (normalized == 'false') {
      return false;
    }
    return (int.tryParse(normalized) ?? 0) != 0;
  }
  return false;
}

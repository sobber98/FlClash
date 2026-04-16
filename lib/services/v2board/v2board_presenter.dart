import 'dart:convert';

import 'package:fl_clash/services/v2board/v2board_models.dart';

const v2boardPaymentCallbackScheme = 'flclash';
const v2boardPaymentCallbackHost = 'payment-callback';

const _defaultPlanHighlights = [
  '高速稳定连接',
  '全球节点覆盖',
  '多设备同时在线',
  '全天候可用',
  '套餐即时生效',
];

const _scalarJsonKeys = {
  'title',
  'name',
  'label',
  'content',
  'description',
  'desc',
  'text',
  'value',
  'amount',
  'traffic',
  'speed',
  'device_limit',
  'deviceLimit',
  'limit',
};

const _ignoredJsonKeys = {
  'id',
  'created_at',
  'updated_at',
  'createdAt',
  'updatedAt',
  'plan_id',
  'group_id',
  'sort',
  'type',
  'status',
};

class V2BoardPaymentOption {
  final String value;
  final String label;
  final Map<String, dynamic>? raw;

  const V2BoardPaymentOption({
    required this.value,
    required this.label,
    this.raw,
  });
}

String v2boardPlainText(String? raw, {bool preserveLineBreaks = true}) {
  var text = raw?.trim() ?? '';
  if (text.isEmpty) {
    return '';
  }
  text = text
      .replaceAll(RegExp(r'<\s*br\s*/?\s*>', caseSensitive: false), '\n')
      .replaceAll(
        RegExp(r'</\s*(p|div|li|ul|ol|section|article|h\d)\s*>', caseSensitive: false),
        '\n',
      )
      .replaceAll(RegExp(r'<\s*li[^>]*>', caseSensitive: false), '• ')
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&amp;', '&')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&ldquo;', '"')
      .replaceAll('&rdquo;', '"')
      .replaceAll('&rsquo;', "'")
      .replaceAll('&mdash;', '-');

  final normalizedLines = text
      .replaceAll('\r\n', '\n')
      .replaceAll('\r', '\n')
      .split('\n')
      .map((line) => line.replaceAll(RegExp(r'[ \t\f\v]+'), ' ').trim())
      .where((line) => preserveLineBreaks ? true : line.isNotEmpty)
      .toList(growable: false);

  final result = preserveLineBreaks
      ? normalizedLines.join('\n').replaceAll(RegExp(r'\n{3,}'), '\n\n')
      : normalizedLines.where((line) => line.isNotEmpty).join(' ');
  return result.trim();
}

String v2boardNoticeHeadline(V2BoardNotice notice) {
  final title = notice.title.trim();
  if (title.isNotEmpty) {
    return title;
  }
  final plain = v2boardPlainText(notice.content, preserveLineBreaks: false);
  if (plain.isEmpty) {
    return '';
  }
  return plain.split(RegExp(r'[。！？!?；;\n]')).first.trim();
}

String v2boardNoticePreview(List<V2BoardNotice> notices, {int maxItems = 3}) {
  return notices.take(maxItems).map((notice) {
    final title = v2boardNoticeHeadline(notice);
    final plain = v2boardPlainText(
      notice.content,
      preserveLineBreaks: false,
    );
    final snippet = plain.length > 72 ? '${plain.substring(0, 72)}...' : plain;
    if (title.isNotEmpty && snippet.isNotEmpty && snippet != title) {
      return '$title：$snippet';
    }
    return title.isNotEmpty ? title : snippet;
  }).where((item) => item.trim().isNotEmpty).join('   ·   ');
}

List<String> v2boardPlanHighlights(
  String? content, {
  int limit = 5,
  List<String> fallback = _defaultPlanHighlights,
}) {
  final raw = content?.trim() ?? '';
  if (raw.isEmpty) {
    return fallback.take(limit).toList(growable: false);
  }

  final highlights = <String>[];
  final decoded = _tryDecodeJson(raw);
  if (decoded != null) {
    _collectJsonHighlights(decoded, highlights);
  } else {
    _collectTextHighlights(raw, highlights);
  }

  final deduped = <String>[];
  final seen = <String>{};
  for (final item in highlights) {
    final normalized = v2boardPlainText(item, preserveLineBreaks: false);
    if (normalized.isEmpty) {
      continue;
    }
    if (seen.add(normalized)) {
      deduped.add(normalized);
    }
    if (deduped.length >= limit) {
      break;
    }
  }

  if (deduped.isEmpty) {
    return fallback.take(limit).toList(growable: false);
  }
  return deduped;
}

List<V2BoardPaymentOption> v2boardPaymentOptions(List<dynamic> methods) {
  final options = <V2BoardPaymentOption>[];
  final seen = <String>{};
  for (final method in methods) {
    final option = _paymentOptionFromDynamic(method);
    if (option == null) {
      continue;
    }
    final key = '${option.value}|${option.label}';
    if (seen.add(key)) {
      options.add(option);
    }
  }
  return options;
}

bool v2boardIsPaymentCallback(Uri uri) {
  return uri.scheme == v2boardPaymentCallbackScheme &&
      uri.host == v2boardPaymentCallbackHost;
}

String v2boardPaymentCallbackUrl(String tradeNo) {
  return Uri(
    scheme: v2boardPaymentCallbackScheme,
    host: v2boardPaymentCallbackHost,
    queryParameters: {'trade_no': tradeNo},
  ).toString();
}

String? v2boardExtractTradeNoFromUri(Uri uri) {
  final tradeNo =
      uri.queryParameters['trade_no'] ?? uri.queryParameters['tradeNo'];
  if (tradeNo == null || tradeNo.trim().isEmpty) {
    return null;
  }
  return tradeNo.trim();
}

String? v2boardCheckoutUrl(
  Map<String, dynamic> result, {
  String? baseUrl,
}) {
  final data = result['data'];
  final candidates = [
    result['url'],
    result['pay_url'],
    result['payment_url'],
    result['checkout_url'],
    if (data is String) data,
    data is Map ? (data)['url'] : null,
    data is Map ? (data)['payment_url'] : null,
    data is Map ? (data)['pay_url'] : null,
    data is Map ? (data)['checkout_url'] : null,
    data is Map ? (data)['link'] : null,
    data is Map ? (data)['redirect'] : null,
  ];
  for (final value in candidates) {
    final text = value?.toString().trim() ?? '';
    final resolved = _resolveCheckoutUrl(text, baseUrl: baseUrl);
    if (resolved != null) {
      return resolved;
    }
  }
  return null;
}

String? _resolveCheckoutUrl(String raw, {String? baseUrl}) {
  if (raw.isEmpty) {
    return null;
  }
  final uri = Uri.tryParse(raw);
  if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
    return uri.toString();
  }
  if (baseUrl == null || baseUrl.trim().isEmpty) {
    return null;
  }
  final baseUri = Uri.tryParse(baseUrl.trim());
  if (baseUri == null) {
    return null;
  }
  if (raw.startsWith('/')) {
    return baseUri.resolve(raw).toString();
  }
  if (uri != null && !uri.hasScheme) {
    return baseUri.resolveUri(uri).toString();
  }
  if (!raw.contains('://') && !raw.startsWith('javascript:')) {
    return baseUri.resolve(raw).toString();
  }
  return null;
}

dynamic _tryDecodeJson(String raw) {
  final trimmed = raw.trim();
  if (!(trimmed.startsWith('{') || trimmed.startsWith('['))) {
    return null;
  }
  try {
    return jsonDecode(trimmed);
  } catch (_) {
    return null;
  }
}

void _collectJsonHighlights(dynamic value, List<String> output, {String? key}) {
  if (value == null) {
    return;
  }
  if (value is List) {
    for (final item in value) {
      _collectJsonHighlights(item, output);
    }
    return;
  }
  if (value is Map) {
    final map = Map<String, dynamic>.from(value);
    final title = _pickScalar(map, const ['title', 'name', 'label']);
    final desc = _pickScalar(
      map,
      const ['content', 'description', 'desc', 'text'],
    );
    final scalarValue = _pickScalar(
      map,
      const ['value', 'amount', 'traffic', 'speed', 'device_limit', 'deviceLimit', 'limit'],
    );

    if (title.isNotEmpty && desc.isNotEmpty) {
      output.add('$title：$desc');
    } else if (title.isNotEmpty && scalarValue.isNotEmpty) {
      output.add('$title：$scalarValue');
    } else if (desc.isNotEmpty) {
      output.add(desc);
    } else if (title.isNotEmpty) {
      output.add(title);
    }

    for (final entry in map.entries) {
      if (_ignoredJsonKeys.contains(entry.key) || _scalarJsonKeys.contains(entry.key)) {
        continue;
      }
      _collectJsonHighlights(entry.value, output, key: entry.key);
    }
    return;
  }

  final text = value.toString().trim();
  if (text.isEmpty || text == 'null') {
    return;
  }
  if (key != null && !_ignoredJsonKeys.contains(key)) {
    output.add('${_prettyKey(key)}：$text');
    return;
  }
  output.add(text);
}

void _collectTextHighlights(String raw, List<String> output) {
  final plain = v2boardPlainText(raw);
  final blocks = plain
      .split(RegExp(r'\n+|\|+|•+'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList(growable: false);

  if (blocks.isEmpty) {
    return;
  }

  for (final block in blocks) {
    final parts = block
        .split(RegExp(r'(?<=[。！？!?；;])\s+'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty);
    output.addAll(parts);
  }
}

String _pickScalar(Map<String, dynamic> map, List<String> keys) {
  for (final key in keys) {
    final value = map[key];
    if (value == null) {
      continue;
    }
    final text = v2boardPlainText(value.toString(), preserveLineBreaks: false);
    if (text.isNotEmpty && text != 'null') {
      return text;
    }
  }
  return '';
}

String _prettyKey(String key) {
  return key.replaceAll(RegExp(r'[_-]+'), ' ').trim();
}

V2BoardPaymentOption? _paymentOptionFromDynamic(dynamic method) {
  if (method == null) {
    return null;
  }
  if (method is String) {
    final text = method.trim();
    if (text.isEmpty) {
      return null;
    }
    return V2BoardPaymentOption(value: text, label: text);
  }
  if (method is Map) {
    final map = Map<String, dynamic>.from(method);
    final label = _pickScalar(
      map,
      const ['name', 'title', 'label', 'display_name', 'method'],
    );
    final value = _pickScalar(
      map,
      const ['method', 'value', 'uuid', 'id', 'code', 'name'],
    );
    if (label.isEmpty && value.isEmpty) {
      return null;
    }
    return V2BoardPaymentOption(
      value: value.isNotEmpty ? value : label,
      label: label.isNotEmpty ? label : value,
      raw: map,
    );
  }
  final text = method.toString().trim();
  if (text.isEmpty) {
    return null;
  }
  return V2BoardPaymentOption(value: text, label: text);
}
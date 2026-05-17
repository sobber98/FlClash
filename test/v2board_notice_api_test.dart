import 'package:flutter_test/flutter_test.dart';
import 'package:v2box/services/v2board/v2board.dart';

void main() {
  test('notice list parser accepts paginated V2Board payloads', () {
    final list = v2boardExtractListPayload({
      'data': {
        'data': [
          {'id': 1, 'title': '维护通知', 'content': '<p>今晚 23:00 维护</p>'},
        ],
        'total': 1,
      },
    });

    final notices = list
        .map((item) => V2BoardNotice.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    expect(notices, hasLength(1));
    expect(notices.single.title, '维护通知');
    expect(v2boardNoticePreview(notices), contains('今晚 23:00 维护'));
  });
}

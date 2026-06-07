import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:v2box/enum/enum.dart';
import 'package:v2box/models/models.dart';
import 'package:v2box/providers/providers.dart';

void main() {
  const groups = [
    Group(
      name: 'Proxy',
      type: GroupType.Selector,
      all: [
        Proxy(name: '香港 高级节点', type: 'Shadowsocks'),
        Proxy(name: '新加坡 标准节点', type: 'Shadowsocks'),
      ],
    ),
  ];

  test('blocked node keywords from app config hide matching proxies', () {
    final container = ProviderContainer(
      overrides: [
        blockedNodeKeywordsProvider.overrideWithValue(['香港']),
        currentGroupsStateProvider.overrideWithValue(
          const GroupsState(value: groups),
        ),
      ],
    );
    addTearDown(container.dispose);

    final filteredGroups = container.read(filterGroupsStateProvider('')).value;

    expect(filteredGroups, hasLength(1));
    expect(filteredGroups.single.all.map((proxy) => proxy.name), ['新加坡 标准节点']);
  });

  test('blocked selected proxy names are not exposed to current-node UI', () {
    final container = ProviderContainer(
      overrides: [
        blockedNodeKeywordsProvider.overrideWithValue(['香港']),
        groupsProvider.overrideWithValue(groups),
        selectedMapProvider.overrideWithValue({'Proxy': '香港 高级节点'}),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(getSelectedProxyNameProvider('Proxy')), isNull);
  });
}

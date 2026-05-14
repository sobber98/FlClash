import 'package:v2box/common/compute.dart';
import 'package:v2box/common/iterable.dart';
import 'package:v2box/common/string.dart';
import 'package:v2box/controller.dart';
import 'package:v2box/core/core.dart';
import 'package:v2box/models/models.dart';

Future<void> proxyDelayTest(Proxy proxy, [String? testUrl]) async {
  final groups = appController.groups;
  final selectedMap = appController.currentProfile?.selectedMap ?? {};
  final state = computeRealSelectedProxyState(
    proxy.name,
    groups: groups,
    selectedMap: selectedMap,
  );
  final currentTestUrl = state.testUrl.takeFirstValid([
    appController.getRealTestUrl(testUrl),
  ]);
  if (state.proxyName.isEmpty) {
    return;
  }
  appController.setDelay(
    Delay(url: currentTestUrl, name: state.proxyName, value: 0),
  );
  appController.setDelay(
    await coreController.getDelay(currentTestUrl, state.proxyName),
  );
}

Future<void> delayTest(List<Proxy> proxies, [String? testUrl]) async {
  final proxyNames = proxies.map((proxy) => proxy.name).toSet().toList();

  final delayProxies = proxyNames.map<Future>((proxyName) async {
    final groups = appController.groups;
    final selectedMap = appController.currentProfile?.selectedMap ?? {};
    final state = computeRealSelectedProxyState(
      proxyName,
      groups: groups,
      selectedMap: selectedMap,
    );
    final url = state.testUrl.takeFirstValid([
      appController.getRealTestUrl(testUrl),
    ]);
    final name = state.proxyName;
    if (name.isEmpty) {
      return;
    }
    appController.setDelay(Delay(url: url, name: name, value: 0));
    appController.setDelay(await coreController.getDelay(url, name));
  }).toList();

  final batchesDelayProxies = delayProxies.batch(100);
  for (final batchDelayProxies in batchesDelayProxies) {
    await Future.wait(batchDelayProxies);
  }
  appController.addSortNum();
}

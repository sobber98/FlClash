import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/views/proxies/common.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AutoTestState {
  final bool isTesting;
  final DateTime? lastUpdatedAt;

  const AutoTestState({this.isTesting = false, this.lastUpdatedAt});

  AutoTestState copyWith({bool? isTesting, DateTime? lastUpdatedAt}) {
    return AutoTestState(
      isTesting: isTesting ?? this.isTesting,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }
}

final autoTestStateProvider =
    NotifierProvider<AutoTestStateNotifier, AutoTestState>(
      AutoTestStateNotifier.new,
    );

class AutoTestStateNotifier extends Notifier<AutoTestState> {
  @override
  AutoTestState build() {
    return const AutoTestState();
  }

  void setTesting(bool isTesting) {
    state = state.copyWith(isTesting: isTesting);
  }

  void setCompleted(DateTime lastUpdatedAt) {
    state = AutoTestState(isTesting: false, lastUpdatedAt: lastUpdatedAt);
  }
}

final autoTestControllerProvider = Provider<AutoTestController>((ref) {
  final controller = AutoTestController(ref);
  final timer = Timer.periodic(const Duration(minutes: 5), (_) {
    unawaited(controller.runNow());
  });
  ref.listen<int?>(
    currentProfileProvider.select((profile) => profile?.id),
    (_, _) => unawaited(controller.runNow()),
  );
  ref.listen<bool>(initProvider, (_, next) {
    if (next) {
      unawaited(controller.runNow());
    }
  });
  ref.onDispose(timer.cancel);
  return controller;
});

class AutoTestController {
  final Ref ref;

  AutoTestController(this.ref);

  Future<void> runNow() async {
    final state = ref.read(autoTestStateProvider);
    if (state.isTesting || !ref.read(initProvider)) {
      return;
    }
    final groups = ref.read(currentGroupsStateProvider).value;
    if (groups.isEmpty) {
      return;
    }
    ref.read(autoTestStateProvider.notifier).setTesting(true);
    try {
      for (final group in groups) {
        await delayTest(group.all, group.testUrl);
      }
      ref.read(autoTestStateProvider.notifier).setCompleted(DateTime.now());
    } catch (error) {
      commonPrint.log('auto test failed: $error', logLevel: LogLevel.warning);
      ref.read(autoTestStateProvider.notifier).setTesting(false);
    }
  }
}

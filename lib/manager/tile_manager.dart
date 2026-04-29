import 'package:v2box/common/app_localizations.dart';
import 'package:v2box/controller.dart';
import 'package:v2box/core/controller.dart';
import 'package:v2box/plugins/app.dart';
import 'package:v2box/plugins/tile.dart';
import 'package:v2box/providers/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TileManager extends ConsumerStatefulWidget {
  final Widget child;

  const TileManager({super.key, required this.child});

  @override
  ConsumerState<TileManager> createState() => _TileContainerState();
}

class _TileContainerState extends ConsumerState<TileManager> with TileListener {
  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  bool get isStart => ref.read(isStartProvider);

  @override
  Future<void> onStart() async {
    if (isStart && coreController.isCompleted) {
      return;
    }
    appController.updateStatus(true);
    app?.tip(appLocalizations.startVpn);
    super.onStart();
  }

  @override
  Future<void> onStop() async {
    if (!isStart) {
      return;
    }
    appController.updateStatus(false);
    app?.tip(appLocalizations.stopVpn);
    super.onStop();
  }

  @override
  void initState() {
    super.initState();
    tile?.addListener(this);
  }

  @override
  void dispose() {
    tile?.removeListener(this);
    super.dispose();
  }
}

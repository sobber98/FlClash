import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/views/v2board/account_view.dart';
import 'package:fl_clash/views/v2board/login_view.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class V2BoardView extends ConsumerWidget {
  const V2BoardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final props = ref.watch(v2boardSettingProvider);
    final isLoggedIn = props?.isLoggedIn ?? false;

    return CommonScaffold(
      title: 'V2Board',
      body: isLoggedIn
          ? const V2BoardAccountView()
          : const V2BoardLoginView(),
    );
  }
}

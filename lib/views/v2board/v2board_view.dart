import 'package:v2box/providers/providers.dart';
import 'package:v2box/services/v2board/v2board.dart';
import 'package:v2box/views/v2board/account_view.dart';
import 'package:v2box/views/v2board/login_view.dart';
import 'package:v2box/widgets/widgets.dart';
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

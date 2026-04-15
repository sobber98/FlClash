import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/views/v2board/account_view.dart';
import 'package:fl_clash/views/v2board/login_view.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  void _showLoginSheet(BuildContext context) {
    showSheet(
      context: context,
      props: SheetProps(isScrollControlled: true),
      builder: (_, type) {
        return AdaptiveSheetScaffold(
          type: type,
          title: '登录',
          body: const V2BoardLoginView(),
        );
      },
    );
  }

  void _showRegisterPage(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const V2BoardRegisterPage()));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final props = ref.watch(v2boardSettingProvider);
    final isLoggedIn = props?.isLoggedIn ?? false;
    final appName = ref.watch(appDisplayNameProvider);
    final enableRegistration = ref.watch(appEnableRegistrationProvider);

    return CommonScaffold(
      title: '我的',
      body: isLoggedIn
          ? const Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: SubscriptionCard(),
                ),
                SizedBox(height: 8),
                Expanded(child: V2BoardAccountView()),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                CommonCard(
                  type: CommonCardType.filled,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 34,
                          backgroundColor: context.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person_outline,
                            size: 36,
                            color: context.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(appName, style: context.textTheme.headlineSmall),
                        const SizedBox(height: 8),
                        Text(
                          '登录后查看订阅状态、同步订阅与公告。',
                          textAlign: TextAlign.center,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        FilledButton(
                          onPressed: () => _showLoginSheet(context),
                          child: const Text('登录'),
                        ),
                        if (enableRegistration) ...[
                          const SizedBox(height: 10),
                          OutlinedButton(
                            onPressed: () => _showRegisterPage(context),
                            child: const Text('注册'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

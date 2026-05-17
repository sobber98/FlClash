import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:v2box/common/common.dart';
import 'package:v2box/controller.dart';
import 'package:v2box/providers/providers.dart';
import 'package:v2box/state.dart';
import 'package:v2box/views/v2board/v2board_design.dart';

class AboutAppView extends ConsumerStatefulWidget {
  const AboutAppView({super.key});

  @override
  ConsumerState<AboutAppView> createState() => _AboutAppViewState();
}

class _AboutAppViewState extends ConsumerState<AboutAppView> {
  late final Future<PackageInfo> _packageInfoFuture;
  bool _checkingUpdate = false;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  Future<void> _checkUpdate() async {
    if (_checkingUpdate) return;
    setState(() {
      _checkingUpdate = true;
    });
    try {
      final userUrl = ref.read(appSettingProvider).updateManifestUrl;
      final configUrl = ref.read(appUpdateManifestUrlProvider);
      final manifestUrl = userUrl.trim().isNotEmpty ? userUrl : configUrl;
      final manifest = manifestUrl.trim().isEmpty
          ? null
          : await request.checkForUpdate(manifestUrl);
      if (appController.isAttach) {
        await appController.checkUpdateResultHandle(
          data: manifest,
          isUser: true,
        );
      } else {
        await globalState.showMessage(
          title: '检查更新',
          message: const TextSpan(text: '当前应用已经是最新版了'),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _checkingUpdate = false;
        });
      }
    }
  }

  String _versionText(PackageInfo packageInfo) {
    final buildNumber = packageInfo.buildNumber.trim();
    if (buildNumber.isEmpty) {
      return 'v${packageInfo.version}';
    }
    return 'v${packageInfo.version} ($buildNumber)';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ref.watch(isMobileViewProvider);
    final appName = ref.watch(appDisplayNameProvider);
    return Scaffold(
      backgroundColor: v2BoardPageBackground,
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            isMobile ? 16 : 24,
            14,
            isMobile ? 16 : 24,
            32,
          ),
          children: [
            _AboutPageHeader(appName: appName, compact: isMobile),
            const SizedBox(height: 18),
            V2BoardCard(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder<PackageInfo>(
                future: _packageInfoFuture,
                builder: (context, snapshot) {
                  final versionText = snapshot.hasData
                      ? _versionText(snapshot.data!)
                      : '-';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              gradient: v2BoardGradient,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.textTheme.headlineSmall
                                      ?.copyWith(
                                        color: v2BoardInk,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '应用版本',
                                  style: context.textTheme.bodyMedium?.copyWith(
                                    color: v2BoardMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            versionText,
                            style: context.textTheme.titleMedium?.copyWith(
                              color: v2BoardPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: V2BoardPrimaryButton(
                          onPressed: _checkUpdate,
                          icon: Icons.system_update_alt_rounded,
                          label: '检查更新',
                          loading: _checkingUpdate,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AboutPageHeader extends StatelessWidget {
  final String appName;
  final bool compact;

  const _AboutPageHeader({required this.appName, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_rounded),
          color: v2BoardInk,
          tooltip: '返回',
        ),
        const SizedBox(width: 4),
        Expanded(
          child: V2BoardPageHeader(
            title: '关于应用',
            subtitle: appName,
            compact: compact,
          ),
        ),
      ],
    );
  }
}

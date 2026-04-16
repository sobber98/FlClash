import 'dart:async';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/state.dart';
import 'package:desktop_webview_window/desktop_webview_window.dart'
  as desktop_webview;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart' as flutter_webview;
import 'package:webview_windows/webview_windows.dart' as windows_webview;

enum _PaymentStage { pending, checking, success, failed, timeout, cancelled }

class PaymentCheckoutView extends ConsumerStatefulWidget {
  final String tradeNo;
  final String planName;
  final String periodLabel;
  final String amountText;
  final String paymentMethodLabel;
  final String? paymentUrl;

  const PaymentCheckoutView({
    super.key,
    required this.tradeNo,
    required this.planName,
    required this.periodLabel,
    required this.amountText,
    required this.paymentMethodLabel,
    this.paymentUrl,
  });

  @override
  ConsumerState<PaymentCheckoutView> createState() =>
      _PaymentCheckoutViewState();
}

class _PaymentCheckoutViewState extends ConsumerState<PaymentCheckoutView> {
  static const _pollInterval = Duration(seconds: 3);
  static const _paymentTimeout = Duration(minutes: 15);

  Timer? _pollTimer;
  StreamSubscription<Uri>? _linkSubscription;
  final List<StreamSubscription<dynamic>> _windowsSubscriptions = [];
  _PaymentStage _stage = _PaymentStage.pending;
  String _hint = '订单已创建，请在客户端内完成支付，支付成功后将自动确认。';
  DateTime? _lastCheckedAt;
  DateTime? _paymentSessionStartedAt;
  bool _openingPayment = false;
  bool _completed = false;
  bool _webViewFailed = false;
  bool _disposing = false;
  bool _desktopWindowOpened = false;
  bool _ignoreNextLinuxWindowClose = false;
  int _webProgress = 0;
  String? _currentUrl;
  flutter_webview.WebViewController? _flutterWebViewController;
  windows_webview.WebviewController? _windowsWebViewController;
  desktop_webview.Webview? _linuxPaymentWindow;

  bool get _hasPaymentUrl => widget.paymentUrl?.isNotEmpty == true;

  bool get _usingFlutterWebView {
    return _hasPaymentUrl && (system.isAndroid || system.isMacOS);
  }

  bool get _usingWindowsWebView {
    return _hasPaymentUrl && system.isWindows;
  }

  bool get _usingLinuxPaymentWindow {
    return _hasPaymentUrl && system.isLinux;
  }

  bool get _canUseEmbeddedWebView {
    return _usingFlutterWebView || _usingWindowsWebView;
  }

  bool get _supportsClientSidePayment {
    return _canUseEmbeddedWebView || _usingLinuxPaymentWindow;
  }

  bool get _isRecoverableStage {
    return _stage == _PaymentStage.timeout || _stage == _PaymentStage.cancelled;
  }

  @override
  void initState() {
    super.initState();
    _paymentSessionStartedAt = DateTime.now();
    if (_usingFlutterWebView) {
      _flutterWebViewController = _buildFlutterWebViewController();
    }
    if (_usingWindowsWebView) {
      unawaited(_initWindowsWebView());
    }
    _linkSubscription = linkManager.uriStream.listen(_handleLink);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final lastUri = linkManager.lastUri;
      if (lastUri != null) {
        await _handleLink(lastUri);
      }
      if (_usingLinuxPaymentWindow) {
        await _openLinuxPaymentWindow(auto: true);
      }
      _startPolling();
      await _checkStatus(trigger: 'init');
    });
  }

  @override
  void dispose() {
    _disposing = true;
    _pollTimer?.cancel();
    _linkSubscription?.cancel();
    for (final subscription in _windowsSubscriptions) {
      subscription.cancel();
    }
    final windowsController = _windowsWebViewController;
    _windowsWebViewController = null;
    if (windowsController != null) {
      unawaited(windowsController.dispose());
    }
    final linuxPaymentWindow = _linuxPaymentWindow;
    _linuxPaymentWindow = null;
    if (linuxPaymentWindow != null) {
      try {
        linuxPaymentWindow.close();
      } catch (_) {}
    }
    super.dispose();
  }

  flutter_webview.WebViewController _buildFlutterWebViewController() {
    final controller = flutter_webview.WebViewController()
      ..setJavaScriptMode(flutter_webview.JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        flutter_webview.NavigationDelegate(
          onProgress: (progress) {
            if (!mounted) {
              return;
            }
            setState(() {
              _webProgress = progress;
              _webViewFailed = false;
            });
          },
          onPageStarted: (url) {
            if (!mounted) {
              return;
            }
            setState(() {
              _currentUrl = url;
              _webProgress = 0;
            });
          },
          onPageFinished: (url) {
            if (!mounted) {
              return;
            }
            setState(() {
              _currentUrl = url;
              _webProgress = 100;
            });
          },
          onWebResourceError: (error) {
            if (!mounted) {
              return;
            }
            final description = error.description.trim();
            setState(() {
              _webViewFailed = true;
              _hint = description.isEmpty
                  ? '支付页加载失败，可刷新重试。'
                  : '支付页加载失败：$description';
            });
          },
          onNavigationRequest: (request) {
            return _handleNavigationRequest(request);
          },
        ),
      );
    final url = widget.paymentUrl;
    if (url != null && url.isNotEmpty) {
      controller.loadRequest(Uri.parse(url));
    }
    return controller;
  }

  Future<void> _initWindowsWebView() async {
    final url = widget.paymentUrl;
    if (url == null || url.isEmpty) {
      return;
    }
    try {
      final version = await windows_webview.WebviewController.getWebViewVersion();
      if (version == null) {
        if (!mounted) {
          return;
        }
        setState(() {
          _webViewFailed = true;
          _hint = '当前 Windows 缺少 WebView2 Runtime，暂时无法在客户端内加载支付页。';
        });
        return;
      }
      final controller = windows_webview.WebviewController();
      await controller.initialize();
      await controller.setBackgroundColor(Colors.white);
      await controller.setPopupWindowPolicy(
        windows_webview.WebviewPopupWindowPolicy.deny,
      );
      _windowsSubscriptions.add(
        controller.url.listen((url) {
          unawaited(_handleObservedUrl(url));
        }),
      );
      _windowsSubscriptions.add(
        controller.loadingState.listen((state) {
          if (!mounted) {
            return;
          }
          setState(() {
            switch (state) {
              case windows_webview.LoadingState.none:
                _webProgress = _webProgress == 0 ? 12 : _webProgress;
                break;
              case windows_webview.LoadingState.loading:
                _webProgress = _webProgress >= 100 ? 68 : 36;
                _webViewFailed = false;
                break;
              case windows_webview.LoadingState.navigationCompleted:
                _webProgress = 100;
                break;
            }
          });
        }),
      );
      _windowsSubscriptions.add(
        controller.onLoadError.listen((_) {
          if (!mounted) {
            return;
          }
          setState(() {
            _webViewFailed = true;
            _hint = '支付页加载失败，可重新载入。';
          });
        }),
      );
      await controller.loadUrl(url);
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _windowsWebViewController = controller;
      });
    } on PlatformException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _webViewFailed = true;
        _hint = 'Windows 支付页初始化失败：${error.message ?? error.code}';
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _webViewFailed = true;
        _hint = 'Windows 支付页初始化失败：$error';
      });
    }
  }

  flutter_webview.NavigationDecision _handleNavigationRequest(
    flutter_webview.NavigationRequest request,
  ) {
    final uri = Uri.tryParse(request.url);
    if (uri == null) {
      return flutter_webview.NavigationDecision.navigate;
    }
    if (v2boardIsPaymentCallback(uri)) {
      unawaited(_handleLink(uri));
      return flutter_webview.NavigationDecision.prevent;
    }
    if (!_isWebNavigation(uri)) {
      unawaited(_launchExternalUri(uri));
      return flutter_webview.NavigationDecision.prevent;
    }
    return flutter_webview.NavigationDecision.navigate;
  }

  bool _isWebNavigation(Uri uri) {
    return uri.scheme == 'http' || uri.scheme == 'https';
  }

  Future<void> _handleObservedUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (mounted) {
      setState(() {
        _currentUrl = url;
      });
    }
    if (uri == null) {
      return;
    }
    if (v2boardIsPaymentCallback(uri)) {
      await _handleLink(uri);
      return;
    }
    if (!_isWebNavigation(uri)) {
      await _launchExternalUri(uri);
    }
  }

  Future<void> _launchExternalUri(Uri uri) async {
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hint = '无法拉起外部支付应用，请稍后重试。';
      });
    }
  }

  Future<void> _handleLink(Uri uri) async {
    if (!v2boardIsPaymentCallback(uri)) {
      return;
    }
    final tradeNo = v2boardExtractTradeNoFromUri(uri);
    if (tradeNo != null && tradeNo != widget.tradeNo) {
      return;
    }
    if (_linuxPaymentWindow != null) {
      _ignoreNextLinuxWindowClose = true;
      try {
        _linuxPaymentWindow?.close();
      } catch (_) {}
      _linuxPaymentWindow = null;
      if (mounted) {
        setState(() {
          _desktopWindowOpened = false;
        });
      }
    }
    await _checkStatus(trigger: 'callback');
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(_pollInterval, (_) {
      if (_completed) {
        return;
      }
      if (_isPaymentTimedOut) {
        _markTimedOut();
        return;
      }
      _checkStatus(trigger: 'poll');
    });
  }

  bool get _isPaymentTimedOut {
    final startedAt = _paymentSessionStartedAt;
    if (startedAt == null || _completed) {
      return false;
    }
    return DateTime.now().difference(startedAt) >= _paymentTimeout;
  }

  Future<void> _checkStatus({required String trigger}) async {
    if (!mounted || _completed) {
      return;
    }
    final api = ref.read(v2boardApiClientProvider);
    if (api == null) {
      return;
    }
    if (_stage != _PaymentStage.success) {
      setState(() {
        _stage = _PaymentStage.checking;
        _hint = trigger == 'callback'
            ? '已收到支付回调，正在确认订单状态...'
            : '正在与服务器确认订单状态...';
      });
    }
    try {
      final paid = await api.checkOrderStatus(widget.tradeNo);
      _lastCheckedAt = DateTime.now();
      if (!mounted) {
        return;
      }
      if (paid) {
        await _completeSuccess();
        return;
      }
      if (_isPaymentTimedOut) {
        _markTimedOut();
        return;
      }
      setState(() {
        if (_stage != _PaymentStage.cancelled) {
          _stage = _PaymentStage.pending;
          _hint = '订单尚未支付完成，支付成功后可自动回到此页或手动点“立即检查”。';
        } else {
          _hint = '订单已保留，恢复支付后可继续在当前订单上完成扣款。';
        }
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _stage = _PaymentStage.failed;
        _hint = '状态检查失败：$error';
      });
    }
  }

  Future<void> _completeSuccess() async {
    if (_completed) {
      return;
    }
    _completed = true;
    _pollTimer?.cancel();
    await ref.read(subscriptionOrdersProvider.notifier).refresh();
    await ref.read(v2boardUserProvider.notifier).fetch();
    await ref.read(v2boardSubscriptionProvider.notifier).fetch();
    await appController.syncV2BoardSubscription();
    if (!mounted) {
      return;
    }
    setState(() {
      _stage = _PaymentStage.success;
      _hint = '支付成功，订单与订阅信息已刷新。';
    });
  }

  void _markTimedOut() {
    if (!mounted || _completed) {
      return;
    }
    _pollTimer?.cancel();
    setState(() {
      _stage = _PaymentStage.timeout;
      _hint = '支付等待已超时，订单仍然保留。你可以稍后恢复订单，继续在当前订单上完成支付。';
    });
  }

  void _markCancelled({String? message}) {
    if (!mounted || _completed) {
      return;
    }
    _pollTimer?.cancel();
    setState(() {
      _stage = _PaymentStage.cancelled;
      _hint = message ?? '本次支付已暂存，订单不会丢失。你可以稍后恢复订单并继续支付。';
      _desktopWindowOpened = false;
    });
  }

  Future<String> _linuxWebviewDataPath() async {
    final homeDirPath = await appPath.homeDirPath;
    return path.join(homeDirPath, 'payment_webview');
  }

  Future<void> _openLinuxPaymentWindow({bool auto = false}) async {
    final url = widget.paymentUrl;
    if (!_usingLinuxPaymentWindow || url == null || url.isEmpty || _openingPayment) {
      return;
    }
    setState(() {
      _openingPayment = true;
      if (auto) {
        _hint = '正在打开应用内支付窗口，请在窗口内完成支付。';
      }
    });
    try {
      _paymentSessionStartedAt = DateTime.now();
      _startPolling();
      final existingWindow = _linuxPaymentWindow;
      if (existingWindow != null) {
        await existingWindow.setWebviewWindowVisibility(true);
        existingWindow.launch(url);
        if (mounted) {
          setState(() {
            _desktopWindowOpened = true;
            _currentUrl = url;
            _webViewFailed = false;
          });
        }
        return;
      }
      final paymentWindow = await desktop_webview.WebviewWindow.create(
        configuration: desktop_webview.CreateConfiguration(
          userDataFolderWindows: await _linuxWebviewDataPath(),
        ),
      );
      paymentWindow
        ..launch(url)
        ..addOnUrlRequestCallback((url) {
          unawaited(_handleObservedUrl(url));
        });
      paymentWindow.onClose.whenComplete(() {
        final ignored = _ignoreNextLinuxWindowClose;
        _ignoreNextLinuxWindowClose = false;
        _linuxPaymentWindow = null;
        if (!mounted || _disposing || _completed || ignored) {
          return;
        }
        _markCancelled(message: '支付窗口已关闭，订单仍保留，可稍后恢复支付。');
      });
      if (!mounted) {
        paymentWindow.close();
        return;
      }
      setState(() {
        _linuxPaymentWindow = paymentWindow;
        _desktopWindowOpened = true;
        _currentUrl = url;
        _webViewFailed = false;
        _webProgress = 100;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _hint = '应用内支付窗口打开失败，可稍后重试。';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _openingPayment = false;
        });
      }
    }
  }

  Future<void> _resumePaymentFlow() async {
    if (_completed) {
      return;
    }
    if (mounted) {
      setState(() {
        _stage = _PaymentStage.pending;
        _hint = '订单已恢复，请继续完成支付。';
        _webViewFailed = false;
      });
    }
    _paymentSessionStartedAt = DateTime.now();
    _startPolling();
    if (_usingLinuxPaymentWindow) {
      await _openLinuxPaymentWindow();
      return;
    }
    await _reloadWebView();
  }

  Future<void> _reloadWebView() async {
    if (_usingFlutterWebView) {
      final controller = _flutterWebViewController;
      if (controller == null) {
        return;
      }
      setState(() {
        _webViewFailed = false;
        _webProgress = 0;
        _hint = '正在重新加载支付页面...';
      });
      await controller.reload();
      return;
    }
    if (_usingWindowsWebView) {
      final controller = _windowsWebViewController;
      if (controller == null) {
        await _initWindowsWebView();
        return;
      }
      setState(() {
        _webViewFailed = false;
        _webProgress = 0;
        _hint = '正在重新加载支付页面...';
      });
      await controller.reload();
      return;
    }
  }

  String _stageTitle() {
    return switch (_stage) {
      _PaymentStage.pending => '等待支付',
      _PaymentStage.checking => '确认支付中',
      _PaymentStage.success => '支付成功',
      _PaymentStage.failed => '状态确认失败',
      _PaymentStage.timeout => '支付超时',
      _PaymentStage.cancelled => '订单已保留',
    };
  }

  Color _stageColor() {
    return switch (_stage) {
      _PaymentStage.pending => const Color(0xFFB45309),
      _PaymentStage.checking => const Color(0xFF1D4ED8),
      _PaymentStage.success => const Color(0xFF047857),
      _PaymentStage.failed => const Color(0xFFB91C1C),
      _PaymentStage.timeout => const Color(0xFFB45309),
      _PaymentStage.cancelled => const Color(0xFF6B7280),
    };
  }

  Color _stageBackground() {
    return switch (_stage) {
      _PaymentStage.pending => const Color(0xFFFFF7ED),
      _PaymentStage.checking => const Color(0xFFEFF6FF),
      _PaymentStage.success => const Color(0xFFECFDF5),
      _PaymentStage.failed => const Color(0xFFFEF2F2),
      _PaymentStage.timeout => const Color(0xFFFFF7ED),
      _PaymentStage.cancelled => const Color(0xFFF3F4F6),
    };
  }

  String _webViewStatusText() {
    if (_usingLinuxPaymentWindow) {
      return _desktopWindowOpened ? '支付窗口已打开' : '支付窗口待恢复';
    }
    if (_canUseEmbeddedWebView) {
      return _webProgress >= 100 ? '支付页已就绪' : '支付页加载中 $_webProgress%';
    }
    return '客户端内支付不可用';
  }

  String _lastCheckedText() {
    final lastCheckedAt = _lastCheckedAt;
    if (lastCheckedAt == null) {
      return '尚未完成状态确认';
    }
    final hour = lastCheckedAt.hour.toString().padLeft(2, '0');
    final minute = lastCheckedAt.minute.toString().padLeft(2, '0');
    final second = lastCheckedAt.second.toString().padLeft(2, '0');
    return '最近检查时间 $hour:$minute:$second';
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.black, width: 2.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _stageBackground(),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _stageTitle(),
                  style: context.textTheme.labelLarge?.copyWith(
                    color: _stageColor(),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (_supportsClientSidePayment)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5F8),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    _webViewStatusText(),
                    style: context.textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF47505E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            widget.planName,
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _hint,
            style: context.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF6B7280),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          _PaymentSummaryRow(label: '订单号', value: widget.tradeNo),
          const SizedBox(height: 12),
          _PaymentSummaryRow(label: '计费周期', value: widget.periodLabel),
          const SizedBox(height: 12),
          _PaymentSummaryRow(label: '支付方式', value: widget.paymentMethodLabel),
          const SizedBox(height: 12),
          _PaymentSummaryRow(label: '支付金额', value: widget.amountText),
          const SizedBox(height: 12),
          Text(
            _lastCheckedText(),
            style: context.textTheme.bodySmall?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebViewCard(BuildContext context) {
    if (_usingLinuxPaymentWindow) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 18,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '支付窗口',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Linux 桌面端将使用应用内专用支付窗口完成支付。若你关闭窗口或支付超时，订单会保留，可直接恢复继续支付。',
              style: context.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FC),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _desktopWindowOpened
                            ? Icons.open_in_new_rounded
                            : Icons.web_asset_off_rounded,
                        color: const Color(0xFF47505E),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _desktopWindowOpened ? '支付窗口运行中' : '支付窗口未打开',
                        style: context.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  if (_currentUrl != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _currentUrl!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF6B7280),
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (!_canUseEmbeddedWebView) {
      return Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x10000000),
              blurRadius: 18,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '支付页面',
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '当前平台暂不支持客户端内支付页面。',
              style: context.textTheme.bodyMedium?.copyWith(
                color: const Color(0xFF9CA3AF),
              ),
            ),
          ],
        ),
      );
    }
    final flutterController = _flutterWebViewController;
    final windowsController = _windowsWebViewController;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            color: const Color(0xFFF8F9FC),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _currentUrl ?? widget.paymentUrl ?? '支付页面加载中',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: '刷新支付页',
                  onPressed: _reloadWebView,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
          ),
          if (_webProgress < 100)
            LinearProgressIndicator(
              value: _webProgress <= 0 ? null : _webProgress / 100,
              minHeight: 2,
            ),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: _usingFlutterWebView && flutterController != null
                      ? flutter_webview.WebViewWidget(
                          controller: flutterController,
                        )
                      : windowsController != null
                      ? windows_webview.Webview(windowsController)
                      : const Center(child: CircularProgressIndicator()),
                ),
                if (_webViewFailed)
                  Positioned.fill(
                    child: ColoredBox(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              size: 42,
                              color: Color(0xFFB91C1C),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '支付页加载失败',
                              style: context.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '可以刷新重试。',
                              textAlign: TextAlign.center,
                              style: context.textTheme.bodyMedium?.copyWith(
                                color: const Color(0xFF6B7280),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '支付操作',
            style: context.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _canUseEmbeddedWebView
                ? '支付流程已嵌入客户端内；若三方钱包需要唤起外部应用，返回后会继续自动确认订单。'
                : _usingLinuxPaymentWindow
                ? 'Linux 桌面端会打开应用内支付窗口；如果你关闭窗口、支付超时或临时离开，可稍后恢复订单继续支付。'
                : '当前平台暂不支持客户端内支付。',
            style: context.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 18),
          if (_isRecoverableStage && _hasPaymentUrl) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _openingPayment ? null : _resumePaymentFlow,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(_openingPayment ? '正在恢复支付...' : '恢复订单并继续支付'),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_usingLinuxPaymentWindow && widget.paymentUrl != null && widget.paymentUrl!.isNotEmpty) ...[
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _openingPayment ? null : () => _openLinuxPaymentWindow(),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  _openingPayment ? '正在打开支付窗口...' : '打开支付窗口',
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => _checkStatus(trigger: 'manual'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('我已完成支付，立即检查'),
            ),
          ),
          const SizedBox(height: 12),
          if (_stage != _PaymentStage.success && _stage != _PaymentStage.cancelled) ...[
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  if (_linuxPaymentWindow != null) {
                    _ignoreNextLinuxWindowClose = true;
                    try {
                      _linuxPaymentWindow?.close();
                    } catch (_) {}
                    _linuxPaymentWindow = null;
                  }
                  _markCancelled();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('稍后支付，保留订单'),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: widget.tradeNo));
                if (mounted) {
                  globalState.showNotifier('订单号已复制');
                }
              },
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('复制订单号'),
            ),
          ),
          if (_stage == _PaymentStage.success) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonal(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text('返回套餐页面'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= 980;
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F8),
        elevation: 0,
        centerTitle: false,
        title: const Text('支付确认'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: isWide
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 360,
                    child: ListView(
                      children: [
                        _buildSummaryCard(context),
                        const SizedBox(height: 18),
                        _buildActionCard(context),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(child: _buildWebViewCard(context)),
                ],
              )
            : ListView(
                children: [
                  _buildSummaryCard(context),
                  const SizedBox(height: 18),
                  SizedBox(height: 420, child: _buildWebViewCard(context)),
                  const SizedBox(height: 18),
                  _buildActionCard(context),
                ],
              ),
      ),
    );
  }
}

class _PaymentSummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _PaymentSummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: context.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF9CA3AF),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
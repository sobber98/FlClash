import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _authHintColor = Color(0xFFC3C8D1);

class V2BoardLoginView extends ConsumerStatefulWidget {
  final bool showRegisterAction;

  const V2BoardLoginView({
    super.key,
    this.showRegisterAction = true,
  });

  @override
  ConsumerState<V2BoardLoginView> createState() => _V2BoardLoginViewState();
}

class _V2BoardLoginViewState extends ConsumerState<V2BoardLoginView> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _obscureController = ValueNotifier<bool>(true);
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final props = ref.read(v2boardSettingProvider);
    _emailController = TextEditingController(text: props?.email ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _obscureController.dispose();
    super.dispose();
  }

  String _resolveServerUrl() {
    return resolveV2BoardServerUrl(
      configuredServerUrl: ref.read(appServerUrlProvider),
      props: ref.read(v2boardSettingProvider),
    );
  }

  void _showServerUnavailableTip() {
    globalState.showMessage(
      title: appLocalizations.tip,
      message: const TextSpan(text: '登录服务暂未配置，请联系管理员。'),
    );
  }

  Future<void> _syncSubscriptionAfterAuth() async {
    final errorMessage = await appController.syncV2BoardSubscription();
    if (!mounted || errorMessage == null) return;
    globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: errorMessage),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final serverUrl = _resolveServerUrl();
    if (serverUrl.isEmpty) {
      _showServerUnavailableTip();
      return;
    }
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final api = V2BoardApi(baseUrl: serverUrl);
      final auth = await api.login(email: email, password: password);

      ref.read(v2boardSettingProvider.notifier).value = V2BoardProps(
        serverUrl: serverUrl,
        authData: auth.authData,
        subscribeToken: auth.token,
        email: email,
        lastLoginDate: DateTime.now(),
      );

      ref
          .read(v2boardApiClientProvider.notifier)
          .init(serverUrl, authData: auth.authData);

      if (mounted) {
        await _syncSubscriptionAfterAuth();
      }
    } on V2BoardApiException catch (e) {
      if (mounted) {
        globalState.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(text: e.message),
        );
      }
    } catch (e) {
      if (mounted) {
        globalState.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(text: e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openRegisterPage() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const V2BoardRegisterPage()));
  }

  void _showForgotPasswordTip() {
    globalState.showNotifier('请联系管理员或客服重置密码');
  }

  @override
  Widget build(BuildContext context) {
    final configuredServer = ref.watch(appServerUrlProvider).trim();
    final storedProps = ref.watch(v2boardSettingProvider);
    final hasServerUrl =
        configuredServer.isNotEmpty ||
        ((storedProps?.serverUrl.trim().isNotEmpty) ?? false);
    final enableRegistration = ref.watch(appEnableRegistrationProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            const _AuthBrandIcon(),
            const SizedBox(height: 24),
            Text(
              '欢迎回来',
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: -0.8,
                color: context.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '请输入您的凭据以访问您的私人网络',
              textAlign: TextAlign.center,
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 36),
            if (!hasServerUrl) ...[
              const _AuthWarning(text: '登录服务暂未配置，请联系管理员。'),
              const SizedBox(height: 16),
            ],
            _AuthInput(
              controller: _emailController,
              hintText: '请输入邮箱地址',
              prefixIcon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入邮箱地址';
                }
                return null;
              },
            ),
            const SizedBox(height: 18),
            ValueListenableBuilder(
              valueListenable: _obscureController,
              builder: (_, obscure, _) {
                return _AuthInput(
                  controller: _passwordController,
                  hintText: '请输入密码',
                  prefixIcon: Icons.lock_outline_rounded,
                  obscureText: obscure,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 8) {
                      return appLocalizations.v2boardPasswordTip;
                    }
                    return null;
                  },
                  suffix: IconButton(
                    onPressed: () {
                      _obscureController.value = !obscure;
                    },
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: _authHintColor,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: hasServerUrl ? _showForgotPasswordTip : null,
                style: TextButton.styleFrom(
                  foregroundColor: context.colorScheme.onSurfaceVariant,
                ),
                child: const Text('忘记密码?'),
              ),
            ),
            const SizedBox(height: 10),
            _AuthPrimaryButton(
              label: '立即登录账户',
              onPressed: _isLoading || !hasServerUrl ? null : _login,
              isLoading: _isLoading,
            ),
            if (widget.showRegisterAction && enableRegistration) ...[
              const SizedBox(height: 24),
              const _AuthDivider(text: '新用户?'),
              const SizedBox(height: 24),
              _AuthSecondaryButton(
                label: '创建新账户',
                onPressed: _isLoading || !hasServerUrl ? null : _openRegisterPage,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class V2BoardRegisterPage extends ConsumerStatefulWidget {
  const V2BoardRegisterPage({super.key});

  @override
  ConsumerState<V2BoardRegisterPage> createState() =>
      _V2BoardRegisterPageState();
}

class _V2BoardRegisterPageState extends ConsumerState<V2BoardRegisterPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _inviteCodeController;
  late TextEditingController _emailCodeController;
  final _passwordObscureController = ValueNotifier<bool>(true);
  final _confirmObscureController = ValueNotifier<bool>(true);
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSendingCode = false;
  V2BoardCommConfig? _commConfig;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _inviteCodeController = TextEditingController();
    _emailCodeController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCommConfig();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _inviteCodeController.dispose();
    _emailCodeController.dispose();
    _passwordObscureController.dispose();
    _confirmObscureController.dispose();
    super.dispose();
  }

  String _resolveServerUrl() {
    return resolveV2BoardServerUrl(
      configuredServerUrl: ref.read(appServerUrlProvider),
      props: ref.read(v2boardSettingProvider),
    );
  }

  void _showServerUnavailableTip() {
    globalState.showMessage(
      title: appLocalizations.tip,
      message: const TextSpan(text: '注册服务暂未配置，请联系管理员。'),
    );
  }

  Future<void> _syncSubscriptionAfterAuth() async {
    final errorMessage = await appController.syncV2BoardSubscription();
    if (!mounted || errorMessage == null) return;
    globalState.showMessage(
      title: appLocalizations.tip,
      message: TextSpan(text: errorMessage),
    );
  }

  Future<void> _loadCommConfig() async {
    final serverUrl = _resolveServerUrl();
    if (serverUrl.isEmpty) return;
    try {
      final api = V2BoardApi(baseUrl: serverUrl);
      final config = await api.getGuestCommConfig();
      if (mounted) setState(() => _commConfig = config);
    } catch (_) {}
  }

  Future<void> _sendEmailCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;
    final serverUrl = _resolveServerUrl();
    if (serverUrl.isEmpty) {
      _showServerUnavailableTip();
      return;
    }
    setState(() => _isSendingCode = true);
    try {
      final api = V2BoardApi(baseUrl: serverUrl);
      await api.sendEmailVerify(email: email);
      if (mounted) {
        globalState.showNotifier(appLocalizations.v2boardEmailSent);
      }
    } catch (e) {
      if (mounted) {
        globalState.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(text: e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _isSendingCode = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final serverUrl = _resolveServerUrl();
    if (serverUrl.isEmpty) {
      _showServerUnavailableTip();
      return;
    }
    setState(() => _isLoading = true);
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      final api = V2BoardApi(baseUrl: serverUrl);
      final auth = await api.register(
        email: email,
        password: password,
        inviteCode: _inviteCodeController.text.trim(),
        emailCode: _emailCodeController.text.trim(),
      );

      ref.read(v2boardSettingProvider.notifier).value = V2BoardProps(
        serverUrl: serverUrl,
        authData: auth.authData,
        subscribeToken: auth.token,
        email: email,
        lastLoginDate: DateTime.now(),
      );

      ref
          .read(v2boardApiClientProvider.notifier)
          .init(serverUrl, authData: auth.authData);

      if (mounted) {
        Navigator.pop(context);
        await _syncSubscriptionAfterAuth();
      }
    } on V2BoardApiException catch (e) {
      if (mounted) {
        globalState.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(text: e.message),
        );
      }
    } catch (e) {
      if (mounted) {
        globalState.showMessage(
          title: appLocalizations.tip,
          message: TextSpan(text: e.toString()),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final configuredServer = ref.watch(appServerUrlProvider).trim();
    final storedProps = ref.watch(v2boardSettingProvider);
    final hasServerUrl =
        configuredServer.isNotEmpty ||
        ((storedProps?.serverUrl.trim().isNotEmpty) ?? false);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const _AuthBrandIcon(),
                    const SizedBox(height: 28),
                    Text(
                      '开启自由之旅',
                      textAlign: TextAlign.center,
                      style: context.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.8,
                        color: context.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '加入我们的全球隐私网络',
                      textAlign: TextAlign.center,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 36),
                    if (!hasServerUrl) ...[
                      const _AuthWarning(text: '注册服务暂未配置，请联系管理员。'),
                      const SizedBox(height: 16),
                    ],
                    _AuthInput(
                      controller: _emailController,
                      hintText: '请输入邮箱地址',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return '请输入邮箱地址';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),
                    ValueListenableBuilder(
                      valueListenable: _passwordObscureController,
                      builder: (_, obscure, _) {
                        return _AuthInput(
                          controller: _passwordController,
                          hintText: '请输入密码（至少8位）',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: obscure,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请输入密码';
                            }
                            if (value.length < 8) {
                              return appLocalizations.v2boardPasswordTip;
                            }
                            return null;
                          },
                          suffix: IconButton(
                            onPressed: () {
                              _passwordObscureController.value = !obscure;
                            },
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: _authHintColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    ValueListenableBuilder(
                      valueListenable: _confirmObscureController,
                      builder: (_, obscure, _) {
                        return _AuthInput(
                          controller: _confirmPasswordController,
                          hintText: '请再次输入密码',
                          prefixIcon: Icons.lock_outline_rounded,
                          obscureText: obscure,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '请再次输入密码';
                            }
                            if (value != _passwordController.text) {
                              return '两次输入的密码不一致';
                            }
                            return null;
                          },
                          suffix: IconButton(
                            onPressed: () {
                              _confirmObscureController.value = !obscure;
                            },
                            icon: Icon(
                              obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: _authHintColor,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    _AuthInput(
                      controller: _inviteCodeController,
                      hintText: '如有邀请码请输入（可选）',
                      prefixIcon: Icons.card_giftcard_outlined,
                      validator: _commConfig?.isInviteForce == true
                          ? (value) {
                              if (value == null || value.trim().isEmpty) {
                                return '请输入邀请码';
                              }
                              return null;
                            }
                          : null,
                    ),
                    if (_commConfig?.isEmailVerify == true) ...[
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _AuthInput(
                              controller: _emailCodeController,
                              hintText: '请输入邮箱验证码',
                              prefixIcon: Icons.verified_outlined,
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return '请输入邮箱验证码';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 60,
                            child: _AuthCompactButton(
                              label: _isSendingCode ? '发送中' : '发送验证码',
                              onPressed: _isSendingCode ? null : _sendEmailCode,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                    _AuthPrimaryButton(
                      label: '创建账户并开始',
                      onPressed: _isLoading || !hasServerUrl ? null : _register,
                      isLoading: _isLoading,
                    ),
                    const SizedBox(height: 24),
                    const _AuthDivider(text: '已有账户?'),
                    const SizedBox(height: 24),
                    _AuthSecondaryButton(
                      label: '返回登录页面',
                      onPressed: () => Navigator.of(context).maybePop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBrandIcon extends StatelessWidget {
  const _AuthBrandIcon();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: context.colorScheme.onSurface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Icon(
          Icons.shield_outlined,
          color: context.colorScheme.surface,
          size: 30,
        ),
      ),
    );
  }
}

class _AuthWarning extends StatelessWidget {
  final String text;

  const _AuthWarning({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: context.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

class _AuthDivider extends StatelessWidget {
  final String text;

  const _AuthDivider({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Divider(color: context.colorScheme.outlineVariant)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            text,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(child: Divider(color: context.colorScheme.outlineVariant)),
      ],
    );
  }
}

class _AuthInput extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _AuthInput({
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: context.colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: context.colorScheme.onSurfaceVariant),
        prefixIcon: Icon(prefixIcon, color: context.colorScheme.onSurfaceVariant),
        suffixIcon: suffix,
        filled: true,
        fillColor: context.colorScheme.surfaceContainerHighest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: context.colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: context.colorScheme.onSurface, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: context.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: context.colorScheme.error, width: 1.5),
        ),
      ),
    );
  }
}

class _AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: context.colorScheme.onSurface,
        foregroundColor: context.colorScheme.surface,
        minimumSize: const Size.fromHeight(56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        elevation: 0,
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: context.colorScheme.surface,
              ),
            )
          : Text(
              label,
              style: context.textTheme.titleMedium?.copyWith(
                color: context.colorScheme.surface,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }
}

class _AuthSecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _AuthSecondaryButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        foregroundColor: context.colorScheme.onSurfaceVariant,
        side: BorderSide(color: context.colorScheme.outlineVariant, width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Text(
        label,
        style: context.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: context.colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _AuthCompactButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _AuthCompactButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: context.colorScheme.onSurface,
        foregroundColor: context.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      child: Text(label),
    );
  }
}

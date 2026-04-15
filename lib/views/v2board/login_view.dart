import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/controller.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/services/v2board/v2board.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class V2BoardLoginView extends ConsumerStatefulWidget {
  const V2BoardLoginView({super.key});

  @override
  ConsumerState<V2BoardLoginView> createState() => _V2BoardLoginViewState();
}

class _V2BoardLoginViewState extends ConsumerState<V2BoardLoginView> {
  late TextEditingController _serverController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final _obscureController = ValueNotifier<bool>(true);
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final props = ref.read(v2boardSettingProvider);
    _serverController = TextEditingController(text: props?.serverUrl ?? '');
    _emailController = TextEditingController(text: props?.email ?? '');
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _serverController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _obscureController.dispose();
    super.dispose();
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
    setState(() => _isLoading = true);
    try {
      final serverUrl = _serverController.text.trim();
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

      ref.read(v2boardApiClientProvider.notifier).init(
            serverUrl,
            authData: auth.authData,
          );

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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Icon(
              Icons.cloud_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'V2Board',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              appLocalizations.v2boardLoginDesc,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextFormField(
              controller: _serverController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.dns),
                border: const OutlineInputBorder(),
                labelText: appLocalizations.v2boardServer,
                hintText: 'https://example.com/api/v1',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.emptyTip(
                      appLocalizations.v2boardServer);
                }
                if (!value.startsWith('http')) {
                  return appLocalizations.v2boardServerTip;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email),
                border: const OutlineInputBorder(),
                labelText: appLocalizations.email,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return appLocalizations.emptyTip(appLocalizations.email);
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: _obscureController,
              builder: (_, obscure, _) {
                return TextFormField(
                  controller: _passwordController,
                  obscureText: obscure,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.password),
                    border: const OutlineInputBorder(),
                    labelText: appLocalizations.password,
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        _obscureController.value = !obscure;
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return appLocalizations.emptyTip(
                          appLocalizations.password);
                    }
                    if (value.length < 8) {
                      return appLocalizations.v2boardPasswordTip;
                    }
                    return null;
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(appLocalizations.v2boardLogin),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _isLoading
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const V2BoardRegisterPage(),
                        ),
                      );
                    },
              child: Text(appLocalizations.v2boardRegister),
            ),
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
  late TextEditingController _serverController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _inviteCodeController;
  late TextEditingController _emailCodeController;
  final _obscureController = ValueNotifier<bool>(true);
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isSendingCode = false;
  V2BoardCommConfig? _commConfig;

  @override
  void initState() {
    super.initState();
    final props = ref.read(v2boardSettingProvider);
    _serverController = TextEditingController(text: props?.serverUrl ?? '');
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _inviteCodeController = TextEditingController();
    _emailCodeController = TextEditingController();
    _loadCommConfig();
  }

  @override
  void dispose() {
    _serverController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _inviteCodeController.dispose();
    _emailCodeController.dispose();
    _obscureController.dispose();
    super.dispose();
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
    final serverUrl = _serverController.text.trim();
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
    setState(() => _isSendingCode = true);
    try {
      final api = V2BoardApi(baseUrl: _serverController.text.trim());
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
    setState(() => _isLoading = true);
    try {
      final serverUrl = _serverController.text.trim();
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

      ref.read(v2boardApiClientProvider.notifier).init(
            serverUrl,
            authData: auth.authData,
          );

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
    return Scaffold(
      appBar: AppBar(title: Text(appLocalizations.v2boardRegister)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _serverController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.dns),
                  border: const OutlineInputBorder(),
                  labelText: appLocalizations.v2boardServer,
                  hintText: 'https://example.com/api/v1',
                ),
                onChanged: (_) => _loadCommConfig(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return appLocalizations.emptyTip(
                        appLocalizations.v2boardServer);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  border: const OutlineInputBorder(),
                  labelText: appLocalizations.email,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return appLocalizations.emptyTip(appLocalizations.email);
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ValueListenableBuilder(
                valueListenable: _obscureController,
                builder: (_, obscure, _) {
                  return TextFormField(
                    controller: _passwordController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.password),
                      border: const OutlineInputBorder(),
                      labelText: appLocalizations.password,
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscure ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          _obscureController.value = !obscure;
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return appLocalizations.emptyTip(
                            appLocalizations.password);
                      }
                      if (value.length < 8) {
                        return appLocalizations.v2boardPasswordTip;
                      }
                      return null;
                    },
                  );
                },
              ),
              if (_commConfig?.isInviteForce == true ||
                  _commConfig != null) ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _inviteCodeController,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.card_giftcard),
                    border: const OutlineInputBorder(),
                    labelText: appLocalizations.v2boardInviteCode,
                  ),
                  validator: _commConfig?.isInviteForce == true
                      ? (value) {
                          if (value == null || value.isEmpty) {
                            return appLocalizations.emptyTip(
                                appLocalizations.v2boardInviteCode);
                          }
                          return null;
                        }
                      : null,
                ),
              ],
              if (_commConfig?.isEmailVerify == true) ...[
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _emailCodeController,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.verified),
                          border: const OutlineInputBorder(),
                          labelText: appLocalizations.v2boardEmailCode,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return appLocalizations.emptyTip(
                                appLocalizations.v2boardEmailCode);
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      height: 56,
                      child: FilledButton.tonal(
                        onPressed: _isSendingCode ? null : _sendEmailCode,
                        child: _isSendingCode
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : Text(appLocalizations.v2boardSendCode),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _isLoading ? null : _register,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(appLocalizations.v2boardRegister),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

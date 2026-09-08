import 'package:flutter/material.dart';

import 'networking/api_client.dart';
import 'networking/token_store.dart';
import 'shared/widgets/app_shell.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PTACollectApp());
}

class PTACollectApp extends StatefulWidget {
  const PTACollectApp({super.key});

  @override
  State<PTACollectApp> createState() => _PTACollectAppState();
}

class _PTACollectAppState extends State<PTACollectApp> {
  final ApiClient _api = ApiClient();
  final TokenStore _tokenStore = TokenStore();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _authenticated = false;
  bool _checking = true;
  bool _loading = false;
  bool _obscurePassword = true;
  String? _userRole;
  String? _userName;

  @override
  void initState() {
    super.initState();
    authExpired.addListener(_onAuthExpired);
    _checkExistingToken();
  }

  void _onAuthExpired() {
    if (!authExpired.value) return;
    if (mounted) {
      setState(() {
        _authenticated = false;
        _userRole = null;
        _userName = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please sign in again.'),
        ),
      );
    }
    authExpired.value = false;
  }

  Future<void> _checkExistingToken() async {
    final token = await _tokenStore.getToken();
    if (token != null) {
      try {
        final response = await _api.get('/auth/me');
        if (response.statusCode == 200) {
          final body = response.data;
          if (body is Map) {
            final user = body['data'];
            if (user is Map) {
              _userRole = user['role']?.toString();
              _userName = user['name']?.toString();
            }
          }
          setState(() {
            _authenticated = true;
            _checking = false;
          });
          return;
        }
      } catch (_) {}
    }
    setState(() => _checking = false);
  }

  @override
  void dispose() {
    authExpired.removeListener(_onAuthExpired);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      debugPrint('[LOGIN] Posting to /auth/login ...');
      final response = await _api
          .post(
            '/auth/login',
            data: {
              'email': _emailController.text.trim(),
              'password': _passwordController.text,
              'device_name': 'flutter',
            },
          )
          .timeout(const Duration(seconds: 15));

      final body = response.data;
      debugPrint('[LOGIN] success=${body is Map ? body['success'] : 'n/a'}');

      if (body is! Map) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unexpected response format from server.'),
            ),
          );
        }
        return;
      }

      if (body['success'] == true) {
        final data = body['data'];
        final token = data is Map ? data['access_token'] as String? : null;
        if (token == null || token.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('No token received from server.')),
            );
          }
          return;
        }
        await _tokenStore.saveToken(token);
        debugPrint('[LOGIN] Token saved, navigating to dashboard');
        final user = data['user'];
        if (user is Map) {
          _userRole = user['role']?.toString();
          _userName = user['name']?.toString();
        }
        if (mounted) {
          setState(() => _authenticated = true);
        }
      } else {
        final msg = body['message']?.toString() ?? 'Login failed';
        debugPrint('[LOGIN] Server rejected: $msg');
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(msg)));
        }
      }
    } catch (e) {
      debugPrint('[LOGIN] failed: ${e.runtimeType}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to sign in. Check your connection and try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _tokenStore.clear();
    if (mounted) {
      setState(() {
        _authenticated = false;
        _userRole = null;
        _userName = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PTA Collect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: _checking
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          : _authenticated
          ? AppShell(
              apiClient: _api,
              userRole: _userRole,
              userName: _userName,
              onLogout: _logout,
            )
          : _buildLoginScreen(),
    );
  }

  Widget _buildLoginScreen() {
    return Scaffold(
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.account_balance_wallet,
                size: 48,
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'PTA Collect',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sign in to access the dashboard',
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.textPrimary),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.background,
                                ),
                              )
                            : const Text('Sign In'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/auth_service.dart';
import '../logic/validators.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_text_field.dart';

import 'menu_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _auth = AuthService();

  bool _loading = false;
  bool _resetLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading || _resetLoading) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final result = await _auth.loginWithFirebase(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (!mounted) return;

      final user = result.user;

      if (user == null || user.role == 'admin') {
        _show(
          result.error ?? 'Login failed. Please try again.',
          Colors.redAccent,
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MenuScreen(user: user),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        _show('Login failed: $e', Colors.redAccent);
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _forgotPassword() async {
    if (_resetLoading || _loading) return;

    if (_emailCtrl.text.trim().isEmpty ||
        Validators.email(_emailCtrl.text) != null) {
      _show(
        'Please enter your registered email address first.',
        Colors.redAccent,
      );
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() => _resetLoading = true);

    try {
      final error = await _auth.sendPasswordResetEmail(
        _emailCtrl.text.trim(),
      );

      if (!mounted) return;

      if (error == null) {
        _show(
          'Password reset link sent. Check your email.',
          Colors.green,
        );
      } else {
        _show(error, Colors.redAccent);
      }
    } catch (e) {
      if (mounted) {
        _show(
          'Unable to send reset email: $e',
          Colors.redAccent,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _resetLoading = false);
      }
    }
  }

  void _show(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF080B18),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF080B18),
                Color(0xFF101D35),
                Color(0xFF080B18),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode:
                    AutovalidateMode.disabled,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.videogame_asset_rounded,
                          size: 65,
                          color: AppTheme.neonCyan,
                          shadows: [
                            Shadow(
                              color: AppTheme.neonCyan,
                              blurRadius: 22,
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        const Text(
                          'NEON XO',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 5,
                            color: AppTheme.neonCyan,
                            shadows: [
                              Shadow(
                                color: AppTheme.neonCyan,
                                blurRadius: 18,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'WELCOME BACK, PLAYER!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppTheme.neonYellow,
                            fontSize: 13,
                            letterSpacing: 2,
                          ),
                        ),

                        const SizedBox(height: 35),

                        const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            color: AppTheme.neonCyan,
                            shadows: [
                              Shadow(
                                color: AppTheme.neonCyan,
                                blurRadius: 14,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        NeonTextField(
                          controller: _emailCtrl,
                          label: 'Email',
                          hint: 'example@gmail.com',
                          tooltip:
                          'Enter your registered email address',
                          icon: Icons.email,
                          keyboardType:
                          TextInputType.emailAddress,
                          maxLength: 40,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(40),
                          ],
                          validateOnBlur: true,
                          validator: Validators.email,
                        ),

                        const SizedBox(height: 18),

                        NeonTextField(
                          controller: _passCtrl,
                          label: 'Password',
                          hint: 'Enter your password',
                          tooltip:
                          'Enter your registered password',
                          icon: Icons.lock,
                          isPassword: true,
                          maxLength: 40,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(40),
                          ],
                          validateOnBlur: true,
                          validator: (v) =>
                          (v == null || v.isEmpty)
                              ? 'Password is required'
                              : null,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                            (_resetLoading || _loading)
                                ? null
                                : _forgotPassword,
                            child: _resetLoading
                                ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2,
                                color:
                                AppTheme.neonCyan,
                              ),
                            )
                                : const Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color:
                                AppTheme.neonCyan,
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 18),

                        NeonButton(
                          text: 'LOGIN',
                          loading: _loading,
                          onPressed:
                          (_loading || _resetLoading)
                              ? null
                              : _submit,
                        ),

                        const SizedBox(height: 18),

                        TextButton(
                          onPressed:
                          (_loading || _resetLoading)
                              ? null
                              : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Don't have an account? Sign up",
                            style: TextStyle(
                              color: AppTheme.neonCyan,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
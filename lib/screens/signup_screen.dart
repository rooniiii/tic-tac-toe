import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart'
as phone_parser;

import '../logic/auth_service.dart';
import '../logic/validators.dart';
import '../theme/app_theme.dart';
import '../widgets/neon_button.dart';
import '../widgets/neon_text_field.dart';
import '../widgets/password_checklist.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  final _confirmFieldKey = GlobalKey<FormFieldState<String>>();

  final _auth = AuthService();

  String _completePhone = '';
  String _selectedCountryIso = 'PK';

  dynamic _phoneValue;
  String? _phoneError;

  bool _phoneTouched = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(_handlePasswordChange);
  }

  void _handlePasswordChange() {
    if (_confirmCtrl.text.isNotEmpty) {
      _confirmFieldKey.currentState?.validate();
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }

    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }

    if (value.trim().length > 40) {
      return 'Name must be at most 40 characters';
    }

    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(value.trim())) {
      return 'Only alphabets are allowed';
    }

    return null;
  }

  String? _validatePhone(dynamic phone) {
    if (phone == null || phone.number.trim().isEmpty) {
      return 'Phone number is required';
    }

    final enteredNumber = phone.number.trim();

    if (_selectedCountryIso == 'PK' &&
        !enteredNumber.startsWith('3')) {
      return 'Pakistan mobile number must start with 3';
    }

    try {
      final parsedPhone = phone_parser.PhoneNumber.parse(
        phone.completeNumber,
      );

      final isValidMobile = parsedPhone.isValid();

      if (!isValidMobile) {
        return 'Enter a valid mobile number for this country';
      }

      return null;
    } catch (_) {
      return 'Enter a valid mobile number for this country';
    }
  }

  void _validatePhoneOnBlur() {
    if (!_phoneTouched || _phoneCtrl.text.trim().isEmpty) {
      return;
    }

    setState(() {
      _phoneError = _validatePhone(_phoneValue);
    });
  }

  @override
  void dispose() {
    _passCtrl.removeListener(_handlePasswordChange);

    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (_loading) return;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_completePhone.isEmpty) {
      _show('Please enter your phone number.', Colors.redAccent);
      return;
    }

    setState(() => _loading = true);

    try {
      final error = await _auth
          .signUpWithFirebase(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _completePhone,
        password: _passCtrl.text,
      )
          .timeout(const Duration(seconds: 75));

      if (!mounted) return;

      if (error != null) {
        setState(() => _loading = false);
        _show(error, Colors.redAccent);
        return;
      }

      setState(() => _loading = false);

      _show(
        'Verification email sent! Please check your inbox and verify your email before logging in.',
        Colors.green,
      );

      await Future.delayed(
        const Duration(milliseconds: 700),
      );

      if (!mounted) return;

      Navigator.pop(context);
    } on TimeoutException {
      if (!mounted) return;

      setState(() => _loading = false);

      _show(
        'Signup is taking too long. Check your internet and try again.',
        Colors.redAccent,
      );
    } catch (e) {
      if (!mounted) return;

      setState(() => _loading = false);

      _show(
        'Signup failed: $e',
        Colors.redAccent,
      );
    }
  }

  void _show(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  OutlineInputBorder _phoneBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(
        color: color,
        width: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090616),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090616),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppTheme.neonCyan,
          ),
          onPressed: _loading
              ? null
              : () => Navigator.pop(context),
        ),
        title: const Text(
          'NEON XO',
          style: TextStyle(
            color: AppTheme.neonCyan,
            fontWeight: FontWeight.bold,
            letterSpacing: 3,
            shadows: [
              Shadow(
                color: AppTheme.neonCyan,
                blurRadius: 12,
              ),
            ],
          ),
        ),
        centerTitle: true,
      ),
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
                Color(0xFF090616),
                Color(0xFF170D32),
                Color(0xFF090616),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
                ),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.disabled,
                  child: Column(
                    children: [
                      const Icon(
                        Icons.videogame_asset_rounded,
                        size: 58,
                        color: AppTheme.neonPink,
                        shadows: [
                          Shadow(
                            color: AppTheme.neonPink,
                            blurRadius: 20,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        'CREATE ACCOUNT',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: AppTheme.neonYellow,
                          shadows: [
                            Shadow(
                              color: AppTheme.neonYellow,
                              blurRadius: 14,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'Join the NEON XO gaming world',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppTheme.neonCyan,
                          fontSize: 13,
                          letterSpacing: 1,
                        ),
                      ),

                      const SizedBox(height: 30),

                      // NAME
                      NeonTextField(
                        controller: _nameCtrl,
                        label: 'Name',
                        hint: 'Enter your name',
                        tooltip: 'Only letters, 3 to 40 characters',
                        icon: Icons.person,
                        maxLength: 40,
                        helperText: 'Maximum 40 characters',
                        validateOnBlur: true,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z ]'),
                          ),
                        ],
                        validator: _validateName,
                      ),

                      const SizedBox(height: 18),

                      // EMAIL
                      NeonTextField(
                        controller: _emailCtrl,
                        label: 'Email',
                        hint: 'example@gmail.com',
                        tooltip: 'Enter a valid email address',
                        icon: Icons.email,
                        keyboardType: TextInputType.emailAddress,
                        maxLength: 40,
                        helperText: 'Maximum 40 characters',
                        validateOnBlur: true,
                        validator: Validators.email,
                      ),

                      const SizedBox(height: 18),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: const [
                            Icon(
                              Icons.phone,
                              color: AppTheme.neonCyan,
                              size: 19,
                            ),
                            SizedBox(width: 9),
                            Text(
                              'Phone number',
                              style: TextStyle(
                                color: AppTheme.neonCyan,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 9),

                      Focus(
                        onFocusChange: (hasFocus) {
                          if (hasFocus) {
                            _phoneTouched = true;
                          } else {
                            _validatePhoneOnBlur();
                          }
                        },
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            dialogBackgroundColor:
                            const Color(0xFF170D32),
                            colorScheme:
                            Theme.of(context).colorScheme.copyWith(
                              primary: AppTheme.neonCyan,
                              surface: const Color(0xFF170D32),
                            ),
                          ),
                          child: IntlPhoneField(
                            controller: _phoneCtrl,
                            initialCountryCode: 'PK',
                            languageCode: 'en',
                            showDropdownIcon: true,
                            dropdownIcon: const Icon(
                              Icons.arrow_drop_down,
                              color: AppTheme.neonCyan,
                            ),
                            dropdownIconPosition:
                            IconPosition.trailing,
                            flagsButtonPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _CountryPhoneInputFormatter(
                                countryIso: _selectedCountryIso,
                              ),
                            ],
                            autovalidateMode:
                            AutovalidateMode.disabled,
                            invalidNumberMessage:
                            'Enter a valid mobile number',
                            validator: _validatePhone,
                            onCountryChanged: (country) {
                              setState(() {
                                _selectedCountryIso = country.code;
                              });

                              _validatePhoneOnBlur();
                            },
                            onChanged: (phone) {
                              _phoneValue = phone;
                              _completePhone = phone.completeNumber;

                              if (_phoneTouched && _phoneError != null) {
                                setState(() {
                                  _phoneError = _validatePhone(phone);
                                });
                              }
                            },
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                            ),
                            dropdownTextStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            cursorColor: AppTheme.neonCyan,
                            decoration: InputDecoration(
                              hintText: 'Enter phone number',
                              errorText: _phoneError,
                              hintStyle: const TextStyle(
                                color: Colors.white54,
                              ),
                              filled: true,
                              fillColor: const Color(0xFF120B27),
                              contentPadding:
                              const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 17,
                              ),
                              enabledBorder: _phoneBorder(
                                AppTheme.purple,
                              ),
                              focusedBorder: _phoneBorder(
                                AppTheme.neonCyan,
                              ),
                              errorBorder: _phoneBorder(
                                Colors.redAccent,
                              ),
                              focusedErrorBorder: _phoneBorder(
                                Colors.redAccent,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // PASSWORD
                      NeonTextField(
                        controller: _passCtrl,
                        label: 'Password',
                        hint: 'Enter strong password',
                        tooltip:
                        '8-40 chars: capital, small, digit, special',
                        icon: Icons.lock,
                        isPassword: true,
                        maxLength: 40,
                        helperText: 'Maximum 40 characters',
                        validateOnBlur: true,
                        validator: Validators.password,
                      ),

                      const SizedBox(height: 10),

                      PasswordChecklist(
                        controller: _passCtrl,
                      ),

                      const SizedBox(height: 12),

                      // CONFIRM PASSWORD
                      NeonTextField(
                        controller: _confirmCtrl,
                        fieldKey: _confirmFieldKey,
                        label: 'Confirm password',
                        hint: 'Retype password',
                        tooltip: 'Must match the password above',
                        icon: Icons.lock_outline,
                        isPassword: true,
                        maxLength: 40,
                        helperText: 'Maximum 40 characters',
                        validateOnBlur: true,
                        validateWhileTyping: true,
                        validator: (value) =>
                            Validators.confirmPassword(
                              value,
                              _passCtrl.text,
                            ),
                      ),

                      const SizedBox(height: 28),

                      if (_loading) ...[
                        const CircularProgressIndicator(
                          color: AppTheme.neonCyan,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Creating your account...',
                          style: TextStyle(
                            color: AppTheme.neonYellow,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      NeonButton(
                        text: 'SIGN UP',
                        loading: _loading,
                        onPressed: _loading ? null : _submit,
                      ),

                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.pop(context),
                        child: const Text(
                          'Already have an account? Login',
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
    );
  }
}

class _CountryPhoneInputFormatter extends TextInputFormatter {
  final String countryIso;

  _CountryPhoneInputFormatter({
    required this.countryIso,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (countryIso == 'PK' &&
        newValue.text.isNotEmpty &&
        newValue.text.startsWith('0')) {
      return oldValue;
    }

    return newValue;
  }
}
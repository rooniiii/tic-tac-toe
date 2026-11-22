class Validators {
  static String? name(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Name is required';
    }
    if (v.trim().length < 3) {
      return 'Name must be at least 3 letters';
    }
    if (v.trim().length > 40) {
      return 'Name must be at most 40 characters';
    }
    if (!RegExp(r'^[a-zA-Z ]+$').hasMatch(v.trim())) {
      return 'Only alphabets are allowed';
    }
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Email is required';
    }
    if (v.trim().length > 40) {
      return 'Email must be at most 40 characters';
    }
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
        .hasMatch(v.trim())) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? phone(String? v) {
    if (v == null || v.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
      return 'Only digits are allowed';
    }
    if (v.length != 11) {
      return 'Phone number must be 11 digits';
    }
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) {
      return 'Password is required';
    }

    final ok = v.length >= 8 &&
        v.length <= 40 &&
        RegExp(r'[A-Z]').hasMatch(v) &&
        RegExp(r'[a-z]').hasMatch(v) &&
        RegExp(r'[0-9]').hasMatch(v) &&
        RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-]').hasMatch(v);

    return ok ? null : 'Password does not meet all the rules';
  }

  static String? confirmPassword(String? v, String original) {
    if (v == null || v.isEmpty) {
      return 'Please retype the password';
    }
    if (v.length > 40) {
      return 'Password must be at most 40 characters';
    }
    if (v != original) {
      return 'Passwords do not match';
    }
    return null;
  }
}
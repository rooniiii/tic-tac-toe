/// Cleans free text before it is stored, displayed or sent anywhere.
///
/// * Removes control characters (except new lines and tabs) that could break
///   layouts or logs.
/// * Hard-limits the length, so oversized input can never reach a buffer,
///   the database or an API (defence against overflow / resource abuse).
///
/// Firestore and Drift never build query strings from user text (all values
/// are passed as parameters), so SQL injection is not possible; this class
/// is an extra layer for everything that is shown or sent as text.
class InputSanitizer {
  static final RegExp _controlChars =
      RegExp(r'[\u0000-\u0008\u000B\u000C\u000E-\u001F\u007F]');

  static String clean(String input, {required int maxLength}) {
    var text = input.replaceAll(_controlChars, '').trim();

    if (text.length > maxLength) {
      text = text.substring(0, maxLength);
    }

    return text;
  }

  /// Accepts only plain https links (used for ad images).
  static bool isSafeHttpsUrl(String? value, {int maxLength = 500}) {
    if (value == null || value.isEmpty || value.length > maxLength) {
      return false;
    }
    final uri = Uri.tryParse(value);
    return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
  }
}

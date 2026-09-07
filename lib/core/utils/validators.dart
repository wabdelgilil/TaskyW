/// دوال مساعدة للتحقق من صحة المدخلات.
class Validators {
  Validators._();

  static final RegExp _hexColorRegex = RegExp(
    r'^#?([0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})$',
  );

  static final RegExp _emailRegex = RegExp(
    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
  );

  /// التحقق من عدم فراغ النص بعد إزالة المسافات البادئة واللاحقة.
  static bool isNotEmpty(String? value) {
    if (value == null) return false;
    return value.trim().isNotEmpty;
  }

  /// التحقق من صحة كود اللون HEX بصيغتَي (#RRGGBB | #RGB).
  static bool isValidHexColor(String? value) {
    if (value == null) return false;
    return _hexColorRegex.hasMatch(value.trim());
  }

  /// التحقق من صحة الرابط (يجب أن يبدأ بـ http أو https وأن يحتوي على مضيف).
  static bool isValidUrl(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    final uri = Uri.tryParse(value.trim());
    if (uri == null) return false;
    return (uri.scheme == 'http' || uri.scheme == 'https') && uri.host.isNotEmpty;
  }

  /// التحقق من صحة البريد الإلكتروني بصيغة مبسطة.
  static bool isValidEmail(String? value) {
    if (value == null || value.trim().isEmpty) return false;
    return _emailRegex.hasMatch(value.trim());
  }
}
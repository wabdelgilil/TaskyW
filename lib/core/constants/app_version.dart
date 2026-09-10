/// ثابت الإصدار المعتمد للتطبيق.
///
/// يجب مزامنته دائماً مع `pubspec.yaml` (سطر `version:`) عند كل ترقية.
class AppVersion {
  AppVersion._();

  /// إصدار التطبيق المعروض في الواجهات (شاشة البروفايل/الإعدادات وحول التطبيق).
  static const String version = '3.0.0+1';

  /// رقم الإصدار القرائي (بدون رقم البناء) للعرض المُبسّط.
  static const String shortVersion = '3.0.0';
}
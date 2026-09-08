import 'package:flutter/foundation.dart';

/// مساعدة لبناء روابط المشاركة والتنقل الحقيقية المتوافقة مع الويب والمنصات الأخرى
class UrlHelper {
  UrlHelper._();

  /// توليد رابط المشاركة العام الحقيقي بناءً على عنوان الموقع الحالي إن كان ويب
  /// أو رابط افتراضي إن كان تطبيقاً سطح مكتب / موبايل
  static String buildShareUrl(String shareToken) {
    if (kIsWeb) {
      final base = Uri.base;
      // في Flutter Web، المسار قد يكون hash (#/share/...) أو path (/share/...)
      // نأخذ الـ origin الحقيقي (مثلاً: http://localhost:5000 أو https://your-domain.vercel.app)
      final portPart = (base.hasPort && base.port != 80 && base.port != 443) ? ':${base.port}' : '';
      final origin = '${base.scheme}://${base.host}$portPart';
      
      // إذا كان التطبيق يستخدم HashUrlStrategy (وهو الافتراضي في flutter web)
      return '$origin/#/share/$shareToken';
    }

    // للمنصات الأخرى خارج المتصفح (مكتبي / أندرويد / iOS)
    return 'https://taskyw.app/#/share/$shareToken';
  }
}

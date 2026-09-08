import 'package:flutter/material.dart';

/// نظام الألوان الموحد لتطبيق TaskyW
/// يدعم الثيم المزدوج (Dark Slate & Crisp Light) وهوية العلامة التجارية الزرقاء المتدرجة.
class AppColors {
  // --- هوية العلامة التجارية (TaskyW Brand Identity) ---
  static const Color brandPrimary = Color(0xFF0284C7);  // Vibrant Sky/Tasky Blue
  static const Color brandLight = Color(0xFF38BDF8);    // Arrow Cyan Light
  static const Color brandDeep = Color(0xFF0A4C8A);     // Deep Royal Typography Blue
  static const Color brandDeepDark = Color(0xFF083358); // Midnight Navy

  /// تدرج الهوية البصرية للشعار والسهم
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFF0B4684),
      Color(0xFF145DA0),
      Color(0xFF237AB9),
      Color(0xFF349ED5),
      Color(0xFF49B7E3),
    ],
  );

  /// تدرج هادئ وخفيف للأزرار والبطاقات
  static const LinearGradient brandGradientSimple = LinearGradient(
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
    colors: [
      Color(0xFF0284C7),
      Color(0xFF38BDF8),
    ],
  );

  // --- وضع السواد العميق (OLED Pure Black Palette) ---
  static const Color oledBackground = Color(0xFF000000); // Absolute Pure Black
  static const Color oledSurface = Color(0xFF101216);    // Deep Obsidian Card
  static const Color oledCard = Color(0xFF161920);       // Elevated Obsidian Slate
  static const Color oledBorder = Color(0xFF262C36);     // Crisp Border 
  static const Color oledTextPrimary = Color(0xFFFFFFFF); // 100% Pure White
  static const Color oledTextSecondary = Color(0xFFE2E8F0); // Crisp Bright Silver
  static const Color oledTextMuted = Color(0xFF94A3B8);   // Muted Slate

  // --- الوضع الليلي (Dark Slate Palette) ---
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B);    // Slate 800
  static const Color darkCard = Color(0xFF243247);       // Elevated Card Slate
  static const Color darkBorder = Color(0xFF334155);     // Slate 700
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50 (أبيض ناصع عالي التباين)
  static const Color darkTextSecondary = Color(0xFFCBD5E1); // Slate 300 (أفتح وأوضح بكثير للقراءة المريحة)
  static const Color darkTextMuted = Color(0xFF94A3B8);   // Slate 400 (بدل 500 الغامق جداً)

  // --- الوضع النهاري (Crisp Light Palette) ---
  static const Color lightBackground = Color(0xFFF1F5F9); // Slate 100 (تباين أوضح مع الكروت البيضاء)
  static const Color lightSurface = Color(0xFFFFFFFF);    // Pure White
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF8FAFC); // Slate 50 (خلفية ناعمة لأعمدة الكانبان)
  static const Color lightBorder = Color(0xFFCBD5E1);     // Slate 300 (حدود واضحة ومحددة بدلاً من الرمادي الباهت)
  static const Color lightBorderStrong = Color(0xFF94A3B8); // Slate 400 (حدود أقوى للفواصل والأعمدة)
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF334155); // Slate 700 (أغمق وأكثر حدة ووضوحاً بدلاً من الرمادي الباهت)
  static const Color lightTextMuted = Color(0xFF64748B);   // Slate 500 (أكثر قتامة وقراءة مريحة للعين)

  // --- ألوان الأولويات (Priority Accents) ---
  static const Color priorityUrgent = Color(0xFFEF4444);  // Red 500
  static const Color priorityHigh = Color(0xFFF97316);    // Orange 500
  static const Color priorityMedium = Color(0xFF3B82F6);  // Blue 500
  static const Color priorityLow = Color(0xFF10B981);     // Emerald 500

  // --- ألوان الحالات (Task Status Accents) ---
  static const Color statusTodo = Color(0xFF64748B);        // Slate 500
  static const Color statusInProgress = Color(0xFF3B82F6);  // Blue 500
  static const Color statusWaiting = Color(0xFFF59E0B);     // Amber 500
  static const Color statusReview = Color(0xFF8B5CF6);      // Purple 500
  static const Color statusCompleted = Color(0xFF10B981);   // Emerald 500

  // --- دوال الألوان المتكيفة الحادة (Adaptive High-Contrast Helpers) ---

  /// لون الحالة المتكيف: يمنح ألواناً زاهية وفاتحة في الليلي (Cyan/Sky/Lime) وألواناً عميقة في النهاري
  static Color adaptiveStatusColor(String status, bool isDark) {
    switch (status.toLowerCase()) {
      case 'in_progress':
        return isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7); // Sky 400 vs Sky 600
      case 'waiting':
        return isDark ? const Color(0xFFFBBF24) : const Color(0xFFD97706); // Amber 400 vs Amber 600
      case 'review':
        return isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED); // Purple 400 vs Purple 600
      case 'completed':
        return isDark ? const Color(0xFF34D399) : const Color(0xFF059669); // Emerald 400 vs Emerald 600
      case 'todo':
      default:
        return isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569); // Slate 400 vs Slate 600
    }
  }

  /// لون الأولوية المتكيف: حاد ومتباين على أي خلفية
  static Color adaptivePriorityColor(String priority, bool isDark) {
    switch (priority.toLowerCase()) {
      case 'urgent':
        return isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626); // Red 400 vs Red 600
      case 'high':
        return isDark ? const Color(0xFFFB923C) : const Color(0xFFEA580C); // Orange 400 vs Orange 600
      case 'low':
        return isDark ? const Color(0xFF34D399) : const Color(0xFF059669); // Emerald 400 vs Emerald 600
      case 'medium':
      default:
        return isDark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB); // Blue 400 vs Blue 600
    }
  }

  /// مواءمة أي لون مخصص ليصبح حاداً ومريحاً على الخلفية (Dark vs Light)
  static Color adaptiveCustomColor(Color color, bool isDark) {
    final hsl = HSLColor.fromColor(color);
    if (isDark) {
      // في الوضع الليلي: نضمن سطوع لا يقل عن 60% حتى لا يختفي في الخلفية الداكنة
      if (hsl.lightness < 0.58) {
        return hsl.withLightness(0.62).toColor();
      }
    } else {
      // في الوضع النهاري: نضمن سطوع لا يزيد عن 45% حتى لا يكون باهتاً على الخلفية البيضاء
      if (hsl.lightness > 0.48) {
        return hsl.withLightness(0.42).toColor();
      }
    }
    return color;
  }

  // --- محددات الألوان التكيفية التلقائية مع كافة الأنماط الثلاثة (Light / Dark Slate / OLED) ---

  /// فحص هل النمط النشط حالياً هو OLED (سواد عميق)
  static bool isOled(BuildContext context) {
    return Theme.of(context).scaffoldBackgroundColor == oledBackground;
  }

  /// لون السطح المتكيف (OLED: #101216 / Dark Slate: #1E293B / Light: #FFFFFF)
  static Color surface(BuildContext context) {
    if (isOled(context)) return oledSurface;
    return Theme.of(context).brightness == Brightness.dark ? darkSurface : lightSurface;
  }

  /// لون البطاقات المتكيف (OLED: #161920 / Dark Slate: #243247 / Light: #FFFFFF)
  static Color card(BuildContext context) {
    if (isOled(context)) return oledCard;
    return Theme.of(context).brightness == Brightness.dark ? darkCard : lightCard;
  }

  /// لون الخلفية المتكيف (OLED: #000000 / Dark Slate: #0F172A / Light: #F1F5F9)
  static Color background(BuildContext context) {
    if (isOled(context)) return oledBackground;
    return Theme.of(context).brightness == Brightness.dark ? darkBackground : lightBackground;
  }

  /// لون الحدود والفواصل المتكيف (OLED: #262C36 / Dark Slate: #334155 / Light: #CBD5E1)
  static Color border(BuildContext context) {
    if (isOled(context)) return oledBorder;
    return Theme.of(context).brightness == Brightness.dark ? darkBorder : lightBorder;
  }

  /// لون النصوص الأساسية المتكيف (OLED: #FFFFFF نقي / Dark Slate: #F8FAFC / Light: #0F172A)
  static Color textPrimary(BuildContext context) {
    if (isOled(context)) return oledTextPrimary;
    return Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;
  }

  /// لون النصوص الثانوية المتكيف (OLED: #E2E8F0 ساطع / Dark Slate: #CBD5E1 / Light: #334155)
  static Color textSecondary(BuildContext context) {
    if (isOled(context)) return oledTextSecondary;
    return Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;
  }

  /// لون النصوص المكتومة المتكيف (OLED: #94A3B8 / Dark Slate: #94A3B8 / Light: #64748B)
  static Color textMuted(BuildContext context) {
    if (isOled(context)) return oledTextMuted;
    return Theme.of(context).brightness == Brightness.dark ? darkTextMuted : lightTextMuted;
  }

  // --- لوحة الألوان المقترحة للاختيار الحر (Custom Color Palette Presets) ---
  static const List<String> presetHexColors = [
    '#3B82F6', // Blue
    '#10B981', // Emerald
    '#8B5CF6', // Purple
    '#F59E0B', // Amber
    '#EF4444', // Red
    '#EC4899', // Pink
    '#06B6D4', // Cyan
    '#6366F1', // Indigo
    '#14B8A6', // Teal
    '#F97316', // Orange
    '#84CC16', // Lime
    '#64748B', // Slate
  ];

  /// تحويل كود HEX إلى Color بأمان مع fallback
  static Color fromHex(String? hexString, {Color fallback = const Color(0xFF3B82F6)}) {
    if (hexString == null || hexString.isEmpty) return fallback;
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return fallback;
    }
  }

  /// تحويل كود Color إلى كود HEX
  static String toHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }
}

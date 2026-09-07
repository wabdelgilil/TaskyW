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

  // --- الوضع الليلي (Dark Slate Palette) ---
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B);    // Slate 800
  static const Color darkCard = Color(0xFF243247);       // Elevated Card Slate
  static const Color darkBorder = Color(0xFF334155);     // Slate 700
  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFF94A3B8); // Slate 400
  static const Color darkTextMuted = Color(0xFF64748B);   // Slate 500

  // --- الوضع النهاري (Crisp Light Palette) ---
  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);    // Pure White
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightBorder = Color(0xFFE2E8F0);     // Slate 200
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600
  static const Color lightTextMuted = Color(0xFF94A3B8);   // Slate 400

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

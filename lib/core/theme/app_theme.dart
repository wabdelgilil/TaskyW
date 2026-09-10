import 'package:flutter/material.dart';
import 'app_colors.dart';

/// نظام الثيم المزدوج العصري لتطبيق TaskyW
class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandLight, // ساطع وعالي التباين على الخلفيات الداكنة بدلاً من الأزرق الغامق
        onPrimary: Color(0xFF0F172A),
        surface: AppColors.darkSurface,
        onSurface: AppColors.darkTextPrimary,
        outline: AppColors.darkBorder,
      ),
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.darkSurface,
        modalBackgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkBackground,
        hintStyle: const TextStyle(color: AppColors.darkTextMuted, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.brandLight, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.darkSurface,
        indicatorColor: AppColors.brandLight.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.brandLight, fontWeight: FontWeight.bold, fontSize: 12);
          }
          return const TextStyle(color: AppColors.darkTextSecondary, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.brandLight);
          }
          return const IconThemeData(color: AppColors.darkTextSecondary);
        }),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brandPrimary,
        onPrimary: Colors.white,
        surface: AppColors.lightSurface,
        onSurface: AppColors.lightTextPrimary,
        outline: AppColors.lightBorder,
      ),
      cardTheme: CardThemeData(
        color: AppColors.lightCard,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.lightSurface,
        modalBackgroundColor: AppColors.lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.lightTextMuted, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.lightSurface,
        indicatorColor: AppColors.brandPrimary.withValues(alpha: 0.12),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.brandPrimary, fontWeight: FontWeight.bold, fontSize: 12);
          }
          return const TextStyle(color: AppColors.lightTextSecondary, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.brandPrimary);
          }
          return const IconThemeData(color: AppColors.lightTextSecondary);
        }),
      ),
    );
  }

  /// ثيم السواد العميق (OLED Pure Black Theme)
  static ThemeData get oledTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.oledBackground,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brandLight, // سماوي ساطع عالي التباين
        onPrimary: Color(0xFF000000),
        surface: AppColors.oledSurface,
        onSurface: AppColors.oledTextPrimary,
        outline: AppColors.oledBorder,
      ),
      cardTheme: CardThemeData(
        color: AppColors.oledCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.oledBorder, width: 1.2),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.oledSurface,
        elevation: 12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.oledBorder, width: 1.2),
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.oledSurface,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: AppColors.oledSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.oledBorder, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.oledSurface,
        modalBackgroundColor: AppColors.oledSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.oledBackground,
        hintStyle: const TextStyle(color: AppColors.oledTextMuted, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.oledTextSecondary, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.oledBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.oledBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.brandLight, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.oledBorder,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: AppColors.oledSurface,
        indicatorColor: AppColors.brandLight.withValues(alpha: 0.25),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(color: AppColors.brandLight, fontWeight: FontWeight.bold, fontSize: 12);
          }
          return const TextStyle(color: AppColors.oledTextSecondary, fontSize: 12);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: AppColors.brandLight);
          }
          return const IconThemeData(color: AppColors.oledTextSecondary);
        }),
      ),
    );
  }
}

/// أنماط الثيم المتاحة في التطبيق (النهاري، الليلي المريح، والسواد التام OLED)
enum AppThemeStyle {
  light,  // الوضع النهاري الصافي
  dark,   // الوضع الليلي الهادئ (Dark Slate)
  oled,   // وضع السواد العميق فائق التباين وتوفير الطاقة (Pure Black)
}

/// متحكم لإدارة واختيار وضع الثيم في الذاكرة ومشاركته عبر الواجهات
class ThemeController extends ChangeNotifier {
  static final ThemeController instance = ThemeController._internal();
  AppThemeStyle _currentStyle = AppThemeStyle.dark;

  ThemeController._internal();

  AppThemeStyle get currentStyle => _currentStyle;

  /// متوافق مع ThemeData في MaterialApp
  ThemeData get activeTheme {
    switch (_currentStyle) {
      case AppThemeStyle.light:
        return AppTheme.lightTheme;
      case AppThemeStyle.oled:
        return AppTheme.oledTheme;
      case AppThemeStyle.dark:
        return AppTheme.darkTheme;
    }
  }

  /// هل النمط الحالي داكن (Dark أو OLED)
  bool get isDarkMode => _currentStyle == AppThemeStyle.dark || _currentStyle == AppThemeStyle.oled;

  /// هل النمط الحالي هو OLED حصراً
  bool get isOledMode => _currentStyle == AppThemeStyle.oled;

  /// اسم النمط المعروض
  String get styleDisplayName {
    switch (_currentStyle) {
      case AppThemeStyle.light:
        return 'الوضع النهاري';
      case AppThemeStyle.oled:
        return 'سواد عميق (OLED)';
      case AppThemeStyle.dark:
        return 'الوضع الليلي';
    }
  }

  /// التبديل الدائري بين الأوضاع الثلاثة بضغطة زر (Light -> Dark -> OLED -> Light)
  void cycleTheme() {
    switch (_currentStyle) {
      case AppThemeStyle.light:
        _currentStyle = AppThemeStyle.dark;
        break;
      case AppThemeStyle.dark:
        _currentStyle = AppThemeStyle.oled;
        break;
      case AppThemeStyle.oled:
        _currentStyle = AppThemeStyle.light;
        break;
    }
    notifyListeners();
  }

  /// للتوافق القديم مع أي استدعاء toggleTheme
  void toggleTheme() => cycleTheme();

  /// تعيين نمط محدد
  void setStyle(AppThemeStyle style) {
    if (_currentStyle != style) {
      _currentStyle = style;
      notifyListeners();
    }
  }
}

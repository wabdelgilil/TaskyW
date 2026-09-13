import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

/// متحكم وضع ودجت سطح المكتب لنظام Windows / Desktop
/// يدير تقليص النافذة إلى كارت عائم وتثبيتها فوق النوافذ (Always on Top)
class DesktopWidgetController extends ChangeNotifier {
  static final DesktopWidgetController instance = DesktopWidgetController._internal();

  DesktopWidgetController._internal();

  bool _isWidgetMode = false;
  bool _isAlwaysOnTop = false;

  Size? _savedFullWindowSize;
  Offset? _savedFullWindowPosition;

  bool get isWidgetMode => _isWidgetMode;
  bool get isAlwaysOnTop => _isAlwaysOnTop;

  bool get isDesktopPlatform =>
      !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

  /// تهيئة مدير النوافذ لسطح المكتب
  Future<void> init() async {
    if (!isDesktopPlatform) return;
    try {
      await windowManager.ensureInitialized();
    } catch (e) {
      debugPrint('[DesktopWidgetController] init error: $e');
    }
  }

  /// التبديل بين وضع الودجت المصغر ومساحة العمل الكاملة
  Future<void> toggleWidgetMode() async {
    if (_isWidgetMode) {
      await exitWidgetMode();
    } else {
      await enterWidgetMode();
    }
  }

  /// الدخول إلى وضع الودجت المصغر
  Future<void> enterWidgetMode() async {
    if (!isDesktopPlatform) return;

    try {
      _savedFullWindowSize = await windowManager.getSize();
      _savedFullWindowPosition = await windowManager.getPosition();

      await windowManager.setMinimumSize(const Size(320, 420));
      await windowManager.setSize(const Size(380, 600));

      if (_isAlwaysOnTop) {
        await windowManager.setAlwaysOnTop(true);
      }

      _isWidgetMode = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[DesktopWidgetController] enterWidgetMode error: $e');
    }
  }

  /// العودة إلى مساحة العمل الكاملة
  Future<void> exitWidgetMode() async {
    if (!isDesktopPlatform) return;

    try {
      final restoreSize = _savedFullWindowSize ?? const Size(1280, 720);
      await windowManager.setMinimumSize(const Size(800, 550));
      await windowManager.setSize(restoreSize);

      if (_savedFullWindowPosition != null) {
        await windowManager.setPosition(_savedFullWindowPosition!);
      }

      // إلغاء التثبيت الإجباري عند العودة للوضع الكامل لتجنب حجب البرامج الأخرى
      await windowManager.setAlwaysOnTop(false);

      _isWidgetMode = false;
      notifyListeners();
    } catch (e) {
      debugPrint('[DesktopWidgetController] exitWidgetMode error: $e');
    }
  }

  /// تبديل خاصية التثبيت فوق جميع النوافذ (Always on Top)
  Future<void> toggleAlwaysOnTop() async {
    if (!isDesktopPlatform) return;

    try {
      _isAlwaysOnTop = !_isAlwaysOnTop;
      await windowManager.setAlwaysOnTop(_isAlwaysOnTop);
      notifyListeners();
    } catch (e) {
      debugPrint('[DesktopWidgetController] toggleAlwaysOnTop error: $e');
    }
  }
}

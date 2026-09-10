import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/core/database/database_tables.dart';
import 'package:tasky/features/settings/data/models/app_settings_model.dart';

/// خدمة تخزين إعدادات التطبيق بنظام مزدوج:
///
/// - `shared_preferences`: مرآة سريعة فورية (سطر ذاكرة للقراءة عند الإقلاع).
/// - SQLite (`user_settings`): النسخة الدائمة المحلية التي تُزامَن مع
///   السحابة (`user_settings` في Supabase) لكل مستخدم مسجل.
///
/// جميع مفاتيح التخزين تبدأ بـ `settings.` لتجنب التعارض مع أي بيانات أخرى.
class SettingsService {
  static const String _keyNotifications = 'settings.notifications_enabled';
  static const String _keyReminderMinutes = 'settings.default_reminder_minutes';
  static const String _keyCurrency = 'settings.default_currency';
  static const String _keyViewMode = 'settings.default_view_mode';
  static const String _keyThemeMode = 'settings.theme_mode';
  static const String _keyLanguageCode = 'settings.language_code';
  static const String _keyLayoutDirection = 'settings.layout_direction';

  static const String _dbRowId = 'default';

  Future<AppSettingsModel> load() async {
    final prefs = await SharedPreferences.getInstance();

    // 1) الأولوية للمرآة السريعة (prefs) إن وُجدت أي إعدادات محفوظة.
    final hasPrefs = prefs.containsKey(_keyNotifications) ||
        prefs.containsKey(_keyReminderMinutes) ||
        prefs.containsKey(_keyCurrency) ||
        prefs.containsKey(_keyViewMode) ||
        prefs.containsKey(_keyThemeMode) ||
        prefs.containsKey(_keyLanguageCode) ||
        prefs.containsKey(_keyLayoutDirection);
    if (hasPrefs) {
      final model = _fromPrefs(prefs);
      // عكسها إلى قاعدة SQLite لتحضيرها للمزامنة السحابية.
      await _mirrorToDb(model);
      return model;
    }

    // 2) لا توجد prefs → قراءة من SQLite (جهاز جديد بعد مزامنة سحابية سابقة).
    final fromDb = await _readFromDb();
    if (fromDb != null) {
      await _writePrefs(fromDb);
      return fromDb;
    }

    return const AppSettingsModel();
  }

  Future<void> save(AppSettingsModel settings) async {
    await _writePrefs(settings);
    await _mirrorToDb(settings);
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyNotifications);
    await prefs.remove(_keyReminderMinutes);
    await prefs.remove(_keyCurrency);
    await prefs.remove(_keyViewMode);
    await prefs.remove(_keyThemeMode);
    await prefs.remove(_keyLanguageCode);
    await prefs.remove(_keyLayoutDirection);

    try {
      final db = await AppDatabase.instance.database;
      await db.delete(
        DatabaseTables.userSettingsTable,
        where: 'id = ?',
        whereArgs: [_dbRowId],
      );
    } catch (e) {
      debugPrint('[SettingsService] clear DB row failed: $e');
    }
  }

  // ─── مرآة الـ prefs ────────────────────────────────────────────────────

  Future<void> _writePrefs(AppSettingsModel model) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifications, model.notificationsEnabled);
    await prefs.setInt(_keyReminderMinutes, model.defaultReminderMinutes);
    await prefs.setString(_keyCurrency, model.defaultCurrency);
    await prefs.setString(_keyViewMode, model.defaultViewMode);
    await prefs.setString(_keyThemeMode, model.themeMode);
    await prefs.setString(_keyLanguageCode, model.languageCode);
    await prefs.setString(_keyLayoutDirection, model.layoutDirection);
  }

  AppSettingsModel _fromPrefs(SharedPreferences prefs) {
    return AppSettingsModel(
      notificationsEnabled: prefs.getBool(_keyNotifications) ?? true,
      defaultReminderMinutes: prefs.getInt(_keyReminderMinutes) ?? 15,
      defaultCurrency: prefs.getString(_keyCurrency) ?? 'SAR',
      defaultViewMode: prefs.getString(_keyViewMode) ?? 'list',
      themeMode: prefs.getString(_keyThemeMode) ?? 'light',
      languageCode: prefs.getString(_keyLanguageCode) ?? 'system',
      layoutDirection: prefs.getString(_keyLayoutDirection) ?? 'ltr',
    );
  }

  // ─── طبقة SQLite ───────────────────────────────────────────────────────

  /// عكس الإعدادات إلى صف SQLite الوحيد (id = 'default') بعلامة `synced`.
  Future<void> _mirrorToDb(AppSettingsModel model) async {
    try {
      final db = await AppDatabase.instance.database;
      final now = DateTime.now().toUtc().toIso8601String();

      final existing = await db.query(
        DatabaseTables.userSettingsTable,
        where: 'id = ?',
        whereArgs: [_dbRowId],
        limit: 1,
      );

      final values = <String, dynamic>{
        'id': _dbRowId,
        'notifications_enabled': model.notificationsEnabled ? 1 : 0,
        'default_reminder_minutes': model.defaultReminderMinutes,
        'default_currency': model.defaultCurrency,
        'default_view_mode': model.defaultViewMode,
        'theme_mode': model.themeMode,
        'language_code': model.languageCode,
        'layout_direction': model.layoutDirection,
        'sync_status': 'synced',
        'updated_at': now,
      };

      if (existing.isEmpty) {
        values['created_at'] = now;
        await db.insert(DatabaseTables.userSettingsTable, values);
      } else {
        values['created_at'] = existing.first['created_at'] ?? now;
        await db.update(
          DatabaseTables.userSettingsTable,
          values,
          where: 'id = ?',
          whereArgs: [_dbRowId],
        );
      }
    } catch (e) {
      debugPrint('[SettingsService] DB mirror failed: $e');
    }
  }

  Future<AppSettingsModel?> _readFromDb() async {
    try {
      final db = await AppDatabase.instance.database;
      final rows = await db.query(
        DatabaseTables.userSettingsTable,
        where: 'id = ?',
        whereArgs: [_dbRowId],
        limit: 1,
      );
      if (rows.isEmpty) return null;

      final r = rows.first;
      return AppSettingsModel(
        notificationsEnabled: (r['notifications_enabled'] as int? ?? 1) != 0,
        defaultReminderMinutes: (r['default_reminder_minutes'] as int? ?? 15),
        defaultCurrency: r['default_currency'] as String? ?? 'SAR',
        defaultViewMode: r['default_view_mode'] as String? ?? 'list',
        themeMode: r['theme_mode'] as String? ?? 'light',
        languageCode: r['language_code'] as String? ?? 'system',
        layoutDirection: r['layout_direction'] as String? ?? 'ltr',
      );
    } catch (e) {
      debugPrint('[SettingsService] DB read failed: $e');
      return null;
    }
  }
}
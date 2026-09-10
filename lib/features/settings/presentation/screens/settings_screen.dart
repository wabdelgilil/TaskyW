import 'package:flutter/material.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tasky/features/settings/data/models/app_settings_model.dart';
import 'package:tasky/core/services/notification_service.dart';
import 'package:tasky/core/constants/app_version.dart';
import 'package:tasky/features/auth/presentation/controllers/auth_controller.dart';

/// شاشة الإعدادات العامة للتطبيق
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: AnimatedBuilder(
        animation: settings,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ===== قسم الإشعارات =====
              _SectionHeader(
                title: 'الإشعارات والتنبيهات',
                icon: Icons.notifications_active_outlined,
                color: AppColors.statusInProgress,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('إشعارات التطبيق'),
                        subtitle: const Text('تشغيل أو إيقاف كل التنبيهات المحلية (تذكيرات المهام)'),
                        value: settings.notificationsEnabled,
                        onChanged: (val) => settings.setNotificationsEnabled(val),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('وقت التذكير الافتراضي'),
                        subtitle: Text('${settings.defaultReminderMinutes} دقيقة قبل الموعد'),
                        trailing: PopupMenuButton<int>(
                          onSelected: (val) => settings.setDefaultReminderMinutes(val),
                          itemBuilder: (_) => [5, 15, 30, 60, 120].map((m) =>
                            PopupMenuItem(value: m, child: Text('$m دقيقة')),
                          ).toList(),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('طلب صلاحية التنبيهات'),
                        subtitle: const Text('تأكيد صلاحية التنبيهات على الأندرويد/IOS'),
                        trailing: ElevatedButton.icon(
                          onPressed: () async {
                            final granted = await NotificationService.instance.requestPermissions();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(
                                  granted ? 'تم تفعيل صلاحية التنبيهات بنجاح' : 'تم رفض طلب الصلاحية',
                                )),
                              );
                            }
                          },
                          icon: const Icon(Icons.security, size: 18),
                          label: const Text('تفعيل'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ===== قسم المالية والعملات =====
              _SectionHeader(
                title: 'المالية والعملات',
                icon: Icons.account_balance_wallet_outlined,
                color: const Color(0xFFF59E0B),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('العملة الافتراضية'),
                        subtitle: Text('العملة المستخدمة في السجلات المالية الجديدة: ${settings.defaultCurrency}'),
                        trailing: PopupMenuButton<String>(
                          initialValue: settings.defaultCurrency,
                          onSelected: (val) => settings.setDefaultCurrency(val),
                          itemBuilder: (_) => AppSettingsModel.supportedCurrencies
                              .map((c) => PopupMenuItem(value: c, child: Text(c)))
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ===== قسم المظهر والثيم =====
              _SectionHeader(
                title: 'المظهر والثيم',
                icon: Icons.palette_outlined,
                color: AppColors.statusCompleted,
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('وضع المظهر'),
                        subtitle: Text(settings.effectiveThemeMode == 'light'
                            ? 'الوضع النهاري (Light)'
                            : (settings.effectiveThemeMode == 'dark'
                                ? 'الوضع الليلي (Dark)'
                                : 'السواد العميق (OLED)')),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _ThemeChoice(
                            label: 'نهاري',
                            icon: Icons.light_mode_outlined,
                            selected: settings.effectiveThemeMode == 'light',
                            onTap: () => settings.setThemeMode('light'),
                          ),
                          const SizedBox(width: 8),
                          _ThemeChoice(
                            label: 'ليلي',
                            icon: Icons.dark_mode_outlined,
                            selected: settings.effectiveThemeMode == 'dark',
                            onTap: () => settings.setThemeMode('dark'),
                          ),
                          const SizedBox(width: 8),
                          _ThemeChoice(
                            label: 'OLED',
                            icon: Icons.brightness_7,
                            selected: settings.effectiveThemeMode == 'oled',
                            onTap: () => settings.setThemeMode('oled'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ===== قسم البيانات حول التطبيق =====
              _SectionHeader(
                title: 'بيانات التطبيق',
                icon: Icons.info_outline,
                color: AppColors.textMuted(context),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('إصدار التطبيق'),
                        subtitle: Text('الإصدار ${AppVersion.shortVersion}'),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('حالة الحساب'),
                        subtitle: Text(
                          AuthController.instance.isAuthenticated
                              ? 'مسجل الدخول: ${AuthController.instance.userEmail ?? 'مستخدم'}'
                              : 'غير مسجل الدخول',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemeChoice extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeChoice({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = selected ? AppColors.statusInProgress : AppColors.textMuted(context);

    return Expanded(
      child: Material(
        color: selected
            ? AppColors.statusInProgress.withOpacity(isDark ? 0.2 : 0.12)
            : (isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.03)),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? AppColors.statusInProgress : AppColors.border(context),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, size: 22, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tasky/core/services/notification_service.dart';
import 'package:tasky/core/constants/app_version.dart';
import 'package:tasky/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tasky/features/settings/data/models/app_currency.dart';
import 'package:tasky/features/settings/presentation/widgets/currency_picker_sheet.dart';

/// شاشة الإعدادات العامة للتطبيق (مع دعم اللغة الرسمي عبر `context.l10n`).
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.instance;

    return AnimatedBuilder(
      animation: settings,
      builder: (context, _) {
        final l10n = context.l10n;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.commonSettings),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ===== قسم اللغة والمنطقة =====
              _SectionHeader(
                title: l10n.sectionLanguage,
                icon: Icons.translate,
                color: const Color(0xFF8B5CF6),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.settingsLanguage),
                        subtitle: Text(l10n.settingsLanguageDesc),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _ChoiceCard(
                            label: l10n.settingsLanguageSystemShort,
                            icon: Icons.language_outlined,
                            selected: settings.languageCode == 'system',
                            onTap: () => settings.updateLanguage('system'),
                          ),
                          const SizedBox(width: 8),
                          _ChoiceCard(
                            label: l10n.languageArabic,
                            icon: Icons.translate,
                            selected: settings.languageCode == 'ar',
                            onTap: () => settings.updateLanguage('ar'),
                          ),
                          const SizedBox(width: 8),
                          _ChoiceCard(
                            label: l10n.languageEnglish,
                            icon: Icons.text_fields,
                            selected: settings.languageCode == 'en',
                            onTap: () => settings.updateLanguage('en'),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.directionTitle),
                        subtitle: Text(l10n.directionDesc),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _ChoiceCard(
                            label: l10n.directionLtr,
                            icon: Icons.horizontal_split,
                            selected: settings.layoutDirection == 'ltr',
                            onTap: () => settings.setLayoutDirection('ltr'),
                          ),
                          const SizedBox(width: 8),
                          _ChoiceCard(
                            label: l10n.directionAuto,
                            icon: Icons.compare_arrows,
                            selected: settings.layoutDirection == 'auto',
                            onTap: () => settings.setLayoutDirection('auto'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ===== قسم الإشعارات =====
              _SectionHeader(
                title: l10n.sectionNotifications,
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
                        title: Text(l10n.settingsNotifications),
                        subtitle: Text(l10n.settingsNotificationsDesc),
                        value: settings.notificationsEnabled,
                        onChanged: (val) => settings.setNotificationsEnabled(val),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.settingsReminderTime),
                        subtitle: Text(
                          l10n.settingsReminderMinutes(settings.defaultReminderMinutes),
                        ),
                        trailing: PopupMenuButton<int>(
                          onSelected: (val) => settings.setDefaultReminderMinutes(val),
                          itemBuilder: (_) => [5, 15, 30, 60, 120].map((m) =>
                            PopupMenuItem(value: m, child: Text('$m')),
                          ).toList(),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.settingsRequestPermission),
                        subtitle: Text(l10n.settingsRequestPermissionDesc),
                        trailing: ElevatedButton.icon(
                          onPressed: () async {
                            final granted = await NotificationService.instance.requestPermissions();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    granted
                                        ? l10n.settingsPermissionGranted
                                        : l10n.settingsPermissionDenied,
                                  ),
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.security, size: 18),
                          label: Text(l10n.settingsEnable),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ===== قسم المالية والعملات =====
              _SectionHeader(
                title: l10n.sectionFinance,
                icon: Icons.account_balance_wallet_outlined,
                color: const Color(0xFFF59E0B),
              ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Builder(
                        builder: (ctx) {
                          final currentCurrency = AppCurrency.findByCode(settings.defaultCurrency);
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(l10n.settingsCurrency),
                            subtitle: Text(
                              '${currentCurrency.flagEmoji} ${currentCurrency.nameAr} (${currentCurrency.code}) - ${currentCurrency.countryAr}',
                            ),
                            trailing: OutlinedButton.icon(
                              onPressed: () {
                                CurrencyPickerSheet.show(
                                  ctx,
                                  selectedCurrencyCode: settings.defaultCurrency,
                                  onCurrencySelected: (code) => settings.setDefaultCurrency(code),
                                );
                              },
                              icon: const Icon(Icons.arrow_drop_down, size: 20),
                              label: Text(
                                '${currentCurrency.flagEmoji} ${currentCurrency.code}',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            onTap: () {
                              CurrencyPickerSheet.show(
                                ctx,
                                selectedCurrencyCode: settings.defaultCurrency,
                                onCurrencySelected: (code) => settings.setDefaultCurrency(code),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ===== قسم المظهر والثيم =====
              _SectionHeader(
                title: l10n.sectionAppearance,
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
                        title: Text(l10n.themeModeLabel),
                        subtitle: Text(
                          settings.effectiveThemeMode == 'light'
                              ? l10n.themeLightFull
                              : (settings.effectiveThemeMode == 'dark'
                                  ? l10n.themeDarkFull
                                  : l10n.themeOledFull),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _ChoiceCard(
                            label: l10n.themeLight,
                            icon: Icons.light_mode_outlined,
                            selected: settings.effectiveThemeMode == 'light',
                            onTap: () => settings.setThemeMode('light'),
                          ),
                          const SizedBox(width: 8),
                          _ChoiceCard(
                            label: l10n.themeDark,
                            icon: Icons.dark_mode_outlined,
                            selected: settings.effectiveThemeMode == 'dark',
                            onTap: () => settings.setThemeMode('dark'),
                          ),
                          const SizedBox(width: 8),
                          _ChoiceCard(
                            label: l10n.themeOled,
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
                title: l10n.sectionData,
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
                        title: Text(l10n.appVersion),
                        subtitle: Text(
                          l10n.versionLabel(AppVersion.shortVersion),
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.accountStatus),
                        subtitle: Text(
                          AuthController.instance.isAuthenticated
                              ? l10n.signedInAs(
                                  AuthController.instance.userEmail ?? 'user')
                              : l10n.signedOut,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
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

class _ChoiceCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceCard({
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
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? AppColors.statusInProgress : AppColors.border(context),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
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
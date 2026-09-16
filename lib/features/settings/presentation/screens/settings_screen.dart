import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
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
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.settingsTestNotification),
                        subtitle: Text(l10n.settingsTestNotificationDesc),
                        trailing: ElevatedButton.icon(
                          onPressed: () async {
                            final success = await NotificationService.instance
                                .showInstantTestNotification();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? l10n.settingsTestNotificationSuccess
                                        : l10n.settingsTestNotificationFailed,
                                  ),
                                  backgroundColor: success
                                      ? AppColors.statusCompleted
                                      : Theme.of(context).colorScheme.error,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.notification_important_outlined, size: 18),
                          label: Text(l10n.settingsTestNotificationBtn),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandPrimary,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ===== قسم الذكاء الاصطناعي والمساعد الصوتي =====
              _SectionHeader(
                title: l10n.sectionAiAssistant,
                icon: Icons.auto_awesome_rounded,
                color: const Color(0xFF6366F1),
              ),
              const _AiSettingsCard(),
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
                      const Divider(height: 24),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.taskCardDensityTitle),
                        subtitle: Text(
                          settings.isCompactCards
                              ? l10n.taskCardDensityCompact
                              : l10n.taskCardDensityComfortable,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _ChoiceCard(
                            label: l10n.taskCardDensityComfortable,
                            icon: Icons.view_agenda_outlined,
                            selected: !settings.isCompactCards,
                            onTap: () => settings.setTaskCardDensity('comfortable'),
                          ),
                          const SizedBox(width: 8),
                          _ChoiceCard(
                            label: l10n.taskCardDensityCompact,
                            icon: Icons.density_medium_rounded,
                            selected: settings.isCompactCards,
                            onTap: () => settings.setTaskCardDensity('compact'),
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
            ? AppColors.statusInProgress.withValues(alpha: isDark ? 0.2 : 0.12)
            : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
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

/// بطاقة إعدادات الذكاء الاصطناعي والمفتاح الشخصي (BYOK)
class _AiSettingsCard extends StatefulWidget {
  const _AiSettingsCard();

  @override
  State<_AiSettingsCard> createState() => _AiSettingsCardState();
}

class _AiSettingsCardState extends State<_AiSettingsCard> {
  late TextEditingController _keyController;
  bool _obscureKey = true;
  bool _isTesting = false;
  String? _testMessage;
  bool? _testSuccess;

  @override
  void initState() {
    super.initState();
    _keyController = TextEditingController(
      text: SettingsController.instance.geminiApiKey ?? '',
    );
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _testKey() async {
    final keyToTest = _keyController.text.trim();
    if (keyToTest.isEmpty) {
      setState(() {
        _testSuccess = false;
        _testMessage = 'يرجى إدخال مفتاح الـ API أولاً.';
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _testMessage = null;
      _testSuccess = null;
    });

    final success = await SettingsController.instance.testGeminiApiKey(keyToTest);

    if (!mounted) return;
    setState(() {
      _isTesting = false;
      _testSuccess = success;
      _testMessage = success
          ? 'تم التحقق بنجاح! المفتاح يعمل وجاهز للاستخدام 🚀'
          : 'فشل التحقق: يرجى التأكد من صحة المفتاح واتصال الإنترنت.';
    });

    if (success) {
      await SettingsController.instance.setGeminiApiKey(keyToTest);
    }
  }

  Future<void> _pasteFromClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text != null && data!.text!.isNotEmpty) {
      setState(() {
        _keyController.text = data.text!.trim();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.instance;
    final hasKey = settings.hasValidAiKey;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // نبذة توضيحية
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Color(0xFF6366F1),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نموذج Google Gemini (BYOK)',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'يعمل المساعد الصوتي بمفتاحك الشخصي المجاني للحفاظ على خصوصية بياناتك وتوفير استخدام غير محدود بدون قيود.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // زر الحصول على المفتاح مجاناً
            OutlinedButton.icon(
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('الحصول على مفتاح مجاني من Google AI Studio'),
              onPressed: () {
                launchUrl(
                  Uri.parse('https://aistudio.google.com/app/apikey'),
                  mode: LaunchMode.externalApplication,
                );
              },
            ),
            const Divider(height: 24),

            // حالة المفتاح الحالية
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                hasKey ? Icons.check_circle_rounded : Icons.warning_amber_rounded,
                color: hasKey ? Colors.green : Colors.orange,
              ),
              title: Text(
                hasKey ? 'المفتاح مسجل ومجهز' : 'لم يتم تسجيل المفتاح بعد',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              subtitle: Text(
                hasKey
                    ? 'المساعد الصوتي والإدخال الذكي مفعّلان وجاهزان'
                    : 'سجل مفتاحك بالأسفل لتفعيل المساعد الذكي',
                style: const TextStyle(fontSize: 11.5),
              ),
              trailing: hasKey
                  ? TextButton(
                      onPressed: () async {
                        await settings.clearGeminiApiKey();
                        _keyController.clear();
                        setState(() {
                          _testMessage = null;
                          _testSuccess = null;
                        });
                      },
                      child: const Text('مسح المفتاح', style: TextStyle(color: Colors.red)),
                    )
                  : null,
            ),
            const SizedBox(height: 8),

            // حقل إدخال المفتاح
            TextField(
              controller: _keyController,
              obscureText: _obscureKey,
              decoration: InputDecoration(
                labelText: 'Google Gemini API Key',
                hintText: 'ألصق المفتاح هنا (AIzaSy...)',
                isDense: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.key_rounded, size: 20),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.content_paste_rounded, size: 20),
                      tooltip: 'لصق من الحافظة',
                      onPressed: _pasteFromClipboard,
                    ),
                    IconButton(
                      icon: Icon(
                        _obscureKey ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      tooltip: _obscureKey ? 'إظهار المفتاح' : 'إخفاء المفتاح',
                      onPressed: () {
                        setState(() => _obscureKey = !_obscureKey);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),

            // أزرار الحفظ والاختبار
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: const Text('حفظ المفتاح'),
                    onPressed: () async {
                      final key = _keyController.text.trim();
                      if (key.isNotEmpty) {
                        await settings.setGeminiApiKey(key);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم حفظ مفتاح Gemini بنجاح ✓'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: _isTesting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bolt_rounded, size: 18),
                    label: const Text('اختبار الاتصال'),
                    onPressed: _isTesting ? null : _testKey,
                  ),
                ),
              ],
            ),

            // نتيجة الاختبار
            if (_testMessage != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: (_testSuccess == true ? Colors.green : Colors.red)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: (_testSuccess == true ? Colors.green : Colors.red)
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testSuccess == true ? Icons.check_circle : Icons.cancel,
                      size: 18,
                      color: _testSuccess == true ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _testMessage!,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _testSuccess == true ? Colors.green : Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const Divider(height: 24),

            // مفتاح تفعيل/تعطيل المساعد
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('تفعيل مساعد الذكاء الاصطناعي'),
              subtitle: const Text('إظهار زر المساعد الصوتي في الواجهات العلوية والسريعة'),
              trailing: Switch(
                value: settings.aiEnabled,
                onChanged: (val) => settings.setAiEnabled(val),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
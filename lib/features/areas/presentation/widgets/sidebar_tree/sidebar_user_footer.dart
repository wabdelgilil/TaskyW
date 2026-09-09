import 'package:flutter/material.dart';

import 'package:tasky/core/services/sync_controller.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/core/theme/app_theme.dart';
import 'package:tasky/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tasky/features/auth/presentation/screens/auth_screen.dart';

/// الجزء السفلي من القائمة الجانبية: بطاقة الحساب ومبدّل الثيم
class SidebarUserFooter extends StatelessWidget {
  const SidebarUserFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black12 : Colors.grey.withOpacity(0.05),
      ),
      child: Column(
        children: [
          // بطاقة المستخدم والمصادقة
          ListenableBuilder(
            listenable: AuthController.instance,
            builder: (context, _) {
              final auth = AuthController.instance;
              if (auth.isAuthenticated) {
                return InkWell(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (ctx) => Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                                child: Text(
                                  (auth.displayName?.isNotEmpty == true ? auth.displayName![0] : 'U').toUpperCase(),
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ),
                              title: Text(auth.displayName ?? 'مستخدم Tasky', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(auth.userEmail ?? ''),
                            ),
                            const Divider(),
                            ListTile(
                              leading: const Icon(Icons.cloud_done_outlined, color: Colors.green),
                              title: const Text('متصل بسحابة Supabase'),
                              subtitle: const Text('المزامنة السحابية نشطة'),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                auth.signOut();
                              },
                              icon: const Icon(Icons.logout, size: 18),
                              label: const Text('تسجيل الخروج'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          child: Text(
                            (auth.displayName?.isNotEmpty == true ? auth.displayName![0] : 'U').toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                auth.displayName ?? 'المستخدم',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                              ListenableBuilder(
                                listenable: SyncController.instance,
                                builder: (context, _) {
                                  final sync = SyncController.instance;
                                  return Row(
                                    children: [
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          color: sync.isSyncing
                                              ? Colors.blueAccent
                                              : sync.hasPending
                                                  ? Colors.amber
                                                  : Colors.green,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        sync.isSyncing
                                            ? 'جاري المزامنة...'
                                            : sync.hasPending
                                                ? '${sync.pendingCount} معلق'
                                                : 'متزامن',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: AppColors.textSecondary(context),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.more_vert, size: 16),
                      ],
                    ),
                  ),
                );
              }

              return InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  margin: const EdgeInsets.only(bottom: 6),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.cloud_outlined, size: 18, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'تسجيل الدخول للسحابة',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 12),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 4),

          // زر مبدل الثيم الثلاثي (نهاري / ليلي هادئ / سواد تام OLED)
          ListenableBuilder(
            listenable: ThemeController.instance,
            builder: (context, _) {
              final themeCtrl = ThemeController.instance;
              IconData themeIcon;
              Color themeColor;

              switch (themeCtrl.currentStyle) {
                case AppThemeStyle.light:
                  themeIcon = Icons.light_mode_rounded;
                  themeColor = Colors.amber;
                  break;
                case AppThemeStyle.oled:
                  themeIcon = Icons.brightness_2_rounded; // قمر سواد تام
                  themeColor = AppColors.brandLight;
                  break;
                case AppThemeStyle.dark:
                  themeIcon = Icons.dark_mode_rounded;
                  themeColor = Colors.blueAccent;
                  break;
              }

              return InkWell(
                onTap: () => themeCtrl.cycleTheme(),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                  child: Row(
                    children: [
                      Icon(themeIcon, size: 18, color: themeColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          themeCtrl.styleDisplayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: themeColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'تبديل',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: themeColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
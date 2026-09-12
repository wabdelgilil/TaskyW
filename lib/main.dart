import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:tasky/l10n/app_localizations.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/tasky_home_screen.dart';
import 'features/settings/presentation/controllers/settings_controller.dart';
import 'features/sharing/presentation/screens/public_share_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // تحميل متغيرات البيئة إن وُجد ملف .env (متاح في أصول التطبيق فقط عند توضيحه).
  // على الويب لا يوجد ملف env مضمَّن → لا نحاول أصلاً (يتجنب 404).
  // المفاتيح لها fallback في SupabaseService (dart-define ثم القيمة الافتراضية).
  if (!kIsWeb) {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {}
  }

  await SupabaseService.initialize();
  await SettingsController.instance.load();

  // ضبط شريط الحالة والنظام ليعمل بسلاسة بدون تداخل على الهواتف
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );

  runApp(const TaskyApp());
}

class TaskyApp extends StatelessWidget {
  const TaskyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        ThemeController.instance,
        SettingsController.instance,
      ]),
      builder: (context, _) {
        return MaterialApp(
          title: 'TaskyW',
          debugShowCheckedModeBanner: false,
          theme: ThemeController.instance.activeTheme,
          locale: SettingsController.instance.activeLocale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) {
            // إبقاء الواجهة كلها LTR (السايد بار يسار دائماً) بغض النظر عن اللغة
            if (SettingsController.instance.isForcedLtr) {
              return Directionality(
                textDirection: TextDirection.ltr,
                child: child!,
              );
            }
            return child!;
          },
          localeListResolutionCallback: (locales, supported) {
            if (SettingsController.instance.activeLocale != null) {
              return SettingsController.instance.activeLocale;
            }
            if (locales != null && locales.isNotEmpty) {
              for (final locale in locales) {
                for (final supportedLocale in supported) {
                  if (supportedLocale.languageCode == locale.languageCode) {
                    return supportedLocale;
                  }
                }
              }
            }
            return const Locale('ar');
          },
          onGenerateRoute: (settings) {
            final name = settings.name ?? '';
            final uri = Uri.tryParse(name);

            // فحص المسار العادي أو المسار المجزأ (#)
            String? token;
            if (uri != null && uri.pathSegments.isNotEmpty) {
              if (uri.pathSegments.first == 'share' && uri.pathSegments.length > 1) {
                token = uri.pathSegments[1];
              }
            }

            if (token == null && uri != null && uri.fragment.isNotEmpty) {
              final fragUri = Uri.tryParse(uri.fragment);
              if (fragUri != null && fragUri.pathSegments.length > 1 && fragUri.pathSegments.first == 'share') {
                token = fragUri.pathSegments[1];
              }
            }

            if (token != null && token.isNotEmpty) {
              return MaterialPageRoute(
                builder: (_) => PublicShareScreen(shareToken: token!),
              );
            }

            return MaterialPageRoute(
              builder: (_) => const TaskyHomeScreen(),
            );
          },
          home: const TaskyHomeScreen(),
        );
      },
    );
  }
}

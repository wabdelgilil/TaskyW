import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/tasky_home_screen.dart';
import 'features/sharing/presentation/screens/public_share_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();

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
      listenable: ThemeController.instance,
      builder: (context, _) {
        return MaterialApp(
          title: 'TaskyW',
          debugShowCheckedModeBanner: false,
          theme: ThemeController.instance.activeTheme,
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

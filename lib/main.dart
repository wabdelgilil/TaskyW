import 'package:flutter/material.dart';
import 'core/services/supabase_service.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/screens/tasky_home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseService.initialize();
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
          home: const TaskyHomeScreen(),
        );
      },
    );
  }
}

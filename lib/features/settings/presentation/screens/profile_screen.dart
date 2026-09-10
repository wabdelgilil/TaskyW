import 'package:flutter/material.dart';
import 'package:tasky/core/constants/app_version.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/core/services/sync_controller.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/features/auth/presentation/controllers/auth_controller.dart';
import 'package:tasky/features/auth/presentation/screens/auth_screen.dart';

/// شاشة البروفايل المستقلة للعرض وتعديل الاسم المعروض.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _nameCtrl;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: AuthController.instance.displayName ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthController.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profileTitle),
        actions: [
          if (auth.isAuthenticated)
            IconButton(
              icon: Icon(_editing ? Icons.close : Icons.edit_outlined, size: 20),
              tooltip: _editing ? context.l10n.commonCancel : context.l10n.editName,
              onPressed: () {
                setState(() {
                  _editing = !_editing;
                  if (!_editing) {
                    _nameCtrl.text = auth.displayName ?? '';
                  }
                });
              },
            ),
        ],
      ),
      body: ListenableBuilder(
        listenable: auth,
        builder: (context, _) {
          if (!auth.isAuthenticated) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off, size: 56, color: AppColors.textMuted(context)),
                  const SizedBox(height: 12),
                  Text(context.l10n.notSignedIn, style: TextStyle(color: AppColors.textSecondary(context), fontSize: 15)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                    ),
                    icon: const Icon(Icons.login, size: 18),
                    label: Text(context.l10n.signIn),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    (auth.displayName?.isNotEmpty == true ? auth.displayName![0] : 'U').toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // الاسم المعروض
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(context.l10n.profileDisplayName, style: TextStyle(fontSize: 12, color: AppColors.textMuted(context))),
                      const SizedBox(height: 6),
                      if (_editing)
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _nameCtrl,
                                autofocus: true,
                                decoration: InputDecoration(hintText: context.l10n.enterNewName),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.check_circle, color: Colors.green),
                              onPressed: () async {
                                final success = await auth.updateDisplayName(_nameCtrl.text, context.l10n);
                                if (success && mounted && context.mounted) {
                                  setState(() => _editing = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(context.l10n.nameUpdatedToast)),
                                  );
                                }
                              },
                            ),
                          ],
                        )
                      else
                        Text(
                          auth.displayName ?? context.l10n.taskyUser,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // البريد الإلكتروني
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: Text(context.l10n.profileEmail),
                  subtitle: Text(auth.userEmail ?? context.l10n.notSpecified),
                ),
              ),
              const SizedBox(height: 10),

              // حالة المزامنة السحابية
              Card(
                child: ListenableBuilder(
                  listenable: SyncController.instance,
                  builder: (context, _) {
                    final sync = SyncController.instance;
                    return ListTile(
                      leading: Icon(
                        Icons.cloud_done_outlined,
                        color: sync.isSyncing
                            ? Colors.blueAccent
                            : sync.hasPending
                                ? Colors.amber
                                : Colors.green,
                      ),
                      title: Text(context.l10n.cloudStatus),
                      subtitle: Text(
                        sync.isSyncing
                            ? context.l10n.syncingNow
                            : sync.hasPending
                                ? context.l10n.pendingChangesCount(sync.pendingCount)
                                : context.l10n.fullySynced,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),

              // إصدار التطبيق
              Card(
                child: ListTile(
                  leading: Icon(Icons.info_outline, color: AppColors.textMuted(context)),
                  title: Text(context.l10n.appVersion),
                  subtitle: Text('Tasky ${AppVersion.shortVersion} (${AppVersion.version})'),
                ),
              ),
              const SizedBox(height: 24),

              // تسجيل الخروج
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                onPressed: () async {
                  await auth.signOut();
                  if (mounted && context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.logout, size: 18),
                label: Text(context.l10n.signOut),
              ),
            ],
          );
        },
      ),
    );
  }
}
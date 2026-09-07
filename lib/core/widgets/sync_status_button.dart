import 'package:flutter/material.dart';
import '../services/sync_controller.dart';

/// زر ذكي وتفاعلي في الهيدر يعرض حالة المزامنة ويتيح طلبها بضغطة زر
class SyncStatusButton extends StatefulWidget {
  final Future<void> Function()? onTriggerSync;

  const SyncStatusButton({super.key, this.onTriggerSync});

  @override
  State<SyncStatusButton> createState() => _SyncStatusButtonState();
}

class _SyncStatusButtonState extends State<SyncStatusButton> with SingleTickerProviderStateMixin {
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SyncController.instance,
      builder: (context, _) {
        final sync = SyncController.instance;

        if (sync.isSyncing) {
          if (!_rotationController.isAnimating) {
            _rotationController.repeat();
          }
        } else {
          if (_rotationController.isAnimating) {
            _rotationController.stop();
            _rotationController.reset();
          }
        }

        // تحديد اللون والأيقونة والنص التوضيحي بقيم أولية آمنة
        Color color = Colors.green;
        Widget iconWidget = const Icon(Icons.cloud_done_rounded, size: 18, color: Colors.green);
        String tooltip = 'جميع بياناتك متزامنة مع السحابة ()';

        switch (sync.state) {
          case SyncStatusState.synced:
            color = Colors.green;
            iconWidget = const Icon(Icons.cloud_done_rounded, size: 18, color: Colors.green);
            tooltip = 'جميع بياناتك متزامنة مع السحابة ()';
            break;

          case SyncStatusState.syncing:
            color = Theme.of(context).colorScheme.primary;
            iconWidget = RotationTransition(
              turns: _rotationController,
              child: const Icon(Icons.sync_rounded, size: 18, color: Colors.blueAccent),
            );
            tooltip = 'جاري المزامنة مع السحابة الآن...';
            break;

          case SyncStatusState.pending:
            color = Colors.amber.shade700;
            iconWidget = Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.cloud_upload_outlined, size: 18, color: Colors.amber),
                if (sync.pendingCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                      constraints: const BoxConstraints(minWidth: 12, minHeight: 12),
                      child: Text(
                        '',
                        style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
            tooltip = 'توجد  تعديلات محلية بانتظار الرفع. اضغط للمزامنة.';
            break;

          case SyncStatusState.offline:
            color = Colors.grey;
            iconWidget = const Icon(Icons.cloud_off_rounded, size: 18, color: Colors.grey);
            tooltip = 'وضع أوفلاين. يعمل التطبيق محلياً بالكامل.';
            break;

          case SyncStatusState.error:
            color = Colors.redAccent;
            iconWidget = const Icon(Icons.sync_problem_rounded, size: 18, color: Colors.redAccent);
            tooltip = sync.errorMessage ?? 'تعذر الاتصال بالسحابة. اضغط للمحاولة مجدداً.';
            break;
        }

        return Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: () {
              if (sync.isSyncing) return;
              sync.triggerSync(onPerformSync: widget.onTriggerSync);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    sync.hasPending
                        ? 'جاري رفع التعديلات السحابية...'
                        : 'جاري فحص وتحديث البيانات مع السحابة...',
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  iconWidget,
                  const SizedBox(width: 6),
                  Text(
                    sync.isSyncing
                        ? 'مزامنة...'
                        : sync.hasPending
                            ? ' معلق'
                            : 'متزامن',
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

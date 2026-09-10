import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import '../services/sync_controller.dart';

/// زر ذكي وتفاعلي في الهيدر يعرض حالة المزامنة ويتيح طلبها بضغطة زر
class SyncStatusButton extends StatefulWidget {
  final Future<void> Function()? onTriggerSync;
  final bool compact;

  const SyncStatusButton({
    super.key,
    this.onTriggerSync,
    this.compact = false,
  });

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
        final l10n = context.l10n;
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
        String tooltip = l10n.syncAllSynced;

        switch (sync.state) {
          case SyncStatusState.synced:
            color = Colors.green;
            iconWidget = const Icon(Icons.cloud_done_rounded, size: 18, color: Colors.green);
            tooltip = l10n.syncAllSynced;
            break;

          case SyncStatusState.syncing:
            color = Theme.of(context).colorScheme.primary;
            iconWidget = RotationTransition(
              turns: _rotationController,
              child: const Icon(Icons.sync_rounded, size: 18, color: Colors.blueAccent),
            );
            tooltip = l10n.syncInProgressNow;
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
                        '${sync.pendingCount}',
                        style: const TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
            tooltip = l10n.syncPendingTooltip(sync.pendingCount);
            break;

          case SyncStatusState.offline:
            color = Colors.grey;
            iconWidget = const Icon(Icons.cloud_off_rounded, size: 18, color: Colors.grey);
            tooltip = l10n.syncOffline;
            break;

          case SyncStatusState.error:
            color = Colors.redAccent;
            iconWidget = const Icon(Icons.sync_problem_rounded, size: 18, color: Colors.redAccent);
            tooltip = sync.errorMessage ?? l10n.syncFailedTapRetry;
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
                        ? l10n.syncUploading
                        : l10n.syncChecking,
                  ),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: widget.compact
                  ? const EdgeInsets.all(8)
                  : const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: widget.compact ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: widget.compact ? null : BorderRadius.circular(20),
                border: Border.all(color: color.withOpacity(0.3), width: 1),
              ),
              child: widget.compact
                  ? iconWidget
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        iconWidget,
                        const SizedBox(width: 6),
                        Text(
                          sync.isSyncing
                              ? l10n.syncNowButton
                              : sync.hasPending
                                  ? l10n.syncPending(sync.pendingCount)
                                  : l10n.syncSynced,
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

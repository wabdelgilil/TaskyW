import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/audio_briefing_controller.dart';

/// شريط التحكم العائم في القراءة الصوتية للمهام (Floating Audio Briefing Bar)
/// يظهر أسفل مساحة العمل تلقائياً أثناء تشغيل النطق الصوتي أو إيقافه مؤقتاً
class AudioBriefingBar extends StatefulWidget {
  const AudioBriefingBar({super.key});

  @override
  State<AudioBriefingBar> createState() => _AudioBriefingBarState();
}

class _AudioBriefingBarState extends State<AudioBriefingBar> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AudioBriefingController.instance;

    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.isActive) {
          return const SizedBox.shrink();
        }

        final isDark = Theme.of(context).brightness == Brightness.dark;
        final currentTask = controller.currentTask;
        final currentIndex = controller.currentIndex;
        final total = controller.totalTasks;
        final isPlaying = controller.isPlaying;

        // نص العنوان للمهمة أو المقدمة
        String subtitle;
        if (currentIndex < 0) {
          subtitle = controller.contextTitle != null
              ? '${context.l10n.readingTasks} (${controller.contextTitle})'
              : context.l10n.readingTasks;
        } else if (currentTask != null) {
          subtitle = currentTask.title;
        } else {
          subtitle = context.l10n.readingTasks;
        }

        final progressText = currentIndex >= 0
            ? context.l10n.audioBarTaskProgress(currentIndex + 1, total)
            : '${total > 0 ? total : 0} ${context.l10n.filterAll}';

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2430) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.35),
              width: 1.4,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // 1. أيقونة الصوت النابضة
              AnimatedBuilder(
                animation: _animController,
                builder: (context, child) {
                  final scale = isPlaying ? 1.0 + (_animController.value * 0.12) : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.14),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPlaying ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),

              // 2. تفاصيل المهمة والعداد
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            controller.contextTitle ?? context.l10n.readTasksAloud,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            progressText,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary(context),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // 3. أزرار التحكم في التشغيل
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // زر السابق
                  IconButton(
                    icon: const Icon(Icons.skip_previous_rounded, size: 22),
                    tooltip: context.l10n.audioPrevious,
                    onPressed: currentIndex > 0
                        ? () => controller.previous(
                              languageCode: Localizations.localeOf(context).languageCode,
                            )
                        : null,
                  ),

                  // زر تشغيل / إيقاف مؤقت
                  IconButton.filled(
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.all(6),
                      minimumSize: const Size(36, 36),
                    ),
                    icon: Icon(
                      isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      size: 20,
                    ),
                    tooltip: isPlaying ? context.l10n.audioPause : context.l10n.audioResume,
                    onPressed: () {
                      if (isPlaying) {
                        controller.pause();
                      } else {
                        controller.resume(
                          languageCode: Localizations.localeOf(context).languageCode,
                        );
                      }
                    },
                  ),

                  // زر التالي
                  IconButton(
                    icon: const Icon(Icons.skip_next_rounded, size: 22),
                    tooltip: context.l10n.audioNext,
                    onPressed: currentIndex < total - 1
                        ? () => controller.next(
                              languageCode: Localizations.localeOf(context).languageCode,
                            )
                        : null,
                  ),

                  // زر الإغلاق والإنهاء
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    tooltip: context.l10n.audioStop,
                    onPressed: () => controller.stop(),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

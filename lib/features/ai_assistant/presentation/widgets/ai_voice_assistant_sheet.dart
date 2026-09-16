import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tasky/features/settings/presentation/screens/settings_screen.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import '../controllers/ai_assistant_controller.dart';

/// نافذة المساعد الصوتي والذكاء الاصطناعي التفاعلية لـ TaskyW
class AiVoiceAssistantSheet extends StatefulWidget {
  final List<ProjectModel> projects;
  final List<AreaModel> areas;
  final List<TaskModel> tasks;
  final Function(TaskModel)? onSaveTask;

  const AiVoiceAssistantSheet({
    super.key,
    this.projects = const [],
    this.areas = const [],
    this.tasks = const [],
    this.onSaveTask,
  });

  static Future<void> show(
    BuildContext context, {
    List<ProjectModel>? projects,
    List<AreaModel>? areas,
    List<TaskModel>? tasks,
    Function(TaskModel)? onSaveTask,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AiVoiceAssistantSheet(
        projects: projects ?? const [],
        areas: areas ?? const [],
        tasks: tasks ?? const [],
        onSaveTask: onSaveTask,
      ),
    );
  }

  @override
  State<AiVoiceAssistantSheet> createState() => _AiVoiceAssistantSheetState();
}

class _AiVoiceAssistantSheetState extends State<AiVoiceAssistantSheet>
    with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _sendText(BuildContext context, String text) {
    if (text.trim().isEmpty) return;
    final aiController = AiAssistantController.instance;

    aiController.processTextCommand(
      text,
      projects: widget.projects,
      areas: widget.areas,
      tasks: widget.tasks,
      onSaveTask: widget.onSaveTask,
    );
    _textController.clear();
  }

  void _toggleRecording(BuildContext context) async {
    final aiController = AiAssistantController.instance;

    if (aiController.isRecording) {
      await aiController.stopAndProcessRecording(
        projects: widget.projects,
        areas: widget.areas,
        tasks: widget.tasks,
        onSaveTask: widget.onSaveTask,
      );
    } else {
      await aiController.startRecording();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = SettingsController.instance;
    final aiController = AiAssistantController.instance;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AnimatedBuilder(
      animation: Listenable.merge([settings, aiController]),
      builder: (context, _) {
        final hasKey = settings.hasValidAiKey;

        return Container(
          margin: EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: bottomInset + 16,
            top: 40,
          ),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E2028) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ─── مقبض السحب وشريط الرأس ──────────────────────────────────────
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'المساعد الصوتي الذكي (Tasky AI)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _getSubTitle(aiController, hasKey),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[400] : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20),
                      onPressed: () {
                        aiController.cancelRecording();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // ─── محتوى النافذة ──────────────────────────────────────────────
              if (!hasKey)
                _buildNoKeyView(context)
              else
                _buildActiveAiView(context, aiController),
            ],
          ),
        );
      },
    );
  }

  String _getSubTitle(AiAssistantController controller, bool hasKey) {
    if (!hasKey) return 'مفتاح Gemini API مطلوب للبدء';
    switch (controller.state) {
      case AiAssistantState.recording:
        return '🔴 جاري الاستماع... اضغط لإنهاء التحدث';
      case AiAssistantState.processing:
        return '⚡ جاري التحليل والتنفيذ...';
      case AiAssistantState.speaking:
        return '🔊 يتحدث الآن...';
      case AiAssistantState.success:
        return '✅ تم تنفيذ الأمر بنجاح';
      case AiAssistantState.error:
        return '⚠️ تعذر إكمال الأمر';
      case AiAssistantState.idle:
        return 'تحدث بصوتك أو اكتب أمرك بالأسفل';
    }
  }

  /// واجهة طلب إدخال المفتاح الشخصي (BYOK)
  Widget _buildNoKeyView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
            ),
            child: const Row(
              children: [
                Icon(Icons.key_rounded, color: Colors.amber, size: 30),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مفتاح Gemini API مطلوب',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'لحماية خصوصيتك ولضمان استخدام مجاني وغير محدود، يتطلب المساعد تسجيل مفتاحك الشخصي المجاني من Google AI Studio.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: const Text('الحصول على مفتاح مجاناً'),
                  onPressed: () {
                    launchUrl(
                      Uri.parse('https://aistudio.google.com/app/apikey'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  icon: const Icon(Icons.settings, size: 16),
                  label: const Text('فتح الإعدادات'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// واجهة المساعد التفاعلية عند توفر المفتاح
  Widget _buildActiveAiView(BuildContext context, AiAssistantController controller) {
    final isRecording = controller.isRecording;
    final isProcessing = controller.isProcessing;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        children: [
          // 1. زر الميكروفون التفاعلي المركزي مع تأثير النبض
          GestureDetector(
            onTap: isProcessing ? null : () => _toggleRecording(context),
            child: AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                final scale = isRecording ? 1.0 + (_pulseController.value * 0.12) : 1.0;
                final ringColor = isRecording ? Colors.redAccent : AppColors.primary;

                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isRecording
                          ? Colors.redAccent
                          : AppColors.primary.withValues(alpha: 0.12),
                      border: Border.all(
                        color: ringColor,
                        width: isRecording ? 3 : 2,
                      ),
                      boxShadow: isRecording
                          ? [
                              BoxShadow(
                                color: Colors.redAccent.withValues(alpha: 0.4),
                                blurRadius: 18,
                                spreadRadius: 4,
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: isProcessing
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(strokeWidth: 3),
                            )
                          : Icon(
                              isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                              size: 36,
                              color: isRecording ? Colors.white : AppColors.primary,
                            ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Text(
            isRecording
                ? 'اضغط هنا لإنهاء التسجيل ومعالجة الأمر'
                : 'اضغط على الميكروفون للتحدث بأمرك',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),

          // 2. رسالة الحالة أو النتيجة أو الخطأ
          if (controller.statusMessage != null || controller.errorMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: controller.errorMessage != null
                    ? Colors.redAccent.withValues(alpha: 0.1)
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.errorMessage != null
                      ? Colors.redAccent.withValues(alpha: 0.3)
                      : AppColors.primary.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    controller.errorMessage != null
                        ? Icons.error_outline_rounded
                        : Icons.info_outline_rounded,
                    size: 18,
                    color: controller.errorMessage != null
                        ? Colors.redAccent
                        : AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      controller.errorMessage ?? controller.statusMessage!,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: controller.errorMessage != null
                            ? Colors.redAccent
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // 3. أزرار الاقتراحات السريعة
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _SuggestionChip(
                  icon: Icons.headphones_rounded,
                  label: 'اقرأ مهام اليوم',
                  onTap: () => _sendText(context, 'اقرأ ليا مهام اليوم'),
                ),
                const SizedBox(width: 8),
                _SuggestionChip(
                  icon: Icons.list_alt_rounded,
                  label: 'اقرأ كل المهام النشطة',
                  onTap: () => _sendText(context, 'اقرأ كل المهام'),
                ),
                const SizedBox(width: 8),
                _SuggestionChip(
                  icon: Icons.warning_amber_rounded,
                  label: 'اقرأ المهام العاجلة',
                  onTap: () => _sendText(context, 'اقرأ المهام العاجلة'),
                ),
                const SizedBox(width: 8),
                _SuggestionChip(
                  icon: Icons.add_task_rounded,
                  label: 'أضف مهمة غداً',
                  onTap: () => _sendText(
                      context, 'أضف مهمة مراجعة المهام غداً الساعة 10 صباحاً'),
                ),
              ],
            ),
          ),

          // 4. حقل الإدخال النصي السريع البديل
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: 'أو اكتب أمرك هنا (مثال: أضف مهمة كذا...)',
                    hintStyle: const TextStyle(fontSize: 12.5),
                    isDense: true,
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onSubmitted: (val) => _sendText(context, val),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                icon: const Icon(Icons.send_rounded, size: 18),
                onPressed: () => _sendText(context, _textController.text),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(label, style: const TextStyle(fontSize: 11.5)),
          ],
        ),
      ),
    );
  }
}

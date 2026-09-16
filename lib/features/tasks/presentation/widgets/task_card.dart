import 'package:flutter/material.dart';
import 'package:tasky/core/l10n/localization_x.dart';
import 'package:tasky/features/tags/data/models/tag_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/priority_badge.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../data/models/task_model.dart';
import '../controllers/audio_briefing_controller.dart';

/// كارت عرض المهمة بتصميم عصري وأنيق مع دعم التخصيص اللوني والشارات التفاعلية
/// وتباين حاد وواضح عند مرور المؤشر (Hover) عبر كافة أنماط العرض الثلاثة.
class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback? onTap;
  final ValueChanged<bool?>? onToggleCompleted;
  final int completedSubtasksCount;
  final int totalSubtasksCount;
  final String? projectName;
  final String? projectEmoji;
  final String? areaName;
  final List<TagModel> tags;
  final VoidCallback? onProjectBadgeTap;
  final Color? projectColor;
  final bool isCompact;

  const TaskCard({
    super.key,
    required this.task,
    this.onTap,
    this.onToggleCompleted,
    this.completedSubtasksCount = 0,
    this.totalSubtasksCount = 0,
    this.projectName,
    this.projectEmoji,
    this.areaName,
    this.tags = const [],
    this.onProjectBadgeTap,
    this.projectColor,
    this.isCompact = false,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isHovered = false;

  bool get isCompleted => widget.task.status == 'completed';

  Color get priorityColor {
    switch (widget.task.priority) {
      case 'urgent':
        return AppColors.priorityUrgent;
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
      default:
        return AppColors.priorityLow;
    }
  }

  bool get isOverdue {
    if (widget.task.dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final due = DateTime(
      widget.task.dueDate!.year,
      widget.task.dueDate!.month,
      widget.task.dueDate!.day,
    );
    return due.isBefore(today);
  }

  bool get isDueToday {
    if (widget.task.dueDate == null || isCompleted) return false;
    final now = DateTime.now();
    return widget.task.dueDate!.year == now.year &&
        widget.task.dueDate!.month == now.month &&
        widget.task.dueDate!.day == now.day;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isOled = AppColors.isOled(context);

    final rawColor = widget.task.colorHex != null
        ? AppColors.fromHex(widget.task.colorHex)
        : null;
    final customColor = rawColor != null
        ? AppColors.adaptiveCustomColor(rawColor, isDark)
        : null;
    final badgeColor = widget.projectColor != null
        ? AppColors.adaptiveCustomColor(widget.projectColor!, isDark)
        : null;

    final briefingController = AudioBriefingController.instance;

    return ListenableBuilder(
      listenable: briefingController,
      builder: (context, _) {
        final isCurrentlySpoken =
            briefingController.currentTaskId == widget.task.id;

        // ─── احتساب ألوان الكارت التفاعلية بناءً على النمط والتحويم ────────
        Color cardBg;
        Color borderColor;
        Color titleColor;
        Color descColor;
        Color metaTextColor;

        if (!isDark) {
          // الوضع النهاري: الكارت الساكن أبيض ➔ عند التحويم يصبح غامقاً مع نص أبيض
          if (_isHovered) {
            cardBg = customColor != null
                ? Color.alphaBlend(
                    customColor.withValues(alpha: 0.22),
                    const Color(0xFF0F172A),
                  )
                : const Color(0xFF0F172A); // Slate 900 غامق حاد ومتباين
            borderColor = customColor ?? AppColors.brandLight;
            titleColor = isCompleted
                ? const Color(0xFF94A3B8)
                : Colors.white;
            descColor = const Color(0xFFCBD5E1); // Slate 300 واضح ومريح
            metaTextColor = const Color(0xFFE2E8F0);
          } else {
            cardBg = customColor != null
                ? customColor.withValues(alpha: 0.08)
                : Colors.white;
            borderColor = customColor != null
                ? customColor.withValues(alpha: 0.50)
                : AppColors.border(context);
            titleColor = isCompleted
                ? AppColors.textMuted(context)
                : AppColors.textPrimary(context);
            descColor = AppColors.textSecondary(context);
            metaTextColor = AppColors.textSecondary(context);
          }
        } else if (isOled) {
          // وضع السواد التام (OLED): الكارت الساكن أوبسيديان ➔ عند التحويم يرتفع وميضه بوضوح
          if (_isHovered) {
            cardBg = customColor != null
                ? Color.alphaBlend(
                    customColor.withValues(alpha: 0.28),
                    const Color(0xFF232A36),
                  )
                : const Color(0xFF232A36);
            borderColor = customColor ?? AppColors.brandLight;
            titleColor = Colors.white;
            descColor = const Color(0xFFF8FAFC);
            metaTextColor = const Color(0xFFE2E8F0);
          } else {
            cardBg = customColor != null
                ? customColor.withValues(alpha: 0.14)
                : AppColors.oledCard;
            borderColor = customColor != null
                ? customColor.withValues(alpha: 0.65)
                : AppColors.oledBorder;
            titleColor = isCompleted
                ? AppColors.textMuted(context)
                : AppColors.textPrimary(context);
            descColor = AppColors.textSecondary(context);
            metaTextColor = AppColors.textSecondary(context);
          }
        } else {
          // الوضع الليلي (Dark Slate): الكارت الساكن #243247 ➔ عند التحويم يرتفع ويزداد سطوعاً
          if (_isHovered) {
            cardBg = customColor != null
                ? Color.alphaBlend(
                    customColor.withValues(alpha: 0.24),
                    const Color(0xFF334561),
                  )
                : const Color(0xFF334561);
            borderColor = customColor ?? AppColors.brandLight;
            titleColor = Colors.white;
            descColor = const Color(0xFFF1F5F9);
            metaTextColor = const Color(0xFFE2E8F0);
          } else {
            cardBg = customColor != null
                ? customColor.withValues(alpha: 0.14)
                : AppColors.darkCard;
            borderColor = customColor != null
                ? customColor.withValues(alpha: 0.65)
                : AppColors.darkBorder;
            titleColor = isCompleted
                ? AppColors.textMuted(context)
                : AppColors.textPrimary(context);
            descColor = AppColors.textSecondary(context);
            metaTextColor = AppColors.textSecondary(context);
          }
        }

        if (widget.isCompact) {
          return MouseRegion(
            onEnter: (_) {
              if (!_isHovered) setState(() => _isHovered = true);
            },
            onExit: (_) {
              if (_isHovered) setState(() => _isHovered = false);
            },
            child: _buildCompactCard(
              context,
              isDark: isDark,
              customColor: customColor,
              badgeColor: badgeColor,
              isCurrentlySpoken: isCurrentlySpoken,
              cardBg: cardBg,
              borderColor: borderColor,
              titleColor: titleColor,
              metaTextColor: metaTextColor,
            ),
          );
        }

        return MouseRegion(
          onEnter: (_) {
            if (!_isHovered) setState(() => _isHovered = true);
          },
          onExit: (_) {
            if (_isHovered) setState(() => _isHovered = false);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 140),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: isCurrentlySpoken
                  ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06)
                  : cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isCurrentlySpoken
                    ? AppColors.primary
                    : (_isHovered
                        ? borderColor
                        : (customColor != null
                            ? (isDark
                                ? customColor.withValues(alpha: 0.65)
                                : customColor.withValues(alpha: 0.50))
                            : AppColors.border(context))),
                width: isCurrentlySpoken
                    ? 2.0
                    : (_isHovered ? 1.6 : (customColor != null ? 1.5 : 1)),
              ),
              boxShadow: [
                BoxShadow(
                  color: isCurrentlySpoken
                      ? AppColors.primary.withValues(alpha: 0.35)
                      : (_isHovered
                          ? (isDark
                              ? Colors.black.withValues(alpha: 0.35)
                              : Colors.black.withValues(alpha: 0.15))
                          : (isDark
                              ? Colors.transparent
                              : Colors.black.withValues(alpha: 0.06))),
                  blurRadius: _isHovered ? 8 : (isCurrentlySpoken ? 6 : 3),
                  offset: Offset(0, _isHovered ? 3 : 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(12),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // شريط اللون المخصص الجانبي
                      if (customColor != null)
                        Container(
                          width: 5,
                          color: customColor,
                        ),

                      // المحتوى الرئيسي
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // صف العنوان وصندوق الاختيار
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Transform.scale(
                                    scale: 0.9,
                                    child: Checkbox(
                                      value: isCompleted,
                                      activeColor: customColor ??
                                          AppColors.statusCompleted,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      side: _isHovered && !isDark
                                          ? const BorderSide(
                                              color: Colors.white70,
                                              width: 1.5,
                                            )
                                          : null,
                                      onChanged: widget.onToggleCompleted,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              widget.task.title,
                                              style: TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w600,
                                                decoration: isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                                color: titleColor,
                                              ),
                                            ),
                                          ),
                                          if (isCurrentlySpoken) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: AppColors.primary
                                                    .withValues(alpha: 0.18),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.volume_up_rounded,
                                                    size: 14,
                                                    color: AppColors.primary,
                                                  ),
                                                  const SizedBox(width: 3),
                                                  Text(
                                                    context.l10n.readingTasks,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: AppColors.primary,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // وصف مقتضب إن وجد
                              if (widget.task.description != null &&
                                  widget.task.description!.trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Padding(
                                  padding: const EdgeInsets.only(right: 36),
                                  child: Text(
                                    widget.task.description!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: descColor,
                                    ),
                                  ),
                                ),
                              ],

                              const SizedBox(height: 10),

                              // صف الشارات والمعلومات السفلية
                              Padding(
                                padding: const EdgeInsets.only(right: 36),
                                child: Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    // شارة الحالة
                                    StatusBadge(status: widget.task.status),

                                    // شارة الأولوية
                                    PriorityBadge(
                                      priority: widget.task.priority,
                                    ),

                                    // مؤشر المهام الفرعية
                                    if (widget.totalSubtasksCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _isHovered && !isDark
                                              ? Colors.white.withValues(alpha: 0.12)
                                              : (isDark
                                                  ? Colors.black26
                                                  : Colors.black.withValues(
                                                      alpha: 0.04)),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: _isHovered && !isDark
                                                ? Colors.white24
                                                : AppColors.border(context),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.checklist_rounded,
                                              size: 12,
                                              color: widget.completedSubtasksCount ==
                                                      widget.totalSubtasksCount
                                                  ? AppColors.statusCompleted
                                                  : metaTextColor,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${widget.completedSubtasksCount}/${widget.totalSubtasksCount}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: widget.completedSubtasksCount ==
                                                        widget.totalSubtasksCount
                                                    ? AppColors.statusCompleted
                                                    : metaTextColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // تاريخ الديدلاين
                                    if (widget.task.dueDate != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isOverdue
                                              ? AppColors.priorityUrgent
                                                  .withValues(alpha: 0.2)
                                              : (isDueToday
                                                  ? AppColors.statusInProgress
                                                      .withValues(alpha: 0.2)
                                                  : (_isHovered && !isDark
                                                      ? Colors.white.withValues(
                                                          alpha: 0.12)
                                                      : (isDark
                                                          ? Colors.black26
                                                          : Colors.black.withValues(
                                                              alpha: 0.04)))),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.calendar_today_rounded,
                                              size: 11,
                                              color: isOverdue
                                                  ? AppColors.priorityUrgent
                                                  : (isDueToday
                                                      ? AppColors.statusInProgress
                                                      : (_isHovered && !isDark
                                                          ? const Color(
                                                              0xFFCBD5E1)
                                                          : Colors.grey)),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${widget.task.dueDate!.day}/${widget.task.dueDate!.month}',
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: isOverdue
                                                  ? AppColors.priorityUrgent
                                                  : (isDueToday
                                                      ? AppColors.statusInProgress
                                                      : (_isHovered && !isDark
                                                          ? const Color(
                                                              0xFFCBD5E1)
                                                          : Colors.grey)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // اسم المشروع التابع له
                                    if (widget.projectName != null)
                                      InkWell(
                                        onTap: widget.onProjectBadgeTap,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: badgeColor != null
                                                ? badgeColor.withValues(
                                                    alpha: isDark ? 0.22 : 0.12)
                                                : (_isHovered && !isDark
                                                    ? Colors.white.withValues(
                                                        alpha: 0.12)
                                                    : (isDark
                                                        ? Colors.white
                                                            .withValues(
                                                                alpha: 0.05)
                                                        : Colors.black
                                                            .withValues(
                                                                alpha: 0.04))),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: badgeColor != null
                                                ? Border.all(
                                                    color: badgeColor
                                                        .withValues(
                                                            alpha: isDark
                                                                ? 0.6
                                                                : 0.45),
                                                    width: 0.9,
                                                  )
                                                : null,
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              if (widget.projectEmoji != null) ...[
                                                Text(
                                                  widget.projectEmoji!,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                  ),
                                                ),
                                                const SizedBox(width: 4),
                                              ],
                                              Text(
                                                widget.projectName!,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                  color: badgeColor != null
                                                      ? AppColors
                                                          .adaptiveCustomColor(
                                                          badgeColor,
                                                          isDark || _isHovered,
                                                        )
                                                      : metaTextColor,
                                                ),
                                              ),
                                              if (widget.onProjectBadgeTap !=
                                                  null) ...[
                                                const SizedBox(width: 3),
                                                Icon(
                                                  Icons.open_in_new,
                                                  size: 10,
                                                  color: badgeColor != null
                                                      ? AppColors
                                                          .adaptiveCustomColor(
                                                          badgeColor,
                                                          isDark || _isHovered,
                                                        )
                                                      : metaTextColor,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ),

                                    // شارة المهمة المتكررة
                                    if (widget.task.isRecurring)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isDark
                                              ? const Color(0xFF8B5CF6)
                                                  .withValues(alpha: 0.2)
                                              : const Color(0xFF8B5CF6)
                                                  .withValues(alpha: 0.1),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color: isDark
                                                ? const Color(0xFFA78BFA)
                                                    .withValues(alpha: 0.4)
                                                : const Color(0xFF7C3AED)
                                                    .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.repeat_rounded,
                                              size: 11,
                                              color: Color(0xFF8B5CF6),
                                            ),
                                            const SizedBox(width: 3),
                                            Text(
                                              widget.task.recurrencePattern ==
                                                      'daily'
                                                  ? context.l10n.recurrenceDaily
                                                  : (widget.task.recurrencePattern ==
                                                          'weekly'
                                                      ? context.l10n
                                                          .recurrenceWeekly
                                                      : (widget.task.recurrencePattern ==
                                                              'monthly'
                                                          ? context.l10n
                                                              .recurrenceMonthly
                                                          : context.l10n
                                                              .recurrenceRecurring)),
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF8B5CF6),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                    // شارات الوسوم
                                    for (final tag in widget.tags)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                          vertical: 2.5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.fromHex(tag.colorHex)
                                              .withValues(
                                            alpha: isDark || _isHovered
                                                ? 0.25
                                                : 0.12,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                          border: Border.all(
                                            color:
                                                AppColors.fromHex(tag.colorHex)
                                                    .withValues(
                                              alpha: isDark || _isHovered
                                                  ? 0.7
                                                  : 0.4,
                                            ),
                                            width: 0.9,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              width: 6,
                                              height: 6,
                                              decoration: BoxDecoration(
                                                color: AppColors.fromHex(
                                                  tag.colorHex,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              tag.name,
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                                color:
                                                    AppColors.adaptiveCustomColor(
                                                  AppColors.fromHex(
                                                    tag.colorHex,
                                                  ),
                                                  isDark || _isHovered,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// كارت المهمة المضغوط (Single-Line Compact Card) لعرض أكبر عدد من المهام في الشاشة
  Widget _buildCompactCard(
    BuildContext context, {
    required bool isDark,
    required Color? customColor,
    required Color? badgeColor,
    required bool isCurrentlySpoken,
    required Color cardBg,
    required Color borderColor,
    required Color titleColor,
    required Color metaTextColor,
  }) {
    final indicatorColor = customColor ?? priorityColor;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: isCurrentlySpoken
            ? AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.06)
            : cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCurrentlySpoken
              ? AppColors.primary
              : (_isHovered
                  ? borderColor
                  : (customColor != null
                      ? (isDark
                          ? customColor.withValues(alpha: 0.6)
                          : customColor.withValues(alpha: 0.45))
                      : AppColors.border(context))),
          width: isCurrentlySpoken
              ? 1.8
              : (_isHovered ? 1.4 : (customColor != null ? 1.2 : 0.8)),
        ),
        boxShadow: [
          BoxShadow(
            color: isCurrentlySpoken
                ? AppColors.primary.withValues(alpha: 0.3)
                : (_isHovered
                    ? (isDark
                        ? Colors.black.withValues(alpha: 0.3)
                        : Colors.black.withValues(alpha: 0.12))
                    : (isDark
                        ? Colors.transparent
                        : Colors.black.withValues(alpha: 0.05))),
            blurRadius: _isHovered ? 6 : (isCurrentlySpoken ? 4 : 2),
            offset: Offset(0, _isHovered ? 2 : 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(8),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // مؤشر اللون/الأولوية الجانبي الرفيع
                Container(
                  width: 3.5,
                  color: indicatorColor,
                ),

                // المحتوى المضغوط في سطر واحد
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        // مربع الاختيار المصغر
                        SizedBox(
                          width: 26,
                          height: 26,
                          child: Transform.scale(
                            scale: 0.82,
                            child: Checkbox(
                              value: isCompleted,
                              activeColor:
                                  customColor ?? AppColors.statusCompleted,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              side: _isHovered && !isDark
                                  ? const BorderSide(
                                      color: Colors.white70,
                                      width: 1.5,
                                    )
                                  : null,
                              onChanged: widget.onToggleCompleted,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),

                        // عنوان المهمة (سطر واحد فقط)
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  widget.task.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w500,
                                    decoration: isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                                    color: titleColor,
                                  ),
                                ),
                              ),
                              if (isCurrentlySpoken) ...[
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.volume_up_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(width: 6),

                        // الشارات الميكرو بالطرف المقابل
                        // 1. شارة المشروع المصغرة
                        if (widget.projectName != null) ...[
                          InkWell(
                            onTap: widget.onProjectBadgeTap,
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1.5,
                              ),
                              decoration: BoxDecoration(
                                color: badgeColor != null
                                    ? badgeColor.withValues(
                                        alpha: isDark ? 0.22 : 0.12)
                                    : (_isHovered && !isDark
                                        ? Colors.white.withValues(alpha: 0.12)
                                        : (isDark
                                            ? Colors.white
                                                .withValues(alpha: 0.06)
                                            : Colors.black
                                                .withValues(alpha: 0.05))),
                                borderRadius: BorderRadius.circular(4),
                                border: badgeColor != null
                                    ? Border.all(
                                        color: badgeColor.withValues(
                                          alpha: isDark ? 0.6 : 0.45,
                                        ),
                                        width: 0.8,
                                      )
                                    : null,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (widget.projectEmoji != null) ...[
                                    Text(
                                      widget.projectEmoji!,
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                    const SizedBox(width: 2),
                                  ],
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 75),
                                    child: Text(
                                      widget.projectName!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: badgeColor != null
                                            ? AppColors.adaptiveCustomColor(
                                                badgeColor,
                                                isDark || _isHovered,
                                              )
                                            : metaTextColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                        ],

                        // 2. عداد المهام الفرعية
                        if (widget.totalSubtasksCount > 0) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.checklist_rounded,
                                size: 12,
                                color: widget.completedSubtasksCount ==
                                        widget.totalSubtasksCount
                                    ? AppColors.statusCompleted
                                    : metaTextColor,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.completedSubtasksCount}/${widget.totalSubtasksCount}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  color: widget.completedSubtasksCount ==
                                          widget.totalSubtasksCount
                                      ? AppColors.statusCompleted
                                      : metaTextColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 5),
                        ],

                        // 3. تاريخ الاستحقاق
                        if (widget.task.dueDate != null) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 11,
                                color: isOverdue
                                    ? AppColors.priorityUrgent
                                    : (isDueToday
                                        ? AppColors.statusInProgress
                                        : (_isHovered && !isDark
                                            ? const Color(0xFFCBD5E1)
                                            : AppColors.textMuted(context))),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${widget.task.dueDate!.day}/${widget.task.dueDate!.month}',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: isOverdue
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isOverdue
                                      ? AppColors.priorityUrgent
                                      : (isDueToday
                                          ? AppColors.statusInProgress
                                          : (_isHovered && !isDark
                                              ? const Color(0xFFCBD5E1)
                                              : AppColors.textMuted(context))),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
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

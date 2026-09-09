import 'package:uuid/uuid.dart';

import '../data/models/subtask_model.dart';
import '../data/models/task_model.dart';
import '../domain/repositories/i_subtask_repository.dart';
import '../domain/repositories/i_task_repository.dart';

/// قيم أنماط التكرار المعتمدة.
class TaskRecurrencePattern {
  static const String daily = 'daily';
  static const String weekly = 'weekly';
  static const String monthly = 'monthly';
  static const String customInterval = 'custom_interval';
}

/// محرك المهام المتكررة: حساب الموعد التالي وإعادة توليد المهمة بعد الإنجاز.
class RecurrenceService {
  /// حساب الموعد التالي بناءً على التاريخ الأساسي ونمط التكرار.
  ///
  /// - daily: يضيف [interval] يوماً.
  /// - weekly: يضيف [interval] × 7 أيام.
  /// - monthly: يضيف [interval] شهراً مع معالجة نهاية الشهر (31 → 30/28).
  /// - custom_interval: يضيف [interval] يوماً.
  static DateTime calculateNextDueDate(
    DateTime baseDate,
    String pattern,
    int interval,
  ) {
    final safeInterval = interval <= 0 ? 1 : interval;
    switch (pattern) {
      case TaskRecurrencePattern.weekly:
        return baseDate.add(Duration(days: safeInterval * 7));
      case TaskRecurrencePattern.monthly:
        return _addMonths(baseDate, safeInterval);
      case TaskRecurrencePattern.daily:
      case TaskRecurrencePattern.customInterval:
      default:
        return baseDate.add(Duration(days: safeInterval));
    }
  }

  static DateTime _addMonths(DateTime date, int months) {
    final totalMonths = date.year * 12 + (date.month - 1) + months;
    final year = totalMonths ~/ 12;
    final month = totalMonths % 12 + 1;
    final lastDayOfMonth = DateTime(year, month + 1, 0).day;
    final day = date.day > lastDayOfMonth ? lastDayOfMonth : date.day;
    return DateTime(year, month, day, date.hour, date.minute, date.second, date.millisecond, date.microsecond);
  }

  /// إعادة توليد مهمة متكررة مكتملة: ينشئ مهمة جديدة بنفس الخصائص
  /// وموعد استحقاق مطابقاً لحساب التكرار، مع نسخ مهامها الفرعية (غير المكتملة).
  ///
  /// يرجع المهمة الجديدة، أو `null` إذا لم تكن المهمة متكررة أو انتهى التكرار.
  static Future<TaskModel?> generateNextRecurrence(
    TaskModel completedTask, {
    required ITaskRepository taskRepo,
    required ISubtaskRepository subtaskRepo,
  }) async {
    if (!completedTask.isRecurring) return null;
    final pattern = completedTask.recurrencePattern;
    if (pattern == null || pattern.isEmpty) return null;

    final baseDate = completedTask.dueDate ?? DateTime.now().toUtc();
    final nextDueDate = calculateNextDueDate(
      baseDate,
      pattern,
      completedTask.recurrenceInterval,
    );

    final endDate = completedTask.recurrenceEndDate;
    if (endDate != null && nextDueDate.isAfter(endDate)) return null;

    final now = DateTime.now().toUtc();
    final nextTask = TaskModel(
      id: const Uuid().v4(),
      areaId: completedTask.areaId,
      projectId: completedTask.projectId,
      title: completedTask.title,
      description: completedTask.description,
      status: 'todo',
      priority: completedTask.priority,
      colorHex: completedTask.colorHex,
      dueDate: nextDueDate,
      reminderTime: completedTask.reminderTime,
      shareToken: null,
      isRecurring: true,
      recurrencePattern: pattern,
      recurrenceInterval: completedTask.recurrenceInterval,
      recurrenceEndDate: completedTask.recurrenceEndDate,
      assignedTo: completedTask.assignedTo,
      orderIndex: completedTask.orderIndex,
      createdAt: now,
      updatedAt: now,
    );
    await taskRepo.insertTask(nextTask);

    final subtasks = await subtaskRepo.getSubtasksForTask(completedTask.id);
    for (final subtask in subtasks) {
      await subtaskRepo.insertSubtask(SubtaskModel(
        id: const Uuid().v4(),
        taskId: nextTask.id,
        title: subtask.title,
        orderIndex: subtask.orderIndex,
        createdAt: now,
        updatedAt: now,
      ));
    }

    return nextTask;
  }
}
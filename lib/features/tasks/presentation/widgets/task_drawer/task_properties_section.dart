import 'package:flutter/material.dart';
import 'package:tasky/core/theme/app_colors.dart';
import 'package:tasky/core/widgets/priority_badge.dart';
import 'package:tasky/core/widgets/status_badge.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';

/// مكون بطاقة الخصائص (الحالة، الأولوية، المجال، المشروع، الديدلاين، التنبيه، التكرار)
class TaskPropertiesSection extends StatelessWidget {
  final String status;
  final String priority;
  final String areaId;
  final String? projectId;
  final DateTime? dueDate;
  final DateTime? reminderTime;
  final bool isRecurring;
  final String recurrencePattern;
  final DateTime? recurrenceEndDate;
  final List<AreaModel> areas;
  final List<ProjectModel> projects;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<String> onAreaChanged;
  final ValueChanged<String?> onProjectChanged;
  final ValueChanged<DateTime?> onDueDateChanged;
  final ValueChanged<DateTime?> onReminderTimeChanged;
  final ValueChanged<bool> onIsRecurringChanged;
  final ValueChanged<String> onRecurrencePatternChanged;
  final ValueChanged<DateTime?> onRecurrenceEndDateChanged;

  const TaskPropertiesSection({
    super.key,
    required this.status,
    required this.priority,
    required this.areaId,
    required this.projectId,
    required this.dueDate,
    required this.reminderTime,
    required this.isRecurring,
    required this.recurrencePattern,
    required this.recurrenceEndDate,
    required this.areas,
    required this.projects,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onAreaChanged,
    required this.onProjectChanged,
    required this.onDueDateChanged,
    required this.onReminderTimeChanged,
    required this.onIsRecurringChanged,
    required this.onRecurrencePatternChanged,
    required this.onRecurrenceEndDateChanged,
  });

  @override
  Widget build(BuildContext context) {
    final areaProjects = projects.where((p) => p.areaId == areaId).toList();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border(context)),
      ),
      child: Column(
        children: [
          // الحالة والأولوية
          Row(
            children: [
              const SizedBox(width: 70, child: Text('الحالة:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
              Expanded(
                child: DropdownButton<String>(
                  value: status,
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'todo', child: StatusBadge(status: 'todo')),
                    DropdownMenuItem(value: 'in_progress', child: StatusBadge(status: 'in_progress')),
                    DropdownMenuItem(value: 'waiting', child: StatusBadge(status: 'waiting')),
                    DropdownMenuItem(value: 'review', child: StatusBadge(status: 'review')),
                    DropdownMenuItem(value: 'completed', child: StatusBadge(status: 'completed')),
                  ],
                  onChanged: (val) {
                    if (val != null) onStatusChanged(val);
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              const SizedBox(width: 70, child: Text('الأولوية:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
              Expanded(
                child: DropdownButton<String>(
                  value: priority,
                  isDense: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'low', child: PriorityBadge(priority: 'low')),
                    DropdownMenuItem(value: 'medium', child: PriorityBadge(priority: 'medium')),
                    DropdownMenuItem(value: 'high', child: PriorityBadge(priority: 'high')),
                    DropdownMenuItem(value: 'urgent', child: PriorityBadge(priority: 'urgent')),
                  ],
                  onChanged: (val) {
                    if (val != null) onPriorityChanged(val);
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          // المجال والمشروع
          Row(
            children: [
              const SizedBox(width: 70, child: Text('المجال:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
              Expanded(
                child: DropdownButton<String>(
                  value: areas.any((a) => a.id == areaId) ? areaId : null,
                  isDense: true,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: areas.map((a) {
                    return DropdownMenuItem(
                      value: a.id,
                      child: Text('${a.iconEmoji} ${a.name}', style: const TextStyle(fontSize: 13)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) onAreaChanged(val);
                  },
                ),
              ),
            ],
          ),
          if (areaProjects.isNotEmpty) ...[
            const Divider(height: 16),
            Row(
              children: [
                const SizedBox(width: 70, child: Text('المشروع:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
                Expanded(
                  child: DropdownButton<String?>(
                    value: projectId,
                    isDense: true,
                    isExpanded: true,
                    underline: const SizedBox(),
                    items: [
                      const DropdownMenuItem(value: null, child: Text('بدون مشروع (مهمة عامة)', style: TextStyle(fontSize: 12, color: Colors.grey))),
                      ...areaProjects.map((p) => DropdownMenuItem(value: p.id, child: Text('${p.iconEmoji} ${p.name}', style: const TextStyle(fontSize: 13)))),
                    ],
                    onChanged: (val) => onProjectChanged(val),
                  ),
                ),
              ],
            ),
          ],
          const Divider(height: 16),
          // تاريخ الديدلاين
          Row(
            children: [
              const SizedBox(width: 70, child: Text('الديدلاين:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2035),
                    );
                    if (picked != null) {
                      onDueDateChanged(picked);
                    }
                  },
                  child: Text(
                    dueDate != null ? '${dueDate!.year}/${dueDate!.month}/${dueDate!.day}' : 'تعيين موعد...',
                    style: TextStyle(
                      fontSize: 13,
                      color: dueDate != null ? Theme.of(context).colorScheme.primary : Colors.grey,
                      fontWeight: dueDate != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (dueDate != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                  splashRadius: 12,
                  onPressed: () => onDueDateChanged(null),
                ),
            ],
          ),
          const Divider(height: 16),
          // وقت التنبيه
          Row(
            children: [
              const SizedBox(width: 70, child: Text('التنبيه:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final now = DateTime.now();
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: reminderTime ?? dueDate ?? now,
                      firstDate: now,
                      lastDate: DateTime(2035),
                    );
                    if (pickedDate != null && context.mounted) {
                      final pickedTime = await showTimePicker(
                        context: context,
                        initialTime: reminderTime != null
                            ? TimeOfDay(hour: reminderTime!.hour, minute: reminderTime!.minute)
                            : const TimeOfDay(hour: 9, minute: 0),
                      );
                      if (pickedTime != null) {
                        onReminderTimeChanged(
                          DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          ),
                        );
                      }
                    }
                  },
                  child: Text(
                    reminderTime != null
                        ? '${reminderTime!.year}/${reminderTime!.month}/${reminderTime!.day} ${reminderTime!.hour.toString().padLeft(2, '0')}:${reminderTime!.minute.toString().padLeft(2, '0')}'
                        : 'ضبط تذكير...',
                    style: TextStyle(
                      fontSize: 13,
                      color: reminderTime != null ? Theme.of(context).colorScheme.primary : Colors.grey,
                      fontWeight: reminderTime != null ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
              if (reminderTime != null)
                IconButton(
                  icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                  splashRadius: 12,
                  onPressed: () => onReminderTimeChanged(null),
                ),
            ],
          ),
          const Divider(height: 16),
          // التكرار الدوري للمهمة
          Row(
            children: [
              const SizedBox(width: 70, child: Text('التكرار:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
              Expanded(
                child: Row(
                  children: [
                    Switch.adaptive(
                      value: isRecurring,
                      activeColor: const Color(0xFF8B5CF6),
                      onChanged: (val) => onIsRecurringChanged(val),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isRecurring ? 'مفعّل' : 'معطّل',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: isRecurring ? FontWeight.bold : FontWeight.normal,
                        color: isRecurring ? const Color(0xFF8B5CF6) : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isRecurring) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 70, child: Text('النمط:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
                Expanded(
                  child: DropdownButton<String>(
                    value: recurrencePattern,
                    isDense: true,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 'daily', child: Text('يومياً', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'weekly', child: Text('أسبوعياً', style: TextStyle(fontSize: 13))),
                      DropdownMenuItem(value: 'monthly', child: Text('شهرياً', style: TextStyle(fontSize: 13))),
                    ],
                    onChanged: (val) {
                      if (val != null) onRecurrencePatternChanged(val);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const SizedBox(width: 70, child: Text('ينتهي في:', style: TextStyle(fontSize: 12.5, color: Colors.grey))),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: recurrenceEndDate ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2035),
                      );
                      if (picked != null) {
                        onRecurrenceEndDateChanged(picked);
                      }
                    },
                    child: Text(
                      recurrenceEndDate != null
                          ? '${recurrenceEndDate!.year}/${recurrenceEndDate!.month}/${recurrenceEndDate!.day}'
                          : 'بدون تاريخ انتهاء (مستمر)',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: recurrenceEndDate != null ? Theme.of(context).colorScheme.primary : Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (recurrenceEndDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16, color: Colors.grey),
                    splashRadius: 12,
                    onPressed: () => onRecurrenceEndDateChanged(null),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

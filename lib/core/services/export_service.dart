import '../../features/tasks/data/models/task_model.dart';

/// خدمة تصدير المهام إلى CSV بدعم كامل للعربية (UTF-8 مع BOM).
class ExportService {
  static const String _bom = '\uFEFF';

  static const Map<String, String> _statusLabels = {
    'todo': 'قيد التنفيذ',
    'in_progress': 'جارٍ العمل',
    'waiting': 'في الانتظار',
    'review': 'قيد المراجعة',
    'completed': 'مكتملة',
  };

  static const Map<String, String> _priorityLabels = {
    'low': 'منخفضة',
    'medium': 'متوسطة',
    'high': 'عالية',
    'urgent': 'عاجلة',
  };

  /// توليد نص CSV لعمود مصدره [tasks].
  ///
  /// يبدأ النص بـ UTF-8 BOM لفتحه بشكل صحيح في Excel والمعالجات النصية,
  /// مع هروب الفواصل وعلامات الاقتباس داخل الخلايا.
  static String exportTasksToCsv({
    required List<TaskModel> tasks,
    Map<String, String>? projectNames,
    Map<String, String>? areaNames,
  }) {
    final header = _row([
      'العنوان',
      'الوصف',
      'المجال',
      'المشروع',
      'الحالة',
      'الأولوية',
      'موعد التسليم',
      'تاريخ الإنشاء',
    ]);

    final rows = <String>[header];
    for (final task in tasks) {
      rows.add(_taskRow(task, projectNames, areaNames));
    }

    return '$_bom${rows.join('\r\n')}\r\n';
  }

  /// صف CSV لمهمة واحدة.
  static String _taskRow(
    TaskModel task,
    Map<String, String>? projectNames,
    Map<String, String>? areaNames,
  ) {
    final projectName = task.projectId != null
        ? (projectNames?[task.projectId] ?? task.projectId)
        : '';
    return _row([
      task.title,
      task.description ?? '',
      areaNames?[task.areaId] ?? '',
      projectName ?? '',
      _statusLabels[task.status] ?? task.status,
      _priorityLabels[task.priority] ?? task.priority,
      _formatIsoDate(task.dueDate),
      _formatIsoDate(task.createdAt),
    ]);
  }

  /// تجميع حقول الصف مع الهروب اللازم.
  static String _row(List<String> fields) {
    final escaped = fields.map(_escapeField).toList();
    return escaped.join(',');
  }

  /// هروب الحقول: إن كانت تغطي فاصلة أو اقتباساً أو سطراً جديداً تُغلّف باقتباسات.
  static String _escapeField(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains('\n') ||
        value.contains('\r')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  /// تنسيق التاريخ بصيغة ISO محلية قصيرة (لا يُترك فارغاً إلا إن كان null).
  static String _formatIsoDate(DateTime? date) {
    if (date == null) return '';
    return date.toUtc().toIso8601String();
  }

  /// تصفية المهام حسب الحالة (null = بدون تصفية).
  static List<TaskModel> filterByStatus(List<TaskModel> tasks, String? status) {
    if (status == null || status.isEmpty) return tasks;
    return tasks.where((t) => t.status == status).toList();
  }

  /// تصفية المهام حسب الأولوية (null = بدون تصفية).
  static List<TaskModel> filterByPriority(List<TaskModel> tasks, String? priority) {
    if (priority == null || priority.isEmpty) return tasks;
    return tasks.where((t) => t.priority == priority).toList();
  }

  /// ترتيب المهام حسب موعد التسليم تصاعدياً (بدون موعد تُؤجل للنهاية).
  static List<TaskModel> sortByDueDate(List<TaskModel> tasks, {bool ascending = true}) {
    final sorted = List<TaskModel>.from(tasks);
    sorted.sort((a, b) {
      if (a.dueDate == null && b.dueDate == null) return 0;
      if (a.dueDate == null) return 1;
      if (b.dueDate == null) return -1;
      final comparison = a.dueDate!.compareTo(b.dueDate!);
      return ascending ? comparison : -comparison;
    });
    return sorted;
  }

  /// ترتيب المهام حسب الأولوية (اختياري لموديل الجداول).
  static List<TaskModel> sortByPriority(
    List<TaskModel> tasks, {
    bool urgentFirst = true,
  }) {
    const priorityRank = {'urgent': 0, 'high': 1, 'medium': 2, 'low': 3};
    final sorted = List<TaskModel>.from(tasks);
    sorted.sort((a, b) {
      final ra = priorityRank[a.priority] ?? 4;
      final rb = priorityRank[b.priority] ?? 4;
      return urgentFirst ? ra.compareTo(rb) : rb.compareTo(ra);
    });
    return sorted;
  }
}
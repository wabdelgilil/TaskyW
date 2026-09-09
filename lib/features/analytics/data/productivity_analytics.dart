import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';

/// نقطة زمنية في بيانات سلسلة زمنية (إكمال أسبوعي/شهري).
class CompletionPoint {
  final String label;
  final int completedCount;
  final int totalCount;

  CompletionPoint({
    required this.label,
    required this.completedCount,
    required this.totalCount,
  });

  double get completionRate =>
      totalCount == 0 ? 0 : (completedCount / totalCount);

  Map<String, dynamic> toMap() => {
        'label': label,
        'completed_count': completedCount,
        'total_count': totalCount,
      };
}

/// إحصائية إنجاز لكيان (منطقة أو مشروع).
class EntityCompletionStat {
  final String id;
  final String name;
  final String iconEmoji;
  final String colorHex;
  final int totalTasks;
  final int completedTasks;

  EntityCompletionStat({
    required this.id,
    required this.name,
    required this.iconEmoji,
    required this.colorHex,
    required this.totalTasks,
    required this.completedTasks,
  });

  double get completionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon_emoji': iconEmoji,
        'color_hex': colorHex,
        'total_tasks': totalTasks,
        'completed_tasks': completedTasks,
      };
}

/// شريحة إنتاجية لساعة من اليوم أو يوم من الأسبوع.
class ProductivitySlice {
  final String label;
  final int count;

  ProductivitySlice({required this.label, required this.count});

  Map<String, dynamic> toMap() => {'label': label, 'count': count};
}

/// النتائج الإجمالية لحسابات المنتجية.
class ProductivityReport {
  final int totalTasks;
  final int activeTasks;
  final int completedTasks;
  final List<CompletionPoint> weeklySeries;
  final List<CompletionPoint> monthlySeries;
  final List<EntityCompletionStat> areas;
  final List<EntityCompletionStat> projects;
  final List<ProductivitySlice> byDayOfWeek;
  final List<ProductivitySlice> byHourOfDay;
  final Map<String, List<TaskModel>> priorityGroups;

  ProductivityReport({
    required this.totalTasks,
    required this.activeTasks,
    required this.completedTasks,
    required this.weeklySeries,
    required this.monthlySeries,
    required this.areas,
    required this.projects,
    required this.byDayOfWeek,
    required this.byHourOfDay,
    required this.priorityGroups,
  });

  double get completionRate =>
      totalTasks == 0 ? 0 : completedTasks / totalTasks;
}

/// محرك حسابات الإنتاجية — منطق نقي الاختبار (Pure Dart).
class ProductivityAnalytics {
  static const List<String> _weekdaysAr = [
    'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت',
  ];

  /// عدد آخر N فترة أسبوعية.
  static const int weeklyBuckets = 8;

  /// عدد آخر N فترة شهرية.
  static const int monthlyBuckets = 6;

  /// يحسب التقرير الكامل من المهام والمناطق والمشاريع النشطة.
  static ProductivityReport buildReport({
    required List<TaskModel> tasks,
    required List<AreaModel> areas,
    required List<ProjectModel> projects,
  }) {
    final now = DateTime.now();

    final completed = tasks
        .where((t) => t.status == 'completed')
        .toList();

    // السلسلة الأسبوعية: لكل أسبوع نعد المهام المكتملة (بـ updated_at كبديل
    // لوقت الإنجاز) والعدد الإجمالي للمهام التي أُنشئت في نفس الأسبوع.
    final weeklySeries = _buildWeeklySeries(completed, now);

    // السلسلة الشهرية.
    final monthlySeries = _buildMonthlySeries(completed, now);

    // الإنجاز حسب المنطقة.
    final areasStats = _buildEntityStats(
      tasks: tasks,
      entities: areas.map((a) => (
            id: a.id,
            name: a.name,
            icon: a.iconEmoji,
            color: a.colorHex,
          )).toList(),
      taskEntityKey: (t) => t.areaId,
    );

    // الإنجاز حسب المشروع.
    final projectsStats = _buildEntityStats(
      tasks: tasks.where((t) => t.projectId != null).toList(),
      entities: projects
          .map((p) => (
                id: p.id,
                name: p.name,
                icon: p.iconEmoji,
                color: p.colorHex,
              ))
          .toList(),
      taskEntityKey: (t) => t.projectId!,
    );

    return ProductivityReport(
      totalTasks: tasks.length,
      activeTasks: tasks.length - completed.length,
      completedTasks: completed.length,
      weeklySeries: weeklySeries,
      monthlySeries: monthlySeries,
      areas: areasStats,
      projects: projectsStats,
      byDayOfWeek: _buildDayOfWeek(completed),
      byHourOfDay: _buildHourOfDay(completed),
      priorityGroups: _groupByPriority(tasks),
    );
  }

  static List<CompletionPoint> _buildWeeklySeries(
    List<TaskModel> completed,
    DateTime now,
  ) {
    final result = <CompletionPoint>[];
    for (var i = weeklyBuckets - 1; i >= 0; i--) {
      final weekStart = _startOfWeek(now).subtract(Duration(days: 7 * i));
      final weekEnd = weekStart.add(const Duration(days: 7));
      final label = '${weekStart.day}/${weekStart.month}';
      final inWeek = completed.where((t) {
        final d = t.updatedAt;
        return !d.isBefore(weekStart) && d.isBefore(weekEnd);
      }).length;
      result.add(CompletionPoint(
        label: label,
        completedCount: inWeek,
        totalCount: 0,
      ));
    }
    return result;
  }

  static List<CompletionPoint> _buildMonthlySeries(
    List<TaskModel> completed,
    DateTime now,
  ) {
    final result = <CompletionPoint>[];
    for (var i = monthlyBuckets - 1; i >= 0; i--) {
      final monthStart = DateTime(now.year, now.month - i, 1);
      final monthEnd =
          DateTime(monthStart.year, monthStart.month + 1, 1);
      final label = '${monthStart.month}/${monthStart.year % 100}';
      final inMonth = completed.where((t) {
        final d = t.updatedAt;
        return !d.isBefore(monthStart) && d.isBefore(monthEnd);
      }).length;
      result.add(CompletionPoint(
        label: label,
        completedCount: inMonth,
        totalCount: 0,
      ));
    }
    return result;
  }

  static DateTime _startOfWeek(DateTime d) {
    final normalized = d.weekday == DateTime.sunday ? 6 : d.weekday - 1;
    return DateTime(d.year, d.month, d.day).subtract(Duration(days: normalized));
  }

  static List<EntityCompletionStat> _buildEntityStats({
    required List<TaskModel> tasks,
    required List<({String id, String name, String icon, String color})>
        entities,
    required String Function(TaskModel) taskEntityKey,
  }) {
    final entitiesWithTasks = entities
        .map((e) {
          final entityTasks =
              tasks.where((t) => taskEntityKey(t) == e.id).toList();
          return EntityCompletionStat(
            id: e.id,
            name: e.name,
            iconEmoji: e.icon,
            colorHex: e.color,
            totalTasks: entityTasks.length,
            completedTasks:
                entityTasks.where((t) => t.status == 'completed').length,
          );
        })
        .where((s) => s.totalTasks > 0)
        .toList()
      ..sort((a, b) => b.completedTasks.compareTo(a.completedTasks));
    return entitiesWithTasks;
  }

  static List<ProductivitySlice> _buildDayOfWeek(List<TaskModel> completed) {
    final counts = List<int>.filled(7, 0);
    for (final t in completed) {
      counts[t.updatedAt.weekday % 7]++;
    }
    final result = <ProductivitySlice>[];
    for (var i = 0; i < 7; i++) {
      result.add(ProductivitySlice(
        label: _weekdaysAr[i],
        count: counts[i],
      ));
    }
    return result;
  }

  static List<ProductivitySlice> _buildHourOfDay(List<TaskModel> completed) {
    final counts = List<int>.filled(24, 0);
    for (final t in completed) {
      counts[t.updatedAt.hour]++;
    }
    return List.generate(24, (h) {
      final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
      final suffix = h < 12 ? 'ص' : 'م';
      return ProductivitySlice(label: '$hour12 $suffix', count: counts[h]);
    });
  }

  static Map<String, List<TaskModel>> _groupByPriority(List<TaskModel> tasks) {
    const priorities = ['urgent', 'high', 'medium', 'low'];
    final map = <String, List<TaskModel>>{};
    for (final p in priorities) {
      map[p] = tasks.where((t) => t.priority == p).toList();
    }
    return map;
  }
}
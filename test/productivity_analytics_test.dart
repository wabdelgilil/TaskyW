import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/analytics/data/productivity_analytics.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';

void main() {
  final now = DateTime.now().toUtc();
  DateTime daysAgo(int daysAgo, [int hour = 10]) => now.subtract(Duration(days: daysAgo, hours: now.hour - hour));

  TaskModel buildTask({
    required String id,
    required String areaId,
    String? projectId,
    required String status,
    required String priority,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) =>
      TaskModel(
        id: id,
        areaId: areaId,
        projectId: projectId,
        title: id,
        status: status,
        priority: priority,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  AreaModel buildArea(String id, String name) => AreaModel(
        id: id,
        name: name,
        createdAt: now,
        updatedAt: now,
      );

  ProjectModel buildProject(String id, String name, String areaId) => ProjectModel(
        id: id,
        areaId: areaId,
        name: name,
        createdAt: now,
        updatedAt: now,
      );

  group('ProductivityAnalytics.buildReport', () {
    test('بيانات فارغة → أصفار', () {
      final report = ProductivityAnalytics.buildReport(
        tasks: [],
        areas: [],
        projects: [],
      );
      expect(report.totalTasks, 0);
      expect(report.completedTasks, 0);
      expect(report.completionRate, 0);
      expect(report.weeklySeries.length, 8);
      expect(report.weeklySeries.every((p) => p.completedCount == 0), isTrue);
      expect(report.monthlySeries.length, 6);
      expect(report.monthlySeries.every((p) => p.completedCount == 0), isTrue);
      expect(report.areas, isEmpty);
      expect(report.projects, isEmpty);
    });

    test('حساب الإجمالي والنسبة بشكل صحيح', () {
      final tasks = [
        buildTask(id: 't1', areaId: 'a1', status: 'completed', priority: 'high',
            createdAt: daysAgo(20), updatedAt: daysAgo(3)),
        buildTask(id: 't2', areaId: 'a1', status: 'todo', priority: 'medium',
            createdAt: daysAgo(15), updatedAt: daysAgo(5)),
        buildTask(id: 't3', areaId: 'a1', status: 'waiting', priority: 'low',
            createdAt: daysAgo(10), updatedAt: daysAgo(2)),
      ];
      final report = ProductivityAnalytics.buildReport(
        tasks: tasks,
        areas: [buildArea('a1', 'العمل')],
        projects: [],
      );
      expect(report.totalTasks, 3);
      expect(report.completedTasks, 1);
      expect(report.activeTasks, 2);
      expect(report.completionRate, closeTo(1 / 3, 0.01));
    });

    test('السلسلة الأسبوعية تُنشئ 8 فترات', () {
      final tasks = [
        buildTask(id: 't1', areaId: 'a1', status: 'completed', priority: 'medium',
            createdAt: daysAgo(40), updatedAt: daysAgo(3)),
      ];
      final report = ProductivityAnalytics.buildReport(
        tasks: tasks,
        areas: [],
        projects: [],
      );
      expect(report.weeklySeries.length, 8);
    });

    test('السلسلة الشهرية تُنشئ 6 فترات', () {
      final report = ProductivityAnalytics.buildReport(
        tasks: [],
        areas: [],
        projects: [],
      );
      expect(report.monthlySeries.length, 6);
    });

    test('المهام تُجمع حسب المنطقة', () {
      final tasks = [
        buildTask(id: 't1', areaId: 'a1', status: 'completed', priority: 'medium',
            createdAt: daysAgo(10), updatedAt: daysAgo(2)),
        buildTask(id: 't2', areaId: 'a1', status: 'todo', priority: 'low',
            createdAt: daysAgo(8), updatedAt: daysAgo(1)),
        buildTask(id: 't3', areaId: 'a2', status: 'completed', priority: 'high',
            createdAt: daysAgo(5), updatedAt: daysAgo(1)),
      ];
      final report = ProductivityAnalytics.buildReport(
        tasks: tasks,
        areas: [buildArea('a1', 'العمل'), buildArea('a2', 'الشخصي')],
        projects: [],
      );
      expect(report.areas.length, 2);
      final a1 = report.areas.firstWhere((s) => s.id == 'a1');
      expect(a1.totalTasks, 2);
      expect(a1.completedTasks, 1);
      expect(a1.name, 'العمل');
    });

    test('المهام تُجمع حسب المشروع', () {
      final tasks = [
        buildTask(id: 't1', areaId: 'a1', projectId: 'p1', status: 'completed',
            priority: 'medium', createdAt: daysAgo(10), updatedAt: daysAgo(3)),
        buildTask(id: 't2', areaId: 'a1', projectId: 'p1', status: 'completed',
            priority: 'medium', createdAt: daysAgo(8), updatedAt: daysAgo(2)),
        buildTask(id: 't3', areaId: 'a1', projectId: 'p2', status: 'todo',
            priority: 'low', createdAt: daysAgo(5), updatedAt: daysAgo(1)),
      ];
      final report = ProductivityAnalytics.buildReport(
        tasks: tasks,
        areas: [buildArea('a1', 'العمل')],
        projects: [buildProject('p1', 'تطبيق', 'a1'), buildProject('p2', 'موقع', 'a1')],
      );
      expect(report.projects.length, 2);
      final p1 = report.projects.firstWhere((s) => s.id == 'p1');
      expect(p1.totalTasks, 2);
      expect(p1.completedTasks, 2);
      expect(p1.completionRate, 1.0);
    });

    test('توزيع الأولويات يجمع كل المهام', () {
      final tasks = [
        buildTask(id: 't1', areaId: 'a1', status: 'todo', priority: 'urgent',
            createdAt: daysAgo(1), updatedAt: daysAgo(0)),
        buildTask(id: 't2', areaId: 'a1', status: 'todo', priority: 'high',
            createdAt: daysAgo(1), updatedAt: daysAgo(0)),
        buildTask(id: 't3', areaId: 'a1', status: 'todo', priority: 'medium',
            createdAt: daysAgo(1), updatedAt: daysAgo(0)),
        buildTask(id: 't4', areaId: 'a1', status: 'completed', priority: 'low',
            createdAt: daysAgo(1), updatedAt: daysAgo(0)),
      ];
      final report = ProductivityAnalytics.buildReport(
        tasks: tasks,
        areas: [],
        projects: [],
      );
      expect(report.priorityGroups['urgent']!.length, 1);
      expect(report.priorityGroups['high']!.length, 1);
      expect(report.priorityGroups['medium']!.length, 1);
      expect(report.priorityGroups['low']!.length, 1);
    });

    test('byDayOfWeek يحتوي 7 أيام', () {
      final report = ProductivityAnalytics.buildReport(
        tasks: [],
        areas: [],
        projects: [],
      );
      expect(report.byDayOfWeek.length, 7);
      expect(report.byDayOfWeek.map((s) => s.label).toList(),
          ['الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت']);
    });

    test('byHourOfDay يحتوي 24 ساعة', () {
      final report = ProductivityAnalytics.buildReport(
        tasks: [],
        areas: [],
        projects: [],
      );
      expect(report.byHourOfDay.length, 24);
      expect(report.byHourOfDay.first.label, '12 ص');
      expect(report.byHourOfDay[12].label, '12 م');
      expect(report.byHourOfDay.last.label, '11 م');
    });

    test('المهام غير المحذوفة فقط تُحسب (الحذف الناعم غير مدعوم في المقارنة)', () {
      final tasks = [
        buildTask(id: 't1', areaId: 'a1', status: 'completed', priority: 'medium',
            createdAt: daysAgo(10), updatedAt: daysAgo(2)),
      ];
      final report = ProductivityAnalytics.buildReport(
        tasks: tasks,
        areas: [buildArea('a1', 'العمل')],
        projects: [],
      );
      expect(report.totalTasks, 1);
      final a1 = report.areas.firstWhere((s) => s.id == 'a1');
      expect(a1.totalTasks, 1);
    });
  });
}
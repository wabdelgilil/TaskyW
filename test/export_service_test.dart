import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/services/export_service.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';

void main() {
  TaskModel makeTask({
    required String id,
    required String title,
    String areaId = 'area-1',
    String? projectId,
    String status = 'todo',
    String priority = 'medium',
    DateTime? dueDate,
    String? description,
  }) {
    final now = DateTime.utc(2026, 9, 8, 10, 0);
    return TaskModel(
      id: id,
      areaId: areaId,
      projectId: projectId,
      title: title,
      description: description,
      status: status,
      priority: priority,
      dueDate: dueDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  group('ExportService.exportTasksToCsv', () {
    test('يبدأ بالنص بعلامة UTF-8 BOM', () {
      final csv = ExportService.exportTasksToCsv(tasks: []);
      expect(csv.startsWith('\uFEFF'), isTrue);
      expect(csv.substring(1).startsWith('العنوان'), isTrue);
    });

    test('يتضمن الترويسة بالعربية وسطر لكل مهمة', () {
      final tasks = [
        makeTask(id: 't1', title: 'مهمة أولى'),
        makeTask(id: 't2', title: 'مهمة ثانية'),
      ];
      final csv = ExportService.exportTasksToCsv(tasks: tasks);
      final lines = csv.trimRight().split('\r\n');
      expect(lines, hasLength(3));
      expect(lines[0], contains('العنوان'));
      expect(lines[1], contains('مهمة أولى'));
      expect(lines[2], contains('مهمة ثانية'));
    });

    test('يستبدل أسماء المجالات والمشاريع إذا وُفرت', () {
      final tasks = [
        makeTask(id: 't1', title: 'مهمة', areaId: 'area-1', projectId: 'proj-1'),
      ];
      final csv = ExportService.exportTasksToCsv(
        tasks: tasks,
        areaNames: {'area-1': 'العمل'},
        projectNames: {'proj-1': 'المشروع أ'},
      );
      expect(csv, contains('العمل'));
      expect(csv, contains('المشروع أ'));
    });

    test('يعرض الحالة والأولوية بالعربية', () {
      final tasks = [
        makeTask(id: 't1', title: 'مهمة', status: 'completed', priority: 'urgent'),
      ];
      final csv = ExportService.exportTasksToCsv(tasks: tasks);
      expect(csv, contains('مكتملة'));
      expect(csv, contains('عاجلة'));
    });

    test('يهرب الفواصل والاقتباسات والسطور الجديدة داخل الخلايا', () {
      final tasks = [
        makeTask(id: 't1', title: 'مهمة, بفاصلة', description: 'وصف "بين اقتباسين"'),
        makeTask(id: 't2', title: 'سطر\nجديد'),
      ];
      final csv = ExportService.exportTasksToCsv(tasks: tasks);
      expect(csv, contains('"مهمة, بفاصلة"'));
      expect(csv, contains('"وصف ""بين اقتباسين"""'));
      expect(csv, contains('"سطر\nجديد"'));
    });

    test('المهام بدون تاريخ تُصدَّر بحقل فارغ', () {
      final tasks = [makeTask(id: 't1', title: 'بلا موعد')];
      final csv = ExportService.exportTasksToCsv(tasks: tasks);
      final line = csv.trimRight().split('\r\n')[1];
      expect(line.split(',')[6], isEmpty);
    });
  });

  group('دوال الفلترة والترتيب', () {
    test('filterByStatus يصفّي حسب الحالة وnull يمرر الجميع', () {
      final tasks = [
        makeTask(id: 'a', title: 'أ', status: 'completed'),
        makeTask(id: 'b', title: 'ب', status: 'todo'),
      ];
      expect(ExportService.filterByStatus(tasks, 'completed'), hasLength(1));
      expect(ExportService.filterByStatus(tasks, null), hasLength(2));
    });

    test('sortByDueDate يقدّم الأقرب تاريخياً', () {
      final tasks = [
        makeTask(id: 'far', title: 'بعيد', dueDate: DateTime.utc(2026, 12, 1)),
        makeTask(id: 'near', title: 'قريب', dueDate: DateTime.utc(2026, 9, 1)),
        makeTask(id: 'none', title: 'بدون'),
      ];
      final sorted = ExportService.sortByDueDate(tasks);
      expect(sorted.map((t) => t.id).take(2), ['near', 'far']);
      expect(sorted.last.id, 'none');

      final desc = ExportService.sortByDueDate(tasks, ascending: false);
      expect(desc.map((t) => t.id).take(2), ['far', 'near']);
    });

    test('sortByPriority يرتّب من العاجلة إلى المنخفضة', () {
      final tasks = [
        makeTask(id: 'm', title: 'أ', priority: 'medium'),
        makeTask(id: 'u', title: 'ب', priority: 'urgent'),
        makeTask(id: 'l', title: 'ج', priority: 'low'),
      ];
      final sorted = ExportService.sortByPriority(tasks);
      expect(sorted.map((t) => t.id), ['u', 'm', 'l']);
    });
  });
}
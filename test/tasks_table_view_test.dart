import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/presentation/widgets/tasks_table_view.dart';

void main() {
  final sampleTasks = [
    TaskModel(
      id: 'task-1',
      areaId: 'area-1',
      title: 'بناء واجهة الجدول',
      description: 'تصميم جدول يشبه Notion',
      status: 'in_progress',
      priority: 'urgent',
      dueDate: DateTime(2026, 9, 10),
      createdAt: DateTime(2026, 9, 1),
      updatedAt: DateTime(2026, 9, 1),
    ),
    TaskModel(
      id: 'task-2',
      areaId: 'area-1',
      title: 'إصلاح مزامنة السحابة',
      status: 'todo',
      priority: 'medium',
      dueDate: DateTime(2026, 9, 15),
      createdAt: DateTime(2026, 9, 2),
      updatedAt: DateTime(2026, 9, 2),
    ),
    TaskModel(
      id: 'task-3',
      areaId: 'area-1',
      title: 'توثيق المعمارية',
      status: 'completed',
      priority: 'low',
      dueDate: DateTime(2026, 9, 5),
      createdAt: DateTime(2026, 9, 3),
      updatedAt: DateTime(2026, 9, 3),
    ),
  ];

  Widget buildTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(
        body: child,
      ),
    );
  }

  testWidgets('TasksTableView renders headers, summary bar and tasks properly', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        TasksTableView(
          tasks: sampleTasks,
          subtaskCounts: const {'task-1': 3},
          completedSubtaskCounts: const {'task-1': 1},
        ),
      ),
    );

    // Verify header column titles
    expect(find.text('عنوان المهمة'), findsOneWidget);
    expect(find.text('الحالة'), findsOneWidget);
    expect(find.text('الأولوية'), findsOneWidget);
    expect(find.text('تاريخ الاستحقاق'), findsOneWidget);

    // Verify task titles
    expect(find.text('بناء واجهة الجدول'), findsOneWidget);
    expect(find.text('إصلاح مزامنة السحابة'), findsOneWidget);
    expect(find.text('توثيق المعمارية'), findsOneWidget);

    // Verify subtask count badge
    expect(find.text('1/3'), findsOneWidget);
  });

  testWidgets('TasksTableView renders empty state when tasks is empty', (tester) async {
    bool addTaskCalled = false;
    await tester.pumpWidget(
      buildTestableWidget(
        TasksTableView(
          tasks: const [],
          onAddTask: () {
            addTaskCalled = true;
          },
        ),
      ),
    );

    expect(find.text('لا توجد مهام لعرضها في الجدول'), findsOneWidget);
    expect(find.text('إضافة مهمة جديدة'), findsOneWidget);

    await tester.tap(find.text('إضافة مهمة جديدة'));
    await tester.pumpAndSettle();
    expect(addTaskCalled, isTrue);
  });

  testWidgets('TasksTableView triggers onToggleCompleted when checkbox clicked', (tester) async {
    TaskModel? toggledTask;
    bool? toggledCompleted;

    await tester.pumpWidget(
      buildTestableWidget(
        TasksTableView(
          tasks: sampleTasks,
          onToggleCompleted: (task, isCompleted) {
            toggledTask = task;
            toggledCompleted = isCompleted;
          },
        ),
      ),
    );

    final checkboxes = find.byType(Checkbox);
    expect(checkboxes, findsNWidgets(3));

    await tester.tap(checkboxes.first);
    await tester.pumpAndSettle();

    expect(toggledTask, isNotNull);
    expect(toggledCompleted, isNotNull);
  });

  testWidgets('TasksTableView sorting reorders tasks', (tester) async {
    await tester.pumpWidget(
      buildTestableWidget(
        TasksTableView(
          tasks: sampleTasks,
        ),
      ),
    );

    await tester.tap(find.text('عنوان المهمة'));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.arrow_upward), findsOneWidget);
  });
}

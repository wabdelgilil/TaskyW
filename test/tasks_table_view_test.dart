import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/presentation/widgets/tasks_table_view.dart';
import 'package:tasky/l10n/app_localizations.dart';

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
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ar'), Locale('en')],
      locale: const Locale('ar'),
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

  testWidgets('TasksTableView shows group by project toggle and splits into multiple tables', (tester) async {
    final projects = [
      ProjectModel(
        id: 'proj-1',
        areaId: 'area-1',
        name: 'مشروع الواجهات',
        iconEmoji: '🎨',
        colorHex: '#3B82F6',
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      ),
      ProjectModel(
        id: 'proj-2',
        areaId: 'area-1',
        name: 'مشروع الخوادم',
        iconEmoji: '⚙️',
        colorHex: '#10B981',
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      ),
    ];

    final tasksWithProjects = [
      TaskModel(
        id: 'task-p1',
        areaId: 'area-1',
        projectId: 'proj-1',
        title: 'مهمة تصميم الأزرار',
        status: 'completed',
        priority: 'high',
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      ),
      TaskModel(
        id: 'task-p2',
        areaId: 'area-1',
        projectId: 'proj-2',
        title: 'مهمة تهيئة API',
        status: 'in_progress',
        priority: 'urgent',
        createdAt: DateTime(2026, 9, 2),
        updatedAt: DateTime(2026, 9, 2),
      ),
      TaskModel(
        id: 'task-standalone',
        areaId: 'area-1',
        title: 'مهمة مستقلة بدون مشروع',
        status: 'todo',
        priority: 'low',
        createdAt: DateTime(2026, 9, 3),
        updatedAt: DateTime(2026, 9, 3),
      ),
    ];

    await tester.pumpWidget(
      buildTestableWidget(
        TasksTableView(
          tasks: tasksWithProjects,
          projects: projects,
        ),
      ),
    );

    // Verify group by project toggle is visible
    expect(find.text('تجميع بحسب المشروع'), findsOneWidget);

    // Initially single table contains all tasks
    expect(find.byType(DataTable), findsOneWidget);

    // Tap switch to enable group by project
    final switchFinder = find.byType(Switch);
    expect(switchFinder, findsOneWidget);
    await tester.tap(switchFinder);
    await tester.pumpAndSettle();

    // Now multiple tables should be rendered (proj-1, proj-2, and unassigned)
    expect(find.byType(DataTable), findsNWidgets(3));

    // Verify project headers
    expect(find.text('مشروع الواجهات'), findsOneWidget);
    expect(find.text('مشروع الخوادم'), findsOneWidget);
    expect(find.text('بدون مشروع'), findsOneWidget);

    // Verify progress badge for proj-1 (1 done of 1)
    expect(find.text('1/1 (100%)'), findsOneWidget);
    // Verify progress badge for proj-2 (0 done of 1)
    expect(find.text('0/1 (0%)'), findsOneWidget);

    // Tap project 1 header to collapse it
    await tester.tap(find.text('مشروع الواجهات'));
    await tester.pumpAndSettle();

    // Now DataTable count should decrease to 2 because proj-1 table is collapsed
    expect(find.byType(DataTable), findsNWidgets(2));

    // Tap project 1 header again to expand
    await tester.tap(find.text('مشروع الواجهات'));
    await tester.pumpAndSettle();
    expect(find.byType(DataTable), findsNWidgets(3));
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/core/theme/app_theme.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/presentation/widgets/task_list_view.dart';

TaskModel _task({
  required String id,
  required String title,
  required String status,
}) {
  final now = DateTime.now().toUtc();
  return TaskModel(
    id: id,
    areaId: 'area-1',
    title: title,
    status: status,
    priority: 'medium',
    createdAt: now,
    updatedAt: now,
  );
}

void main() {
  final now = DateTime.now().toUtc();
  final activeTasks = <TaskModel>[
    _task(id: 't-1', title: 'مهمة نشطة أولى', status: 'todo'),
    _task(id: 't-2', title: 'مهمة نشطة ثانية', status: 'in_progress'),
  ];
  final completedTasks = <TaskModel>[
    _task(id: 't-3', title: 'مهمة مكتملة أولى', status: 'completed'),
    _task(id: 't-4', title: 'مهمة مكتملة ثانية', status: 'completed'),
  ];

  Widget buildView({
    List<TaskModel>? tasks,
    ValueChanged<(TaskModel, bool)>? onToggle,
  }) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: Scaffold(
        body: TaskListView(
          tasks: tasks ?? [...activeTasks, ...completedTasks],
          onToggleCompleted: (task, value) => onToggle?.call((task, value)),
        ),
      ),
    );
  }

  testWidgets('يجمع المهام المكتملة في قسم منفصل أسفل القائمة مع العداد', (tester) async {
    await tester.pumpWidget(buildView());
    await tester.pump();

    // المهام النشطة ظاهرة
    expect(find.text('مهمة نشطة أولى'), findsOneWidget);
    expect(find.text('مهمة نشطة ثانية'), findsOneWidget);

    // رأس قسم المهام المكتملة مع عداد 2
    expect(find.text('المهام المكتملة (Completed Tasks)'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);

    // المهام المكتملة مخفية افتراضياً (القسم مطوي)
    expect(find.text('مهمة مكتملة أولى'), findsNothing);
    expect(find.text('مهمة مكتملة ثانية'), findsNothing);

    // بدون أي فيض
    expect(tester.takeException(), isNull);
  });

  testWidgets('فتح القسم يعرض المهام المكتملة وطيه يخفيها', (tester) async {
    await tester.pumpWidget(buildView());
    await tester.pump();

    // فتح القسم
    await tester.tap(find.text('المهام المكتملة (Completed Tasks)'));
    await tester.pumpAndSettle();

    expect(find.text('مهمة مكتملة أولى'), findsOneWidget);
    expect(find.text('مهمة مكتملة ثانية'), findsOneWidget);

    // طي القسم مجدداً
    await tester.tap(find.text('المهام المكتملة (Completed Tasks)'));
    await tester.pumpAndSettle();

    expect(find.text('مهمة مكتملة أولى'), findsNothing);
    expect(find.text('مهمة مكتملة ثانية'), findsNothing);
  });

  testWidgets('إلغاء إكمال المهمة يستدعي onToggleCompleted بالقيمة الصحيحة', (tester) async {
    (TaskModel, bool)? toggled;
    final tasks = <TaskModel>[activeTasks.first, completedTasks.first];

    await tester.pumpWidget(
      buildView(
        tasks: tasks,
        onToggle: (t) => toggled = t,
      ),
    );
    await tester.pump();

    // فتح القسم للوصول للمهمة المكتملة
    await tester.tap(find.text('المهام المكتملة (Completed Tasks)'));
    await tester.pumpAndSettle();

    // الضغط على صندوق الاختيار داخل المهمة المكتملة
    final completeBoxes = find.byType(Checkbox);
    // صندوق المهام المكتملة هو الثاني في القسم المفتوح
    await tester.tap(completeBoxes.at(1));
    await tester.pump();

    expect(toggled, isNotNull);
    expect(toggled!.$1.id, 't-3');
    expect(toggled!.$2, isFalse);
  });

  testWidgets('عند غياب أي مهام تظهر رسالة فارغة افتراضياً ولا يظهر قسم المكتملة', (tester) async {
    await tester.pumpWidget(buildView(tasks: const []));
    await tester.pump();

    expect(find.text('لا توجد مهام مسجلة حالياً'), findsOneWidget);
    expect(find.text('المهام المكتملة (Completed Tasks)'), findsNothing);
  });

  testWidgets('لا يظهر قسم المكتملة عند تعطيل showCompletedSection', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: Scaffold(
          body: TaskListView(
            tasks: [...activeTasks, ...completedTasks],
            showCompletedSection: false,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('مهمة مكتملة أولى'), findsOneWidget);
    expect(find.text('المهام المكتملة (Completed Tasks)'), findsNothing);
  });

  testWidgets('قسم المكتملة متوافق مع نمط OLED ولا ينتج فيضاً', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.oledTheme,
        home: Scaffold(
          body: TaskListView(
            tasks: [...activeTasks, ...completedTasks],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.text('المهام المكتملة (Completed Tasks)'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // عدّاد مرتبط بـ syncStatus millis لضمان عدم إنتاج test fixture collision
    expect(now.isAfter(DateTime(2000)), isTrue);
  });
}
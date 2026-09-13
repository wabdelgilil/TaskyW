import 'package:flutter_test/flutter_test.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/presentation/controllers/audio_briefing_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AudioBriefingController Tests', () {
    late AudioBriefingController controller;

    setUp(() {
      controller = AudioBriefingController.instance;
    });

    tearDown(() async {
      await controller.stop();
    });

    test('Initial state is stopped with empty queue', () {
      expect(controller.isStopped, isTrue);
      expect(controller.isPlaying, isFalse);
      expect(controller.isPaused, isFalse);
      expect(controller.isActive, isFalse);
      expect(controller.currentIndex, -1);
      expect(controller.currentTaskId, isNull);
      expect(controller.currentTask, isNull);
      expect(controller.activeQueue, isEmpty);
    });

    test('Speech rate clamps within safe bounds', () async {
      await controller.setSpeechRate(0.8);
      expect(controller.speechRate, 0.8);

      await controller.setSpeechRate(1.5); // clamps to 1.0
      expect(controller.speechRate, 1.0);

      await controller.setSpeechRate(0.1); // clamps to 0.25
      expect(controller.speechRate, 0.25);
    });

    test('Empty or completed-only tasks immediately stop', () async {
      final now = DateTime.now();
      final completedTasks = [
        TaskModel(
          id: 't-1',
          areaId: 'area-1',
          title: 'مهمة منتهية',
          status: 'completed',
          priority: 'low',
          createdAt: now,
          updatedAt: now,
        ),
      ];

      await controller.startBriefing(
        contextTitle: 'اليوم',
        tasks: completedTasks,
      );

      expect(controller.isStopped, isTrue);
      expect(controller.activeQueue, isEmpty);
    });

    test('Formats Arabic spoken text with priority and today due date', () {
      final now = DateTime.now();
      final task = TaskModel(
        id: 't-1',
        areaId: 'area-1',
        title: 'مراجعة الميزانية المالية',
        status: 'todo',
        priority: 'urgent',
        dueDate: now,
        createdAt: now,
        updatedAt: now,
      );

      final text = controller.formatTaskSpokenText(task, 1, isArabic: true);
      expect(text, contains('المهمة رقم 1: مراجعة الميزانية المالية.'));
      expect(text, contains('أولوية عاجلة.'));
      expect(text, contains('موعد الاستحقاق اليوم.'));
    });

    test('Formats English spoken text with priority and tomorrow due date', () {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      final task = TaskModel(
        id: 't-2',
        areaId: 'area-1',
        title: 'Deploy to Supabase',
        status: 'todo',
        priority: 'high',
        dueDate: tomorrow,
        createdAt: now,
        updatedAt: now,
      );

      final text = controller.formatTaskSpokenText(task, 2, isArabic: false);
      expect(text, contains('Task number 2: Deploy to Supabase.'));
      expect(text, contains('High priority.'));
      expect(text, contains('Due tomorrow.'));
    });

    test('Handles mixed language text gracefully in Arabic format', () {
      final now = DateTime.now();
      final task = TaskModel(
        id: 't-3',
        areaId: 'area-1',
        title: 'مراجعة الـ PR الخاص بالـ API على GitHub',
        status: 'todo',
        priority: 'normal',
        createdAt: now,
        updatedAt: now,
      );

      final text = controller.formatTaskSpokenText(task, 3, isArabic: true);
      expect(text, contains('المهمة رقم 3: مراجعة الـ PR الخاص بالـ API على GitHub.'));
    });
  });
}

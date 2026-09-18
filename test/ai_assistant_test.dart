import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tasky/core/database/app_database.dart';
import 'package:tasky/features/ai_assistant/data/models/ai_intent_model.dart';
import 'package:tasky/features/ai_assistant/data/services/gemini_voice_service.dart';
import 'package:tasky/features/ai_assistant/presentation/controllers/ai_assistant_controller.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await AppDatabase.resetForTest();
    AppDatabase.inMemory = true;
    SharedPreferences.setMockInitialValues({});
    await SettingsController.instance.load();
  });

  tearDown(() async {
    await AppDatabase.resetForTest();
  });

  group('AiIntentResult JSON Parsing Tests', () {
    test('parses create_task JSON correctly with markdown fence', () {
      const raw = '''
```json
{
  "intent": "create_task",
  "voice_reply": "تمت إضافة مهمة اجتماع المتجر غداً الساعة 5 م",
  "create_task": {
    "title": "اجتماع المتجر",
    "description": "مناقشة الطلبيات",
    "due_date": "2026-09-18T17:00:00",
    "priority": "urgent",
    "project_id": "proj-123",
    "project_name": "المتجر"
  }
}
```
''';
      final result = AiIntentResult.tryParseRawJson(raw);
      expect(result, isNotNull);
      expect(result!.type, equals(AiIntentType.createTask));
      expect(result.voiceReply, contains('تمت إضافة'));
      expect(result.createTask, isNotNull);
      expect(result.createTask!.title, equals('اجتماع المتجر'));
      expect(result.createTask!.priority, equals('urgent'));
      expect(result.createTask!.projectId, equals('proj-123'));
      expect(result.createTask!.dueDate?.day, equals(18));
    });

    test('parses read_tasks JSON correctly', () {
      const raw = '''
{
  "intent": "read_tasks",
  "voice_reply": "حاضر، جاري قراءة مهام اليوم",
  "read_tasks": {
    "scope": "today",
    "target_name": "اليوم"
  }
}
''';
      final result = AiIntentResult.tryParseRawJson(raw);
      expect(result, isNotNull);
      expect(result!.type, equals(AiIntentType.readTasks));
      expect(result.readTasks, isNotNull);
      expect(result.readTasks!.scope, equals('today'));
    });

    test('parses project scoped read_tasks JSON correctly', () {
      const raw = '''
{
  "intent": "read_tasks",
  "voice_reply": "سأقرأ لك مهام مشروع التسويق",
  "read_tasks": {
    "scope": "project",
    "target_id": "proj-456",
    "target_name": "التسويق"
  }
}
''';
      final result = AiIntentResult.tryParseRawJson(raw);
      expect(result, isNotNull);
      expect(result!.type, equals(AiIntentType.readTasks));
      expect(result.readTasks!.scope, equals('project'));
      expect(result.readTasks!.targetId, equals('proj-456'));
    });

    test('parses conversational help gracefully', () {
      const raw = '''
{
  "intent": "conversational_help",
  "voice_reply": "يمكنك استخدام شريط المهام لتنظيم أولوياتك.",
  "answer": "يمكنك استخدام شريط المهام لتنظيم أولوياتك."
}
''';
      final result = AiIntentResult.tryParseRawJson(raw);
      expect(result, isNotNull);
      expect(result!.type, equals(AiIntentType.conversationalHelp));
      expect(result.conversationalAnswer, contains('أولوياتك'));
    });
  });

  group('SettingsController BYOK AI Key Management Tests', () {
    test('initially hasValidAiKey is false', () {
      final settings = SettingsController.instance;
      expect(settings.hasValidAiKey, isFalse);
      expect(settings.geminiApiKey, isNull);
    });

    test('setGeminiApiKey updates key and hasValidAiKey', () async {
      final settings = SettingsController.instance;
      await settings.setGeminiApiKey('AIzaSyTest123456');

      expect(settings.geminiApiKey, equals('AIzaSyTest123456'));
      expect(settings.hasValidAiKey, isTrue);
    });

    test('clearGeminiApiKey removes the key', () async {
      final settings = SettingsController.instance;
      await settings.setGeminiApiKey('AIzaSyTest123456');
      expect(settings.hasValidAiKey, isTrue);

      await settings.clearGeminiApiKey();
      expect(settings.geminiApiKey, isNull);
      expect(settings.hasValidAiKey, isFalse);
    });

    test('setAiEnabled toggles AI assistant state', () async {
      final settings = SettingsController.instance;
      expect(settings.aiEnabled, isTrue);

      await settings.setAiEnabled(false);
      expect(settings.aiEnabled, isFalse);

      await settings.setAiEnabled(true);
      expect(settings.aiEnabled, isTrue);
    });
  });

  group('AiAssistantController State Management Tests', () {
    test('initial state is idle', () {
      final controller = AiAssistantController.instance;
      controller.reset();
      expect(controller.state, equals(AiAssistantState.idle));
      expect(controller.isRecording, isFalse);
      expect(controller.isProcessing, isFalse);
      expect(controller.isSpeaking, isFalse);
    });

    test('recording fails with message if API key is missing', () async {
      final settings = SettingsController.instance;
      await settings.clearGeminiApiKey();

      final controller = AiAssistantController.instance;
      final started = await controller.startRecording();

      expect(started, isFalse);
      expect(controller.state, equals(AiAssistantState.error));
      expect(controller.errorMessage, contains('مفتاح Gemini API'));
    });

    test('GeminiVoiceService pcmToWav produces valid RIFF WAVE header', () {
      final dummyPcm = List<int>.generate(100, (i) => i % 256);
      final wav = GeminiVoiceService.pcmToWav(
        Uint8List.fromList(dummyPcm),
        sampleRate: 24000,
        channels: 1,
        bitDepth: 16,
      );

      expect(wav.length, equals(44 + 100));
      // RIFF header magic bytes
      expect(String.fromCharCodes(wav.sublist(0, 4)), equals('RIFF'));
      // WAVE header magic bytes
      expect(String.fromCharCodes(wav.sublist(8, 12)), equals('WAVE'));
      // fmt sub-chunk
      expect(String.fromCharCodes(wav.sublist(12, 16)), equals('fmt '));
      // data sub-chunk
      expect(String.fromCharCodes(wav.sublist(36, 40)), equals('data'));
    });

    test('GeminiVoiceService tracks lastSpeechError when key is missing', () async {
      final settings = SettingsController.instance;
      await settings.clearGeminiApiKey();

      final result = await GeminiVoiceService.instance.generateAiSpeech('مرحبا');
      expect(result, isNull);
      expect(GeminiVoiceService.instance.lastSpeechError, contains('مفتاح Gemini API'));
    });
  });
}

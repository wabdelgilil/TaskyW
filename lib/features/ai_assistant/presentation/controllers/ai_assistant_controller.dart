import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/presentation/controllers/audio_briefing_controller.dart';
import 'package:tasky/features/tasks/presentation/controllers/tasks_controller.dart';
import '../../data/models/ai_intent_model.dart';
import '../../data/services/gemini_voice_service.dart';

enum AiAssistantState {
  idle,
  recording,
  processing,
  speaking,
  success,
  error,
}

/// متحكم المساعد الصوتي والذكاء الاصطناعي لتطبيق TaskyW
class AiAssistantController extends ChangeNotifier {
  static final AiAssistantController instance = AiAssistantController._internal();

  AiAssistantController._internal() {
    _initTts();
  }

  final GeminiVoiceService _service = GeminiVoiceService.instance;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final FlutterTts _tts = FlutterTts();

  AiAssistantState _state = AiAssistantState.idle;
  String? _statusMessage;
  String? _errorMessage;
  AiIntentResult? _lastResult;
  TaskModel? _createdTask;
  String? _currentRecordingPath;

  AiAssistantState get state => _state;
  String? get statusMessage => _statusMessage;
  String? get errorMessage => _errorMessage;
  AiIntentResult? get lastResult => _lastResult;
  TaskModel? get createdTask => _createdTask;
  bool get isRecording => _state == AiAssistantState.recording;
  bool get isProcessing => _state == AiAssistantState.processing;
  bool get isSpeaking => _state == AiAssistantState.speaking;

  Future<void> _initTts() async {
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('[AiAssistantController] TTS init error: $e');
    }
  }

  void reset() {
    _state = AiAssistantState.idle;
    _statusMessage = null;
    _errorMessage = null;
    _lastResult = null;
    _createdTask = null;
    notifyListeners();
  }

  // ─── تسجيل الصوت والأوامر الصوتية ────────────────────────────────────────

  /// بدء تسجيل الصوت
  Future<bool> startRecording() async {
    try {
      if (!SettingsController.instance.hasValidAiKey) {
        _errorMessage = 'يرجى إدخال مفتاح Gemini API في الإعدادات أولاً.';
        _state = AiAssistantState.error;
        notifyListeners();
        return false;
      }

      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        _errorMessage = 'صلاحية الميكروفون مطلوبة للتسجيل الصوتي.';
        _state = AiAssistantState.error;
        notifyListeners();
        return false;
      }

      final dir = await getTemporaryDirectory();
      final filePath = '${dir.path}/tasky_ai_cmd_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = filePath;

      const config = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 44100,
      );

      await _audioRecorder.start(config, path: filePath);
      _state = AiAssistantState.recording;
      _statusMessage = 'جاري الاستماع... تحدث الآن';
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('[AiAssistantController] startRecording error: $e');
      _errorMessage = 'فشل بدء التسجيل: $e';
      _state = AiAssistantState.error;
      notifyListeners();
      return false;
    }
  }

  /// إيقاف تسجيل الصوت ومعالجة الأمر
  Future<void> stopAndProcessRecording({
    required TasksController tasksController,
    required List<ProjectModel> projects,
    required List<AreaModel> areas,
  }) async {
    try {
      if (_state != AiAssistantState.recording) return;

      final path = await _audioRecorder.stop();
      final filePath = path ?? _currentRecordingPath;
      if (filePath == null) {
        _state = AiAssistantState.idle;
        notifyListeners();
        return;
      }

      final file = File(filePath);
      if (!await file.exists()) {
        _errorMessage = 'تعذر العثور على ملف التسجيل الصوتي.';
        _state = AiAssistantState.error;
        notifyListeners();
        return;
      }

      final bytes = await file.readAsBytes();
      // حذف الملف المؤقت بعد قراءته
      try {
        await file.delete();
      } catch (_) {}

      if (bytes.lengthInBytes < 1000) {
        _errorMessage = 'التسجيل قصير جداً، يرجى المحاولة مرة أخرى.';
        _state = AiAssistantState.error;
        notifyListeners();
        return;
      }

      _state = AiAssistantState.processing;
      _statusMessage = 'جاري تحليل وفهم الأمر الصوتي...';
      notifyListeners();

      final result = await _service.processAudioCommand(
        bytes,
        mimeType: 'audio/mp4',
        projects: projects,
        areas: areas,
      );

      await _executeIntent(
        result,
        tasksController: tasksController,
        projects: projects,
        areas: areas,
      );
    } catch (e) {
      debugPrint('[AiAssistantController] stopAndProcessRecording error: $e');
      _errorMessage = 'حدث خطأ أثناء معالجة الصوت: $e';
      _state = AiAssistantState.error;
      notifyListeners();
    }
  }

  /// إلغاء التسجيل بدون معالجة
  Future<void> cancelRecording() async {
    try {
      if (_state == AiAssistantState.recording) {
        await _audioRecorder.stop();
        if (_currentRecordingPath != null) {
          final file = File(_currentRecordingPath!);
          if (await file.exists()) {
            await file.delete();
          }
        }
      }
    } catch (_) {}
    _state = AiAssistantState.idle;
    _statusMessage = null;
    notifyListeners();
  }

  // ─── معالجة الأوامر النصية ────────────────────────────────────────────────

  /// معالجة أمر نصي مباشر
  Future<void> processTextCommand(
    String text, {
    required TasksController tasksController,
    required List<ProjectModel> projects,
    required List<AreaModel> areas,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    if (!SettingsController.instance.hasValidAiKey) {
      _errorMessage = 'يرجى إدخال مفتاح Gemini API في الإعدادات أولاً.';
      _state = AiAssistantState.error;
      notifyListeners();
      return;
    }

    _state = AiAssistantState.processing;
    _statusMessage = 'جاري التفكير والتنفيذ...';
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.processTextCommand(
        trimmed,
        projects: projects,
        areas: areas,
      );

      await _executeIntent(
        result,
        tasksController: tasksController,
        projects: projects,
        areas: areas,
      );
    } catch (e) {
      debugPrint('[AiAssistantController] processTextCommand error: $e');
      _errorMessage = 'فشل تنفيذ الأمر: $e';
      _state = AiAssistantState.error;
      notifyListeners();
    }
  }

  // ─── تنفيذ النية المحددة (Intent Execution) ──────────────────────────────

  Future<void> _executeIntent(
    AiIntentResult result, {
    required TasksController tasksController,
    required List<ProjectModel> projects,
    required List<AreaModel> areas,
  }) async {
    _lastResult = result;

    switch (result.type) {
      case AiIntentType.createTask:
        await _handleCreateTask(result, tasksController, projects, areas);
        break;

      case AiIntentType.readTasks:
        await _handleReadTasks(result, tasksController, projects, areas);
        break;

      case AiIntentType.conversationalHelp:
        _state = AiAssistantState.success;
        _statusMessage = result.conversationalAnswer ?? result.voiceReply;
        notifyListeners();
        await _speak(result.voiceReply);
        break;

      case AiIntentType.unknown:
        _state = AiAssistantState.error;
        _errorMessage = result.voiceReply.isNotEmpty
            ? result.voiceReply
            : 'عذراً، لم أستطع فهم الأمر المطلوب.';
        notifyListeners();
        await _speak(_errorMessage!);
        break;
    }
  }

  /// تنفيذ إنشاء المهمة وحفظها
  Future<void> _handleCreateTask(
    AiIntentResult result,
    TasksController tasksController,
    List<ProjectModel> projects,
    List<AreaModel> areas,
  ) async {
    final params = result.createTask;
    if (params == null || params.title.isEmpty) {
      _errorMessage = 'لم يتم تحديد عنوان صالح للمهمة.';
      _state = AiAssistantState.error;
      notifyListeners();
      return;
    }

    // مطابقة المجال إن لم يكن محدداً ولكن حُدد المشروع
    String? matchedAreaId = params.areaId;
    if (matchedAreaId == null && params.projectId != null) {
      final prj = projects.where((p) => p.id == params.projectId).firstOrNull;
      if (prj != null) {
        matchedAreaId = prj.areaId;
      }
    }
    // إذا لم يتوفر أي مجال، نربطها بأول مجال متاح
    if (matchedAreaId == null && areas.isNotEmpty) {
      matchedAreaId = areas.first.id;
    }

    final newTask = TaskModel(
      id: const Uuid().v4(),
      title: params.title,
      description: params.description,
      areaId: matchedAreaId ?? 'general',
      projectId: params.projectId,
      priority: params.priority,
      status: 'todo',
      dueDate: params.dueDate,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      syncStatus: 'pending_insert',
    );

    await tasksController.createTask(newTask);
    _createdTask = newTask;
    _state = AiAssistantState.success;
    _statusMessage = result.voiceReply;
    notifyListeners();

    await _speak(result.voiceReply);
  }

  /// تنفيذ قراءة واستعراض المهام عبر AudioBriefingController
  Future<void> _handleReadTasks(
    AiIntentResult result,
    TasksController tasksController,
    List<ProjectModel> projects,
    List<AreaModel> areas,
  ) async {
    final params = result.readTasks ?? const ReadTasksParams(scope: 'today');
    List<TaskModel> targetTasks = [];
    String contextTitle = 'مهام اليوم';

    switch (params.scope) {
      case 'today':
        targetTasks = tasksController.todayTasks;
        contextTitle = 'مهام اليوم';
        break;

      case 'tomorrow':
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        targetTasks = tasksController.tasks.where((t) {
          if (t.dueDate == null) return false;
          return t.dueDate!.year == tomorrow.year &&
              t.dueDate!.month == tomorrow.month &&
              t.dueDate!.day == tomorrow.day &&
              t.status != 'completed';
        }).toList();
        contextTitle = 'مهام الغد';
        break;

      case 'upcoming':
        targetTasks = tasksController.upcomingTasks;
        contextTitle = 'المهام القادمة';
        break;

      case 'urgent':
        targetTasks = tasksController.urgentTasks;
        contextTitle = 'المهام العاجلة';
        break;

      case 'project':
        if (params.targetId != null) {
          targetTasks = tasksController.tasks
              .where((t) => t.projectId == params.targetId && t.status != 'completed')
              .toList();
        } else if (params.targetName != null) {
          final query = params.targetName!.toLowerCase();
          final prj = projects.where((p) => p.name.toLowerCase().contains(query)).firstOrNull;
          if (prj != null) {
            targetTasks = tasksController.tasks
                .where((t) => t.projectId == prj.id && t.status != 'completed')
                .toList();
            contextTitle = 'مشروع ${prj.name}';
          }
        }
        break;

      case 'area':
        if (params.targetId != null) {
          targetTasks = tasksController.tasks
              .where((t) => t.areaId == params.targetId && t.status != 'completed')
              .toList();
        } else if (params.targetName != null) {
          final query = params.targetName!.toLowerCase();
          final area = areas.where((a) => a.name.toLowerCase().contains(query)).firstOrNull;
          if (area != null) {
            targetTasks = tasksController.tasks
                .where((t) => t.areaId == area.id && t.status != 'completed')
                .toList();
            contextTitle = 'مجال ${area.name}';
          }
        }
        break;

      case 'all':
      default:
        targetTasks = tasksController.tasks.where((t) => t.status != 'completed').toList();
        contextTitle = 'كافة المهام النشطة';
        break;
    }

    _state = AiAssistantState.success;
    if (targetTasks.isEmpty) {
      _statusMessage = 'لا توجد مهام في $contextTitle.';
      notifyListeners();
      await _speak('لا توجد مهام مسجلة في $contextTitle، جدولك فارغ!');
      return;
    }

    _statusMessage = 'جاري قراءة ${targetTasks.length} مهام في $contextTitle...';
    notifyListeners();

    // تشغيل القراءة عبر المحرك الصوتي القائم
    AudioBriefingController.instance.startBriefing(
      contextTitle: contextTitle,
      tasks: targetTasks,
      languageCode: 'ar',
    );
  }

  /// نطق رد المساعد صوتياً
  Future<void> _speak(String text) async {
    if (text.trim().isEmpty) return;
    try {
      _state = AiAssistantState.speaking;
      notifyListeners();

      final isArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(text);
      await _tts.setLanguage(isArabic ? 'ar' : 'en-US');
      await _tts.speak(text);
    } catch (e) {
      debugPrint('[AiAssistantController] speak error: $e');
    } finally {
      if (_state == AiAssistantState.speaking) {
        _state = AiAssistantState.idle;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _audioRecorder.dispose();
    super.dispose();
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:uuid/uuid.dart';

import 'package:tasky/core/utils/date_time_utils.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import 'package:tasky/features/tasks/data/repositories/task_repository_impl.dart';
import 'package:tasky/features/tasks/presentation/controllers/audio_briefing_controller.dart';
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

  final List<int> _recordedChunks = [];
  StreamSubscription<Uint8List>? _recordSub;

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

  // ─── تسجيل الصوت والأوامر الصوتية (Cross-Platform In-Memory) ───────────

  /// بدء تسجيل الصوت عبر Stream مباشر في الذاكرة (يدعم Web وكل الأنظمة)
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

      _recordedChunks.clear();
      const config = RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      );

      final stream = await _audioRecorder.startStream(config);
      _recordSub = stream.listen((data) {
        _recordedChunks.addAll(data);
      });

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

  /// إيقاف تسجيل الصوت ومعالجة الأمر عبر الذاكرة مباشرة
  Future<void> stopAndProcessRecording({
    required List<ProjectModel> projects,
    required List<AreaModel> areas,
    List<TaskModel> tasks = const [],
    Function(TaskModel)? onSaveTask,
  }) async {
    try {
      if (_state != AiAssistantState.recording) return;

      await _audioRecorder.stop();
      await _recordSub?.cancel();
      _recordSub = null;

      if (_recordedChunks.length < 1600) {
        _errorMessage = 'التسجيل قصير جداً، يرجى المحاولة مرة أخرى.';
        _state = AiAssistantState.error;
        notifyListeners();
        return;
      }

      _state = AiAssistantState.processing;
      _statusMessage = 'جاري تحليل وفهم الأمر الصوتي...';
      notifyListeners();

      final pcmBytes = Uint8List.fromList(_recordedChunks);
      final wavBytes = _pcmToWav(pcmBytes, sampleRate: 16000, channels: 1);

      final result = await _service.processAudioCommand(
        wavBytes,
        mimeType: 'audio/wav',
        projects: projects,
        areas: areas,
      );

      await _executeIntent(
        result,
        projects: projects,
        areas: areas,
        tasks: tasks,
        onSaveTask: onSaveTask,
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
        await _recordSub?.cancel();
        _recordSub = null;
        _recordedChunks.clear();
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
    required List<ProjectModel> projects,
    required List<AreaModel> areas,
    List<TaskModel> tasks = const [],
    Function(TaskModel)? onSaveTask,
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
        projects: projects,
        areas: areas,
        tasks: tasks,
        onSaveTask: onSaveTask,
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
    required List<ProjectModel> projects,
    required List<AreaModel> areas,
    required List<TaskModel> tasks,
    Function(TaskModel)? onSaveTask,
  }) async {
    _lastResult = result;

    switch (result.type) {
      case AiIntentType.createTask:
        await _handleCreateTask(result, projects, areas, onSaveTask);
        break;

      case AiIntentType.readTasks:
        await _handleReadTasks(result, projects, areas, tasks);
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

  /// تنفيذ إنشاء المهمة وحفظها محلياً وتحديث الواجهة فوراً
  Future<void> _handleCreateTask(
    AiIntentResult result,
    List<ProjectModel> projects,
    List<AreaModel> areas,
    Function(TaskModel)? onSaveTask,
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

    // حفظ في قاعدة البيانات المحلية إن أمكن
    try {
      final repo = TaskRepositoryImpl();
      await repo.insertTask(newTask);
    } catch (e) {
      debugPrint('[AiAssistantController] DB save fallback error: $e');
    }

    // تحديث الواجهة عبر callback الحفظ المباشر
    onSaveTask?.call(newTask);

    _createdTask = newTask;
    _state = AiAssistantState.success;
    _statusMessage = result.voiceReply;
    notifyListeners();

    await _speak(result.voiceReply);
  }

  /// تنفيذ قراءة واستعراض المهام عبر AudioBriefingController
  Future<void> _handleReadTasks(
    AiIntentResult result,
    List<ProjectModel> projects,
    List<AreaModel> areas,
    List<TaskModel> providedTasks,
  ) async {
    final params = result.readTasks ?? const ReadTasksParams(scope: 'today');
    List<TaskModel> allTasks = providedTasks;
    if (allTasks.isEmpty) {
      try {
        allTasks = await TaskRepositoryImpl().getTasks();
      } catch (_) {}
    }

    List<TaskModel> targetTasks = [];
    String contextTitle = 'مهام اليوم';

    switch (params.scope) {
      case 'today':
        targetTasks = allTasks
            .where((t) => DateTimeUtils.isToday(t.dueDate) && t.status != 'completed')
            .toList();
        contextTitle = 'مهام اليوم';
        break;

      case 'tomorrow':
        final tomorrow = DateTime.now().add(const Duration(days: 1));
        targetTasks = allTasks.where((t) {
          if (t.dueDate == null) return false;
          return t.dueDate!.year == tomorrow.year &&
              t.dueDate!.month == tomorrow.month &&
              t.dueDate!.day == tomorrow.day &&
              t.status != 'completed';
        }).toList();
        contextTitle = 'مهام الغد';
        break;

      case 'upcoming':
        targetTasks = allTasks
            .where((t) => DateTimeUtils.isUpcoming(t.dueDate) && t.status != 'completed')
            .toList();
        contextTitle = 'المهام القادمة';
        break;

      case 'urgent':
        targetTasks = allTasks
            .where((t) => t.priority == 'urgent' && t.status != 'completed')
            .toList();
        contextTitle = 'المهام العاجلة';
        break;

      case 'project':
        if (params.targetId != null) {
          targetTasks = allTasks
              .where((t) => t.projectId == params.targetId && t.status != 'completed')
              .toList();
        } else if (params.targetName != null) {
          final query = params.targetName!.toLowerCase();
          final prj = projects.where((p) => p.name.toLowerCase().contains(query)).firstOrNull;
          if (prj != null) {
            targetTasks = allTasks
                .where((t) => t.projectId == prj.id && t.status != 'completed')
                .toList();
            contextTitle = 'مشروع ${prj.name}';
          }
        }
        break;

      case 'area':
        if (params.targetId != null) {
          targetTasks = allTasks
              .where((t) => t.areaId == params.targetId && t.status != 'completed')
              .toList();
        } else if (params.targetName != null) {
          final query = params.targetName!.toLowerCase();
          final area = areas.where((a) => a.name.toLowerCase().contains(query)).firstOrNull;
          if (area != null) {
            targetTasks = allTasks
                .where((t) => t.areaId == area.id && t.status != 'completed')
                .toList();
            contextTitle = 'مجال ${area.name}';
          }
        }
        break;

      case 'all':
      default:
        targetTasks = allTasks.where((t) => t.status != 'completed').toList();
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

  /// تحويل بيانات PCM 16-bit الخام إلى ملف WAV قياسي في الذاكرة
  static Uint8List _pcmToWav(
    Uint8List pcmBytes, {
    int sampleRate = 16000,
    int channels = 1,
    int bitDepth = 16,
  }) {
    final byteRate = sampleRate * channels * (bitDepth ~/ 8);
    final blockAlign = channels * (bitDepth ~/ 8);
    final dataSize = pcmBytes.length;
    final chunkSize = 36 + dataSize;

    final header = ByteData(44);
    // RIFF chunk
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, chunkSize, Endian.little);
    header.setUint8(8, 0x57);  // W
    header.setUint8(9, 0x41);  // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E

    // fmt sub-chunk
    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6D); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little); // Subchunk1Size
    header.setUint16(20, 1, Endian.little);  // PCM format
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitDepth, Endian.little);

    // data sub-chunk
    header.setUint8(36, 0x64); // d
    header.setUint8(37, 0x61); // a
    header.setUint8(38, 0x74); // t
    header.setUint8(39, 0x61); // a
    header.setUint32(40, dataSize, Endian.little);

    final wav = Uint8List(44 + dataSize);
    wav.setRange(0, 44, header.buffer.asUint8List());
    wav.setRange(44, 44 + dataSize, pcmBytes);
    return wav;
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
    _recordSub?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }
}

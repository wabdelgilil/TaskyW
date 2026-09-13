import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../data/models/task_model.dart';

/// حالة تشغيل الموجز الصوتي للمهام
enum AudioBriefingState { stopped, playing, paused }

/// متحكم القراءة الصوتية للمهام (Audio Briefing & TTS Controller)
/// يدير محرك النطق، طابور المهام، حالات التشغيل، وتحديد المهمة النشطة حالياً
class AudioBriefingController extends ChangeNotifier {
  static final AudioBriefingController instance = AudioBriefingController._internal();

  AudioBriefingController._internal() {
    _initTts();
  }

  // محرك النطق
  final FlutterTts _tts = FlutterTts();
  bool _isTtsInitialized = false;

  // الحالات
  AudioBriefingState _state = AudioBriefingState.stopped;
  String? _contextTitle;
  List<TaskModel> _activeQueue = [];
  int _currentIndex = -1; // -1 = مقدمة، 0..N = المهام
  String? _currentTaskId;
  double _speechRate = 0.5;
  int _sessionId = 0;
  Completer<void>? _itemCompleter;

  // Getters
  AudioBriefingState get state => _state;
  bool get isPlaying => _state == AudioBriefingState.playing;
  bool get isPaused => _state == AudioBriefingState.paused;
  bool get isStopped => _state == AudioBriefingState.stopped;
  bool get isActive => _state != AudioBriefingState.stopped;

  String? get contextTitle => _contextTitle;
  List<TaskModel> get activeQueue => List.unmodifiable(_activeQueue);
  int get currentIndex => _currentIndex;
  int get totalTasks => _activeQueue.length;
  String? get currentTaskId => _currentTaskId;
  double get speechRate => _speechRate;

  TaskModel? get currentTask {
    if (_currentIndex >= 0 && _currentIndex < _activeQueue.length) {
      return _activeQueue[_currentIndex];
    }
    return null;
  }

  Future<void> _initTts() async {
    if (_isTtsInitialized) return;
    try {
      await _tts.awaitSpeakCompletion(true);
      await _tts.setSpeechRate(_speechRate);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      _tts.setCompletionHandler(() {
        if (_itemCompleter != null && !_itemCompleter!.isCompleted) {
          _itemCompleter!.complete();
        }
      });

      _tts.setCancelHandler(() {
        if (_itemCompleter != null && !_itemCompleter!.isCompleted) {
          _itemCompleter!.complete();
        }
      });

      _tts.setErrorHandler((msg) {
        debugPrint('[AudioBriefing] TTS error: $msg');
        if (_itemCompleter != null && !_itemCompleter!.isCompleted) {
          _itemCompleter!.complete();
        }
      });

      _isTtsInitialized = true;
    } catch (e) {
      debugPrint('[AudioBriefing] Failed to initialize TTS: $e');
    }
  }

  /// ضبط لغة النطق المناسبة للنص (عربي أو إنجليزي)
  Future<void> _configureLanguage(String text, {String? preferredLang}) async {
    try {
      final isArabic = preferredLang == 'ar' || RegExp(r'[\u0600-\u06FF]').hasMatch(text);
      if (isArabic) {
        await _tts.setLanguage('ar');
      } else {
        await _tts.setLanguage('en-US');
      }
    } catch (e) {
      debugPrint('[AudioBriefing] Error setting language: $e');
    }
  }

  /// بدء القراءة الصوتية لسياق محدد مع قائمة من المهام
  Future<void> startBriefing({
    required String contextTitle,
    required List<TaskModel> tasks,
    String? languageCode,
  }) async {
    await _initTts();

    // تصفية المهام غير المكتملة فقط
    final pendingTasks = tasks.where((t) => t.status != 'completed').toList();
    if (pendingTasks.isEmpty) {
      await stop();
      return;
    }

    // إيقاف أي جلسة سابقة
    await stop(notify: false);

    _sessionId++;
    final currentSession = _sessionId;
    _contextTitle = contextTitle;
    _activeQueue = pendingTasks;
    _currentIndex = -1;
    _currentTaskId = null;
    _state = AudioBriefingState.playing;
    notifyListeners();

    // 1. قراءة المقدمة
    final isAr = languageCode == 'ar' || RegExp(r'[\u0600-\u06FF]').hasMatch(contextTitle);
    final introText = isAr
        ? 'ملخص مهام $contextTitle: لديك ${pendingTasks.length} مهام متبقية.'
        : 'Tasks summary for $contextTitle: you have ${pendingTasks.length} pending tasks.';

    await _speakText(introText, languageCode: isAr ? 'ar' : 'en');
    if (_sessionId != currentSession || _state != AudioBriefingState.playing) return;

    // 2. قراءة كل مهمة بالتسلسل
    _currentIndex = 0;
    while (_currentIndex < _activeQueue.length) {
      if (_sessionId != currentSession || _state == AudioBriefingState.stopped) break;

      if (_state == AudioBriefingState.paused) {
        // ننتظر حتى يستأنف المستخدم
        await Future.delayed(const Duration(milliseconds: 300));
        continue;
      }

      final task = _activeQueue[_currentIndex];
      _currentTaskId = task.id;
      notifyListeners();

      // فحص لغة المهمة الفردية: إذا كانت إنجليزية بالكامل تُنطق بمحرك إنجليزي فصيح
      // وإذا كانت عربية أو مخلطة (عربي + إنجليزي) تُنطق بالمحرك العربي الذي يدعم الكلمات اللاتينية المدمجة
      final isTaskArabic = RegExp(r'[\u0600-\u06FF]').hasMatch(task.title) || (isAr && task.title.trim().isEmpty);
      final taskSpokenText = _formatTaskSpokenText(task, _currentIndex + 1, isArabic: isTaskArabic);
      await _speakText(taskSpokenText, languageCode: isTaskArabic ? 'ar' : 'en');

      if (_sessionId != currentSession || _state == AudioBriefingState.stopped) break;

      // وقفة بسيطة بين المهام (800ms)
      await Future.delayed(const Duration(milliseconds: 800));

      if (_sessionId != currentSession || _state != AudioBriefingState.playing) break;

      _currentIndex++;
    }

    // انتهاء القراءة
    if (_sessionId == currentSession && _state == AudioBriefingState.playing) {
      final endText = isAr ? 'تمت قراءة جميع المهام.' : 'All tasks completed.';
      await _speakText(endText, languageCode: isAr ? 'ar' : 'en');
      await stop();
    }
  }

  /// صياغة النص المقروء للمهمة (متاحة أيضاً للاختبارات البرمجية)
  String formatTaskSpokenText(TaskModel task, int number, {required bool isArabic}) {
    return _formatTaskSpokenText(task, number, isArabic: isArabic);
  }

  String _formatTaskSpokenText(TaskModel task, int number, {required bool isArabic}) {
    final buffer = StringBuffer();
    if (isArabic) {
      buffer.write('المهمة رقم $number: ${task.title}.');
      if (task.priority == 'urgent') {
        buffer.write(' أولوية عاجلة.');
      } else if (task.priority == 'high') {
        buffer.write(' أولوية مرتفعة.');
      }
      if (task.dueDate != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final due = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        if (due.isAtSameMomentAs(today)) {
          buffer.write(' موعد الاستحقاق اليوم.');
        } else if (due.difference(today).inDays == 1) {
          buffer.write(' موعد الاستحقاق غداً.');
        } else {
          buffer.write(' موعد الاستحقاق ${task.dueDate!.day}/${task.dueDate!.month}.');
        }
      }
    } else {
      buffer.write('Task number $number: ${task.title}.');
      if (task.priority == 'urgent') {
        buffer.write(' Urgent priority.');
      } else if (task.priority == 'high') {
        buffer.write(' High priority.');
      }
      if (task.dueDate != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final due = DateTime(task.dueDate!.year, task.dueDate!.month, task.dueDate!.day);
        if (due.isAtSameMomentAs(today)) {
          buffer.write(' Due today.');
        } else if (due.difference(today).inDays == 1) {
          buffer.write(' Due tomorrow.');
        } else {
          buffer.write(' Due date ${task.dueDate!.day}/${task.dueDate!.month}.');
        }
      }
    }
    return buffer.toString();
  }

  /// نطق نص وانتظار اكتماله
  Future<void> _speakText(String text, {String? languageCode}) async {
    try {
      await _configureLanguage(text, preferredLang: languageCode);
      _itemCompleter = Completer<void>();
      await _tts.speak(text);

      // انتظار النطق مع حد أقصى للحماية (15 ثانية)
      await _itemCompleter?.future.timeout(
        const Duration(seconds: 15),
        onTimeout: () {},
      );
    } catch (e) {
      debugPrint('[AudioBriefing] Speak error: $e');
    } finally {
      _itemCompleter = null;
    }
  }

  /// إيقاف مؤقت
  Future<void> pause() async {
    if (_state != AudioBriefingState.playing) return;
    _state = AudioBriefingState.paused;
    try {
      await _tts.stop();
    } catch (_) {}
    if (_itemCompleter != null && !_itemCompleter!.isCompleted) {
      _itemCompleter!.complete();
    }
    notifyListeners();
  }

  /// استئناف القراءة
  Future<void> resume({String? languageCode}) async {
    if (_state != AudioBriefingState.paused) return;
    _state = AudioBriefingState.playing;
    notifyListeners();

    if (_currentIndex >= 0 && _currentIndex < _activeQueue.length) {
      final task = _activeQueue[_currentIndex];
      _currentTaskId = task.id;
      final isAr = RegExp(r'[\u0600-\u06FF]').hasMatch(task.title);
      final text = _formatTaskSpokenText(task, _currentIndex + 1, isArabic: isAr);
      await _speakText(text, languageCode: isAr ? 'ar' : 'en');
    }
  }

  /// الانتقال للمهمة التالية
  Future<void> next({String? languageCode}) async {
    if (_activeQueue.isEmpty) return;
    try {
      await _tts.stop();
    } catch (_) {}
    if (_itemCompleter != null && !_itemCompleter!.isCompleted) {
      _itemCompleter!.complete();
    }

    if (_currentIndex + 1 < _activeQueue.length) {
      _currentIndex++;
      _currentTaskId = _activeQueue[_currentIndex].id;
      _state = AudioBriefingState.playing;
      notifyListeners();

      final task = _activeQueue[_currentIndex];
      final isAr = RegExp(r'[\u0600-\u06FF]').hasMatch(task.title);
      final text = _formatTaskSpokenText(task, _currentIndex + 1, isArabic: isAr);
      await _speakText(text, languageCode: isAr ? 'ar' : 'en');
    } else {
      await stop();
    }
  }

  /// العودة للمهمة السابقة
  Future<void> previous({String? languageCode}) async {
    if (_activeQueue.isEmpty) return;
    try {
      await _tts.stop();
    } catch (_) {}
    if (_itemCompleter != null && !_itemCompleter!.isCompleted) {
      _itemCompleter!.complete();
    }

    if (_currentIndex > 0) {
      _currentIndex--;
    }
    _currentTaskId = _activeQueue[_currentIndex].id;
    _state = AudioBriefingState.playing;
    notifyListeners();

    final task = _activeQueue[_currentIndex];
    final isAr = RegExp(r'[\u0600-\u06FF]').hasMatch(task.title);
    final text = _formatTaskSpokenText(task, _currentIndex + 1, isArabic: isAr);
    await _speakText(text, languageCode: isAr ? 'ar' : 'en');
  }

  /// إيقاف كامل وإنهاء الجلسة
  Future<void> stop({bool notify = true}) async {
    _sessionId++;
    _state = AudioBriefingState.stopped;
    _currentIndex = -1;
    _currentTaskId = null;
    _activeQueue = [];
    _contextTitle = null;

    try {
      await _tts.stop();
    } catch (_) {}

    if (_itemCompleter != null && !_itemCompleter!.isCompleted) {
      _itemCompleter!.complete();
    }

    if (notify) {
      notifyListeners();
    }
  }

  /// تغيير سرعة النطق (بين 0.25 و 1.0)
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.25, 1.0);
    try {
      await _tts.setSpeechRate(_speechRate);
    } catch (_) {}
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

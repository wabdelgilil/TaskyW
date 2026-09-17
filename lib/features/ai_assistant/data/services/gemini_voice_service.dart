import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';
import 'package:tasky/features/tasks/data/models/task_model.dart';
import '../models/ai_intent_model.dart';

/// خدمة الذكاء الاصطناعي لمعالجة الأوامر الصوتية والنصية عبر Gemini
class GeminiVoiceService {
  static final GeminiVoiceService instance = GeminiVoiceService._internal();

  GeminiVoiceService._internal();

  /// تجهيز النموذج المولد مع تكوين إخراج JSON صارم
  GenerativeModel? _buildModel({String? overrideApiKey, String? overrideModel}) {
    final apiKey = overrideApiKey ?? SettingsController.instance.geminiApiKey;
    if (apiKey == null || apiKey.trim().isEmpty) {
      return null;
    }

    String modelName = overrideModel ?? SettingsController.instance.aiModel;
    if (modelName == 'gemini-2.0-flash' || modelName == 'gemini-1.5-flash') {
      modelName = 'gemini-2.5-flash';
    }

    return GenerativeModel(
      model: modelName,
      apiKey: apiKey.trim(),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.2,
      ),
    );
  }

  /// بناء تعليمات النظام (System Context) متضمنة التاريخ والمشاريع والمجالات وقائمة المهام الحالية
  String _buildSystemContext({
    required List<ProjectModel> projects,
    required List<AreaModel> areas,
    List<TaskModel> tasks = const [],
  }) {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final projectsJson = projects.map((p) => {'id': p.id, 'name': p.name}).toList();
    final areasJson = areas.map((a) => {'id': a.id, 'name': a.name}).toList();

    final activeTasksJson = tasks.where((t) => t.status != 'completed').take(40).map((t) {
      final prj = projects.where((p) => p.id == t.projectId).firstOrNull?.name;
      final area = areas.where((a) => a.id == t.areaId).firstOrNull?.name;
      return {
        'id': t.id,
        'title': t.title,
        'due': t.dueDate != null
            ? '${t.dueDate!.year}-${t.dueDate!.month.toString().padLeft(2, '0')}-${t.dueDate!.day.toString().padLeft(2, '0')} ${t.dueDate!.hour.toString().padLeft(2, '0')}:${t.dueDate!.minute.toString().padLeft(2, '0')}'
            : null,
        'priority': t.priority,
        'project': prj,
        'area': area,
      };
    }).toList();

    return '''
أنت المساعد الذكي الصوتي الشخصي لتطبيق إدارة المهام TaskyW.
مهمتك تحليل أوامر المستخدم بذكاء فائق واستخراج النية والإجراء المناسب بصيغة JSON صارمة.

### معلومات الوقت والسياق:
- تاريخ اليوم: $dateStr (السنة-الشهر-اليوم)
- الوقت الحالي: $timeStr
- اليوم من الأسبوع: ${_getDayName(now.weekday)}
- المشاريع المسجلة: ${jsonEncode(projectsJson)}
- المجالات (Areas) المسجلة: ${jsonEncode(areasJson)}
- المهام النشطة الحالية للمستخدم:
${jsonEncode(activeTasksJson)}

### النوايا المدعومة (Intents):
1. **create_task**: إذا طلب المستخدم إضافة أو تسجيل مهمة جديدة.
   - قم بحساب تاريخ ووقت الاستحقاق بدقة بصيغة ISO 8601 بناءً على اليوم الحالي.
   - طابق اسم المشروع أو المجال مع القائمة وضع الـ id والاسم.
   - حدد الأولوية (urgent, high, medium, low).
   - اكتب في voice_reply رسالة تأكيد لطيفة وذكية.

2. **read_tasks**: إذا طلب المستخدم قراءة مهامه أو استعراضها أو سأل عما عليه فعله (مثل: "اقرأ مهام اليوم", "إيه اللي ورايا في مشروع المتجر", "لخص أولوياتي", "اقرأ كل المهام"):
   - قم بتحليل قائمة المهام النشطة المعطاة أعلاه، وصِغ **ملخصاً صوتياً تنفيذياً ذكياً وجذاباً جداً (AI Executive Voice Briefing)**:
     * تحدث كأنك سكرتير تنفيذي ذكي وخبير إنتاجية يتحدث بلهجة ودودة ومحترمة (بالعامية المصرية الراقية أو العربية الفصحى الحديثة).
     * اذكر عدد المهام بشكل عام في جملة افتتاحية رشيقة.
     * رتب المهام بحسب الأهمية والاستعجال، وابدأ دائماً بالمهام العاجلة والأقرب في موعد التسليم مع تنبيه ذكي للمستخدم.
     * اذكر المشاريع والمجالات بأسلوب سردي بشري سلس ومريح للأذن (تجنب السرد الآلي الرتيب مثل "المهمة رقم 1 كذا ورقم 2 كذا").
     * إذا لم تكن هناك مهام في النطاق المطلوب، أخبره بلطف أن جدوله خالٍ تماماً ويمكنه الاسترخاء.
     * اختم بنصيحة ذكية أو سؤال تحفيزي لطيف (مثال: "تحب نبدأ بمهمة كذا الأول؟").
   - ضع هذا النص السردي الذكي كاملاً في حقل `voice_reply` ليتم نطقه للمستخدم وعرضه في الشاشة.
   - ضع في `matched_task_ids` مصفوفة بالـ IDs الخاصة بالمهام التي تم ذكرها في الملخص.

3. **conversational_help**: إذا سأل سؤالاً عاماً أو طلب استشارة إنتاجية.

### مواصفات مخرجات الـ JSON:
يجب أن يكون الرد عبارة عن كائن JSON صالح فقط:
{
  "intent": "create_task" | "read_tasks" | "conversational_help",
  "voice_reply": "نص الرد أو الملخص التنفيذي الذكي الكامل للنطق والعرض",
  "create_task": {
    "title": "عنوان المهمة",
    "description": "تفاصيل إضافية إن وجدت",
    "due_date": "YYYY-MM-DDTHH:mm:ss",
    "priority": "urgent" | "high" | "medium" | "low",
    "project_id": "معرف المشروع",
    "project_name": "اسم المشروع",
    "area_id": "معرف المجال",
    "area_name": "اسم المجال"
  },
  "read_tasks": {
    "scope": "today" | "tomorrow" | "upcoming" | "urgent" | "project" | "area" | "all",
    "target_id": "معرف المشروع أو المجال إن وجد",
    "target_name": "اسم المشروع أو المجال",
    "matched_task_ids": ["task-id-1", "task-id-2"]
  }
}
''';
  }

  static String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.saturday:
        return 'السبت';
      case DateTime.sunday:
        return 'الأحد';
      case DateTime.monday:
        return 'الإثنين';
      case DateTime.tuesday:
        return 'الثلاثاء';
      case DateTime.wednesday:
        return 'الأربعاء';
      case DateTime.thursday:
        return 'الخميس';
      case DateTime.friday:
        return 'الجمعة';
      default:
        return '';
    }
  }

  /// معالجة أمر نصي
  Future<AiIntentResult> processTextCommand(
    String commandText, {
    required List<ProjectModel> projects,
    required List<AreaModel> areas,
    List<TaskModel> tasks = const [],
    String? overrideApiKey,
  }) async {
    final model = _buildModel(overrideApiKey: overrideApiKey);
    if (model == null) {
      return const AiIntentResult(
        type: AiIntentType.unknown,
        voiceReply: 'يرجى تسجيل مفتاح Gemini API في الإعدادات أولاً.',
      );
    }

    try {
      final systemContext = _buildSystemContext(projects: projects, areas: areas, tasks: tasks);
      final prompt = '$systemContext\n\nأمر المستخدم:\n"$commandText"';

      final response = await model.generateContent([
        Content.text(prompt),
      ]);

      final raw = response.text;
      if (raw == null || raw.isEmpty) {
        return const AiIntentResult(
          type: AiIntentType.unknown,
          voiceReply: 'لم أتمكن من استيعاب الأمر، يرجى المحاولة مرة أخرى.',
        );
      }

      final parsed = AiIntentResult.tryParseRawJson(raw);
      if (parsed != null) {
        return parsed;
      }

      return AiIntentResult(
        type: AiIntentType.conversationalHelp,
        voiceReply: raw,
        conversationalAnswer: raw,
      );
    } catch (e) {
      debugPrint('[GeminiVoiceService] processTextCommand error: $e');
      return AiIntentResult(
        type: AiIntentType.unknown,
        voiceReply: 'حدث خطأ أثناء معالجة الأمر: ${e.toString()}',
      );
    }
  }

  /// معالجة أمر صوتي مسجل (Multimodal Audio Bytes)
  Future<AiIntentResult> processAudioCommand(
    Uint8List audioBytes, {
    required String mimeType,
    required List<ProjectModel> projects,
    required List<AreaModel> areas,
    List<TaskModel> tasks = const [],
    String? overrideApiKey,
  }) async {
    final model = _buildModel(overrideApiKey: overrideApiKey);
    if (model == null) {
      return const AiIntentResult(
        type: AiIntentType.unknown,
        voiceReply: 'يرجى تسجيل مفتاح Gemini API في الإعدادات أولاً.',
      );
    }

    try {
      final systemContext = _buildSystemContext(projects: projects, areas: areas, tasks: tasks);
      final promptText = '$systemContext\n\nاستمع إلى المقطع الصوتي المرفق، وافهم أمر المستخدم بدقة ونفذ النية المطلوبة:';

      final response = await model.generateContent([
        Content.text(promptText),
        Content.data(mimeType, audioBytes),
      ]);

      final raw = response.text;
      if (raw == null || raw.isEmpty) {
        return const AiIntentResult(
          type: AiIntentType.unknown,
          voiceReply: 'لم أتمكن من سماع الأمر بوضوح، يرجى إعادة المحاولة.',
        );
      }

      final parsed = AiIntentResult.tryParseRawJson(raw);
      if (parsed != null) {
        return parsed;
      }

      return AiIntentResult(
        type: AiIntentType.conversationalHelp,
        voiceReply: raw,
        conversationalAnswer: raw,
      );
    } catch (e) {
      debugPrint('[GeminiVoiceService] processAudioCommand error: $e');
      return AiIntentResult(
        type: AiIntentType.unknown,
        voiceReply: 'حدث خطأ أثناء الاستماع للأمر الصوتي: ${e.toString()}',
      );
    }
  }

  /// تحويل مصفوفة بايتات PCM الخام إلى ملف WAV قياسي في الذاكرة
  static Uint8List pcmToWav(
    Uint8List pcmBytes, {
    int sampleRate = 24000,
    int channels = 1,
    int bitDepth = 16,
  }) {
    final byteRate = sampleRate * channels * (bitDepth ~/ 8);
    final blockAlign = channels * (bitDepth ~/ 8);
    final dataSize = pcmBytes.length;
    final chunkSize = 36 + dataSize;

    final header = ByteData(44);
    header.setUint8(0, 0x52); // R
    header.setUint8(1, 0x49); // I
    header.setUint8(2, 0x46); // F
    header.setUint8(3, 0x46); // F
    header.setUint32(4, chunkSize, Endian.little);
    header.setUint8(8, 0x57);  // W
    header.setUint8(9, 0x41);  // A
    header.setUint8(10, 0x56); // V
    header.setUint8(11, 0x45); // E

    header.setUint8(12, 0x66); // f
    header.setUint8(13, 0x6D); // m
    header.setUint8(14, 0x74); // t
    header.setUint8(15, 0x20); // ' '
    header.setUint32(16, 16, Endian.little);
    header.setUint16(20, 1, Endian.little);  // PCM format
    header.setUint16(22, channels, Endian.little);
    header.setUint32(24, sampleRate, Endian.little);
    header.setUint32(28, byteRate, Endian.little);
    header.setUint16(32, blockAlign, Endian.little);
    header.setUint16(34, bitDepth, Endian.little);

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

  /// توليد صوت بشري طبيعي حقيقي مباشرة من نموذج Gemini (Generative Voice AI)
  ///
  /// يرسل النص إلى نموذج `gemini-2.5-flash-preview-tts` ويعيد ملف صوتي بصيغة WAV
  /// جاهز للتشغيل مباشرة في المتصفح أو الويندوز أو الموبايل بدون أي تحويل روبوتي.
  Future<Uint8List?> generateAiSpeech(
    String text, {
    String? voiceName,
    String? overrideApiKey,
  }) async {
    final apiKey = overrideApiKey ?? SettingsController.instance.geminiApiKey;
    if (apiKey == null || apiKey.trim().isEmpty) return null;

    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return null;

    final selectedVoice = voiceName ?? SettingsController.instance.aiVoice;

    // استخدام نموذج Gemini TTS الصوتي المتطور
    const ttsModel = 'gemini-2.5-flash-preview-tts';
    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$ttsModel:generateContent?key=${apiKey.trim()}',
    );

    final payload = {
      "contents": [
        {
          "role": "user",
          "parts": [
            {
              "text": trimmedText,
            }
          ]
        }
      ],
      "generationConfig": {
        "responseModalities": ["AUDIO"],
        "speechConfig": {
          "voiceConfig": {
            "prebuiltVoiceConfig": {
              "voiceName": selectedVoice,
            }
          }
        }
      }
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 25));

      if (response.statusCode != 200) {
        debugPrint('[GeminiVoiceService] TTS request failed (${response.statusCode}): ${response.body}');
        return null;
      }

      final data = jsonDecode(utf8.decode(response.bodyBytes));
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) return null;

      final parts = candidates[0]['content']?['parts'] as List?;
      if (parts == null) return null;

      for (final part in parts) {
        if (part['inlineData'] != null) {
          final base64Data = part['inlineData']['data'] as String?;
          if (base64Data != null && base64Data.isNotEmpty) {
            final pcmBytes = base64Decode(base64Data);
            // تحويل دفق PCM 24000Hz إلى WAV نقي متوافق مع كافة المشغلات
            return pcmToWav(pcmBytes, sampleRate: 24000, channels: 1, bitDepth: 16);
          }
        }
      }
      return null;
    } catch (e) {
      debugPrint('[GeminiVoiceService] generateAiSpeech error: $e');
      return null;
    }
  }
}

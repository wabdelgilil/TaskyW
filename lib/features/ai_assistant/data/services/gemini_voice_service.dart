import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:tasky/features/areas/data/models/area_model.dart';
import 'package:tasky/features/projects/data/models/project_model.dart';
import 'package:tasky/features/settings/presentation/controllers/settings_controller.dart';
import '../models/ai_intent_model.dart';

/// خدمة الذكاء الاصطناعي لمعالجة الأوامر الصوتية والنصية عبر Gemini
class GeminiVoiceService {
  static final GeminiVoiceService instance = GeminiVoiceService._internal();

  GeminiVoiceService._internal();

  /// تجهيز النموذج المولد مع تكوين إخراج JSON صارم
  GenerativeModel? _buildModel({String? overrideApiKey}) {
    final apiKey = overrideApiKey ?? SettingsController.instance.geminiApiKey;
    if (apiKey == null || apiKey.trim().isEmpty) {
      return null;
    }

    final modelName = SettingsController.instance.aiModel;

    return GenerativeModel(
      model: modelName,
      apiKey: apiKey.trim(),
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
        temperature: 0.2,
      ),
    );
  }

  /// بناء تعليمات النظام (System Context) متضمنة التاريخ والمشاريع والمجالات
  String _buildSystemContext({
    required List<ProjectModel> projects,
    required List<AreaModel> areas,
  }) {
    final now = DateTime.now();
    final dateStr = '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final projectsJson = projects.map((p) => {'id': p.id, 'name': p.name}).toList();
    final areasJson = areas.map((a) => {'id': a.id, 'name': a.name}).toList();

    return '''
أنت المساعد الذكي الصوتي الشخصي لتطبيق إدارة المهام TaskyW.
مهمتك تحليل أوامر المستخدم (سواء كانت نصية أو مسجلة صوتياً باللهجات العربية أو الفصحى أو الإنجليزية) واستخراج النية (Intent) والإجراء المناسب بصيغة JSON صارمة فقط.

### معلومات السياق الحالي:
- تاريخ اليوم: $dateStr (السنة-الشهر-اليوم)
- الوقت الحالي: $timeStr
- اليوم من الأسبوع: ${_getDayName(now.weekday)}
- المشاريع المسجلة لدى المستخدم:
${jsonEncode(projectsJson)}
- المجالات (Areas) المسجلة:
${jsonEncode(areasJson)}

### النوايا المدعومة (Intents):
1. **create_task**: إذا طلب المستخدم إضافة أو تسجيل أو تذكير بمهمة جديدة (مثل: "سجل اجتماع مع أحمد بكرة العصر في مشروع المتجر").
   - قم بحساب تاريخ ووقت الاستحقاق بدقة بناءً على تاريخ ووقت اليوم في صيغة ISO 8601 (مثال: "2026-09-18T16:00:00").
   - طابق اسم المشروع أو المجال مع قائمة المشاريع والمجالات المتاحة وضع معرفه (id) واسمه. إذا لم يذكر مشروعاً اتركه null.
   - حدد الأولوية: urgent (عاجل), high (مهم), medium (عادي), low (منخفض). الافتراضي: medium.
   - اكتب voice_reply: رد صوتي لطيف ومختصر بالعربية لتأكيد الإضافة.

2. **read_tasks**: إذا طلب المستخدم قراءة أو استعراض مهامه صوتياً (مثل: "اقرأ مهام اليوم", "ايه اللي ورايا في مشروع المتجر", "اقرأ كل المهام").
   - حدد الـ scope بدقة:
     * 'today': مهام اليوم.
     * 'tomorrow': مهام الغد.
     * 'upcoming': المهام القادمة.
     * 'urgent': المهام العاجلة.
     * 'project': مهام مشروع معين (وضع target_id و target_name للمشروع المطابق).
     * 'area': مهام مجال معين (وضع target_id و target_name للمجال المطابق).
     * 'all': كل المهام النشطة.
   - اكتب voice_reply: رد صوتي قصير مثل "حاضر، جاري قراءة مهام اليوم..." أو "حاضر، سأقرأ لك مهام مشروع المتجر...".

3. **conversational_help**: إذا سأل سؤالاً عاماً أو نصيحة إنتاجية في التطبيق.

### مواصفات مخرجات الـ JSON:
يجب أن يكون الرد عبارة عن كائن JSON صالح فقط بدون أي شروحات، بالشكل:
{
  "intent": "create_task" | "read_tasks" | "conversational_help",
  "voice_reply": "نص الرد الذي سيُنطق للمستخدم صوتياً",
  "create_task": {
    "title": "عنوان المهمة",
    "description": "تفاصيل إضافية إن وجدت",
    "due_date": "YYYY-MM-DDTHH:mm:ss",
    "priority": "urgent" | "high" | "medium" | "low",
    "project_id": "معرف المشروع إن طابق",
    "project_name": "اسم المشروع إن طابق",
    "area_id": "معرف المجال إن طابق",
    "area_name": "اسم المجال إن طابق"
  },
  "read_tasks": {
    "scope": "today" | "tomorrow" | "upcoming" | "urgent" | "project" | "area" | "all",
    "target_id": "معرف المشروع أو المجال إن كان النطاق project أو area",
    "target_name": "اسم المشروع أو المجال"
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
      final systemContext = _buildSystemContext(projects: projects, areas: areas);
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
      final systemContext = _buildSystemContext(projects: projects, areas: areas);
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
}

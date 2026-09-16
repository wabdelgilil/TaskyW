import 'dart:convert';

/// نوع نية المستخدم المستخرجة من الأمر الصوتي أو النصي
enum AiIntentType {
  createTask,
  readTasks,
  conversationalHelp,
  unknown,
}

/// معاملات إنشاء مهمة جديدة
class CreateTaskParams {
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String priority; // urgent, high, medium, low
  final String? projectId;
  final String? projectName;
  final String? areaId;
  final String? areaName;

  const CreateTaskParams({
    required this.title,
    this.description,
    this.dueDate,
    this.priority = 'medium',
    this.projectId,
    this.projectName,
    this.areaId,
    this.areaName,
  });

  factory CreateTaskParams.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['due_date'] != null && json['due_date'].toString().isNotEmpty) {
      try {
        parsedDate = DateTime.tryParse(json['due_date'].toString());
      } catch (_) {}
    }

    String p = (json['priority'] ?? 'medium').toString().toLowerCase();
    if (!['urgent', 'high', 'medium', 'low'].contains(p)) {
      p = 'medium';
    }

    return CreateTaskParams(
      title: json['title']?.toString().trim() ?? 'مهمة جديدة',
      description: json['description']?.toString().trim(),
      dueDate: parsedDate,
      priority: p,
      projectId: json['project_id']?.toString(),
      projectName: json['project_name']?.toString(),
      areaId: json['area_id']?.toString(),
      areaName: json['area_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'due_date': dueDate?.toIso8601String(),
        'priority': priority,
        'project_id': projectId,
        'project_name': projectName,
        'area_id': areaId,
        'area_name': areaName,
      };
}

/// معاملات قراءة واستعراض المهام صوتياً
class ReadTasksParams {
  /// نطاق القراءة: today, tomorrow, upcoming, project, area, all, urgent, waiting
  final String scope;
  final String? targetId;
  final String? targetName;

  const ReadTasksParams({
    required this.scope,
    this.targetId,
    this.targetName,
  });

  factory ReadTasksParams.fromJson(Map<String, dynamic> json) {
    return ReadTasksParams(
      scope: (json['scope'] ?? 'today').toString().toLowerCase(),
      targetId: json['target_id']?.toString(),
      targetName: json['target_name']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'scope': scope,
        'target_id': targetId,
        'target_name': targetName,
      };
}

/// النموذج الكلي لنية الذكاء الاصطناعي المستخرجة
class AiIntentResult {
  final AiIntentType type;
  final String voiceReply;
  final CreateTaskParams? createTask;
  final ReadTasksParams? readTasks;
  final String? conversationalAnswer;

  const AiIntentResult({
    required this.type,
    required this.voiceReply,
    this.createTask,
    this.readTasks,
    this.conversationalAnswer,
  });

  factory AiIntentResult.fromJson(Map<String, dynamic> json) {
    final intentStr = (json['intent'] ?? 'unknown').toString().toLowerCase();
    final voiceReply = json['voice_reply']?.toString() ?? '';

    AiIntentType type = AiIntentType.unknown;
    CreateTaskParams? createParams;
    ReadTasksParams? readParams;

    if (intentStr == 'create_task' && json['create_task'] is Map<String, dynamic>) {
      type = AiIntentType.createTask;
      createParams = CreateTaskParams.fromJson(json['create_task'] as Map<String, dynamic>);
    } else if (intentStr == 'read_tasks' && json['read_tasks'] is Map<String, dynamic>) {
      type = AiIntentType.readTasks;
      readParams = ReadTasksParams.fromJson(json['read_tasks'] as Map<String, dynamic>);
    } else if (intentStr == 'conversational_help' || intentStr == 'chat') {
      type = AiIntentType.conversationalHelp;
    }

    return AiIntentResult(
      type: type,
      voiceReply: voiceReply,
      createTask: createParams,
      readTasks: readParams,
      conversationalAnswer: json['answer']?.toString() ?? voiceReply,
    );
  }

  static AiIntentResult? tryParseRawJson(String rawText) {
    try {
      String cleaned = rawText.trim();
      // استخراج JSON إن كان محاطاً بعلامات markdown ```json ... ```
      if (cleaned.contains('```json')) {
        final start = cleaned.indexOf('```json') + 7;
        final end = cleaned.lastIndexOf('```');
        if (end > start) {
          cleaned = cleaned.substring(start, end).trim();
        }
      } else if (cleaned.contains('```')) {
        final start = cleaned.indexOf('```') + 3;
        final end = cleaned.lastIndexOf('```');
        if (end > start) {
          cleaned = cleaned.substring(start, end).trim();
        }
      }

      final Map<String, dynamic> map = jsonDecode(cleaned) as Map<String, dynamic>;
      return AiIntentResult.fromJson(map);
    } catch (_) {
      return null;
    }
  }
}

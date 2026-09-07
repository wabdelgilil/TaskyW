# 02. دليل ومخطط تنفيذ طبقة قاعدة البيانات والنماذج (Database Implementation Guide & Specs)

> **موجه إلى مهندس/وكيل قاعدة البيانات (To Database Agent)**:
> هذا المستند يمثل المواصفة البرمجية والتنفيذية الكاملة لطبقة البيانات (Data Layer). يحتوي على كود DDL الكامل، ونماذج Dart، وعقود المستودعات (Repository Contracts)، وإرشادات التهيئة، لتنفيذها مباشرة دون أي لبس.

---

## 1. الحزم المطلوبة في `pubspec.yaml` (Required Dependencies)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # قاعدة البيانات والملفات المحلية
  sqflite: ^2.3.3+1
  sqflite_common_ffi: ^2.3.3   # ضروري جداً لتشغيل SQLite على Windows Desktop
  path_provider: ^2.1.2
  path: ^1.9.0

  # توليد المعرفات الفريدة
  uuid: ^4.3.3

  # للمساواة والـ Value Objects
  equatable: ^2.0.5
```

---

## 2. الهيكل الشجري للملفات المتوقع بناؤها (Target File Structure)

```
lib/
├── core/
│   └── database/
│       ├── app_database.dart           # تهيئة الاتصال والـ Singleton ودعم Windows Desktop
│       ├── database_tables.dart        # نصوص SQL DDL وإنشاء الجداول والفهارس
│       └── database_seeder.dart        # إدخال البيانات الافتراضية عند أول تشغيل
│
└── features/
    ├── areas/
    │   ├── data/
    │   │   ├── models/area_model.dart
    │   │   └── repositories/area_repository_impl.dart
    │   └── domain/
    │       └── repositories/i_area_repository.dart
    │
    ├── projects/
    │   ├── data/
    │   │   ├── models/project_model.dart
    │   │   └── repositories/project_repository_impl.dart
    │   └── domain/
    │       └── repositories/i_project_repository.dart
    │
    └── tasks/
        ├── data/
        │   ├── models/task_model.dart
        │   ├── models/subtask_model.dart
        │   └── repositories/task_repository_impl.dart
        └── domain/
            └── repositories/i_task_repository.dart
```

---

## 3. نصوص SQL الكاملة لإنشاء الجداول والفهارس (SQL DDL Scripts)

```sql
-- 1. جدول المجالات (Areas)
CREATE TABLE IF NOT EXISTS areas (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    icon_emoji TEXT NOT NULL DEFAULT '📁',
    color_hex TEXT NOT NULL DEFAULT '#3B82F6',
    order_index INTEGER NOT NULL DEFAULT 0,
    sync_status TEXT NOT NULL DEFAULT 'pending_insert',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
);

-- 2. جدول المشاريع (Projects)
CREATE TABLE IF NOT EXISTS projects (
    id TEXT PRIMARY KEY,
    area_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    icon_emoji TEXT NOT NULL DEFAULT '📋',
    color_hex TEXT NOT NULL DEFAULT '#10B981',
    status TEXT NOT NULL DEFAULT 'active', -- 'active', 'on_hold', 'completed'
    target_date TEXT,
    order_index INTEGER NOT NULL DEFAULT 0,
    sync_status TEXT NOT NULL DEFAULT 'pending_insert',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT,
    FOREIGN KEY (area_id) REFERENCES areas (id) ON DELETE CASCADE
);

-- 3. جدول المهام (Tasks)
CREATE TABLE IF NOT EXISTS tasks (
    id TEXT PRIMARY KEY,
    area_id TEXT NOT NULL,
    project_id TEXT, -- اختياري: إذا كانت المهمة عامة تتبع المجال مباشرة
    title TEXT NOT NULL,
    description TEXT,
    status TEXT NOT NULL DEFAULT 'todo', -- 'todo', 'in_progress', 'waiting', 'review', 'completed'
    priority TEXT NOT NULL DEFAULT 'medium', -- 'low', 'medium', 'high', 'urgent'
    color_hex TEXT, -- لون مخصص للمهمة يختاره المستخدم
    due_date TEXT,
    reminder_time TEXT,
    share_token TEXT UNIQUE,
    order_index INTEGER NOT NULL DEFAULT 0,
    sync_status TEXT NOT NULL DEFAULT 'pending_insert',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT,
    FOREIGN KEY (area_id) REFERENCES areas (id) ON DELETE CASCADE,
    FOREIGN KEY (project_id) REFERENCES projects (id) ON DELETE CASCADE
);

-- 4. جدول المهام الفرعية (Subtasks)
CREATE TABLE IF NOT EXISTS subtasks (
    id TEXT PRIMARY KEY,
    task_id TEXT NOT NULL,
    title TEXT NOT NULL,
    is_completed INTEGER NOT NULL DEFAULT 0, -- 0 (false) أو 1 (true)
    order_index INTEGER NOT NULL DEFAULT 0,
    sync_status TEXT NOT NULL DEFAULT 'pending_insert',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT,
    FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
);

-- فهارس تحسين سرعة الاستعلام والبحث المقيّد بالسياق (Performance & Search Indexes)
CREATE INDEX IF NOT EXISTS idx_areas_deleted ON areas (deleted_at);
CREATE INDEX IF NOT EXISTS idx_projects_area ON projects (area_id, deleted_at);
CREATE INDEX IF NOT EXISTS idx_tasks_project ON tasks (project_id, deleted_at);
CREATE INDEX IF NOT EXISTS idx_tasks_area ON tasks (area_id, deleted_at);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks (status);
CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks (due_date);
CREATE INDEX IF NOT EXISTS idx_subtasks_task ON subtasks (task_id, deleted_at);
```

---

## 4. تهيئة قاعدة البيانات ودعم الويندوز (Database Initialization)

يجب تفعيل `sqfliteFfiInit()` لدعم بيئة الويندوز:

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  static Database? _database;

  AppDatabase._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'tasky3_database.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // تنفيذ أوامر إنشاء الجداول والفهارس
        await _createTables(db);
        // إدخال المجالات الافتراضية
        await _seedInitialData(db);
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future<void> _createTables(Database db) async {
    // تنفيذ استعلامات DDL المذكورة في القسم 3
  }

  Future<void> _seedInitialData(Database db) async {
    // زراعة 3 مجالات افتراضية لتسهيل بدء الاستخدام
    final now = DateTime.now().toUtc().toIso8601String();
    final batch = db.batch();
    
    batch.insert('areas', {
      'id': 'area-work-main',
      'name': 'العمل الأساسي',
      'icon_emoji': '💼',
      'color_hex': '#3B82F6',
      'order_index': 0,
      'sync_status': 'pending_insert',
      'created_at': now,
      'updated_at': now,
      'deleted_at': null,
    });

    batch.insert('areas', {
      'id': 'area-projects-side',
      'name': 'المشاريع الخاصة',
      'icon_emoji': '🚀',
      'color_hex': '#10B981',
      'order_index': 1,
      'sync_status': 'pending_insert',
      'created_at': now,
      'updated_at': now,
      'deleted_at': null,
    });

    batch.insert('areas', {
      'id': 'area-personal-life',
      'name': 'الحياة الشخصية',
      'icon_emoji': '🏠',
      'color_hex': '#8B5CF6',
      'order_index': 2,
      'sync_status': 'pending_insert',
      'created_at': now,
      'updated_at': now,
      'deleted_at': null,
    });

    await batch.commit(noResult: true);
  }
}
```

---

## 5. مواصفات نماذج البيانات (Data Models / Entities)

### أ. نموذج المجال `AreaModel`
```dart
class AreaModel {
  final String id;
  final String name;
  final String iconEmoji;
  final String colorHex;
  final int orderIndex;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  AreaModel({
    required this.id,
    required this.name,
    this.iconEmoji = '📁',
    this.colorHex = '#3B82F6',
    this.orderIndex = 0,
    this.syncStatus = 'pending_insert',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'icon_emoji': iconEmoji,
    'color_hex': colorHex,
    'order_index': orderIndex,
    'sync_status': syncStatus,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  factory AreaModel.fromMap(Map<String, dynamic> map) => AreaModel(
    id: map['id'] as String,
    name: map['name'] as String,
    iconEmoji: map['icon_emoji'] as String? ?? '📁',
    colorHex: map['color_hex'] as String? ?? '#3B82F6',
    orderIndex: map['order_index'] as int? ?? 0,
    syncStatus: map['sync_status'] as String? ?? 'pending_insert',
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
  );

  AreaModel copyWith({
    String? id,
    String? name,
    String? iconEmoji,
    String? colorHex,
    int? orderIndex,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) => AreaModel(
    id: id ?? this.id,
    name: name ?? this.name,
    iconEmoji: iconEmoji ?? this.iconEmoji,
    colorHex: colorHex ?? this.colorHex,
    orderIndex: orderIndex ?? this.orderIndex,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );
}
```

### ب. نموذج المشروع `ProjectModel`
```dart
class ProjectModel {
  final String id;
  final String areaId;
  final String name;
  final String? description;
  final String iconEmoji;
  final String colorHex;
  final String status; // active, on_hold, completed
  final DateTime? targetDate;
  final int orderIndex;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  ProjectModel({
    required this.id,
    required this.areaId,
    required this.name,
    this.description,
    this.iconEmoji = '📋',
    this.colorHex = '#10B981',
    this.status = 'active',
    this.targetDate,
    this.orderIndex = 0,
    this.syncStatus = 'pending_insert',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'area_id': areaId,
    'name': name,
    'description': description,
    'icon_emoji': iconEmoji,
    'color_hex': colorHex,
    'status': status,
    'target_date': targetDate?.toUtc().toIso8601String(),
    'order_index': orderIndex,
    'sync_status': syncStatus,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  factory ProjectModel.fromMap(Map<String, dynamic> map) => ProjectModel(
    id: map['id'] as String,
    areaId: map['area_id'] as String,
    name: map['name'] as String,
    description: map['description'] as String?,
    iconEmoji: map['icon_emoji'] as String? ?? '📋',
    colorHex: map['color_hex'] as String? ?? '#10B981',
    status: map['status'] as String? ?? 'active',
    targetDate: map['target_date'] != null ? DateTime.parse(map['target_date'] as String) : null,
    orderIndex: map['order_index'] as int? ?? 0,
    syncStatus: map['sync_status'] as String? ?? 'pending_insert',
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
  );

  ProjectModel copyWith({
    String? id,
    String? areaId,
    String? name,
    String? description,
    String? iconEmoji,
    String? colorHex,
    String? status,
    DateTime? targetDate,
    int? orderIndex,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) => ProjectModel(
    id: id ?? this.id,
    areaId: areaId ?? this.areaId,
    name: name ?? this.name,
    description: description ?? this.description,
    iconEmoji: iconEmoji ?? this.iconEmoji,
    colorHex: colorHex ?? this.colorHex,
    status: status ?? this.status,
    targetDate: targetDate ?? this.targetDate,
    orderIndex: orderIndex ?? this.orderIndex,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );
}
```

### ج. نموذج المهمة `TaskModel`
```dart
class TaskModel {
  final String id;
  final String areaId;
  final String? projectId;
  final String title;
  final String? description;
  final String status; // todo, in_progress, waiting, review, completed
  final String priority; // low, medium, high, urgent
  final String? colorHex;
  final DateTime? dueDate;
  final DateTime? reminderTime;
  final String? shareToken;
  final int orderIndex;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  TaskModel({
    required this.id,
    required this.areaId,
    this.projectId,
    required this.title,
    this.description,
    this.status = 'todo',
    this.priority = 'medium',
    this.colorHex,
    this.dueDate,
    this.reminderTime,
    this.shareToken,
    this.orderIndex = 0,
    this.syncStatus = 'pending_insert',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'area_id': areaId,
    'project_id': projectId,
    'title': title,
    'description': description,
    'status': status,
    'priority': priority,
    'color_hex': colorHex,
    'due_date': dueDate?.toUtc().toIso8601String(),
    'reminder_time': reminderTime?.toUtc().toIso8601String(),
    'share_token': shareToken,
    'order_index': orderIndex,
    'sync_status': syncStatus,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  factory TaskModel.fromMap(Map<String, dynamic> map) => TaskModel(
    id: map['id'] as String,
    areaId: map['area_id'] as String,
    projectId: map['project_id'] as String?,
    title: map['title'] as String,
    description: map['description'] as String?,
    status: map['status'] as String? ?? 'todo',
    priority: map['priority'] as String? ?? 'medium',
    colorHex: map['color_hex'] as String?,
    dueDate: map['due_date'] != null ? DateTime.parse(map['due_date'] as String) : null,
    reminderTime: map['reminder_time'] != null ? DateTime.parse(map['reminder_time'] as String) : null,
    shareToken: map['share_token'] as String?,
    orderIndex: map['order_index'] as int? ?? 0,
    syncStatus: map['sync_status'] as String? ?? 'pending_insert',
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
  );

  TaskModel copyWith({
    String? id,
    String? areaId,
    String? projectId,
    String? title,
    String? description,
    String? status,
    String? priority,
    String? colorHex,
    DateTime? dueDate,
    DateTime? reminderTime,
    String? shareToken,
    int? orderIndex,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) => TaskModel(
    id: id ?? this.id,
    areaId: areaId ?? this.areaId,
    projectId: projectId ?? this.projectId,
    title: title ?? this.title,
    description: description ?? this.description,
    status: status ?? this.status,
    priority: priority ?? this.priority,
    colorHex: colorHex ?? this.colorHex,
    dueDate: dueDate ?? this.dueDate,
    reminderTime: reminderTime ?? this.reminderTime,
    shareToken: shareToken ?? this.shareToken,
    orderIndex: orderIndex ?? this.orderIndex,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );
}
```

### د. نموذج المهمة الفرعية `SubtaskModel`
```dart
class SubtaskModel {
  final String id;
  final String taskId;
  final String title;
  final bool isCompleted;
  final int orderIndex;
  final String syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  SubtaskModel({
    required this.id,
    required this.taskId,
    required this.title,
    this.isCompleted = false,
    this.orderIndex = 0,
    this.syncStatus = 'pending_insert',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'task_id': taskId,
    'title': title,
    'is_completed': isCompleted ? 1 : 0,
    'order_index': orderIndex,
    'sync_status': syncStatus,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    'deleted_at': deletedAt?.toUtc().toIso8601String(),
  };

  factory SubtaskModel.fromMap(Map<String, dynamic> map) => SubtaskModel(
    id: map['id'] as String,
    taskId: map['task_id'] as String,
    title: map['title'] as String,
    isCompleted: (map['is_completed'] as int? ?? 0) == 1,
    orderIndex: map['order_index'] as int? ?? 0,
    syncStatus: map['sync_status'] as String? ?? 'pending_insert',
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    deletedAt: map['deleted_at'] != null ? DateTime.parse(map['deleted_at'] as String) : null,
  );

  SubtaskModel copyWith({
    String? id,
    String? taskId,
    String? title,
    bool? isCompleted,
    int? orderIndex,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) => SubtaskModel(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    title: title ?? this.title,
    isCompleted: isCompleted ?? this.isCompleted,
    orderIndex: orderIndex ?? this.orderIndex,
    syncStatus: syncStatus ?? this.syncStatus,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt ?? this.deletedAt,
  );
}
```

---

## 6. عقود المستودعات (Repository Contracts / Interfaces)

### أ. `IAreaRepository`
```dart
abstract class IAreaRepository {
  Future<List<AreaModel>> getAllAreas();
  Future<AreaModel?> getAreaById(String id);
  Future<void> insertArea(AreaModel area);
  Future<void> updateArea(AreaModel area);
  Future<void> softDeleteArea(String id);
}
```

### ب. `IProjectRepository`
```dart
abstract class IProjectRepository {
  Future<List<ProjectModel>> getAllProjects();
  Future<List<ProjectModel>> getProjectsByArea(String areaId);
  Future<ProjectModel?> getProjectById(String id);
  Future<void> insertProject(ProjectModel project);
  Future<void> updateProject(ProjectModel project);
  Future<void> softDeleteProject(String id);
}
```

### ج. `ITaskRepository`
```dart
abstract class ITaskRepository {
  Future<List<TaskModel>> getTasks({
    String? areaId,
    String? projectId,
    String? status,
    String? priority,
    DateTime? dueBefore,
  });
  Future<TaskModel?> getTaskById(String id);
  Future<void> insertTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> updateTaskStatus(String id, String status);
  Future<void> softDeleteTask(String id);
  
  // استعلام البحث المقيّد بالسياق
  Future<List<TaskModel>> searchTasks(String query, {String? areaId, String? projectId});
}
```

### د. `ISubtaskRepository`
```dart
abstract class ISubtaskRepository {
  Future<List<SubtaskModel>> getSubtasksForTask(String taskId);
  Future<void> insertSubtask(SubtaskModel subtask);
  Future<void> updateSubtask(SubtaskModel subtask);
  Future<void> toggleSubtaskCompletion(String id, bool isCompleted);
  Future<void> softDeleteSubtask(String id);
}
```

---

## 7. قواعد الاستعلام الهامة لمهندس قاعدة البيانات (Critical Implementation Rules)
1. **استبعاد المحذوف هادئاً دائماً**: كل استعلام `SELECT` يجب أن يحتوي افتراضياً على:
   `WHERE deleted_at IS NULL`
2. **تحديث الطابع الزمني**: كل عملية `UPDATE` لأي حقل يجب أن تحدث حقل `updated_at` تلقائياً إلى `DateTime.now().toUtc().toIso8601String()`.
3. **ضبط حالة المزامنة**:
   - السجلات الجديدة: `sync_status = 'pending_insert'`
   - السجلات المعدلة: `sync_status = 'pending_update'`
   - الحذف الهادئ: يُعيّن `deleted_at = now` وتُصبح `sync_status = 'pending_delete'`.

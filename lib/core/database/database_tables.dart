class DatabaseTables {
  static const String areaTable = 'areas';
  static const String projectTable = 'projects';
  static const String taskTable = 'tasks';
  static const String subtaskTable = 'subtasks';

  static const String createAreaTable = '''
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
  ''';

  static const String createProjectTable = '''
    CREATE TABLE IF NOT EXISTS projects (
      id TEXT PRIMARY KEY,
      area_id TEXT NOT NULL,
      name TEXT NOT NULL,
      description TEXT,
      icon_emoji TEXT NOT NULL DEFAULT '📋',
      color_hex TEXT NOT NULL DEFAULT '#10B981',
      status TEXT NOT NULL DEFAULT 'active',
      target_date TEXT,
      order_index INTEGER NOT NULL DEFAULT 0,
      sync_status TEXT NOT NULL DEFAULT 'pending_insert',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      deleted_at TEXT,
      FOREIGN KEY (area_id) REFERENCES areas (id) ON DELETE CASCADE
    );
  ''';

  static const String createTaskTable = '''
    CREATE TABLE IF NOT EXISTS tasks (
      id TEXT PRIMARY KEY,
      area_id TEXT NOT NULL,
      project_id TEXT,
      title TEXT NOT NULL,
      description TEXT,
      status TEXT NOT NULL DEFAULT 'todo',
      priority TEXT NOT NULL DEFAULT 'medium',
      color_hex TEXT,
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
  ''';

  static const String createSubtaskTable = '''
    CREATE TABLE IF NOT EXISTS subtasks (
      id TEXT PRIMARY KEY,
      task_id TEXT NOT NULL,
      title TEXT NOT NULL,
      is_completed INTEGER NOT NULL DEFAULT 0,
      order_index INTEGER NOT NULL DEFAULT 0,
      sync_status TEXT NOT NULL DEFAULT 'pending_insert',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      deleted_at TEXT,
      FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
    );
  ''';

  static const String createAreaIndex = '''
    CREATE INDEX IF NOT EXISTS idx_areas_deleted ON areas (deleted_at);
  ''';

  static const String createProjectIndex = '''
    CREATE INDEX IF NOT EXISTS idx_projects_area ON projects (area_id, deleted_at);
  ''';

  static const String createTaskProjectIndex = '''
    CREATE INDEX IF NOT EXISTS idx_tasks_project ON tasks (project_id, deleted_at);
  ''';

  static const String createTaskAreaIndex = '''
    CREATE INDEX IF NOT EXISTS idx_tasks_area ON tasks (area_id, deleted_at);
  ''';

  static const String createTaskStatusIndex = '''
    CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks (status);
  ''';

  static const String createTaskDueDateIndex = '''
    CREATE INDEX IF NOT EXISTS idx_tasks_due_date ON tasks (due_date);
  ''';

  static const String createSubtaskIndex = '''
    CREATE INDEX IF NOT EXISTS idx_subtasks_task ON subtasks (task_id, deleted_at);
  ''';

  static List<String> get allCreateStatements => [
    createAreaTable,
    createProjectTable,
    createTaskTable,
    createSubtaskTable,
    createAreaIndex,
    createProjectIndex,
    createTaskProjectIndex,
    createTaskAreaIndex,
    createTaskStatusIndex,
    createTaskDueDateIndex,
    createSubtaskIndex,
  ];
}

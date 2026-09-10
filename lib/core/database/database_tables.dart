class DatabaseTables {
  static const String areaTable = 'areas';
  static const String projectTable = 'projects';
  static const String taskTable = 'tasks';
  static const String subtaskTable = 'subtasks';
  static const String tagTable = 'tags';
  static const String taskTagTable = 'task_tags';
  static const String entityShareTable = 'entity_shares';
  static const String attachmentTable = 'attachments';

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
      notifications_enabled INTEGER NOT NULL DEFAULT 1,
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
      is_recurring INTEGER NOT NULL DEFAULT 0,
      recurrence_pattern TEXT,
      recurrence_interval INTEGER NOT NULL DEFAULT 1,
      recurrence_end_date TEXT,
      assigned_to TEXT,
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

  static const String createTagTable = '''
    CREATE TABLE IF NOT EXISTS tags (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      color_hex TEXT NOT NULL DEFAULT '#64748B',
      order_index INTEGER NOT NULL DEFAULT 0,
      sync_status TEXT NOT NULL DEFAULT 'pending_insert',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      deleted_at TEXT
    );
  ''';

  static const String createTaskTagTable = '''
    CREATE TABLE IF NOT EXISTS task_tags (
      id TEXT,
      task_id TEXT NOT NULL,
      tag_id TEXT NOT NULL,
      created_at TEXT NOT NULL,
      sync_status TEXT NOT NULL DEFAULT 'pending_insert',
      updated_at TEXT,
      deleted_at TEXT,
      PRIMARY KEY (task_id, tag_id),
      FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE,
      FOREIGN KEY (tag_id) REFERENCES tags (id) ON DELETE CASCADE
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

  static const String createTagDeletedIndex = '''
    CREATE INDEX IF NOT EXISTS idx_tags_deleted ON tags (deleted_at);
  ''';

  static const String createTaskTagsTaskIndex = '''
    CREATE INDEX IF NOT EXISTS idx_task_tags_task ON task_tags (task_id);
  ''';

  static const String createTaskTagsTagIndex = '''
    CREATE INDEX IF NOT EXISTS idx_task_tags_tag ON task_tags (tag_id);
  ''';

  static const String createEntityShareTable = '''
    CREATE TABLE IF NOT EXISTS entity_shares (
      id TEXT PRIMARY KEY,
      entity_type TEXT NOT NULL,
      entity_id TEXT NOT NULL,
      owner_id TEXT,
      collaborator_id TEXT,
      collaborator_email TEXT,
      permission_level TEXT NOT NULL DEFAULT 'viewer',
      status TEXT NOT NULL DEFAULT 'pending',
      created_at TEXT NOT NULL,
      updated_at TEXT,
      deleted_at TEXT,
      sync_status TEXT NOT NULL DEFAULT 'synced'
    );
  ''';

  static const String createEntityShareIndex = '''
    CREATE INDEX IF NOT EXISTS idx_entity_shares_entity ON entity_shares (entity_type, entity_id);
  ''';

  static const String createAttachmentTable = '''
    CREATE TABLE IF NOT EXISTS attachments (
      id TEXT PRIMARY KEY,
      task_id TEXT NOT NULL,
      file_name TEXT NOT NULL,
      file_path TEXT,
      file_size INTEGER NOT NULL DEFAULT 0,
      mime_type TEXT,
      file_url TEXT,
      sync_status TEXT NOT NULL DEFAULT 'pending_insert',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      deleted_at TEXT,
      FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
    );
  ''';

  static const String createAttachmentTaskIndex = '''
    CREATE INDEX IF NOT EXISTS idx_attachments_task ON attachments (task_id, deleted_at);
  ''';

  static const String noteTable = 'notes';

  static const String createNoteTable = '''
    CREATE TABLE IF NOT EXISTS notes (
      id TEXT PRIMARY KEY,
      title TEXT NOT NULL,
      content TEXT,
      color_hex TEXT,
      is_pinned INTEGER NOT NULL DEFAULT 0,
      is_archived INTEGER NOT NULL DEFAULT 0,
      area_id TEXT,
      sync_status TEXT NOT NULL DEFAULT 'pending_insert',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      deleted_at TEXT
    );
  ''';

  static const String createNotePinnedIndex = '''
    CREATE INDEX IF NOT EXISTS idx_notes_pinned ON notes (is_pinned, updated_at);
  ''';

  static const String createNoteAreaIndex = '''
    CREATE INDEX IF NOT EXISTS idx_notes_area ON notes (area_id);
  ''';

  static const String createNoteDeletedIndex = '''
    CREATE INDEX IF NOT EXISTS idx_notes_deleted ON notes (deleted_at);
  ''';

  static const String financialRecordTable = 'financial_records';

  static const String createFinancialRecordTable = '''
    CREATE TABLE IF NOT EXISTS financial_records (
      id TEXT PRIMARY KEY,
      type TEXT NOT NULL,
      amount REAL NOT NULL,
      currency TEXT NOT NULL DEFAULT 'EGP',
      title TEXT NOT NULL,
      category TEXT,
      status TEXT NOT NULL DEFAULT 'completed',
      from_account TEXT,
      to_account TEXT,
      settlement_type TEXT NOT NULL DEFAULT 'none',
      settlement_status TEXT NOT NULL DEFAULT 'none',
      receipt_path TEXT,
      area_id TEXT,
      transaction_date TEXT NOT NULL,
      notes TEXT,
      sync_status TEXT NOT NULL DEFAULT 'pending_insert',
      created_at TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      deleted_at TEXT
    );
  ''';

  static const String createFinancialStatusIndex = '''
    CREATE INDEX IF NOT EXISTS idx_financial_status ON financial_records (status);
  ''';

  static const String createFinancialSettlementIndex = '''
    CREATE INDEX IF NOT EXISTS idx_financial_settlement ON financial_records (settlement_type, settlement_status);
  ''';

  static const String createFinancialDateIndex = '''
    CREATE INDEX IF NOT EXISTS idx_financial_date ON financial_records (transaction_date);
  ''';

  static const String createFinancialDeletedIndex = '''
    CREATE INDEX IF NOT EXISTS idx_financial_deleted ON financial_records (deleted_at);
  ''';

  static List<String> get allCreateStatements => [
    createAreaTable,
    createProjectTable,
    createTaskTable,
    createSubtaskTable,
    createTagTable,
    createTaskTagTable,
    createEntityShareTable,
    createAreaIndex,
    createProjectIndex,
    createTaskProjectIndex,
    createTaskAreaIndex,
    createTaskStatusIndex,
    createTaskDueDateIndex,
    createSubtaskIndex,
    createTagDeletedIndex,
    createTaskTagsTaskIndex,
    createTaskTagsTagIndex,
    createEntityShareIndex,
    createAttachmentTable,
    createAttachmentTaskIndex,
    createNoteTable,
    createNotePinnedIndex,
    createNoteAreaIndex,
    createNoteDeletedIndex,
    createFinancialRecordTable,
    createFinancialStatusIndex,
    createFinancialSettlementIndex,
    createFinancialDateIndex,
    createFinancialDeletedIndex,
  ];
}

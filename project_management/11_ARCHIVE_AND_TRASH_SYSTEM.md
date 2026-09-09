# 11. مواصفات نظام الأرشفة الشامل وسلة المهملات (Global Archive & Trash System)

> **موجه إلى مهندس المنطق والخدمات الخلفية (To Backend & Logic Agent)**:
> أنت مسؤول عن تمديد طبقة البيانات (Data Layer)، واستعلامات المستودعات (Repositories)، وإدارة الحالة (Controllers) لمنظومة الأرشفة الشاملة وسلة المهملات. التزم بمبدأ عدم التداخل (Zero Collision) وتجنب إنشاء أو تعديل أي شاشات أو ثيمات للـ UI.

---

## 1. الفلسفة العامة وهيكل الحالات الثلاث

تتبع TaskyW معايير إنتاجية صارمة لتنظيم دورة حياة البيانات:

| الحالة | المفهوم والدلالة | التأثير التقني في قاعدة البيانات | إمكانية الاسترجاع |
| :--- | :--- | :--- | :--- |
| **مكتملة (`completed`)** | مهام منجزة بنجاح؛ تظل ضمن سياق المشروع/المجال الحالي ولكن مجمعة ومطوية لراحة العين. | `status = 'completed'` و `deleted_at IS NULL`. | إلغاء التحديد (`todo`). |
| **مؤرشفة (`archived`)** | مشاريع أو مهام أو ملاحظات منتهية أردنا إخفاءها من مساحات العمل اليومية النشطة لمنع التشتت مع الحفاظ على مرجعيتها كاملة. | `status = 'archived'` أو `is_archived = 1` و `deleted_at IS NULL`. | إلغاء الأرشفة (`unarchive`) وإعادتها فوراً لمكانها النشط. |
| **سلة المهملات (`trash / soft deleted`)** | عناصر محذوفة (مهام، مشاريع، ملاحظات) تنتظر الاستعادة أو الحذف النهائي. | `deleted_at IS NOT NULL` و `sync_status = 'pending_delete'`. | استعادة (`restore`) أو إفراغ نهائي (`permanentlyDelete` / `emptyTrash`). |

---

## 2. متطلبات الباك إند والمنطق البرمجي بدقة (Backend Deliverables)

### أ. طبقة المهام (`lib/features/tasks/`)
1. **نموذج المهمة (`TaskModel`)**:
   - اعتماد القيمة `status = 'archived'`.
   - إضافة Helper Getters:
     - `bool get isArchived => status == 'archived';`
     - `bool get isDeleted => deletedAt != null;`

2. **مستودع المهام (`ITaskRepository` و `TaskRepositoryImpl`)**:
   - `getTasks(...)`:
     - استبعاد المهام المؤرشفة تلقائياً من القوائم العادية افتراضياً (`status != 'archived' AND deleted_at IS NULL`) ما لم يُطلب صراحة `status = 'archived'`.
   - `Future<List<TaskModel>> getArchivedTasks({String? areaId, String? projectId})`:
     - جلب جميع المهام التي تحمل `status = 'archived' AND deleted_at IS NULL`.
   - `Future<List<TaskModel>> getTrashTasks()`:
     - جلب جميع المهام المحذوفة ناعماً `deleted_at IS NOT NULL` مرتبة بالأحدث.
   - `Future<void> archiveTask(String id)`:
     - تعيين `status = 'archived'` وتحديث `updated_at` وضبط `sync_status = 'pending_update'`.
   - `Future<void> unarchiveTask(String id, {String targetStatus = 'todo'})`:
     - إعادة المهمة من الأرشيف وتعيين `status = targetStatus` وتحديث `sync_status = 'pending_update'`.
   - `Future<void> restoreTaskFromTrash(String id)`:
     - إلغاء الحذف الناعم: تصفير `deleted_at = NULL` وضبط `sync_status = 'pending_update'`.
   - `Future<void> permanentlyDeleteTask(String id)`:
     - حذف نهائي فعلي من SQLite: `DELETE FROM tasks WHERE id = ?`.
   - `Future<void> emptyTrash()`:
     - تفريغ سلة مهام المهملات بالكامل بحذف كل السجلات التي تحمل `deleted_at IS NOT NULL`.

3. **متحكم المهام (`TasksController`)**:
   - Getters:
     - `List<TaskModel> get archivedTasks`
     - `List<TaskModel> get trashTasks`
     - `int get archivedCount`
     - `int get trashCount`
   - Actions:
     - `Future<void> loadArchivedTasks()`
     - `Future<void> loadTrashTasks()`
     - `Future<bool> archiveTask(String id)`
     - `Future<bool> unarchiveTask(String id)`
     - `Future<bool> restoreTask(String id)`
     - `Future<bool> permanentlyDeleteTask(String id)`
     - `Future<bool> emptyTrash()`

---

### ب. طبقة المشاريع (`lib/features/projects/`)
1. **نموذج المشروع (`ProjectModel`)**:
   - دعم حالة الأرشفة `status = 'archived'`.
   - Helper Getters:
     - `bool get isArchived => status == 'archived';`
     - `bool get isDeleted => deletedAt != null;`

2. **مستودع المشاريع (`IProjectRepository` و `ProjectRepositoryImpl`)**:
   - تعديل `getAllProjects()` و `getProjectsByArea(...)` لاستبعاد المشاريع المؤرشفة (`status != 'archived' AND deleted_at IS NULL`) افتراضياً.
   - إضافة دالة `Future<List<ProjectModel>> getArchivedProjects({String? areaId})`.
   - إضافة دالة `Future<List<ProjectModel>> getTrashProjects()`.
   - إضافة دوال: `archiveProject(id)`, `unarchiveProject(id)`, `restoreProject(id)`, `permanentlyDeleteProject(id)`.

3. **متحكم المشاريع (`ProjectsController`)**:
   - Getters:
     - `List<ProjectModel> get archivedProjects`
     - `List<ProjectModel> get trashProjects`
   - Actions لمزامنة الأرشفة والاستعادة والحذف النهائي للمشاريع.

---

### ج. التوافق مع الملاحظات والمستودع المعرفي (`Notes`)
- موديول الملاحظات (`NoteRepositoryImpl` و `NotesController`) يدعم بالفعل `isArchived` و `deletedAt`.
- توفير ربط موحد للأرشيف وسلة المهملات لاسترجاع الملاحظات المؤرشفة والمحذوفة جنباً إلى جنب مع المهام والمشاريع.

---

## 3. معايير الاختبار والجودة
1. كتابة ملف اختبار شامل: `test/archive_and_trash_test.dart` يختبر:
   - دورة حياة المهمة والمشروع: نشط ← مؤرشف ← مستعاد من الأرشيف.
   - دورة سلة المهملات: حذف ناعم ← ظهور في سلة المهملات ← استرجاع بنجاح مع إلغاء الحذف الناعم.
   - الحذف النهائي وتفريغ السلة (`emptyTrash`).
   - استبعاد العناصر المؤرشفة والمحذوفة من الفلاتر اليومية والعادية (اليوم، القادمة، العاجلة، المعلقة).
2. فحص الأكواد: `flutter analyze` بدون أي أخطاء أو تحذيرات (`No issues found!`).
3. تشغيل `flutter test` والتأكد من نجاح 100% من الاختبارات.

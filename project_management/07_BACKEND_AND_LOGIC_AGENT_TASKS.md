# 07. مهام وكيل المنطق والخدمات الخلفية (Backend & Logic Agent Tasks)

> **موجه إلى مهندس المنطق والخدمات (To Logic/State Agent)**:
> أنت مسؤول عن محركات المنطق غير المرئية (Headless Logic) وإدارة الحالة وخدمات النظام المساعدة. لا تقم بإنشاء أو تعديل أي ملفات تصميم مرئية (UI Widgets/Screens/Themes).

---

## 1. مبدأ عدم التداخل (Zero Collision Principle)

| المجال | نطاق عملك (وكيل المنطق) | نطاق عمل وكيل الواجهات (UI Agent) |
| :--- | :--- | :--- |
| **المجلدات** | `lib/core/services/`<br>`lib/core/utils/`<br>`lib/features/**/presentation/controllers/` | `lib/core/theme/`<br>`lib/features/**/presentation/screens/`<br>`lib/features/**/presentation/widgets/` |
| **المسؤولية** | معالجة البيانات، إدارة الحالة، التنبيهات، وحساب الفلاتر | الألوان، الحواف، الخطوط، الكروت، الكانبان، الشجرة الجانبية، والشاشات |

---

## 2. قائمة المهام الموكلة إليك بدقة (Deliverables)

### أ. دوال المساعدة والتنسيق (`lib/core/utils/`)
1. **`date_time_utils.dart`**:
   - `bool isToday(DateTime? date)`: فحص ما إذا كان التاريخ يوافق اليوم الحالي.
   - `bool isUpcoming(DateTime? date)`: فحص ما إذا كان التاريخ بعد اليوم.
   - `bool isOverdue(DateTime? date)`: فحص ما إذا كان الموعد قد انقضى ولم تكتمل المهمة.
   - `String formatFriendlyDate(DateTime? date)`: تنسيق التاريخ بصيغة مريحة (مثل: "اليوم 10:00 ص"، "غداً"، "الأحد 12 مارس").
2. **`validators.dart`**:
   - التحقق من عدم فراغ النصوص، صحة كود اللون HEX، وصحة الروابط.

---

### ب. خدمة التنبيهات المحلية (`lib/core/services/notification_service.dart`)
1. إضافة حزمة `flutter_local_notifications: ^17.2.2` أو ما يماثلها في `pubspec.yaml`.
2. إنشاء فئة `NotificationService` (Singleton):
   - دالة `init()`: تهيئة الإشعارات لنظامي Windows و Android/iOS.
   - دالة `requestPermissions()`: طلب صلاحيات التنبيه.
   - دالة `scheduleTaskReminder({required String taskId, required String title, required DateTime scheduledDate})`.
   - دالة `cancelTaskReminder(String taskId)`.

---

### ج. فئات إدارة الحالة (Controllers / Notifiers)
باستخدام `ChangeNotifier` (أو Provider) القياسي في Flutter لتسهيل الربط المباشر مع واجهات المستخدم:

1. **`lib/features/areas/presentation/controllers/areas_controller.dart`**:
   - يحتفظ بقائمة `List<AreaModel> areas`.
   - يحتفظ بالمعرف المختار حالياً `String? selectedAreaId`.
   - دوال: `loadAreas()`, `selectArea(String? id)`, `createArea(...)`, `updateArea(...)`, `deleteArea(String id)`.

2. **`lib/features/projects/presentation/controllers/projects_controller.dart`**:
   - يحتفظ بقائمة `List<ProjectModel> projects`.
   - يحتفظ بالمشروع المختار حالياً `String? selectedProjectId`.
   - دوال: `loadProjects({String? areaId})`, `selectProject(String? id)`, `createProject(...)`, `updateProject(...)`, `deleteProject(String id)`.
   - دالة استخراج مشاريع مجال محدد `List<ProjectModel> getProjectsForArea(String areaId)`.

3. **`lib/features/tasks/presentation/controllers/tasks_controller.dart`**:
   - يحتفظ بقائمة المهام المحملة `List<TaskModel> tasks`.
   - فلاتر حسابية فورية (Getters):
     - `List<TaskModel> get todayTasks` (مهام اليوم غير المكتملة).
     - `List<TaskModel> get upcomingTasks` (مهام قادمة).
     - `List<TaskModel> get waitingTasks` (المهام في حالة waiting).
     - `List<TaskModel> get urgentTasks` (المهام بأولوية urgent).
     - `List<TaskModel> get completedTasks`.
   - دوال العمليات:
     - `loadTasks({String? areaId, String? projectId, String? status})`.
     - `createTask(TaskModel task)`.
     - `updateTask(TaskModel task)`.
     - `updateStatus(String taskId, String newStatus)`.
     - `deleteTask(String taskId)`.

4. **`lib/features/tasks/presentation/controllers/subtasks_controller.dart`**:
   - إدارة المهام الفرعية لمهمة محددة:
     - `loadSubtasks(String taskId)`.
     - `toggleCompletion(String subtaskId, bool isCompleted)`.
     - `addSubtask(String taskId, String title)`.
     - `deleteSubtask(String subtaskId)`.
     - Getter لحساب نسبة التقدم: `double getProgress(String taskId)`.

5. **`lib/features/tasks/presentation/controllers/search_controller.dart`**:
   - إدارة نص البحث الحالي `String query`.
   - نطاق البحث `SearchScope { global, area, project }`.
   - المعرف النشط للنطاق `String? activeScopeId`.
   - تنفيذ دالة البحث اللحظي مع Debounce وإرجاع قائمة `List<TaskModel> searchResults`.

---

## 3. معايير الجودة والتسليم
- كتابة اختبارات وحدة (Unit Tests) للمتحكمات (Controllers) ودوائر التواريخ.
- التأكد من خلو الكود تماماً من أي أخطاء عند تشغيل `flutter analyze`.

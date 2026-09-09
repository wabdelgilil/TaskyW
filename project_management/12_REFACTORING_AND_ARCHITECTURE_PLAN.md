# 12. خطة إعادة الهيكلة الشاملة ومواءمة المعمارية (Refactoring & Architecture Alignment Plan)

## نظرة عامة (Overview)
تهدف هذه الخطة إلى معالجة الديون التقنية المتراكمة والازدواجيات والترهل في الملفات الضخمة الناتجة عن سرعة بناء الميزات السابقة في مشروع **TaskyW**، مع الالتزام التام بعدم كسر أو تغيير أي ميزة تشغيلية، والحفاظ المستمر على نسبة نجاح 100% لجميع الاختبارات (219/219 اختباراً) وفحص `flutter analyze` خالٍ تماماً من الأخطاء والتحذيرات.

---

## هيكل القيادة وتوزيع الأدوار (Leadership & Roles Distribution)

```mermaid
graph TD
    User([المستخدم / المطور]) --> Master[الوكيل الرئيسي - Master Agent]
    Master --> Architecture[القرارات المعمارية وضبط الجودة]
    Master --> StateMgmt[إدارة الحالة والمتحكمات الحساسة]
    Master --> Verification[الفحص الشامل والاختبارات 219/219]
    Master --> Subagent[الوكيل الفرعي - Subagent]
    Subagent --> WidgetDecomp[تفكيك الواجهات واستخراج النوافذ]
    Subagent --> ComponentExtraction[فصل الأقسام الفرعية المستقلة]
    Subagent --> LocalTests[كتابة وتحديث اختبارات المكونات]
```

### 1. الوكيل الرئيسي (Master Agent - Lead Architect)
* **المسؤولية العليا**:
  * الإشراف الكامل على البنية المعمارية وتنسيق العمل وتسلسل المهام.
  * إدارة التغييرات الحساسة في طبقة البيانات وإدارة الحالة المركزية (`Controllers` و `Repositories`).
  * اتخاذ القرارات المعمارية الفاصلة وحل أي تعارضات (Conflicts).
  * إجراء الفحص النهائي للجودة (`flutter analyze` و `flutter test`).
  * التحديث الرسمي لوثائق المشروع (`MASTER_PLAN.md` و `COMPLETED_WORK.md`).
  * تفويض المهام المحددة بدقة إلى الوكيل الفرعي ومراجعة مخرجاته قبل اعتمادها.

### 2. الوكيل الفرعي (Subagent - Component Implementation Specialist)
* **المسؤولية التنفيذية**:
  * تنفيذ حزم مهام معزولة ومحددة النطاق يُكلف بها من قِبل الوكيل الرئيسي.
  * تفكيك الواجهات الكبيرة واستخراج المكونات الفرعية الصرفة (Pure UI Components & Dialogs).
  * كتابة وتحديث اختبارات الواجهات للمكونات المستخرجة حديثاً.
  * **الضوابط الصارمة**:
    * لا يعدل على جداول أو ترقيات قاعدة البيانات أو سكيما المزامنة السحابية.
    * لا يمس الملفات المشتركة إلا بتنسيق مسبق منعاً لتضارب الأكواد (Merge Conflicts).
    * يلتزم بإنهاء كل مهمة فرعية بفحص نظيف (`flutter analyze`) قبل تسليم المهمة للماستر.

---

## محاور وخريطة مراحل إعادة الهيكلة (Detailed Refactoring Phases)

```mermaid
graph LR
    P1[المرحلة 1: تنظيف الازدواجيات والكود الميت] --> P2[المرحلة 2: تفكيك الواجهات الضخمة]
    P2 --> P3[المرحلة 3: ربط المتحكمات وحل الـ Callback Drilling]
    P3 --> P4[المرحلة 4: مواءمة المجلدات والتغليف النهائي]
```

---

### 🔹 المرحلة 1: تنظيف الازدواجيات والكود الميت (Deduplication & Dead Code Removal)
* **الهدف**: القضاء على الازدواجية في نماذج المشاركة والخدمات القديمة غير المستخدمة.
* **المهام التفصيلية**:
  1. **توحيد نموذج المشاركة `EntityShareModel`**:
     * الاعتماد الحصري على نموذج `EntityShareModel` الموجود في `lib/features/collaboration/data/models/entity_share_model.dart` ودعمه لكافة الحالات (المشاركة العامة برابط + مشاركة الأعضاء بحساب).
     * حذف الملف القديم المكرر `lib/core/models/entity_share_model.dart`.
  2. **تنظيف منظومة المشاركة القديمة**:
     * توجيه `ShareReadService` للاعتماد على النموذج الموحد.
     * إزالة الكود الميت `SharingController` غير المستخدم في الواجهات، وتحديث الاختبارات المرتبطة به.
* **توزيع الأدوار**:
  * **الوكيل الفرعي**: فحص وتحديث واردات (Imports) كلاس `EntityShareModel` وتعديل اختبار `share_read_service_test.dart`.
  * **الوكيل الرئيسي**: مراجعة التوحيد المعماري، حذف الملفات الزائدة، وتشغيل فحص السلامة الشامل.

---

### 🔹 المرحلة 2: تفكيك الواجهات العملاقة (Decomposing God Widgets)
* **الهدف**: تقسيم الملفات التي تجاوزت 1,000 سطر إلى مكوّنات نظيفة يسهل صيانتها واختبارها.

#### 2.1 تفكيك `MainLayoutScreen` (1,526 سطراً):
1. **استخراج نوافذ الحوار إلى مجلد مستقل (`lib/features/home/presentation/widgets/dialogs/`)**:
   * `AddTaskDialog`: نافذة إضافة المهمة السريعة بتفاصيلها.
   * `AddProjectDialog`: نافذة إضافة المشروع مع الإيموجي والألوان.
   * `AddAreaDialog`: نافذة إضافة المجال.
   * `ExportTasksDialog`: نافذة تصدير ومعاينة CSV/Excel.
2. **استخراج شريط الرأس (`MainHeader`)**:
   * نقل ترويسة الشاشات العريضة والموبايل وحقل البحث التكيفي إلى ويدجت مستقل `MainHeaderWidget`.
3. **استخراج موزع مساحة العمل (`MainWorkspaceSwitcher`)**:
   * فصل تبديل المحتوى (قائمة، كانبان، جدول، تفاصيل مشروع، تفاصيل مجال، ملاحظات، مالية) إلى ويدجت منظم.

#### 2.2 تفكيك `TaskDetailDrawer` (1,005 أسطر):
* تقسيم الدرج إلى مكونات فرعية في (`lib/features/tasks/presentation/widgets/task_drawer/`):
  * `TaskSubtasksSection`: إدارة وتشيك ليست المهام الفرعية.
  * `TaskRecurrenceSection`: إعدادات ونمط التكرار الدوري.
  * `TaskDatesRemindersSection`: اختيار المواعيد والتوقيت والتنبيهات المحلية.
  * `TaskTagsSection`: اختيار وإنشاء الوسوم التفاعلية.

#### 2.3 تحسين `HierarchicalTreeSidebar` (953 سطراً):
* تفكيك عناصر الشجرة الجانبية إلى مكوّنات فرعية:
  * `SidebarSmartFiltersSection`: اليوم، القادمة، المعلقة، العاجلة.
  * `SidebarAreasTreeSection`: المجالات والمشاريع التابعة لها بنسب الإنجاز.
  * `SidebarTagsSection`: قائمة الوسوم مع عداداتها.
  * `SidebarSharedSection`: المشاريع والمجالات المشتركة مع المستخدم.

* **توزيع الأدوار**:
  * **الوكيل الفرعي**:
    * استخراج حوارات `AddTaskDialog`, `AddProjectDialog`, `AddAreaDialog`, `ExportTasksDialog`.
    * استخراج أقسام درج تفاصيل المهمة `TaskDetailDrawer` وتحويلها لملفات مستقلة.
  * **الوكيل الرئيسي**:
    * إعادة تجميع `MainLayoutScreen` و `TaskDetailDrawer` باستخدام المكونات المستخرجة.
    * التحقق من ثبات شجرة الـ Widgets واستقرار كافة اختبارات الـ UI (`widget_test.dart` و `task_list_view_test.dart` و `task_attachments_section_test.dart`).

---

### 🔹 المرحلة 3: ربط المتحكمات وحل Callback Drilling (State Management Alignment)
* **الهدف**: التخلص من تمرير أكثر من 20 كولباك في الشاشات، وتفعيل المتحكمات الجاهزة التي بنيت ولم تُستخدم في الواجهة الرئيسية.

* **المهام التفصيلية**:
  1. **تحديث `TaskyHomeScreen`**:
     * استبدال الاستدعاء المباشر للمستودعات الخام (`_taskRepo`, `_projectRepo`, `_areaRepo`, `_tagRepo`) بالمتحكمات المعتمدة:
       * `TasksController`
       * `AreasController`
       * `ProjectsController`
       * `TagsController`
  2. **تبسيط `MainLayoutScreen`**:
     * استقبال المتحكمات مباشرة أو عبر موفر حالة / `ListenableBuilder`، بدلاً من حشد 20+ دالة رد نداء في الـ Constructor.
     * توحيد منطق التصفية والبحث في متحكم المهام والبحث (`TasksController` / `SearchController`).

* **توزيع الأدوار**:
  * **الوكيل الرئيسي حصراً**: تنفيذ هذه المرحلة لأنها تمس عصب تدفق البيانات والحالة في كامل التطبيق.
  * **الوكيل الفرعي**: تحديث اختبارات الواجهات التي تنشئ `MainLayoutScreen` لتتوافق مع الهيكل المبسط الجديد.

---

### 🔹 المرحلة 4: إعادة تنظيم هيكلية المجلدات والتغليف النهائي (Folder Structure Alignment)
* **الهدف**: نقل الملفات الموضوعة في مسارات غير متناسقة إلى حزم ميزاتها المناسبة (Clean Architecture Modular Packaging).

* **المهام التفصيلية**:
  1. **نقل ملفات الوسوم (Tags Feature)**:
     * نقل `lib/core/models/tag_model.dart` ➔ `lib/features/tags/data/models/tag_model.dart`.
     * نقل `lib/core/repositories/tag_repository.dart` ➔ `lib/features/tags/domain/repositories/i_tag_repository.dart`.
     * نقل `lib/core/repositories/tag_repository_impl.dart` ➔ `lib/features/tags/data/repositories/tag_repository_impl.dart`.
  2. **نقل القائمة الجانبية (Global Navigation)**:
     * نقل `hierarchical_tree_sidebar.dart` من `features/areas/` إلى `features/home/presentation/widgets/` أو `core/navigation/`.
  3. **تحديث شامل لكافة مسارات الاستيراد (Imports)** في كافة الملفات والاختبارات.

* **توزيع الأدوار**:
  * **الوكيل الفرعي**: تنفيذ النقل وتعديل مسارات الـ imports في ملفات الـ presentation والـ tests.
  * **الوكيل الرئيسي**: المراجعة والتحقق النهائي عبر `flutter analyze` و `flutter test` وضمان عدم ترك أي مسار معلق.

---

## مصفوفة الصلاحيات وحدود العمل (Permissions & Boundaries Matrix)

| الإجراء | الوكيل الرئيسي (Master Agent) | الوكيل الفرعي (Subagent) |
| :--- | :---: | :---: |
| تعديل ملفات التخطيط والوثائق (`MASTER_PLAN.md`, `COMPLETED_WORK.md`) | ✅ مسموح حصرياً | ❌ ممنوع |
| تعديل نماذج قواعد البيانات وخدمات المزامنة السحابية | ✅ مسموح | ❌ ممنوع |
| إجراء تعديلات على المتحكمات المركزية (`State Controllers`) | ✅ مسموح | ⚠️ بتفويض صريح فقط |
| استخراج مكونات الواجهات وتفكيك ملفات العرض (`UI Widgets & Dialogs`) | ✅ مسموح | ✅ مسموح وموصى به |
| كتابة وتعديل اختبارات الوحدة والواجهات الخاصة بالمكونات | ✅ مسموح | ✅ مسموح وموصى به |
| التحقق النهائي الشامل وتأكيد اعتماد المرحلة للمستخدم | ✅ مسموح حصرياً | ❌ ممنوع |

---

## معايير الجودة والإنجاز لكل خطوة (Definition of Done - DoD)
قبل إعلان اكتمال أي خطوة أو مرحلة من المراحل الأربع:
1. أن ينتهي أمر `flutter analyze` بنتيجة **`No issues found!`** (0 أخطاء و 0 تحذيرات).
2. أن تنجح جميع اختبارات التطبيق **219/219 اختباراً** دون أي إخفاق.
3. عدم انكسار أي ميزة أو تجربة استخدام بصرية على أي منصة (Desktop, Mobile, Web).
4. توثيق المنجزات في سجل الأعمال وتحديث حالة الخطة.

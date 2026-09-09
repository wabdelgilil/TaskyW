# TaskyW (Tasky 3.0) - Master Plan (خطة العمل الشاملة)

## نظرة عامة على المشروع (Project Overview)
نظام وتطبيق إنتاجية عام وشامل ومرن لإدارة المهام والمشاريع (**General-Purpose Task & Project Management System**)، يحمل الهوية والعلامة التجارية الرسمية **TaskyW**، مصمم ليكون قابلاً للتخصيص ومناسباً لأي مجال أو تخصص (هندسة، إدارة أعمال، برمجة، عمل حر، دراسة، إدارة حياة شخصية)، دون أي حصر بمجال بعينه. يعتمد النظام على معايير عالمية كمنهجية **PARA** ومبدأ **Offline-First** للعمل فائق السرعة بدون إنترنت أولاً عبر قاعدة بيانات SQLite محلية، مع معمارية مهيأة بالكامل للمزامنة السحابية والمشاركة عبر **Supabase**.

---

## فهرس وثائق إدارة المشروع (Documentation Index)
يعمل ملف `MASTER_PLAN.md` كفهرس ومرجع مركزي يربط جميع خطط وتفاصيل المشروع المتخصصة في المجلد:
1. 📐 [01_ARCHITECTURE_AND_TECH_STACK.md](file:///d:/programming/Tasky3.0/project_management/01_ARCHITECTURE_AND_TECH_STACK.md): تفاصيل معمارية النظام النظيفة (Clean Architecture)، بيئة Flutter متعددة المنصات، واستراتيجية Offline-First.
2. 🗄️ [02_DATABASE_SCHEMA_AND_MODELS.md](file:///d:/programming/Tasky3.0/project_management/02_DATABASE_SCHEMA_AND_MODELS.md): الجداول الكاملة لـ SQLite، معرفات UUID، الحذف الهادئ، وتتبع حالات المزامنة.
3. 🎨 [03_UI_UX_DESIGN_SPECIFICATIONS.md](file:///d:/programming/Tasky3.0/project_management/03_UI_UX_DESIGN_SPECIFICATIONS.md): مواصفات الواجهات، الشجرة التفاعلية للـ Sidebar، شريط التنقل السفلي، منتقي الألوان، وصفحات التفاصيل.
4. 🔍 [04_SEARCH_AND_FILTERING_ENGINE.md](file:///d:/programming/Tasky3.0/project_management/04_SEARCH_AND_FILTERING_ENGINE.md): المعايير التقنية لمحرك البحث المقيّد بالسياق وعزل نتائج البحث ومنع التشتت.
5. 🤝 [05_COLLABORATION_AND_SHARING.md](file:///d:/programming/Tasky3.0/project_management/05_COLLABORATION_AND_SHARING.md): مواصفات رابط المشاركة العام للمهمة الواحدة، ومشاركة المشاريع مع فرق العمل وصلاحياتها.
6. 🚀 [06_FUTURE_MODULES_ROADMAP.md](file:///d:/programming/Tasky3.0/project_management/06_FUTURE_MODULES_ROADMAP.md): تفاصيل ومواصفات العرض الجدولي (Notion/Excel-like DataGrid)، والوسوم، والتكرار الدوري، والمرفقات.
7. ⚙️ [07_BACKEND_AND_LOGIC_AGENT_TASKS.md](file:///d:/programming/Tasky3.0/project_management/07_BACKEND_AND_LOGIC_AGENT_TASKS.md): دليل مهام وكيل المنطق وإدارة الحالة وخدمات التنبيهات (Headless Logic & State).
8. 👥 [08_COLLABORATION_BACKEND_TASKS.md](file:///d:/programming/Tasky3.0/project_management/08_COLLABORATION_BACKEND_TASKS.md): دليل مهام وكيل المنطق لمنظومة المشاركة مع أعضاء الفريق وتحديد الصلاحيات (Viewer/Editor/Admin).
9. 💰 [09_FINANCIAL_LOGS_AND_EXPENSE_TRACKING.md](file:///d:/programming/Tasky3.0/project_management/09_FINANCIAL_LOGS_AND_EXPENSE_TRACKING.md): مواصفات وتفاصيل وحدة السجل المالي وتتبع المصروفات، التحويلات، والفواتير المعلقة.
10. 📝 [10_GENERAL_NOTES_AND_KNOWLEDGE_VAULT.md](file:///d:/programming/Tasky3.0/project_management/10_GENERAL_NOTES_AND_KNOWLEDGE_VAULT.md): مواصفات وتفاصيل وحدة الملاحظات العامة والأفكار والمستودع المعرفي.
11. 🗄️ [11_ARCHIVE_AND_TRASH_SYSTEM.md](file:///d:/programming/Tasky3.0/project_management/11_ARCHIVE_AND_TRASH_SYSTEM.md): مواصفات نظام الأرشفة، وسلة المهملات، والحذف الناعم/النهائي للمهام.
12. 🧹 [12_REFACTORING_AND_ARCHITECTURE_PLAN.md](file:///d:/programming/Tasky3.0/project_management/12_REFACTORING_AND_ARCHITECTURE_PLAN.md): خطة إعادة الهيكلة الشاملة، تفكيك الواجهات المتضخمة، ربط المتحكمات، وتوزيع الأدوار بين الوكيل الرئيسي والفرعي.
13. ✅ [COMPLETED_WORK.md](file:///d:/programming/Tasky3.0/project_management/COMPLETED_WORK.md): السجل الرسمي لتتبع الأعمال والإنجازات المكتملة.

---

## المبادئ المعمارية والتقنية (Architecture & Tech Stack)
*(التفاصيل الكاملة متوفرة في الوثيقة: [01_ARCHITECTURE_AND_TECH_STACK.md](file:///d:/programming/Tasky3.0/project_management/01_ARCHITECTURE_AND_TECH_STACK.md))*
* **منصة التطوير الأساسية**: Flutter (Dart) لتوفير كود موحد يعمل على:
  - Windows Desktop
  - Mobile (Android / iOS)
  - Web
* **قاعدة البيانات المحلية**: SQLite (عبر `drift` أو `sqflite_common_ffi`).
* **السحابة والمزامنة المستقبلية**: Supabase (PostgreSQL + Auth + Storage + RLS).
* **إستراتيجية المزامنة (Offline-First Ready)**:
  - جميع المعرفات من نوع `UUID v4` لمنع التضارب بين الأجهزة.
  - حقول تتبع المزامنة في كل جدول: `created_at`، `updated_at`، `deleted_at` (Soft Delete)، `sync_status`، `share_token`.
* **التنبيهات**: Local Notifications للنظام المكتبي والموبايل بدون الحاجة للإنترنت.

---

## القسم الأول: النسخة الأولى (Section 1: MVP)

### 1. طبقة البيانات والهيكل (Data & Database Layer)
*(المخطط الكامل للجداول والنماذج متوفر في: [02_DATABASE_SCHEMA_AND_MODELS.md](file:///d:/programming/Tasky3.0/project_management/02_DATABASE_SCHEMA_AND_MODELS.md))*
- [x] إعداد بنية قاعدة البيانات المحلية SQLite بتصميم متوافق 100% مع Supabase Schema.
- [x] جدول المجالات `areas`:
  - `id` (UUID), `name`, `icon_emoji`, `color_hex`, `order_index`, `created_at`, `updated_at`, `deleted_at`.
  - حرية كاملة للمستخدم في إنشاء وتعديل وحذف المجالات بأي مسميات وألوان وإيموجيز تناسب مجاله.
  - أمثلة مجالات افتراضية أولية عامة: (💼 العمل الأساسي | 🚀 المشاريع الخاصة | 🏠 الحياة الشخصية).
- [x] جدول المشاريع `projects`:
  - `id` (UUID), `area_id`, `name`, `description`, `icon_emoji`, `color_hex`, `status` (active, on_hold, completed), `target_date`, `created_at`, `updated_at`, `deleted_at`.
- [x] جدول المهام `tasks`:
  - `id` (UUID), `project_id` (اختياري/يمكن ربطها بالمجال مباشرة), `area_id`, `title`, `description`, `status` (todo, in_progress, waiting, review, completed), `priority` (low, medium, high, urgent), `color_hex`, `due_date`, `reminder_time`, `share_token`, `created_at`, `updated_at`, `deleted_at`.
- [x] جدول المهام الفرعية `subtasks`:
  - `id` (UUID), `task_id`, `title`, `is_completed`, `order_index`, `created_at`, `updated_at`, `deleted_at`.
- [x] طبقة التجريد للـ Repositories ومخازن البيانات (Clean Architecture).

### 2. واجهات وتجربة المستخدم (UI & UX Experience)
*(المواصفات التفصيلية للواجهات متوفرة في: [03_UI_UX_DESIGN_SPECIFICATIONS.md](file:///d:/programming/Tasky3.0/project_management/03_UI_UX_DESIGN_SPECIFICATIONS.md))*
- [x] تصميم نظام الثيم الثلاثي (Dark Slate / Crisp Light / Pure OLED Midnight) عالي التباين متجاوب بالكامل مع الشاشات العريضة (Desktop/Web) والشاشات الصغيرة والموبايل مع معالجة فيض الهيدر (Zero Overflow).
- [x] القائمة الجانبية (Hierarchical Tree Sidebar):
  - مقسمة إلى مجموعات منطقية (Smart Views, Areas & Projects, Settings).
  - شجرة تفرعية تفاعلية: فتح وطي المجال (Expand/Collapse) لإظهار المشاريع التابعة له ونسب الإنجاز.
  - أيقونات وإيموجي وألوان مخصصة لكل مجال ومشروع.
  - عدادات ذكية للمهام المتبقية في كل قسم.
- [x] طرق عرض المهام موحدة في رأس الصفحة (Header View Switcher):
  - **عرض القائمة الذكية (Smart List View)**: مهام اليوم، القادمة، المتأخرة، مع إمكانية الفلترة السريعة.
  - **عرض لوحة كانبان (Kanban Board View)**: أعمدة مصنفة حسب الحالات (To-Do / In Progress / Waiting / Review / Done) مع السحب والإفلات.
  - **عرض جدول البيانات التفاعلي (Interactive DataGrid / Table View)**: عرض Notion-like مع فرز وتعديل فوري داخل الخلايا.
  - مدمجة حصرياً في الشريط العلوي (SegmentedButton على الشاشات الكبيرة وأيقونة تدوير ثلاثية ذكية على الموبايل)، مع إلغاء التكرار في الشريط السفلي.
- [x] نظام البحث الذكي المقيّد بالسياق (Context-Aware Scoped Search):
  *(المعايير التقنية متوفرة في: [04_SEARCH_AND_FILTERING_ENGINE.md](file:///d:/programming/Tasky3.0/project_management/04_SEARCH_AND_FILTERING_ENGINE.md))*
  - **عزل نطاق البحث تلقائياً**:
    - عند التواجد داخل مشروع: يحصر البحث بنسبة 100% في مهام ومهام فرعية ووصف هذا المشروع فقط، دون خروج أي نتائج من خارجه.
    - عند التواجد داخل مجال: يحصر البحث في مشاريع ومهام هذا المجال فقط.
    - عند التواجد في العرض العام: يبحث عبر النظام كاملاً مع توضيح اسم المجال والمشروع لكل نتيجة.
  - شريط بحث ديناميكي يعرض اسم النطاق الحالي (مثال: `🔍 بحث في مشروع [اسم المشروع]...`).
  - خيار مرن بضغطة زر لتوسيع البحث إلى (البحث العام في كل المجالات) في حال رغب المستخدم.
  - بحث لحظي وسريع (Instant Search) في العناوين والأوصاف والمهام الفرعية.
- [x] صفحات ونوافذ التفاصيل المتكاملة (Dedicated Detail & Edit Pages):
  - **صفحة تفاصيل وتعديل المهمة (Task Detail Page / Drawer)**:
    - عرض وتعديل العنوان والوصف الغني والملاحظات الفنية.
    - تعديل الحالة، الأولوية، واللون المخصص للمهمة (Task Color).
    - تعيين/تعديل التاريخ، التوقيت، وجدولة التذكير.
    - إدارة المهام الفرعية (Subtasks) بنظام التشيك ليست ومؤشر الإنجاز.
    - تغيير المشروع أو المجال التابع له المهمة، وزر المشاركة والأرشفة.
  - **صفحة تفاصيل وإدارة المشروع (Project Detail Page)**:
    - عرض بيانات المشروع (الاسم، الوصف، الإيموجي، واللون المخصص، الموعد المستهدف، الحالة).
    - إحصائيات ونسب إنجاز المشروع (نسبة الاكتمال، عدد المهام المنجزة والمتبقية).
    - قائمة المهام التابعة للمشروع مباشرة مع إمكانية الفلترة والإضافة السريعة داخل المشروع.
    - إمكانية التعديل الكامل لبيانات المشروع أو نقله لمجال آخر أو أرشفته.
  - **صفحة تفاصيل وإدارة المجال (Area Detail Page)**:
    - عرض بيانات المجال (الاسم، الإيموجي، اللون، والترتيب).
    - نظرة عامة وإحصائيات شاملة للمجال (عدد المشاريع النشطة، إجمالي المهام، ومعدل الإنجاز العام).
    - استعراض جميع المشاريع التابعة للمجال مع إمكانية إضافة مشروع جديد تحته مباشرة.
    - استعراض المهام العامة التابعة للمجال مباشرة (بدون مشروع محدد).
    - إمكانية تعديل اسم ولون وأيقونة المجال بالكامل.

### 3. نظام التنبيهات المحلي (Local Notifications)
- [x] إعداد مشغل التنبيهات المحلية لجدولة التنبيه عند حلول `reminder_time` على الويندوز والموبايل.
- [x] إدارة أذونات التنبيه وتعديل أوقات الإشعار وربطه بدرج تفاصيل المهمة.

---

## القسم الثاني: التحديثات المستقبلية (Section 2: Future Updates)

### 1. المزامنة السحابية والحسابات (Supabase Cloud Sync & Auth)
- [x] تفعيل خادم Supabase وتطبيق قواعد البيانات (PostgreSQL Migrations).
- [x] محرك المزامنة التلقائي في الخلفية (Offline-to-Cloud Sync Engine) مع معالجة النزاعات (Conflict Resolution).
- [x] تسجيل الدخول والمصادقة (Email/Password, Magic Link, Google Auth).

### 2. منظومة المشاركة والصلاحيات والعمل الجماعي (Sharing & Collaboration)
*(المواصفات التفصيلية للمشاركة متوفرة في: [05_COLLABORATION_AND_SHARING.md](file:///d:/programming/Tasky3.0/project_management/05_COLLABORATION_AND_SHARING.md))*
- [x] **المشاركة متعددة المستويات (Multi-Level Scope)**:
  - مشاركة على مستوى **المجال (Area)**: الوصول للمجال بكامل مشاريعه ومهامه.
  - مشاركة على مستوى **المشروع (Project)**: الوصول للمشروع المحدد ومهامه فقط.
  - مشاركة على مستوى **المهمة (Task)**: الوصول لمهمة فردية وخطواتها الفرعية.
- [x] **المشاركة برابط عام خارجي بدون حساب (Public Read-Only Links)**:
  - توليد رابط فريد ومؤمن (`https://domain/share/[share_token]`) لأي مجال أو مشروع أو مهمة.
  - صلاحية **رؤية وعرض فقط (Read-Only)** 100% دون حاجة لحساب، عبر واجهة PublicShareScreen المخصصة مع إمكانية تعطيل الرابط في أي وقت.
- [x] **المشاركة مع أعضاء الفريق بحساب (Authenticated Collaborators with Roles)**:
  - دعوة الأشخاص بالبريد الإلكتروني للوصول إلى المجال أو المشروع أو المهمة عبر السحابة.
  - **تحديد الصلاحية أثناء المشاركة بدقة**:
    - 👁️ **مشاهدة فقط (Viewer)**: استعراض وتتبع التحديثات دون تعديل أو حذف.
    - ✏️ **رؤية وتعديل (Editor)**: تغيير الحالات، وتعديل النصوص، وإضافة مهام دون صلاحية الحذف.
    - 🗑️ **تحكم كامل (Admin)**: رؤية وتعديل وحذف المهام والمشاريع التابعة للنطاق.
  - جدول صلاحيات ومشاركات موحد (`entity_shares`) مع إسناد المهام لأعضاء الفريق (`assigned_to`) وواجهة موحدة `UniversalShareDialog`.
  - [x] **تقييد صلاحية إعادة المشاركة وإدارة الصلاحيات (Admin-Only Re-sharing & Permission Delegation)**:
    - منع المتعاونين من مشاركة الكيان أو تعديل صلاحيات أي عضو آخر إلا إذا كانت صلاحيتهم **مسؤول (Admin)** أو **المالك الأصلي (Owner)**؛ وحظر وصول الـ Viewers والـ Editors لنافذة التعديل أو قفلها للعرض فقط.

### 3. تجربة وسلوك المهام المكتملة (Completed Tasks UX & Grouping)
- [x] **عزل وتمييز المهام المكتملة في أسفل القائمة (Completed Tasks Section with Distinct Styling)**:
  - عند الضغط على الـ Checkbox وإكمال المهمة، تنتقل تلقائياً إلى قسم سفلي منفصل مخصص للمهام المكتملة (`Completed Tasks Section`).
  - تطبيق تصميم وشكل بصري مختلف ومميز للمهام المكتملة (مثال: خط مشطوب Strikethrough، شفافية خفيفة Opacity، لون باهت هادئ، وخيار طي/فتح للقسم).


### 4. وحدات وميزات متقدمة وتوسعية (Advanced Modular Features)
*(المواصفات وخارطة الطريق متوفرة في: [06_FUTURE_MODULES_ROADMAP.md](file:///d:/programming/Tasky3.0/project_management/06_FUTURE_MODULES_ROADMAP.md))*
- [x] نظام الوسوم والتصنيفات الديناميكية الحرة (Tags & Labels) مع فلترة متعددة وواجهات كاملة (قائمة، كانبان، درج تفاصيل، شريط جانبي).
- [x] المهام المتكررة والمجدولة دورياً (Recurring Tasks / Scheduled Routines) بدعم يومي/أسبوعي/شهري/سنوي وشارة 🔁 وتوليد تلقائي للنسخة التالية عند الإكمال.
- [x] إرفاق المستندات والصور والملفات (File & Document Attachments) ومزامنتها مع Supabase Storage.
- [ ] قسم الموارد والمعرفة (Resources & Knowledge Vault): ملاحظات عامة، جهات اتصال، مراجع، روابط سريعة.
  - [x] الملاحظات العامة (General Notes): شاشة مخصصة في الشريط الجانبي مع بحث فوري، تثبيت/إلغاء تثبيت، أرشفة، ألوان، حذف ناعم، ومزامنة كاملة مع Supabase (جدول `notes` + RLS).
- [x] نظام أرشفة المهام والمشاريع وسلة المهملات (Global Archive & Trash System):
  - [x] **الباك إند والمنطق**: استعلامات الأرشفة واستبعادها من المهام والمشاريع النشطة، واستعادة وسلة المهملات (`deleted_at IS NOT NULL`) مع الحذف النهائي وتفريغ السلة في `TaskRepositoryImpl`، `ProjectRepositoryImpl`، `TasksController`، و`ProjectsController`.
  - [x] **واجهة المستخدم**: عروض مخصصة للأرشيف العام وسلة المهملات في القائمة الجانبية والشاشة المركزية مع تبويبات ثلاثية والبحث الفوري وإمكانية الاسترجاع بنقرة زر وتفريغ السلة الآمن.
- [x] تقارير ومؤشرات أداء متقدمة (Productivity Analytics & Time Tracking).
  - [x] **باك إند التحليلات**: محرك `ProductivityAnalytics` (نسبة الإنجاز، سلسلة زمنية أسبوعية/شهرية، التجميع حسب المنطقة/المشروع، إنتاجية أيام الأسبوع وساعات الذروة، توزيع الأولويات) + `AnalyticsController` مع 14 اختباراً. (واجهة المستخدم من مسؤولية خبير الواجهات).

### 5. طريقة العرض الجدولي التفاعلي (Interactive Table / DataGrid View - شبيه بجداول Notion/Excel)
*(تفاصيل سيناريو الجداول متوفرة في: [06_FUTURE_MODULES_ROADMAP.md](file:///d:/programming/Tasky3.0/project_management/06_FUTURE_MODULES_ROADMAP.md))*
- [x] **العرض الجدولي الشامل (Global Table View)**:
  - جدول بيانات تفاعلي متقدم للمهام (`TasksTableView`) مدمج في مساحة العمل الرئيسية مع مبدل ثلاثي (قائمة | كانبان | جدول).
  - شريط إحصائي علوي (`Tasks Count Summary`) يعرض عدد المهام الإجمالي مع تمييز شارات الحالة والأولوية.
- [x] **العرض الجدولي حسب المجال والمشروع (Context-Aware Table View)**:
  - تكامل سلس مع صفحة تفاصيل المشروع `ProjectDetailScreen` لعرض مهام المشروع في جدول بيانات متكامل مع إمكانية التعديل والإضافة المباشرة.
  - دعم التصفية المباشرة للمجال والمشروع في مساحة العمل المركزية.
- [x] **ميزات تفاعلية متقدمة للجدول**:
  - التعديل المباشر داخل الخلايا (Inline Cell Editing): قوائم منسدلة فورية لتعديل الحالة (`StatusBadge`) وتعديل الأولوية (`PriorityBadge`) مع حفظ محلي ومزامنة سحابية تلقائية.
  - فرز تفاعلي تصاعدي/تنازلي بضغطة زر لجميع الأعمدة الرئيسية (العنوان، الحالة، الأولوية، وتاريخ الاستحقاق).
  - خانة إكمال المهام السريعة (`Checkbox`) وتحديث تلقائي للمهام المتكررة.
  - تمييز لوني ديناميكي للمهام المتأخرة (`Overdue - أحمر`) ومهام اليوم (`Today - برتقالي`).
  - شارات وسوم ملونة (`Tag Chips`) مع مؤشر التدفق (`+N`).
  - عداد المهام الفرعية المنجزة كنسبة رقمية (`Done / Total Subtasks`).
  - تجاوب كامل مع أنظمة الألوان (النهاري، الليلي، ونمط السواد المطلق OLED Midnight).
  - [x] التصدير المباشر لبيانات المهام بصيغة CSV / Excel داعمة للغة العربية بترميز UTF-8 BOM.

### 6. وحدة السجل المالي والمصروفات وتسوية الحسابات (Financial Logs & Settlements - موديول مستقل)
*(المواصفات التفصيلية متوفرة في: [09_FINANCIAL_LOGS_AND_EXPENSE_TRACKING.md](file:///d:/programming/Tasky3.0/project_management/09_FINANCIAL_LOGS_AND_EXPENSE_TRACKING.md))*
- [x] **الاستقلالية المعمارية الكاملة**: موديول منفصل كلياً في شاشته وقاعدة بياناته عن موديول المهام، لعدم تعقيد واجهات أو منطق المهام.
- [x] **بنية البيانات والـ Offline-First**:
  - جدول `financial_records` محلياً وسحابياً مع سياسات RLS، ومعرفات UUID، وحالات المزامنة (ترقية DB v7 + ملف ترحيل Supabase).
- [x] **الميزات التشغيلية الرئيسية (التسويات والفواتير)**:
  - متابعة **الفواتير والمشتريات المعلقة (`Pending Invoices`)**: شارة تحذيرية وتنبيه ذكي للعمليات التي لم تُستلم فواتيرها بعد مع إمكانية إرفاق الإيصال بنقرة زر.
  - **تسوية الحسابات التبادلية بين الشغل والشخصي**:
    - تسجيل المصاريف المدفوعة للشغل من الجيب الخاص (مطلوب استرداده / Reimbursement).
    - تسجيل المصاريف الشخصية المدفوعة من حساب أو عهدة الشغل (مستحق سداده للعمل).
    - مؤشر صافي التسوية (لك عند الشغل / عليك للشغل).
  - تسجيل التحويلات المالية بين الحسابات والوسائط (بنك، كاش، محفظة إلكترونية، عهدة).
- [x] **واجهات وتجربة المستخدم (UI/UX)**:
  - شاشة مركزية مستقلة للسجل المالي والتسويات (`FinancialLogScreen`) مع إحصائيات سريعة وتصفية ذكية وتصدير لـ Excel.
  - زر إضافة سريع يدعم تحديد نوع المعاملة ومصدر الدفع ومربع "لم أستلم الفاتورة بعد".
  - تصدير كشوف تسوية الحسابات بضغطة زر لملف Excel/CSV داعم للعربية (UTF-8 BOM) لتقديمه للمحاسبة.

### 7. وحدة الملاحظات العامة ومستودع المعرفة (General Notes - موديول مستقل)
*(المواصفات التفصيلية متوفرة في: [10_GENERAL_NOTES_AND_KNOWLEDGE_VAULT.md](file:///d:/programming/Tasky3.0/project_management/10_GENERAL_NOTES_AND_KNOWLEDGE_VAULT.md))*
- [x] **الاستقلالية والبساطة**: موديول حر هادئ بدون مواعيد استحقاق أو ضغوط مهام، مخصص للأفكار، المسودات، جهات الاتصال، والمراجع.
- [x] **بنية البيانات والـ Offline-First**:
  - جدول `notes` محلياً وسحابياً (title, content, color_hex, is_pinned, is_archived, area_id, sync_status) مع RLS على Supabase.
- [x] **الميزات والواجهات (UI/UX)**:
  - شاشة مخصصة للملاحظات في القائمة الجانبية (`NotesScreen`) بنمط بطاقات مرنة وشبكية (Keep-like).
  - تثبيت الملاحظات الهامة في الأعلى (`Pinned Notes`).
  - محرر نصوص خفيف وسريع للحفظ الفوري مع باليتة ألوان متنوعة.
  - بحث لحظي في عناوين ونصوص الملاحظات.

### 8. مواءمة المعمارية وإعادة الهيكلة الشاملة (Architecture Alignment & Refactoring)
*(التفاصيل ومصفوفة توزيع الأدوار بين الوكيل الرئيسي والفرعي متوفرة في: [12_REFACTORING_AND_ARCHITECTURE_PLAN.md](file:///d:/programming/Tasky3.0/project_management/12_REFACTORING_AND_ARCHITECTURE_PLAN.md))*
- [ ] **المرحلة 1: تنظيف وحسم الازدواجيات والكود الميت (Deduplication & Dead Code)**:
  - توحيد نموذج المشاركة `EntityShareModel` في `features/collaboration` وحذف النموذج المكرر في `core/models`.
  - إزالة `SharingController` وربط `ShareReadService` بالنموذج الموحد.
- [ ] **المرحلة 2: تفكيك الواجهات العملاقة (Decomposing God Widgets)**:
  - تفكيك `MainLayoutScreen` (1,526 سطر) واستخراج حوارات الإضافة ومكونات الرأس ومساحة العمل لمجلد `widgets/dialogs/`.
  - تفكيك `TaskDetailDrawer` (1,005 أسطر) إلى أقسام مستقلة (المهام الفرعية، التكرار، التواريخ والتذكيرات، الوسوم).
  - تفكيك `HierarchicalTreeSidebar` (953 سطراً) إلى أقسام شجرة فرعية نظيفة.
- [ ] **المرحلة 3: ربط المتحكمات والتخلص من الـ Callback Drilling (State Management Alignment)**:
  - تفعيل `TasksController`, `AreasController`, `ProjectsController`, `TagsController` داخل `TaskyHomeScreen`.
  - تبسيط معاملات `MainLayoutScreen` وحذف أكثر من 20 دالة Callback متسلسلة.
- [ ] **المرحلة 4: إعادة تنظيم هيكلية المجلدات والتغليف النهائي (Folder Structure Alignment)**:
  - نقل ملفات الوسوم (`TagModel`, `TagRepository`) إلى مجلد `lib/features/tags/`.
  - نقل `HierarchicalTreeSidebar` إلى مسار الملاحة المشترك في `lib/features/home/presentation/widgets/`.
  - الحفاظ التام والمستمر على 219/219 اختباراً ناجحاً ونظافة `flutter analyze`.

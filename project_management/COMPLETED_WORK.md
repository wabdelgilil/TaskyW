# Completed Work (الأعمال المنجزة)

## سجل الإنجازات والمهام المكتملة

### [2026-09-08] - بناء وتكامل نافذة المشاركة والتعاون الموحدة مع تحديد الصلاحيات (Universal Share Dialog & Permissions)
- **نافذة المشاركة التفاعلية الموحدة (`UniversalShareDialog`)**:
  - تصميم نافذة موحدة أنيقة متجاوبة بتبويبين للتحكم الشامل في مشاركة الكيانات (مجال / مشروع / مهمة):
    1. **تبويب أعضاء الفريق (بحساب)**:
       - إمكانية كتابة البريد الإلكتروني للشخص المدعو.
       - قائمة منسدلة لتحديد مستوى الصلاحية: 👁️ مشاهدة فقط (`viewer`)، ✏️ محرر / تعديل (`editor`)، أو 🗑️ تحكم كامل (`admin`).
       - استعراض قائمة المشتركين الفعليين مع شارات الحالة (نشط / معلّق)، وقائمة منسدلة فورية لتعديل الصلاحيات أو زر لسحب الصلاحية (`Revoke`).
    2. **تبويب الرابط العام (بدون حساب)**:
       - مفتاح تفعيل/تعطيل الرابط العام، مع توليد الرابط وعرضه بضغطة زر لنسخه للحافظة.
       - تنبيه أمني واضح يوضح أن الرابط العام يتيح القراءة فقط للمحتوى المعني دون المساس بأي بيانات أخرى.
- **ربط الواجهات ونقاط المشاركة**:
  - ربط زر المشاركة في رأس صفحة تفاصيل المشروع (`ProjectDetailScreen`).
  - ربط زر المشاركة في رأس صفحة تفاصيل المجال (`AreaDetailScreen`).
  - ربط زر المشاركة في درج تفاصيل المهمة (`TaskDetailDrawer`).
- **تحديث إعدادات بناء أندرويد (Core Library Desugaring & Incremental Cache)**:
  - تفعيل `isCoreLibraryDesugaringEnabled = true` وإضافة مكتبة `desugar_jdk_libs:2.0.4` لحل متطلبات حزمة `flutter_local_notifications`.
  - ضبط `kotlin.incremental=false` في `gradle.properties` لمنع تضارب الكاش عبر الأقراص على بيئة ويندوز.
- **التحقق والاختبار**:
  - اجتياز جميع اختبارات المشروع بنجاح (129/129 اختباراً).
  - اجتياز فحص `flutter analyze` بنظافة تامة (No issues found!).

### [2026-09-08] - إزالة التكرار الداخلي وتوحيد أنماط الرؤية في الشريط العلوي وإضافة أشرطة التمرير الأفقية

- **إبقاء شريط التنقل السفلي (`bottomNavigationBar`)**:
  - تم الإبقاء الكامل على شريط التنقل السفلي في `MainLayoutScreen` مع خياراته وتكامله بسلاسة على شاشات الموبايل.
- **إزالة محدد العرض الداخلي المكرر في تفاصيل المشروع والمجال**:
  - إزالة الـ `SegmentedButton` المكرر داخل `ProjectDetailScreen`.
  - توحيد والاعتماد الحصري على محدد أنماط الرؤية الموجود في رأس مساحة العمل (`Header`):
    - **الشاشات الكبيرة والمتوسطة**: محدد ثلاثي أنيق (`SegmentedButton: قائمة | كانبان | جدول`).
    - **شاشات الموبايل**: أيقونة مدمجة للتدوير بين الأنماط الثلاثة.
  - تمرير `viewMode` مباشرة لشاشات تفاصيل المشاريع والمجالات بحيث تتناغم طريقة العرض فوراً مع اختيار الرأس بدون تضارب أو ازدواجية.
- **إضافة شريط تمرير أفقي ورأسي تفاعلي (Horizontal & Vertical Scrollbars)**:
  - **عرض الكانبان (`KanbanBoardView`)**: تزويد لوحة الكانبان بشريط تمرير أفقي دائم وظاهر (`thumbVisibility: true`, `trackVisibility: true`) مع `ScrollController` مخصص لتسهيل التنقل والسحب بين الأعمدة على سطح المكتب وشاشات اللمس.
  - **عرض الجدول (`TasksTableView`)**: تزويد جدول البيانات بأشرطة تمرير أفقية ورأسية واضحة ومستقلة مع فصل إشعارات التمرير (`notificationPredicate`) لسهولة فحص الأعمدة العريضة.
- **التحقق والاختبار**:
  - اجتياز جميع اختبارات المشروع بنجاح (129/129 اختباراً).
  - اجتياز فحص `flutter analyze` بنظافة كاملة (0 أخطاء و 0 تحذيرات).

### [2026-09-08] - بناء وتكامل طريقة العرض الجدولي التفاعلي (Interactive DataGrid / Table View - Notion/Airtable Style)
- **مكوّن جدول المهام التفاعلي المتقدم (`TasksTableView`)**:
  - تصميم وبناء مكوّن جدول بيانات متكامل مستوحى من Notion و Airtable مع رأس ثابت، تمرير أفقي وعمودي سلس، وتأثيرات تحويم ناعمة (`Hover Effect`).
  - **التعديل المباشر داخل الخلايا (Inline Cell Editing)**:
    - إمكانية تغيير حالة المهمة فوراً عبر قائمة منسدلة داخل الخلية (`StatusBadge`) مع حفظ تلقائي ومزامنة سحابية.
    - إمكانية تغيير أولوية المهمة فوراً عبر قائمة منسدلة داخل الخلية (`PriorityBadge`) مع حفظ تلقائي ومزامنة سحابية.
    - مربع إكمال المهمة المباشر (`Checkbox`) مع دعم التوليد التلقائي للنسخة التالية في حال كانت المهمة متكررة دورياً (`RecurrenceService`).
  - **الفرز التفاعلي للأعمدة (Interactive Column Sorting)**:
    - دعم فرز تصاعدي وتنازلي متكامل لأعمدة: عنوان المهمة، الحالة، الأولوية، وتاريخ الاستحقاق.
    - ظهور مؤشرات اتجاه الفرز (سهم صاعد/هابط) بصرياً في رأس كل عمود مفروز.
  - **خلايا البيانات الذكية والمؤشرات البصرية**:
    - خلية تاريخ الاستحقاق: تمييز تلقائي باللون الأحمر والأيقونة التحذيرية للمهام المتأخرة (`Overdue`) وباللون البرتقالي لمهام اليوم (`Due Today`).
    - خلية النطاق: عرض أيقونة واسم المشروع أو المجال التابع له المهمة.
    - خلية الوسوم: عرض رقاقات الوسوم الملونة (`Tag Chips`) مع عداد الفائض (`+N`).
    - خلية المهام الفرعية: مؤشر رقمي لنسبة الإنجاز (`Done / Total Subtasks`).
    - شريط إحصائي أسفل/أعلى الجدول يعرض إجمالي المهام المعروضة وحالة التصفية.
- **تكامل مساحة العمل المركزية (`MainLayoutScreen`)**:
  - إضافة خيار "عرض الجدول" (`Table Mode`) في محدد العرض الثلاثي للشاشات المكتبية واللوحية (`SegmentedButton: قائمة | كانبان | جدول`).
  - دعم التدوير السلس بضغطة زر بين أوضاع العرض الثلاثة على شاشات الموبايل (`list -> kanban -> table -> list`).
  - ربط كامل لجميع العمليات التفاعلية (`onTaskTap`, `onToggleCompleted`, `onTaskStatusChanged`, `onTaskPriorityChanged`, `onAddTask`).
- **تكامل صفحة تفاصيل المشروع (`ProjectDetailScreen`)**:
  - إضافة وضع العرض الجدولي لمهام المشروع في الـ `SegmentedButton` لتمكين المستخدم من إدارة مهام مشروعه بأسلوب جدول بيانات Notion.
- **حزمة الاختبارات والتحقق المعماري**:
  - إنشاء حزمة اختبارات مخصصة `test/tasks_table_view_test.dart` لتغطية تصيير الرؤوس، عدادات المهام، حالة الجدول الفارغ، فرز الأعمدة، ونقر خلايا الإكمال.
  - اجتياز جميع اختبارات المشروع بنجاح تام (129/129 اختباراً اجتياز كامل 100%).
  - اجتياز فحص `flutter analyze` بنظافة كاملة وبدون أي تحذيرات أو أخطاء (`No issues found!`).

### [2026-09-08] - استكمال واجهات المستخدم (UI & Aesthetics) للوسوم والتكرار والتصدير والمشاركة العامة
- **واجهات الوسوم والتصنيفات (Tags & Labels UI)**:
  - **بطاقات المهام (`TaskCard`)**: عرض رقاقات الوسوم (`Tag Chips`) الملونة بألوان متباينة تكيفية مع نقطة لونية واسم الوسم وتجاوب بصري كامل مع ثيمات التطبيق (النهاري، الليلي، وOLED).
  - **درج تفاصيل المهمة (`TaskDetailDrawer`)**: إضافة قسم متكامل لإدارة الوسوم، استعراض الوسوم المطبقة مع خيار إزالتها بضغطة زر، زر إضافة وسم يفتح نافذة سفلية أنيقة (`BottomSheet`) لاختيار الوسوم المتوفرة أو إنشاء وسم جديد مباشرة وتحديد لونه من لوحة ألوان دائرية جذابة.
  - **الشريط الجانبي التفاعلي (`HierarchicalTreeSidebar`)**: إضافة قسم "الوسوم والتصنيفات" مع عداد المهام لكل وسم، وإمكانية تصفية المهام بضغطة واحدة، وإضافة وسم جديد فوراً.
  - **ربط شاشات وتخطيطات العمل**: تمرير الوسوم وربطها في `MainLayoutScreen` وعروض القائمة والكانبان وصفحات تفاصيل المشروع والمجال.
- **واجهات المهام المتكررة (Recurring Tasks UI)**:
  - **درج تفاصيل المهمة**: إضافة بطاقة خصائص التكرار الدوري تشمل مفتاح تفعيل (`Switch`)، وقائمة اختيار النمط (يومي، أسبوعي، شهري، سنوي)، وتحديد فاصل التكرار (`interval`) وتاريخ الانتهاء الاختياري.
  - **شارة التكرار في البطاقة (`TaskCard`)**: إبراز المهام المتكررة بشارة أرجوانية أنيقة `🔁 [النمط]` لتمييزها بصرياً فوراً.
  - **توليد المهمة التالية تلقائياً**: توليد المهمة القادمة مباشرة عبر `RecurrenceService.generateNextRecurrence` عند إكمال المهمة سواء من الـ Checkbox أو لوحة كانبان.
- **تصدير المهام إلى CSV / Excel متوافق مع اللغة العربية**:
  - إضافة زر تصدير مباشر في الشريط العلوي (`_buildTopHeader`) للشاشات المكتبية والموبايل.
  - تشفير بمحدد UTF-8 BOM (`\uFEFF`) لضمان فتح الملفات في Excel بدون تشوه الحروف العربية، مع معالجة الفواصل وحقول علامات التنصيص (RFC 4180).
  - نافذة منبثقة تفاعلية للمعاينة السريعة ونسخ البيانات للحافظة فوراً بنقرة واحدة.
- **شاشة المشاركة العامة (`PublicShareScreen`) وتوجيه الروابط**:
  - إنشاء صفحة متجاوبة أنيقة `PublicShareScreen` مخصصة للزوار بدون تسجيل دخول لقراءة المهمة أو المشروع أو المجال عبر الرمز العام `token`، متصلة بخدمة `ShareReadService.fetchPublicEntityByToken`.
  - عرض تفاصيل الكيان وحالته وأولويته وتاريخ استحقاقه وعناصره الفرعية (Subtasks / Tasks) بأسلوب قراءة فقط متناسق مع هوية TaskyW.
  - دعم مسارات التنقل العامة (`/share/:token`) في `main.dart`.
- **التحقق والاختبار الشامل**:
  - `flutter analyze`: بدون أي أخطاء أو تحذيرات (`No issues found!`).
  - `flutter test`: نجاح كافة الاختبارات الـ 109 بنجاح تام (109/109 passed).

### [2026-09-08] - مزامنة الوسوم مع السحابة (Tags Cloud Sync) + نشر ترحيل المشاركة
- **ترحيل سحابي جديد** [20260908000200_add_tags_tables.sql](file:///d:/programming/Tasky3.0/supabase/migrations/20260908000200_add_tags_tables.sql):
  - جدول `tags` (id, user_id, name, color_hex, order_index, sync_status, timestamps) ومثيلته `task_tags` (id, user_id, task_id, tag_id + unique(task_id, tag_id)) مع FKs متتالية على `tasks`/`tags`.
  - الفهارس `idx_tags_deleted` و `idx_task_tags_task` و `idx_task_tags_tag`، وتفعيل RLS وسياسات select/insert/update/delete لمالك الصف فقط على الجدولين.
- **مزامنة محلية v3**: ترقية قاعدة SQLite إلى الإصدار v3 مع `_ensureTaskTagColumns` (ALTER آمن + تعبئة الهوية المستقرة `task_id|tag_id` للروابط القديمة) في مساري الويب والـ Desktop.
- **جدول `task_tags` محلياً**: إضافة أعمدة `id` و `sync_status` و `updated_at` و `deleted_at` لدعم دورة المزامنة.
- **`TagRepositoryImpl`**: كتابة الروابط بهوية مستقرة وحالة `pending_insert`، وفك ربط هادئ (`pending_delete`) مع استعادة تلقائية عند إعادة الإسناد، وترشيح الروابط المحذوفة في القراءات.
- **`SyncService._tables`**: إضافة `tags` و `task_tags` (بقوائم الأعمدة الصحيحة) لرفع وتنزيل الروابط تلقائياً.
- **نشر على Supabase (مشروع yjcpevqahefzcpbvajcq فقط)**:
  - ترحيل المشاركة [20260907000200_setup_entity_shares.sql](file:///d:/programming/Tasky3.0/supabase/migrations/20260907000200_setup_entity_shares.sql) مؤكد تطبيقه (جدول `entity_shares` + RPC `get_shared_entity` + سياسات RLS).
  - تطبيق `20260908000100` (أعمدة التكرار - آمنة لإعادة التنفيذ) و `20260908000200` عبر `supabase db push --db-url`.
  - التحقق: الجداول السبع حاضرة، RLS مفعّل، 4 سياسات لكل جدول، وسجل الترحيلات يحتوي الأربعة.
- **الاختبارات**: إضافة اختبارات لمزامنة الروابط في [test/tags_test.dart](file:///d:/programming/Tasky3.0/test/tags_test.dart) (+2) واجتياز كامل السويت + `flutter analyze` نظيف.

### [2026-09-08] - إصلاح روابط المشاركة العامة (Public Share Links)
- **المشكلة**: زر «مشاركة المهمة» في واجهة المهمة كان يكتب `share_token` على صف `tasks` محلياً فقط (نمط offline-first يُزامَن لاحقاً)، بينما كانت دالة `get_shared_entity` تقرأ من جدول `entity_shares` حصراً → وكان `entity_shares` **فارغاً** فتُرفض كل الروابط برسالة «الرابط غير صالح أو انتهت صلاحيته».
- **الحل** [20260908000300_fix_public_share_lookup.sql](file:///d:/programming/Tasky3.0/supabase/migrations/20260908000300_fix_public_share_lookup.sql):
  - إضافة **مسار تراجعي** داخل `get_shared_entity`: عند غياب سجل في `entity_shares` تبحث المهمة مباشرة عبر `tasks.share_token` (قراءة عامة فقط)، ويبقى السلوك الأصلي لـ entity_shares (area/project/task) كما هو.
  - سياسة قراءة عامة لمهام المهام الفرعية المنتمية لمهمة لها `share_token`.
- **تصحيح إضافي** [20260908000400_fix_public_share_subtask_policy.sql](file:///d:/programming/Tasky3.0/supabase/migrations/20260908000400_fix_public_share_subtask_policy.sql):
  - سياسة `EXISTS` السابقة تتأثر بـ RLS الخاصة بـ `tasks` نفسها فتُرجع صفراً للمجهول؛ استُبدلت بدالة مساعدة `task_is_public(text)` بسمة `security definer` (تجاوز RLS) تفحص `share_token` فقط.
- **النشر والتحقق (مشروع yjcpevqahefzcpbvajcq فقط)**:
  - تطبيق الترحيلين عبر `supabase db push --db-url`.
  - تحقق REST بمستخدم مجهول (anon): `rpc/get_shared_entity` بالرمز `41e94162` يعيد المهمة ✅ والمهام الفرعية 2/2 ✅ والرمز غير الصحيح يعيد 400 ✅.
- **النتيجة**: `flutter test` **113/113** و`flutter analyze` نظيف.

### [2026-09-08] - حل تداخل الشريط العلوي على الموبايل (Responsive Header & Full Expansion Search)
- **معالجة فيض واختفاء وتداخل عناصر الهيدر في الشاشات الصغيرة (< 600px)**:
  - **التصميم المتجاوب التكيفي للشاشات الصغيرة**:
    - فصل شريط الرأس تلقائياً حسب قياس الشاشة (Desktop >= 900, Tablet 600-900, Mobile < 600).
    - **على شاشات الموبايل**:
      - تقليص شريط العنوان لإتاحة المساحة مع قصر العنوان ومنع أي تجاوز (`TextOverflow.ellipsis`).
      - تحويل حقل البحث إلى زر أيقونة أنيق؛ عند النقر عليه يتمدد كشريط بحث كامل (`Full-width Search Bar`) يملأ رأس الشاشة مع زر رجوع (Back) وزر مسح سريع وزر بحث شامل.
      - تحويل زر حالة المزامنة السحابية `SyncStatusButton` إلى وضع مدمج (`compact: true`) يظهر كأيقونة دائرية أنيقة مع شارة عدد التعديلات المعلقة دون نصوص تفيض.
      - تحويل زر التبديل بين القائمة والكانبان إلى أيقونة مدمجة تبادلية.
      - دعم زر الحساب وتسجيل الدخول المدمج (صورة شخصية دائرية أو أيقونة بروفايل مدمجة بدلاً من الأزرار العريضة).
      - نقل إضافة المهام في الموبايل إلى زر إجراء عائم (`FloatingActionButton`) مريح وفي متناول الإبهام فوق الشريط السفلي.
  - **التحقق والاختبار**:
    - إضافة اختبار متجاوب مخصص لشاشات الموبايل في [test/widget_test.dart](file:///d:/programming/Tasky3.0/test/widget_test.dart).
    - اجتياز جميع اختبارات المشروع (65/65) بنجاح تام وبدون أي استثناء فيض (`RenderFlex overflow`).
    - كود نظيف تماماً (`flutter analyze: No issues found`).

### [2026-09-08] - تعميم وتطبيق نمط السواد العميق (OLED) على كامل واجهات التطبيق
- **حل مشكلة بقاء أجزاء من الواجهة باللون الأزرق الكحلي (Dark Slate) عند تفعيل نمط OLED**:
  - **السبب**: كانت المكونات الرئيسية تعتمد على شرط `isDark ? AppColors.darkSurface : AppColors.lightSurface`، وبما أن كلاً من الوضعين الليلي وOLED يعتبران داكنين (`brightness == Brightness.dark`)، كانت الواجهات تجلب تلقائياً درجات الكحلي `darkSurface` (#1E293B) و `darkBorder` (#334155).
  - **الحل الجذري المنجز**:
    - استحداث دوال ألوان تكيفية شاملة في [AppColors](file:///d:/programming/Tasky3.0/lib/core/theme/app_colors.dart) تكتشف نمط OLED بدقة وتوفر:
      - `AppColors.surface(context)`: يعيد السطح الحالك (`#101216`) في OLED، والكحلي (`#1E293B`) في الليلي، والأبيض في النهاري.
      - `AppColors.card(context)`: يعيد كروت الأوبسيديان (`#161920`) في OLED.
      - `AppColors.border(context)`: يعيد الحدود الداكنة الحادة (`#262C36`) في OLED.
      - `AppColors.background(context)`, `textPrimary`, `textSecondary`, `textMuted`.
    - ربط كافة مكونات الشاشة المركزية بالدوال التكيفية:
      - **الشريط الجانبي (`HierarchicalTreeSidebar`)**: أصبح بالكامل سطح أسود حالك (`#101216`) بحدود سوداء حادة ونصوص ناصعة بيضاء وفضية.
      - **الشريط العلوي (`_buildTopHeader`)**: أصبح متوافقاً 100% مع خلفية السواد العميق.
      - **أعمدة كانبان (`KanbanBoardView`)**: أصبحت أسطحها وخلفياتها سوداء حالكة متناسقة تماماً مع خلفية مساحة العمل.
      - **درج تفاصيل المهمة المنزلق (`TaskDetailDrawer`)**: تم تعميم السواد العميق والحدود التكيفية عليه.
      - **بطاقات المهام والمشاريع والمجالات (`TaskCard`, `ProjectDetailScreen`, `AreaDetailScreen`)**.
  - **التحقق والاختبار**:
    - إضافة اختبار وحدة مخصص للتحقق من اتساق نمط OLED عبر كامل الشاشات في [test/widget_test.dart](file:///d:/programming/Tasky3.0/test/widget_test.dart).
    - نجاح جميع الاختبارات الـ **66/66 اختباراً**، مع خلو الكود تماماً من أي تحذيرات (`flutter analyze: No issues found`).

### [2026-09-08] - دعم تدفق تأكيد البريد الإلكتروني (Email Confirmation Workflow)
- **معالجة تفعيل تأكيد البريد في Supabase وحالات المستخدم غير المؤكد**:
  - **في إنشاء الحساب (`SignUp`)**:
    - عند إنشاء حساب في وجود شرط تأكيد البريد (`session == null`)، ينتقل المستخدم تلقائياً إلى واجهة توجيهية متخصصة ومصممة بأعلى معايير الـ UX (`emailConfirmationPending`).
    - توضح للمستخدم إرسال رابط التفعيل إلى بريده مع بطاقة أنيقة تعرض الإيميل، وتنبيه بارز لفحص مجلد **الرسائل غير المرغوب فيها (Spam / Junk)**.
    - توفير أزرار مباشرة لإعادة إرسال الرابط بنقرة واحدة أو الانتقال لتسجيل الدخول بمجرد التأكيد مع حفظ البريد في الحقل تلقائياً.
  - **في تسجيل الدخول (`SignIn`)**:
    - اكتشاف خطأ `Email not confirmed` وترجمته إلى رسالة عربية واضحة ومباشرة.
    - عرض بطاقة تنبيه تفاعلية أسفل رسالة الخطأ توفر زراً مباشراً: **"إعادة إرسال رابط التفعيل الآن"** دون الحاجة لإعادة ملء النماذج.
  - إضافة دالة `resendConfirmationEmail` في `AuthController` عبر `supabase.auth.resend(type: OtpType.signup)`.
  - إضافة اختبارات وحدة شاملة في `test/auth_controller_test.dart` واجتياز **64/64 اختبار** بنجاح، و`flutter analyze` نظيف (0 issues).

### [2026-09-08] - إصلاح مزامنة SQLite مع Supabase (تصفية أعمدة السحابة user_id)
- **حل خطأ SQLite: `table areas has no column named user_id`**:
  - جداول Supabase تحتوي على عمود `user_id` لسياسات الأمان RLS، بينما جداول SQLite المحلية لا تحتاج هذا الحقل.
  - عند جلب البيانات من السحابة، كان يتم تمرير الحقول بالكامل بما فيها `user_id` إلى جمل `INSERT/UPDATE` في SQLite مما يسبب فشل المزامنة بـ `SqliteException(1)`.
  - تحديث [SyncService.toLocalRow](file:///d:/programming/Tasky3.0/lib/core/services/sync_service.dart) لفلترة وتصفية أي أعمدة غير معرفة محلياً وقصرها على أعمدة الجدول المحلي فقط، وضمان تحويل `is_completed` للأعداد الصحيحة.
  - تحديث [SyncService.toCloudPayload](file:///d:/programming/Tasky3.0/lib/core/services/sync_service.dart) لإرفاق `user_id` في حمولة الرفع السحابي لضمان نجاح سياسات RLS.
  - إضافة اختبارات وحدة واجتياز 61/61 اختبار بنجاح، و`flutter analyze` خالٍ تماماً (0 issues).

### [2026-09-08] - إعداد البناء التلقائي لمشروع Flutter Web على Vercel
- **حل خطأ البناء على Vercel (`flutter: command not found`)**:
  - خوادم Vercel القياسية لا تحتوي على Flutter SDK مثبتاً بشكل افتراضي.
  - إنشاء سكربت بناء خفيف وسريع [vercel-build.sh](file:///d:/programming/Tasky3.0/vercel-build.sh) يقوم بفحص وتثبيت Flutter SDK (قناة stable بعمق 1) وإضافة مسار الـ bin إلى PATH تلقائياً وتشغيل `flutter build web --release`.
  - تحديث ملف إعدادات [vercel.json](file:///d:/programming/Tasky3.0/vercel.json) ليعتمد `bash vercel-build.sh` كـ `buildCommand`.
  - التحقق من نجاح بناء الويب محلياً وخلوّه من الأخطاء.

### [2026-09-08] - تطبيق نظام الظلال الميكرو الناعمة (Subtle Micro-Shadows & Depth)
- **إضافة عمق وفصل طبقي ناعم وفائق السرعة (Zero Performance Impact)**:
  - **كروت المهام (`TaskCard`)**: إضافة ظل ميكرو ناعم جداً (`elevation: 1` بشفافية `0.08` في النهاري فقط)، بينما تظل مسطحة بنقاء في الليلي `elevation: 0` مع تباين ألوان الأسطح.
  - **شريط الرأس العلوي (`_buildTopHeader`)**: إضافة ظل ناعم هادئ (`Offset(0, 2)` بـ `blurRadius: 4` وشفافية `0.03`) يفصل الرأس كطبقة عائمة مستقرة فوق المحتوى دون استهلاك المعالج.
  - **الشجرة والقائمة الجانبية (`HierarchicalTreeSidebar`)**: إضافة ظل طفيف باتجاه مساحة العمل (`Offset(1, 0)` بـ `blurRadius: 6` وشفافية `0.025`) يعطي انطباعاً طبيعياً بانسياب القائمة.
  - **درج التفاصيل (`TaskDetailDrawer`)**: إضافة ظل ميكرو جانبي ناعم وواضح (`Offset(-2, 0)` بـ `blurRadius: 8`).
  - **كروت تفاصيل المجالات والمشاريع (`AreaDetailScreen` & `ProjectDetailScreen`)**: إضافة ظل خفيف للبطاقات يعزز البعد البصري عن الخلفية.
- **التأكيد والاختبار**:
  - فحص الكود: `flutter analyze` خالٍ تماماً (0 issues).
  - اختبارات الوحدة: `flutter test` اجتاز 58/58 اختبار بنجاح.

### [2026-09-08] - نظام الألوان التكيفي عالي التباين (Adaptive High-Contrast System)
- **حل مشكلة تداخل الألوان وتقارب الدرجات بين الوضعين الليلي والنهاري**:
  - **نظام تكيف ديناميكي ذكي للألوان (`AppColors.adaptiveStatusColor` & `AppColors.adaptivePriorityColor`)**:
    - **في الوضع الليلي (Dark Slate)**:
      - استبدال درجات الأزرق والرمادي الكاتمة بألوان ناصعة ومضيئة تشع بوضوح على الخلفية الداكنة: السماوي الزاهي (Cyan / Sky 400 `0xFF38BDF8`) كـ Primary، الأصفر المشرق (Amber 400 `0xFFFBBF24`) للمعلّقة، الأحمر المتوهج (Red 400 `0xFFF87171`) للعاجل، والزمردي النابض (Emerald 400 `0xFF34D399`) للمكتمل.
      - ترقية النصوص الثانوية `darkTextSecondary` إلى Slate 300 (`0xFFCBD5E1`) والمكتومة إلى Slate 400 لإراحة العين ومنع "العتمة".
    - **في الوضع النهاري (Crisp Light)**:
      - التخلص من الرمادي الباهت واستخدام ألوان عميقة وحادة وحاسمة: Slate 700 (`0xFF334155`) للنصوص بدلاً من الرمادي الخافت، Sky 600 (`0xFF0284C7`)، Amber 600 (`0xFFD97706`)، Red 600 (`0xFFDC2626`)، و Emerald 600 (`0xFF059669`).
  - **معالجة مواءمة السطوع للألوان المخصصة (`AppColors.adaptiveCustomColor`)**:
    - خوارزمية ذكية تقوم بضبط سطوع أي لون مخصص للمجال أو المشروع أو المهمة عبر HSL: يرتفع سطوعه تلقائياً في الوضع الليلي (Lightness >= 62%) حتى لا يختفي في الظلام، وينخفض في الوضع النهاري (Lightness <= 42%) حتى لا يبهت على الخلفية البيضاء.
  - **تطبيق النظام على كافة المكونات**:
    - شارات الحالات (`StatusBadge`) وشارات الأولويات (`PriorityBadge`).
    - كروت المهام (`TaskCard`) وشريط اللون الرأسي المخصص.
    - شجرة القائمة الجانبية (`HierarchicalTreeSidebar`) ومشاريعها وفلاترها السريعة.
    - أعمدة كانبان (`KanbanBoardView`) وشريط التنقل وأزرار وحقول الإدخال.
- **التأكيد والاختبار**:
  - فحص الكود: `flutter analyze` خالٍ تماماً (0 issues).
  - اختبارات الوحدة: `flutter test` اجتاز 58/58 اختبار بنجاح تام.

### [2026-09-08] - تحسين حدود وتباين الوضع النهاري وتفعيل المزامنة التلقائية اللحظية
- **تحسين حدود وتباين الوضع النهاري (Crisp Light Borders & Contrast)**:
  - تحديث لوحة ألوان الوضع النهاري في `AppColors`:
    - تعزيز لون الحدود `lightBorder` من الرمادي الباهت `0xFFE2E8F0` إلى `0xFFCBD5E1` (Slate 300) مع إضافة `lightBorderStrong = 0xFF94A3B8`.
    - ضبط خلفية التطبيق `lightBackground` إلى `0xFFF1F5F9` (Slate 100) لإبراز الكروت البيضاء النقية والمساحات بوضوح.
    - إضافة لون ناعم مخصص لأعمدة الكانبان `lightSurfaceSubtle = 0xFFF8FAFC` لتمييز الأعمدة عن كروت المهام.
  - تطبيق حدود واضحة وأنيقة بسماكة 1.2px على:
    - الشجرة الجانبية (`HierarchicalTreeSidebar`) باستخدام `BorderDirectional(end: ...)`.
    - شريط الرأس العلوي ومحرك البحث (`_buildTopHeader`).
    - أعمدة كانبان بورد (`KanbanBoardView`).
    - كروت المجالات والمشاريع وصفحات التفاصيل.
- **تفعيل المزامنة التلقائية اللحظية (Background Auto-Sync with Debouncing)**:
  - ربط كافة عمليات التعديل (إضافة/تعديل/حذف مهمة، مهمة فرعية، مجال، مشروع، أو تغيير الحالة) بـ `_scheduleAutoSync()` تلقائياً في الخلفية.
  - استخدام آلية Debounce (تأخير 1.5 ثانية بعد آخر تعديل) لتجميع التعديلات ورفعها دفعة واحدة إلى Supabase بدون إرهاق الشبكة أو تكرار الطلبات.
  - إضافة مزامنة تلقائية هادئة عند بدء تشغيل التطبيق (Startup Sync) لجلب أي تحديثات من الأجهزة الأخرى.
  - بقاء زر المزامنة العلوي متاحاً كدليل حالة لحظي (متزامن / جاري الرفع / معلق) أو للإجبار اليدوي عند الحاجة.
- **التأكيد والاختبار**:
  - فحص الكود: `flutter analyze` خالٍ تماماً (0 issues).
  - اختبارات الوحدة: `flutter test` اجتاز 58/58 اختبار بنجاح.

### [2026-09-07] - التخطيط والعصف الذهني الأولي وبدء المشروع
- **العصف الذهني وتحديد المتطلبات**:
  - تحديد مجالات العمل الرئيسية (مهندس صيانة وتشغيل ومشاريع، عمل حر خارجي، حياة شخصية).
  - اختيار واعتماد منهجية **PARA** ودمجها مع متطلبات الهندسة والصيانة.
  - اعتماد مبدأ **Offline-First** بالاعتماد على SQLite محلياً أولاً، مع التوافق 100% مع Supabase للمزامنة السحابية لاحقاً.
  - اعتماد إمكانية المشاركة المستقبلية (رابط عام لمهمة واحدة + مشاركة المشاريع مع فريق العمل بحسابات وصلاحيات).
  - تحديد المنصة والتقنية: **Flutter** (Dart) لدعم الويندوز، الموبايل، والويب بكود موحد.
- **إعداد وثائق إدارة المشروع واعتماد متطلبات الواجهة (UI/UX)**:
  - إنشاء وتحديث `project_management/MASTER_PLAN.md` بالمتطلبات المعمارية وتفاصيل الواجهات.
  - اعتماد نظام التخصيص اللوني الكامل (المجال، المشروع، والمهمة عبر Color Picker).
  - اعتماد القائمة الجانبية كشجرة تفاعلية هرمية (Hierarchical Tree Sidebar) بمجموعات وإمكانية فتح/طي المشاريع.
  - اعتماد شريط التنقل السفلي الموحد (Bottom Navigation Bar) عبر الويب، الديسكتوب، والموبايل.
  - اعتماد صفحات تفاصيل وتعديل متكاملة (Dedicated Detail & Edit Pages) لكل من: المهمة، المشروع، والمجال مع إحصائيات وإمكانية التعديل الكامل.
  - تأكيد الهوية المعمارية للنظام كنظام عام، مرن، وقابل للتخصيص بالكامل (General-Purpose & Modular) لأي مجال أو تخصص (هندسي، تجاري، تقني، شخصي...).
  - إضافة وتوثيق ميزة العرض الجدولي التفاعلي (Interactive Table / DataGrid View - شبيه بجدول Notion) في قسم التحديثات المستقبلية (Section 2: Future Updates) بالسيناريو المقترح (عرض عام هرمي، وعرض مخصص للمجال، وعرض مخصص للمشروع، مع إمكانية التصدير والفرز).
  - اعتماد وتوثيق نظام البحث الذكي المقيّد بالسياق (Context-Aware Scoped Search) ضمن الـ MVP: حصر نتائج البحث تلقائياً داخل المشروع أو المجال النشط لمنع التشتت مع خيار التوسيع للبحث الشامل.
  - **تأسيس منظومة التوثيق وإدارة المشروع الموديلار (Modular Documentation Hub)**:
    - تحويل `MASTER_PLAN.md` إلى فهرس رئيسي ومرجع موحد لكافة وثائق المشروع.
    - إنشاء 6 ملفات تفصيلية متخصصة ومربوطة بالماستر بلان:
      1. `01_ARCHITECTURE_AND_TECH_STACK.md` (المعمارية والتقنيات).
      2. `02_DATABASE_SCHEMA_AND_MODELS.md` (مخطط قاعدة البيانات والجداول).
      3. `03_UI_UX_DESIGN_SPECIFICATIONS.md` (مواصفات الواجهات وتجربة المستخدم).
      4. `04_SEARCH_AND_FILTERING_ENGINE.md` (محرك البحث المقيّد بالسياق).
      5. `05_COLLABORATION_AND_SHARING.md` (المشاركة وروابط الويب والعمل الجماعي).
      6. `06_FUTURE_MODULES_ROADMAP.md` (خارطة طريق الميزات المستقبلية والعرض الجدولي).
  - **توسيع وتفصيل دليل تنفيذ قاعدة البيانات بالكامل (02_DATABASE_SCHEMA_AND_MODELS.md)**:
    - توفير كود DDL الجداول والفهارس بالكامل لدعم SQLite مع استبعاد المحذوفات هادئاً.
    - كتابة نماذج Dart مع كامل دوال التحويل والنسخ (`toMap`, `fromMap`, `copyWith`).
    - كتابة كود تهيئة قاعدة البيانات والاتصال المزدوج للويندوز والموبايل (`sqflite_common_ffi`).
    - تعريف عقود المستودعات (Repository Interfaces: `IAreaRepository`, `IProjectRepository`, `ITaskRepository`, `ISubtaskRepository`).
    - إعداد سكريبت زراعة البيانات الافتراضية الأولية (Database Seeder).
  - إنشاء وتحديث `project_management/COMPLETED_WORK.md` لتتبع سير العمل خطوة بخطوة.

### [2026-09-07] - مراجعة واعتماد واختبار طبقة قاعدة البيانات (Data Layer Review & Verification)
- **فحص الكود والملفات**:
  - تم فحص ملفات طبقة قاعدة البيانات المنفذة: `AppDatabase`, `DatabaseTables`, `DatabaseSeeder` وكافة الـ Models والـ Repositories.
  - التحقق من توافق الجداول 100% مع الخطة (معرفات UUID، الحذف الهادئ `deleted_at`، تتبع حالات المزامنة `sync_status`).
  - التحقق من دعم نظام الويندوز المكتبي عبر `sqflite_common_ffi`.
- **التحسينات الفنية**:
  - تعزيز دالة البحث المقيّد بالسياق (`searchTasks`) في `TaskRepositoryImpl` لتبحث أيضاً في عناوين المهام الفرعية (Subtasks) وليس فقط عنوان ووصف المهمة الرئيسية.
- **الاختبار والتأكيد (Verification & Tests)**:
  - تشغيل `flutter analyze`: نتيجة خالية تماماً من أي تحذيرات أو أخطاء (`No issues found!`).
  - تشغيل الاختبارات الآلية `flutter test test/database_test.dart`: نجاح كافة الاختبارات (زراعة البيانات الافتراضية، إنشاء المشاريع والمجالات، الحذف الهادئ، البحث المقيّد بالسياق، وإدارة المهام الفرعية).
- **تحديث الخطة**:
  - تعليم كافة بنود طبقة البيانات والهيكل كمكتملة `[x]` في `MASTER_PLAN.md`.
  - إنشاء وتوثيق `project_management/07_BACKEND_AND_LOGIC_AGENT_TASKS.md` الذي يحدد مهام وكيل المنطق وإدارة الحالة ومنع التداخل البرمجي بنسبة 100%.

### [2026-09-07] - بناء وإنجاز طبقة الواجهات وتجربة المستخدم (UI/UX Track Implementation)
- **نظام الثيم والهوية البصرية**:
  - إنشاء `AppColors` و `AppTheme` للوضع الليلي المريح للعين (Dark Slate) والوضع النهاري فائق النقاء (Crisp Light).
  - إنشاء `ThemeController` للتبديل اللحظي التفاعلي بين الدارك مود واللايت مود.
- **المكونات البصرية التفاعلية (Reusable Widgets)**:
  - `ColorPickerDialog`: منتقي ألوان ذكي يتيح للمستخدم اختيار ألوان مخصصة للمجالات والمشاريع والمهام (ألوان مقترحة + كود HEX حر).
  - `EmojiPickerDialog`: منتقي إيموجي مصنف حسب بيئة العمل والمشاريع والهندسة والشخصية.
  - `StatusBadge` و `PriorityBadge`: شارات أنيقة تعرض حالات المهمة وأولوياتها بألوان ورموز دقيقة.
  - `ProgressBarWidget`: شريط تقدم متحرك يعرض نسب الإنجاز للمشاريع والمهام الفرعية.
- **كارت المهمة ولوحة الكانبان والقوائم**:
  - `TaskCard`: كارت غني يدعم الإطار اللوني المخصص، عداد المهام الفرعية (`X/Y`)، شارات الحالات وتواريخ الديدلاين.
  - `KanbanBoardView`: لوحة كانبان بـ 5 أعمدة كاملة تدعم السحب والإفلات التفاعلي (Drag & Drop) ونقل المهام بين الحالات.
  - `TaskListView`: قائمة ذكية للمهام مع حالات خلو الشاشة وإمكانية الإنجاز الفوري بنقرة زر.
- **الشجرة الهرمية الجانبية (Hierarchical Tree Sidebar)**:
  - شجرة تفاعلية تضم الفلاتر السريعة (اليوم، القادمة، المعلقة، العاجلة) وشجرة المجالات والمشاريع القابلة للفتح والطي (Expand/Collapse) مع العدادات اللحظية ومبدل الثيم.
- **صفحات التفاصيل والإدارة المستقلة**:
  - `TaskDetailDrawer`: درج منزلق لتفاصيل وتعديل المهمة، الملاحظات الفنية، وإدارة قائمة المهام الفرعية (Checklist).
  - `ProjectDetailScreen`: صفحة كاملة للمشروع تعرض مؤشرات الإنجاز، شريط التقدم، وتبديل الكانبان/القوائم.
  - `AreaDetailScreen`: صفحة متكاملة للمجال تضم بطاقات مشاريعه والمهام العامة التابعة له.
- **الشاشة الهيكلية المتجاوبة (MainLayoutScreen & TaskyHomeScreen)**:
  - محرك البحث الذكي المقيّد بالسياق (Context-Aware Scoped Search) مع زر التبديل للبحث الشامل.
  - شريط التنقل السفلي الموحد (Bottom Navigation Bar) عبر الموبايل والديسكتوب.
  - ربط الشاشات بمستودعات البيانات وعمليات الـ CRUD لتوفير تجربة Offline-First سريعة ومحلية 100%.
- **تحديث الخطة والتحقق**:
  - تعليم كافة بنود واجهات وتجربة المستخدم كمكتملة `[x]` في `MASTER_PLAN.md`.
  - التأكد من خلو الكود تماماً من الأخطاء عبر `flutter analyze` (`No issues found!`).

### [2026-09-07] - مراجعة واعتماد طبقة المنطق وإدارة الحالة وربط التنبيهات (Headless Logic, Controllers & Notifications Review)
- **مراجعة ملفات وكيل المنطق (Logic Agent Files Review)**:
  - فحص واعتماد أدوات المساعدة والتحقق:
    - [validators.dart](file:///d:/programming/Tasky3.0/lib/core/utils/validators.dart): التحقق من صحة النصوص، الألوان HEX، الروابط، والبريد الإلكتروني.
    - [date_time_utils.dart](file:///d:/programming/Tasky3.0/lib/core/utils/date_time_utils.dart): حسابات التواريخ الذكية والديدلاين مع الصياغة العربية المقروءة.
  - فحص واعتماد متحكمات إدارة الحالة (Controllers):
    - [areas_controller.dart](file:///d:/programming/Tasky3.0/lib/features/areas/presentation/controllers/areas_controller.dart): إدارة تحميل وإنشاء وتعديل وحذف المجالات مع اختيار المجال النشط.
    - [projects_controller.dart](file:///d:/programming/Tasky3.0/lib/features/projects/presentation/controllers/projects_controller.dart): إدارة المشاريع وربطها بالمجال والفلترة الفورية.
    - [tasks_controller.dart](file:///d:/programming/Tasky3.0/lib/features/tasks/presentation/controllers/tasks_controller.dart): إدارة المهام، التحديث اللحظي للحالات، والفلاتر الذكية المحسوبة فورياً (Today, Upcoming, Waiting, Urgent, Completed).
    - [subtasks_controller.dart](file:///d:/programming/Tasky3.0/lib/features/tasks/presentation/controllers/subtasks_controller.dart): إدارة قائمة المهام الفرعية وحساب نسبة التقدم لكل مهمة.
    - [search_controller.dart](file:///d:/programming/Tasky3.0/lib/features/tasks/presentation/controllers/search_controller.dart): إدارة البحث اللحظي المقيّد بالسياق (Global, Area, Project) مع ميزة Debounce لمنع الاستعلامات غير الضرورية.
- **خدمة التنبيهات المحلية والربط مع الواجهة**:
  - فحص واعتماد [notification_service.dart](file:///d:/programming/Tasky3.0/lib/core/services/notification_service.dart): دعم جدولة وإلغاء التنبيهات وإدارة المناطق الزمنية.
  - ربط التنبيهات مباشرة داخل [task_detail_drawer.dart](file:///d:/programming/Tasky3.0/lib/features/tasks/presentation/widgets/task_detail_drawer.dart):
    - إضافة منتقي تاريخ ووقت التنبيه (`_reminderTime`).
    - جدولة التنبيه تلقائياً عند حفظ المهمة أو إلغاؤه عند اكتمال المهمة أو حذف موعد التذكير.
- **الاختبارات الشاملة والتأكيد**:
  - تشغيل `flutter test` لكامل حزم الاختبارات: **47 اختباراً آلياً بنجاح 100%** عبر (`controllers_test.dart`, `database_test.dart`, `date_time_utils_test.dart`, `validators_test.dart`, `widget_test.dart`).
  - تشغيل `flutter analyze`: **0 أخطاء و 0 تحذيرات (`No issues found!`)**.
  - اعتماد اكتمال القسم الأول (MVP) بنسبة 100% وتحديث [MASTER_PLAN.md](file:///d:/programming/Tasky3.0/project_management/MASTER_PLAN.md).

### [2026-09-07] - إزالة المجالات الافتراضية، إضافة نوافذ تأكيد الحذف، وإبراز أزرار المشاركة وصفحات التفاصيل
- **إزالة المجالات المسبقة (Clean Start)**:
  - تفريغ زراعة البيانات الأولية في [database_seeder.dart](file:///d:/programming/Tasky3.0/lib/core/database/database_seeder.dart) لتبدأ قاعدة البيانات نظيفة تماماً بدون أي مجالات مفروضة، مع إتاحة الحرية الكاملة للمستخدم لإنشاء مجالاته وتخصيصها.
- **نافذة تأكيد الحذف لمنع الحذف بالخطأ (Confirm Delete Dialog)**:
  - إنشاء مكون [confirm_delete_dialog.dart](file:///d:/programming/Tasky3.0/lib/core/widgets/confirm_delete_dialog.dart) بتصميم أنيق وتحذير باللون الأحمر لمنع الحذف العرضي.
  - تطبيق نافذة التأكيد على:
    1. حذف المجالات في [area_detail_screen.dart](file:///d:/programming/Tasky3.0/lib/features/areas/presentation/screens/area_detail_screen.dart).
    2. حذف المشاريع في [project_detail_screen.dart](file:///d:/programming/Tasky3.0/lib/features/projects/presentation/screens/project_detail_screen.dart).
    3. حذف المهام في [task_detail_drawer.dart](file:///d:/programming/Tasky3.0/lib/features/tasks/presentation/widgets/task_detail_drawer.dart).
    4. حذف المهام الفرعية (Subtasks) في [task_detail_drawer.dart](file:///d:/programming/Tasky3.0/lib/features/tasks/presentation/widgets/task_detail_drawer.dart).
- **أزرار المشاركة (Share Actions)**:
  - إضافة زر مشاركة المهمة برابط عام (`Share Token`) في أعلى [task_detail_drawer.dart](file:///d:/programming/Tasky3.0/lib/features/tasks/presentation/widgets/task_detail_drawer.dart) ينسخ الرابط الفريد تلقائياً إلى الحافظة (`Clipboard`).
  - إضافة زر مشاركة المشروع في [project_detail_screen.dart](file:///d:/programming/Tasky3.0/lib/features/projects/presentation/screens/project_detail_screen.dart) مع إشعار توضيحي بخصوص التحديثات السحابية القادمة (Team Collaboration).
- **التحقق والاختبارات**:
  - خلو الكود من التحذيرات (`flutter analyze` -> `No issues found!`).
  - نجاح جميع الاختبارات الآلية (47/47) بنسبة 100%.
  - تحديث وتوافق تشغيل Chrome مع كافة التعديلات.

### [2026-09-07] - تحديث منظومة المشاركة متعددة المستويات ومصفوفة الصلاحيات
- **تحديث الخطة والوثائق المركزية**:
  - تحديث [05_COLLABORATION_AND_SHARING.md](file:///d:/programming/Tasky3.0/project_management/05_COLLABORATION_AND_SHARING.md) و [MASTER_PLAN.md](file:///d:/programming/Tasky3.0/project_management/MASTER_PLAN.md):
    1. **توسيع نطاق المشاركة (Multi-Level Scope)** ليشمل 3 مستويات كاملة: مشاركة المجال (Area)، أو المشروع (Project)، أو المهمة (Task).
    2. **اعتماد صيغتي الوصول (Dual Access Modes)**:
       - **رابط عام خارجي بدون حساب (Public Link)**: بصلاحية **رؤية فقط (Read-Only)** 100% مع صفحة ويب خفيفة ومؤمنة وإمكانية إلغاء الرابط بأي وقت.
       - **مشاركة مع أعضاء الفريق بحساب (Authenticated Collaborators)**: مع تحديد الصلاحية بدقة أثناء الدعوة عبر 3 أدوار رئيسية:
         - 👁️ **مشاهدة فقط (`viewer`)**: استعراض وتتبع التحديثات الحية دون إمكانية التعديل أو الحذف.
         - ✏️ **رؤية وتعديل (`editor`)**: تغيير الحالات، وتعديل النصوص، وإضافة مهام، دون إمكانية حذف المشروع أو المجال.
         - 🗑️ **تحكم كامل وحذف (`admin`)**: رؤية وتعديل وإضافة وحذف المهام والمشاريع التابعة للنطاق.
    3. **تصميم هيكل البيانات السحابي**: جدول `entity_shares` لربط النطاقات بمعرفات المستخدمين وتتبع الصلاحيات وسجل النشاط.

### [2026-09-07] - نشر التطبيق على GitHub و Vercel باسم TaskyW
- **بناء نسخة الويب والتحسينات السحابية**:
  - بناء تطبيق Flutter Web للإنتاج (`flutter build web --release`).
  - تضمين مكتبات WebAssembly و Web Worker (`sqlite3.wasm` و `sqflite_sw.js`) لتمكين عمل SQLite محلياً بالكامل على متصفحات الويب والموبايل.
  - إعداد ملف `vercel.json` لتحديد إعدادات العزل الأمني ومنافذ WASM (`COOP: same-origin` و `COEP: require-corp`) وتوجيه الـ SPA.
- **الرفع على GitHub**:
  - إنشاء مستودع عام جديد باسم **`TaskyW`**: [github.com/wabdelgilil/TaskyW](https://github.com/wabdelgilil/TaskyW).
  - دفع كود المشروع بالكامل إلى الفرع الرئيسي `main`.
- **النشر المباشر على Vercel**:
  - ربط المشروع ونشره للإنتاج بنجاح تحت اسم **`taskyw`**.
  - الرابط المباشر للإنتاج: [https://taskyw.vercel.app](https://taskyw.vercel.app).

### [2026-09-07] - بناء وتجهيز واجهات المصادقة وتكامل Supabase Auth
- **طبقة إدارة المصادقة (Auth Controller & Service)**:
  - ربط وتهيئة `supabase_flutter` بمشروع `yjcpevqahefzcpbvajcq` الرسمي وحفظ البيانات في [supabase_service.dart](file:///d:/programming/Tasky3.0/lib/core/services/supabase_service.dart).
  - إنشاء [auth_controller.dart](file:///d:/programming/Tasky3.0/lib/features/auth/presentation/controllers/auth_controller.dart) للاستماع لتغيرات الجلسة، تسجيل الدخول بالبريد وكلمة المرور، إنشاء الحساب، واستعادة كلمة المرور مع ترجمة واضحة للأخطاء.
- **واجهات المستخدم (UI & Screens)**:
  - إنشاء شاشة [auth_screen.dart](file:///d:/programming/Tasky3.0/lib/features/auth/presentation/screens/auth_screen.dart) بتصميم أنيق متجاوب (Sign In / Sign Up / Forgot Password) مع الحفاظ على مبدأ **Offline-First** وإمكانية المتابعة كضيف محلياً دون إجبار.
  - إضافة زر الملف الشخصي وتسجيل الدخول في أعلى شريط التطبيق [main_layout_screen.dart](file:///d:/programming/Tasky3.0/lib/features/home/presentation/screens/main_layout_screen.dart).
  - إضافة بطاقة المستخدم وحالة الاتصال بالسحابة في أسفل الشجرة الجانبية [hierarchical_tree_sidebar.dart](file:///d:/programming/Tasky3.0/lib/features/areas/presentation/widgets/hierarchical_tree_sidebar.dart).
- **قواعد العمل الجديدة**:
  - إضافة قاعدة صارمة في [AGENTS.md](file:///d:/programming/Tasky3.0/AGENTS.md) تمنع نهائياً أي نشر على Vercel أو رفع على GitHub إلا بعد موافقة صريحة مسبقة من المستخدم.
- **الاختبارات والتحقق**:
  - فحص `flutter analyze`: نتيجة خالية تماماً من الأخطاء والتحذيرات (`No issues found!`).
  - فحص كافة الاختبارات `flutter test`: نجاح 47 اختباراً من أصل 47 بنسبة 100%.

### [2026-09-07] - اعتماد وتطبيق هوية وشعار TaskyW الجديد فائق الدقة (Vector SVG & Brand Identity)
- **إعادة بناء وتوليد الشعار المتجهي (Vector Master SVG)**:
  - رسم دقيق لمونوغرام **TW** مع السهم الصاعد ↗ والانحناءات المتناسقة والتدرج اللوني الأزرق الأصلي (`#49B7E3` إلى `#0B4684`).
  - رقمنة الخط الطباعي الرسمي لكلمة **TaskyW** في صيغ متجهة نقية لا نهائية الدقة (`taskyw_emblem.svg`, `taskyw_logo_vertical.svg`, `taskyw_logo_horizontal.svg`, `taskyw_logo_horizontal_dark.svg`).
- **تصدير حزمة الأيقونات والصور النقطية فائقة الدقة (Ultra High-Res PNGs)**:
  - توليد نسخ الماستر بدقة `1024×1024` و `512×512` و `256×256` و `128×128` و `64×64` و `32×32` و `16×16`.
  - تحديث أيقونات المنصات:
    - Web Favicon وأيقونات PWA (`web/favicon.png`, `web/icons/Icon-192.png`, `web/icons/Icon-512.png`).
    - Android Mipmap Launchers (`android/app/src/main/res/mipmap-*`).
    - Windows App Icon (`windows/runner/resources/app_icon.ico`).
    - macOS App Icons (`macos/Runner/Assets.xcassets/AppIcon.appiconset/`).
- **تحديث الهوية البصرية عبر التطبيق (Flutter UI & Themes)**:
  - إنشاء ويدجت فلاتر مخصص وموحد [tasky_logo.dart](file:///d:/programming/Tasky3.0/lib/core/widgets/tasky_logo.dart) يدعم عرض الرمز منفرداً، والشعار الأفقي، والشعار الرأسي مع التوافق التام مع الوضع الليلي والنهاري.
  - تحديث [app_colors.dart](file:///d:/programming/Tasky3.0/lib/core/theme/app_colors.dart) بإضافة ألوان وهوية العلامة التجارية (`brandPrimary`, `brandLight`, `brandDeep`, `brandGradient`).
  - تحديث [app_theme.dart](file:///d:/programming/Tasky3.0/lib/core/theme/app_theme.dart) لربط الثيمات باللون الأساسي الموحد.
  - تحديث القائمة الجانبية [hierarchical_tree_sidebar.dart](file:///d:/programming/Tasky3.0/lib/features/areas/presentation/widgets/hierarchical_tree_sidebar.dart) لتعرض الشعار الرسمي الجديد بدلاً من الصندوق المؤقت.
  - تحديث اسم التطبيق وعناوينه في [main.dart](file:///d:/programming/Tasky3.0/lib/main.dart) و [index.html](file:///d:/programming/Tasky3.0/web/index.html) و [manifest.json](file:///d:/programming/Tasky3.0/web/manifest.json) و [AndroidManifest.xml](file:///d:/programming/Tasky3.0/android/app/src/main/AndroidManifest.xml) و [main.cpp](file:///d:/programming/Tasky3.0/windows/runner/main.cpp) و [Runner.rc](file:///d:/programming/Tasky3.0/windows/runner/Runner.rc).
- **الاختبارات والتحقق الآلي**:
  - فحص `flutter analyze`: **0 أخطاء و 0 تحذيرات (`No issues found!`)**.
  - فحص `flutter test`: **نجاح 47 اختباراً من أصل 47 بنسبة 100%**.

### [2026-09-07] - بناء منظومة وواجهات المزامنة السحابية اللحظية (Offline-First Sync UI)
- **متحكم المزامنة اللحظي (Sync Controller)**:
  - إنشاء [sync_controller.dart](file:///d:/programming/Tasky3.0/lib/core/services/sync_controller.dart) كـ `ChangeNotifier` تفاعلي يدير حالات المزامنة:
    - 🟢 `synced`: متزامن تماماً مع عرض توقيت آخر مزامنة.
    - 🔵 `syncing`: جاري الرفع والاتصال مع حركة دوران سلسة للأيقونة.
    - 🟡 `pending`: وجود تعديلات محلية معلقة مع إبراز عدد العمليات المعلقة.
    - ⚪ `offline`: انقطاع الإنترنت والعمل محلياً بالكامل (Offline-First).
    - 🔴 `error`: تنبيه المستخدم عند فشل الاتصال مع إتاحة إعادة المحاولة فوراً.
  - دعم بدء وطلب المزامنة القسرية الفورية (`triggerSync`).
- **المكونات البصرية التفاعلية (Sync Widgets)**:
  - إنشاء مكون زر المزامنة الذكي [sync_status_button.dart](file:///d:/programming/Tasky3.0/lib/core/widgets/sync_status_button.dart) بحركة أنيميشن ومظهر كبسولة تفاعلية (Pill) يتغير لونها وأيقونتها تلقائياً حسب الحالة.
  - دمجه في أعلى شريط التطبيق [main_layout_screen.dart](file:///d:/programming/Tasky3.0/lib/features/home/presentation/screens/main_layout_screen.dart) بجوار زر إنشاء مهمة والملف الشخصي.
  - إضافة مؤشر حالة المزامنة اللحظي (Live Sync Indicator) في بطاقة المستخدم بأسفل الشجرة الجانبية [hierarchical_tree_sidebar.dart](file:///d:/programming/Tasky3.0/lib/features/areas/presentation/widgets/hierarchical_tree_sidebar.dart).
- **الاختبارات والتحقق والربط الكامل**:
  - ربط [SyncService.instance](file:///d:/programming/Tasky3.0/lib/core/services/sync_service.dart) مباشرة مع [TaskyHomeScreen](file:///d:/programming/Tasky3.0/lib/features/home/presentation/screens/tasky_home_screen.dart) ومعالج `onSyncRequested`.
  - تحديث عداد العمليات المعلقة في الخلفية تلقائياً (`countPendingChanges`) ليعكس عدد العناصر التي تنتظر الرفع بدقة.
  - خلو الكود تماماً من التحذيرات والأخطاء (`flutter analyze` -> `No issues found!`).
  - اجتياز كافة الاختبارات بنجاح تام: **58 من أصل 58 اختباراً آلياً بنسبة 100%** عبر (`sync_service_test.dart`, `sharing_service_test.dart`, `controllers_test.dart`, `database_test.dart`, `date_time_utils_test.dart`, `validators_test.dart`, `widget_test.dart`).

### [2026-09-08] - دعم الإدخال المخصص للإيموجي والرموز باللصق وأكواد Unicode
- **تحديث نافذة اختيار الرموز التعبيرية [emoji_picker_dialog.dart](file:///d:/programming/Tasky3.0/lib/core/widgets/emoji_picker_dialog.dart)**:
  - إضافة حقل إدخال مخصص مع زر لصق مباشر من الحافظة (`Clipboard Paste`).
  - دعم إدخال أي رمز تعبيري عبر النسخ واللصق المباشر (مثل: 🤖 أو 🚀 أو أي إيموجي مركب).
  - دعم التعرف الذكي والتحويل التلقائي لصيغ أكواد اليونيكود المتعددة:
    - صيغة الـ Hex: `U+1F680` أو `1F680` أو `0x1F680` أو `\u1F680`.
    - صيغة HTML Entity: `&#128640;` أو الكود العشري المباشر.
  - إظهار معاينة فورية حية في رأس النافذة للرمز المكتوب أو الملصوق مع التحقق من صحته ومعالجة الأخطاء.
- **الاختبارات والتحقق**:
  - `flutter analyze`: **0 أخطاء و 0 تحذيرات (`No issues found!`)**.
  - `flutter test`: **نجاح 58 من 58 اختباراً آلياً بنسبة 100%**.

### [2026-09-08] - نظام الوسوم والتصنيفات (Tags & Labels) - Backend
- **جدولا الوسوم (`tags`) والربط (`task_tags`)** في [database_tables.dart](file:///d:/programming/Tasky3.0/lib/core/database/database_tables.dart):
  - `tags`: `id (PK)`, `name`, `color_hex`, `order_index`, `sync_status`, `created_at`, `updated_at`, `deleted_at` مع فهرس `idx_tags_deleted`.
  - `task_tags`: مفتاح مركّب `(task_id, tag_id)` مع FK حذف متتالٍ وفهارس `idx_task_tags_task` و `idx_task_tags_tag`.
- **ترقية قاعدة SQLite إلى v2** في [app_database.dart](file:///d:/programming/Tasky3.0/lib/core/database/app_database.dart):
  - تفعيل `onUpgrade` في مساري الويب والـ Desktop لإعادة تطبيق جمل `IF NOT EXISTS` على قواعد v1 القائمة (إضافة الجداول الجديدة دون تكرار).
- **طبقة النماذج والبيانات**:
  - [TagModel](file:///d:/programming/Tasky3.0/lib/core/models/tag_model.dart): `toMap/fromMap/copyWith` + المساواة/الهاش.
  - [ITagRepository](file:///d:/programming/Tasky3.0/lib/core/repositories/tag_repository.dart) و [TagRepositoryImpl](file:///d:/programming/Tasky3.0/lib/core/repositories/tag_repository_impl.dart): إسناد/فك الوسم عن المهمة، جلب وسوم المهمة، وجلب معرفات المهام للوسم.
- **[TagsController](file:///d:/programming/Tasky3.0/lib/features/tags/presentation/controllers/tags_controller.dart)**:
  - `createTag/updateTag/deleteTag/loadTags/selectTag` + التخصيص والإسناد (`assignTagToTask` / `removeTagFromTask`).
  - **فلترة المهام حسب الوسم النشط** (`filterTasksByActiveTag`) ومسح الفلترة (`clearTagFilter`).
- **الاختبارات**: إضافة [test/tags_test.dart](file:///d:/programming/Tasky3.0/test/tags_test.dart) (+9 اختبارات) واجتياز كامل السويت.

### [2026-09-08] - محرك المهام المتكررة (Recurring Tasks Engine)
- **أعمدة جديدة في `tasks`**: `is_recurring`, `recurrence_pattern`, `recurrence_interval`, `recurrence_end_date`.
- **ترقية قاعدة SQLite v2**: `_ensureTaskColumns` في [app_database.dart](file:///d:/programming/Tasky3.0/lib/core/database/app_database.dart) تضيف الأعمدة المفقودة عبر `PRAGMA table_info` + `ALTER TABLE` (آمنة للتكرار).
- **[TaskModel](file:///d:/programming/Tasky3.0/lib/features/tasks/data/models/task_model.dart)**: حقول التكرار في `toMap/fromMap/copyWith`.
- **[RecurrenceService](file:///d:/programming/Tasky3.0/lib/core/services/recurrence_service.dart)**:
  - `calculateNextDueDate(baseDate, pattern, interval)` يدعم `daily / weekly / monthly / custom_interval` مع معالجة نهاية الشهر (31 → 28/30).
  - `generateNextRecurrence(completedTask, taskRepo, subtaskRepo)`: ينشئ نسخة `todo` جديدة بنفس الخصائص ويعيد إنشاء مهامها الفرعية غير المكتملة، ويتوقف عند تجاوز `recurrenceEndDate`.
- **[TasksController](file:///d:/programming/Tasky3.0/lib/features/tasks/presentation/controllers/tasks_controller.dart)**: ربط التكرار في `updateStatus` عند إكمال مهمة متكررة.
- **الاختبارات**: إضافة [test/recurrence_test.dart](file:///d:/programming/Tasky3.0/test/recurrence_test.dart) (+11) و [test/database_upgrade_test.dart](file:///d:/programming/Tasky3.0/test/database_upgrade_test.dart) (مسار الترقية v1→v2 +1).

### [2026-09-08] - خدمة تصدير CSV (Export Service)
- **[ExportService](file:///d:/programming/Tasky3.0/lib/core/services/export_service.dart)**:
  - `exportTasksToCsv({required tasks, projectNames, areaNames})` يبدأ بـ UTF-8 BOM لفتح صحيح في Excel مع الحفاظ الكامل على العربية.
  - هروب الفواصل والاقتباسات والسطور الجديدة داخل الخلايا (RFC 4180).
  - دوال مساعدة للعرض الجدولي: `filterByStatus`, `filterByPriority`, `sortByDueDate`, `sortByPriority`.
- **الاختبارات**: إضافة [test/export_service_test.dart](file:///d:/programming/Tasky3.0/test/export_service_test.dart) (+9).

### [2026-09-08] - منطق المشاركة والتعاون (Sharing & Collaborators Backend)
- **[EntityShareModel](file:///d:/programming/Tasky3.0/lib/core/models/entity_share_model.dart)**: نموذج مطابق لجدول السحابة `entity_shares` مع `toMap/fromMap` والصلاحيات (`viewer/editor/admin`) ودوال `canEdit/canDelete/isPublicLink`.
- **[ShareReadService](file:///d:/programming/Tasky3.0/lib/core/services/share_read_service.dart)**: قراءة الكيانات العامة عبر RPC `get_shared_entity` (بدون حساب):
  - `fetchPublicEntityByToken`: يجلب المهمة + مهامها الفرعية، أو المشروع + مهامه، أو المجال + مشاريعه (قراءة فقط).
  - `fetchPublicTaskWithSubtasks` وبنية `SharedEntityResult` مع عقد `SupabaseServiceLike` قابل للحقن للاختبار.
- **[SharingController](file:///d:/programming/Tasky3.0/lib/features/sharing/presentation/controllers/sharing_controller.dart)**: يشرف على الرابط العام والدعوات والصلاحيات (`loadShares/generatePublicLink/revokePublicLink/inviteCollaborator/updatePermission/removeShare`).
- **إسناد المهام (`assigned_to`)**: عمود جديد في `tasks` و [TaskModel](file:///d:/programming/Tasky3.0/lib/features/tasks/data/models/task_model.dart) + ترحيل سحابي [20260908000100_add_task_recurrence_columns.sql](file:///d:/programming/Tasky3.0/supabase/migrations/20260908000100_add_task_recurrence_columns.sql) لمواكبة `SyncService`.
- **مزامنة الأعمدة الجديدة**: تحديث قائمة أعمدة `tasks` في [sync_service.dart](file:///d:/programming/Tasky3.0/lib/core/services/sync_service.dart) لتشمل حقول التكرار و`assigned_to`.
- **الاختبارات**: إضافة [test/share_read_service_test.dart](file:///d:/programming/Tasky3.0/test/share_read_service_test.dart) (+11).

### [2026-09-08] - التحقق النهائي من المهام الخلفية الأربع
- `flutter analyze`: **0 أخطاء و 0 تحذيرات (`No issues found!`)**.
- `flutter test`: **نجاح 113 من 113 اختباراً آلياً بنسبة 100%**.

### [2026-09-08] - منظومة التعاون وتحديد الصلاحيات (Collaboration & Access Control) - Backend
> يتبع مواصفات [08_COLLABORATION_BACKEND_TASKS.md](file:///d:/programming/Tasky3.0/project_management/08_COLLABORATION_BACKEND_TASKS.md) — بلا واجهات UI، منطق قاعدة بيانات/خدمات/تحكم فقط.

- **ترحيل سحابي غير مدمر** [20260908000500_entity_shares_and_permissions.sql](file:///d:/programming/Tasky3.0/supabase/migrations/20260908000500_entity_shares_and_permissions.sql):
  - أعمدة جديدة في `entity_shares` عبر `ADD COLUMN IF NOT EXISTS`: `collaborator_id (uuid FK→auth.users)`, `collaborator_email`, `permission_level`, `status (default active)`, `deleted_at (timestamptz)`.
  - قيود `CHECK` (permission_level: viewer/editor/admin) و (status: pending/active/revoked) و unique `(entity_type, entity_id, collaborator_email)` بكتل `DO` آمنة (لا توجد IF NOT EXISTS للقيود في Postgres).
  - فهارس أداء: `idx_entity_shares_collab_email` و `idx_entity_shares_collab_user`.
  - سياسات RLS للمتعاونين على **areas / projects / tasks / subtasks**: قراءة (active)، تعديل (editor/admin)، حذف (admin فقط) — إلى جانب بقاء سياسات المالك القائمة.
  - سياسة قراءة لسجلات المتعاون نفسه في `entity_shares` (`entity_shares_select_collaborator`).
  - **Auto-Link بالبريد**: دالة `auto_link_collaborators()` (security definer) + Trigger `trg_auto_link_collaborators` على `auth.users` (بعد إدراج أو تغيير البريد) لربط الدعوات المعلقة بحساب المستخدم وتفعيلها، ودالة `auto_link_collaborator_current()` (RPC) لربطها لحظة تسجيل الدخول. حُدّدت الأذونات (تعمل عبر authenticated فقط).
- **قاعدة SQLite المحلية (Offline-First)**: جدول `entity_shares` جديد في [database_tables.dart](file:///d:/programming/Tasky3.0/lib/core/database/database_tables.dart) (id/entity_type/entity_id/owner_id/collaborator_id/collaborator_email/permission_level/status/created_at/updated_at/deleted_at/sync_status + فهرس) وترقية **v3 → v4** في [app_database.dart](file:///d:/programming/Tasky3.0/lib/core/database/app_database.dart) (عبر `_createTables` IF NOT EXISTS في `onUpgrade`).
- **[EntityShareModel](file:///d:/programming/Tasky3.0/lib/features/collaboration/data/models/entity_share_model.dart)**: نموذج تعاون جديد بمعرّف الكيان والمتعاون (`collaboratorId/collaboratorEmail/permissionLevel/status`) مع enums `CollaborationPermission` و `CollaborationShareStatus` ودوال `canEdit/canDelete/isActive` و `fromMap/toMap/copyWith`.
- **[CollaborationRepository](file:///d:/programming/Tasky3.0/lib/features/collaboration/data/repositories/collaboration_repository.dart)** (`ICollaborationRepository` + `CollaborationRepositoryImpl`):
  - `getEntityShares/getShareById/upsertShare/upsertShares/updatePermission/revokeShare` (حذف ناعم عبر `deleted_at`).
  - فحص الصلاحية المحلي السريع `getUserPermission(entityId, currentUserId)` → owner/editor/admin/viewer.
  - `getSharesForUser` لجلب مشاركات المستخدم النشطة دون اتصال.
- **[CollaborationService](file:///d:/programming/Tasky3.0/lib/core/services/collaboration_service.dart)** مع عقد ضخ `CollaborationCloud` (معتمد بـ `SupabaseCollaborationCloud` الحقيقي، وقابل للاستبدال في الاختبارات):
  - `inviteCollaborator` (بريد → pending + الكاش المحلي)، `updateCollaboratorPermission`، `revokeShare`، `getEntityShares` (سحابة أولاً ثم احتياط محلي)، `fetchSharedWithMe` (دمج بيانات الكيان مع الصلاحية، واحتياط محلي عند الانقطاع).
- **[PermissionGuardService](file:///d:/programming/Tasky3.0/lib/core/services/permission_guard_service.dart)**: فحوص متزامنة `canEdit/canDelete/isOwner/getPermission` من خريطة داخلية تُغذّى بـ `loadShares` (المالك=owner دائماً، pending/revoked لا تمنح صلاحيات، غير المذكور يعامل كملكية محلية).
- **[CollaborationController](file:///d:/programming/Tasky3.0/lib/features/collaboration/presentation/controllers/collaboration_controller.dart)**: `ChangeNotifier` يوفّر `loadEntityShares/invite/updatePermission/revoke/loadSharedWithMe/canEdit/canDelete/isOwner` ويبني حارس الصلاحيات من السجلات المحلية تلقائياً.
- **النشر**: طُبّق الترحيل فعلياً على مشروع Tasky الوحيد `yjcpevqahefzcpbvajcq` عبر `supabase db push --db-url` وتحقّق من الأعمدة والقيود والفهارس والسياسات (17 سياسة تعاون) والدالتين والـ Trigger.
- **الاختبارات**: إضافة [test/permission_guard_test.dart](file:///d:/programming/Tasky3.0/test/permission_guard_test.dart) (+8) و [test/collaboration_service_test.dart](file:///d:/programming/Tasky3.0/test/collaboration_service_test.dart) (+8) بذكاء اختبار fake cloud يحاكي Supabase والانقطاع.

### [2026-09-08] - التحقق النهائي من منظومة التعاون
- `flutter analyze`: **0 أخطاء و 0 تحذيرات (`No issues found!`)**.
- `flutter test`: **نجاح 129 من 129 اختباراً آلياً بنسبة 100%**.







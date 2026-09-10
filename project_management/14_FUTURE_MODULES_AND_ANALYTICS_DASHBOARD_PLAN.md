# خطة الوحدات المؤجلة: لوحة التحليلات المتقدمة، وضع التركيز، ومستودع الموارد والتقويم
### Document ID: `14_FUTURE_MODULES_AND_ANALYTICS_DASHBOARD_PLAN.md`
### ارتباط الماستر بلان: مرتبط بـ `MASTER_PLAN.md` (القسم الثاني - بند 4 و 10)

---

## 1. نظرة عامة والهدف المعماري (Overview & Objectives)
هذه الوثيقة هي المرجع الهندسي الشامل لكافة **الوحدات والميزات المؤجلة** في خارطة طريق Tasky 3.0، وتأتي لتنظيم وتفصيل المهام التي لم تشملها الحزمة الحالية (الموبايل والتنبيهات). 

تمت صياغة هذا الدليل بتركيز استثنائي على **طبقة العرض والواجهات (Frontend & UI/UX)** بتفاصيل مكونات دقيقة ومحددة، لتمكين أي وكيل (سواء الوكيل الرئيسي أو الوكيل الفرعي) من تنفيذها دون أي لبس أو غموض في التصميم أو تجربة الاستخدام.

---

## 2. فهرس الوحدات المؤجلة (Postponed Modules Index)

| الوحدة | الاسم الوظيفي | حالة الباك إند | حالة الفرونت إند المستهدفة |
| :---: | :--- | :---: | :--- |
| **الوحدة الأولى** | **لوحة التحليلات ومؤشرات الإنتاجية (Analytics Dashboard)** | ✅ مكتمل ومختبر 100% | 📋 مطلوب بناء الشاشة والرسوم البيانية التفاعلية بالكامل |
| **الوحدة الثانية** | **وضع التركيز ومؤقت البومودورو (Zen Focus Mode & Pomodoro)** | 📋 مطلوب مؤقت وخدمة زمنية | 📋 مطلوب شاشة تركيز وحلقة زمنية تفاعلية |
| **الوحدة الثالثة** | **مستودع المراجع وجهات الاتصال (Bookmarks & Contacts Vault)** | 📋 مطلوب جداول ومستودعات | 📋 مطلوب بطاقات تفاعلية وحوارات إضافة |
| **الوحدة الرابعة** | **تصدير التقويم الخارجي ومزامنة المواعيد (iCal / .ics Sync)** | 📋 مطلوب محرك توليد RFC 5545 | 📋 زر وحوار تصدير وتنزيل التقويم |

---

## 3. تفاصيل الوحدات والمواصفات المعمارية الدقيقة

---

### 📊 الوحدة الأولى: لوحة التحليلات ومؤشرات الإنتاجية (Analytics Dashboard)

#### أ. الجاهزية الخلفية القائمة (Existing Backend State)
- محرك التحليلات مبني بالكامل في: [`lib/features/analytics/data/productivity_analytics.dart`](file:///d:/programming/Tasky3.0/lib/features/analytics/data/productivity_analytics.dart).
- المتحكم جاهز ومربوط في: [`lib/features/analytics/presentation/controllers/analytics_controller.dart`](file:///d:/programming/Tasky3.0/lib/features/analytics/presentation/controllers/analytics_controller.dart).
- البيانات المتاحة لحظياً:
  1. `report.totalTasks`, `report.activeTasks`, `report.completedTasks`, `report.completionRate`.
  2. السلاسل الزمنية الأسبوعية والشهرية: `weeklySeries` و `monthlySeries` عبر `CompletionPoint`.
  3. إحصائيات إنجاز كل مشروع ومجال: `report.projects` و `report.areas` عبر `EntityCompletionStat`.
  4. ساعات الذروة وأفضل أيام الإنجاز: `report.byHourOfDay` و `report.byDayOfWeek` عبر `ProductivitySlice`.
  5. تصنيف المهام حسب الأولوية: `report.priorityGroups`.

#### ب. مواصفات الواجهات الدقيقة (Frontend Detailed Specs)
المسار المقترح للملفات:
- الشاشة الرئيسية: `lib/features/analytics/presentation/screens/analytics_dashboard_screen.dart`
- الويدجتس الفرعية: `lib/features/analytics/presentation/widgets/`
  1. `analytics_kpi_cards.dart`
  2. `completion_velocity_chart.dart`
  3. `entity_progress_section.dart`
  4. `peak_productivity_heatmap.dart`
  5. `priority_breakdown_card.dart`

##### 1. الشاشة الرئيسية والهيكل العام (`AnalyticsDashboardScreen`):
- **الرأس (Header)**:
  - عنوان أنيق: "📈 تحليلات الإنتاجية ومؤشرات الأداء".
  - محدد النطاق الزمني (`SegmentedButton` أو `ChoiceChip`): خياران (أسبوعي `weekly` / شهري `monthly`) يربطان مباشرة بـ `AnalyticsController.setRange()`.
  - زر تحديث لحظي للبيانات مع دوران الأيقونة عند التحميل.
- **التجاوب (Responsiveness)**:
  - **الديسكتوب (`screenWidth >= 900`)**: شبكة من عمودين (Two-column layout):
    - العمود الأيمن (عرض 60%): بطاقات الـ KPI + رسم بياني لمعدل الإنجاز + جدول ساعات الذروة.
    - العمود الأيسر (عرض 40%): نسب إنجاز المشاريع والمجالات + توزيع الأولويات.
  - **الموبايل والتابلت (`screenWidth < 900`)**: عمود واحد قابل للتمرير بسلاسة (`SingleChildScrollView`) بترتيب بطاقات رأسي منظم مع مسافات 16 بكسل.

##### 2. بطاقات المؤشرات الرئيسية (`AnalyticsKpiCards`):
صف من 4 بطاقات إحصائية صغيرة متباعدة:
1. **معدل الإنجاز العام**: نسبة مئوية ضخمة (مثال: `84%`) ملونة بـ `AppColors.statusCompleted` مع شريط مصغر.
2. **المهام المنجزة**: رقم واضح مع أيقونة `Icons.task_alt_rounded`.
3. **المهام قيد العمل**: عدد المهام النشطة مع أيقونة `Icons.pending_actions_rounded`.
4. **نسبة الكفاءة والالتزام**: مؤشر يوضح نسبة المهام المنجزة في موعدها مقابل المتأخرة.

##### 3. الرسم البياني لمعدل الإنجاز (`CompletionVelocityChart`):
- رسم بياني شريطي (Bar Chart) أنيق مبني باستخدام `CustomPainter` خفيف وعالي الأداء بدون مكتبات ثقيلة، أو بالاعتماد على حزمة رسوم متوافقة.
- **محور السينات (X-Axis)**: التسميات الزمنية (`CompletionPoint.label` مثل: الأسبوع 1، الأسبوع 2، إلخ).
- **الأعمدة**:
  - عمود رمادي باهت يمثل إجمالي المهام `totalCount`.
  - عمود داخلي أو متداخل بلون الهوية الأساسي `Theme.of(context).colorScheme.primary` يمثل `completedCount`.
- **التفاعل**: إظهار Tooltip عند لمس أو تحريك المؤشر فوق العمود يعرض: "تم إنجاز X من إجمالي Y مهمة (Z%)".

##### 4. تقدم المجالات والمشاريع (`EntityProgressSection`):
- بطاقة مقسمة إلى تبويبين: (المشاريع | المجالات).
- كل عنصر يعرض:
  - الإيموجي والاسم واللون المخصص.
  - شريط تقدم عريض (`LinearProgressIndicator`) مخصص بلون الكيان نفسه (`colorHex`).
  - نسبة مئوية دقيقة + عداد نصي: `12 / 16 مهمة`.

##### 5. خريطة ساعات الذروة وأيام الأسبوع (`PeakProductivityHeatmap`):
- **أيام الأسبوع**: شريط أفقي للأيام السبعة (السبت - الجمعة) تتباين فيه كثافة لون الأعمدة حسب عدد المهام المنجزة في ذلك اليوم لتحديد "أكثر الأيام إنتاجية".
- **ساعات اليوم**: خط بياني أو شريط مدمج لساعات اليوم (من 00:00 إلى 23:00) يوضح ساعة الذروة الصباحية أو المسائية.

---

### ⏱️ الوحدة الثانية: وضع التركيز ومؤقت البومودورو (Zen Focus Mode & Pomodoro)

#### أ. الرؤية والهدف
تمكين المستخدم من الدخول في حالة تركيز عميق (Flow State) لمهمة واحدة محددة دون تشتت، مع مؤقت دورات العمل والاستراحة (تقنية Pomodoro: 25 دقيقة عمل / 5 دقائق استراحة قصيرة / 15 دقيقة استراحة طويلة بعد 4 دورات).

#### ب. الباك إند المطلوب (Backend Requirements)
- حقول إضافية في جدول `tasks`:
  - `time_spent_seconds INTEGER NOT NULL DEFAULT 0` (الوقت الفعلي المستغرق).
  - `pomodoro_cycles INTEGER NOT NULL DEFAULT 0` (عدد دورات البومودورو المكتملة).
- خدمة المؤقت `FocusTimerService`:
  - إدارة المؤقت التنازلي مع حفظ الحالة في الخلفية وإصدار تنبيه محلي عند انتهاء الدورة.

#### ج. مواصفات الواجهات الدقيقة (Frontend Detailed Specs)
المسار المقترح للملفات:
- الشاشة الكاملة / النافذة: `lib/features/focus/presentation/screens/focus_mode_screen.dart`
- الويدجت العائمة: `lib/features/focus/presentation/widgets/pomodoro_timer_widget.dart`

##### 1. واجهة شاشة التركيز (`FocusModeScreen`):
- **وضع السواد والصفاء (Minimalist Zen Layout)**:
  - خلفية داكنة هادئة خالية من أي قوائم جانبية أو شاشات تشتيت.
  - زر إغلاق صغير في الزاوية العلوية مع زر لتشغيل/كتم صوت التكتكة الهادئ.
- **بطاقة المهمة قيد التركيز**:
  - عنوان المهمة بخط عريض وواضح في المنتصف.
  - شارة المشروع التابع له ولونه.
  - الخطوات الفرعية (Checklist) قابلة للتعليم المباشر بنقرة واحدة.
- **حلقة المؤقت المركزية (Circular Animated Timer)**:
  - حلقة دائرية بقطر 240 بكسل ذات مؤشر تقدم دائري انسيابي (`CircularProgressIndicator` بسماكة 10 بكسل).
  - كتابة الوقت المتبقي في منتصف الحلقة بخط رقمي بارز وعصري (مثال: `24:15`).
  - نص توضيحي تحته: "جلسة تركيز 🧠" أو "استراحة قصيرة ☕".
  - مؤشر نقاط يوضح عدد الدورات المنجزة (مثال: `● ● ○ ○` - الدورة 2 من 4).
- **أزرار التحكم التفاعلية**:
  - زر مركزي ضخم: تشغيل / إيقاف مؤقت (`Icons.play_arrow_rounded` / `Icons.pause_rounded`).
  - زر إعادة ضبط الدورة (`Icons.replay_rounded`).
  - زر إكمال المهمة وإنهاء الجلسة (`Icons.check_circle_outline_rounded`).

---

### 📚 الوحدة الثالثة: مستودع المراجع وجهات الاتصال (Bookmarks & Contacts Vault)

#### أ. الرؤية والهدف
توسيع مستودع المعرفة الحالي (الذي يحتوي على الملاحظات فقط) ليشمل نوعين جديدين من الموارد المعرفية المرتبطة بمشاريع ومجالات المستخدم:
1. **الروابط والمراجع (Bookmarks Vault)**: حفظ المقالات، روابط الأدوات، والوثائق السحابية.
2. **دليل جهات الاتصال والموردين (Contacts & Directory)**: حفظ بيانات الموردين، العملاء، والفنيين مع الاتصال السريع.

#### ب. الباك إند المطلوب (Backend Requirements)
- جدول `bookmarks`:
  - `id` (UUID), `title`, `url`, `description`, `icon_url`, `project_id`, `area_id`, `is_favorite`, `created_at`, `deleted_at`.
- جدول `contacts`:
  - `id` (UUID), `name`, `role`, `company`, `phone`, `email`, `project_id`, `area_id`, `notes`, `created_at`, `deleted_at`.
- مستودعات `BookmarkRepositoryImpl` و `ContactRepositoryImpl` متوافقة مع SQLite و Supabase Offline-First.

#### ج. مواصفات الواجهات الدقيقة (Frontend Detailed Specs)
المسار المقترح للملفات:
- تعديل مستودع المعرفة: `lib/features/resources/presentation/screens/resources_vault_screen.dart`
- الويدجتس:
  - `bookmark_card.dart`
  - `contact_card.dart`
  - `add_bookmark_dialog.dart`
  - `add_contact_dialog.dart`

##### 1. دمج التبويبات في شاشة المستودع:
- شريط تبويبات علوي أنيق (`TabBar`):
  1. 📝 **الملاحظات (Notes)** (الوحدة الحالية القائمة).
  2. 🔗 **الروابط والمراجع (Bookmarks)**.
  3. 👤 **دليل الاتصال (Contacts)**.

##### 2. بطاقة الرابط المرجعي (`BookmarkCard`):
- أيقونة الرابط أو Favicon مأخوذ تلقائياً من النطاق.
- عنوان الرابط بخط عريض مع اسم النطاق بالأسفل بلون خافت (مثال: `github.com/flutter/flutter`).
- شارة المشروع التابع له الرابط.
- أزرار سريعة:
  - زر فتح الرابط مباشرة في المتصفح الخارجي عبر `url_launcher`.
  - زر نسخ الرابط للحافظة مع إشعار SnackBar.
  - زر حذف أو تعديل.

##### 3. بطاقة جهة الاتصال (`ContactCard`):
- صورة شخصية دائرية أو الحرف الأول بلون مشتق من اسم الشخص.
- الاسم والصفة المهنية والشركة (مثال: "م. أحمد - مقاولات التكييف").
- شارة المشروع المرتبط به.
- صف أزرار تفاعلي سريع:
  - زر اتصال هاتفي مباشر (`tel:`) عبر `url_launcher`.
  - زر إرسال بريد إلكتروني (`mailto:`).
  - زر محادثة WhatsApp مباشرة.

---

### 📅 الوحدة الرابعة: تصدير التقويم الخارجي ومزامنة المواعيد (iCal / .ics Sync)

#### أ. الرؤية والهدف
تمكين المستخدم من تصدير مهامه ومشاريعها المحددة بتواريخ استحقاق وتذكير إلى ملف قياسي عالمي (`.ics` متوافق مع معيار RFC 5545)، لفتحه واستيراده بضغطة زر داخل **Google Calendar**, **Apple Calendar**, أو **Outlook**.

#### ب. الباك إند المطلوب (Backend Requirements)
- خدمة `IcsCalendarService`:
  - تجميع المهام غير المكتملة التي تمتلك `due_date`.
  - توليد نص بتنسيق `VCALENDAR` القياسي يحتوي على أحداث `VEVENT` لكل مهمة (العنوان، الوصف، تاريخ البداية والنهاية، المنبه `VALARM` إذا وُجد `reminder_time`).

#### ج. مواصفات الواجهات الدقيقة (Frontend Detailed Specs)
المسار المقترح للملفات:
- `lib/features/calendar_export/presentation/dialogs/export_calendar_dialog.dart`
- زر الوصول: إضافته في شاشة الإعدادات وقائمة تصدير الهيدر بجانب تصدير CSV.

##### 1. حوار تصدير التقويم (`ExportCalendarDialog`):
- بطاقة تعريفية توضح الميزة: "تصدير المهام إلى Google Calendar و Apple Calendar".
- خيارات تصفية التصدير:
  - تصدير مهام كافة المشاريع أو اختيار مشروع محدد.
  - خيار تضمين أو استبعاد المهام المكتملة.
- أزرار الإجراء:
  - **تنزيل ملف `.ics`**: حفظ الملف على الجهاز محلياً.
  - **نسخ نص التقويم**: لنسخه في تطبيقات الويب.
  - دليل إرشادي سريع بكيفية استيراد الملف في Google Calendar بـ 3 خطوات.

---

## 4. تعليمات ومعايير التصميم الصارمة لمنفذ الواجهات (UI Design System Tokens)

على من يقوم بتنفيذ واجهات هذه الوحدات (سواء الوكيل الرئيسي أو الوكيل الفرعي) الالتزام التام بالمعايير التالية:
1. **لوحة الألوان**:
   - الاعتماد الحصري على دوال [`AppColors`](file:///d:/programming/Tasky3.0/lib/core/theme/app_colors.dart):
     - الخلفيات: `AppColors.surface(context)` و `AppColors.background(context)`.
     - الحدود: `AppColors.border(context)`.
     - النصوص: `AppColors.textPrimary(context)` و `AppColors.textSecondary(context)`.
     - الحالات: `AppColors.statusCompleted`, `AppColors.priorityUrgent`, إلخ.
2. **الثيم الثلاثي (Triple Theme Support)**:
   - دعم الوضع النهاري (Light)، الليلي المائل للأزرق (Dark Slate)، ووضع السواد المطلق (OLED Midnight).
   - تجنب استخدام `Colors.white` أو `Colors.black` بشكل ثابت، بل استخدام الشفافيات المتكيفة `withOpacity`.
3. **الحواف والزوايا**:
   - البطاقات والحاويات: `BorderRadius.circular(12)`.
   - النوافذ السفلية (BottomSheets): `BorderRadius.vertical(top: Radius.circular(20))`.
   - الرقائق والشارات (Badges & Chips): `BorderRadius.circular(6)`.
4. **معالجة الحالات الفارغة والتحميل**:
   - استخدام ويدجت الحالة الفارغة الموحدة [`EmptyStateView`](file:///d:/programming/Tasky3.0/lib/core/widgets/empty_state_view.dart) عند خلو النتائج.
   - وضع مؤشرات تحميل ناعمة `CircularProgressIndicator` غير حاجزة للتجربة.

---

## 5. خطة الفحص والتحقق الصارم (Quality Assurance & Zero Regressions)

عند بدء تنفيذ أي من هذه الوحدات المؤجلة، يجب تطبيق بوابات الجودة الإلزامية:
1. **فحص Linter**: تشغيل `flutter analyze` والتأكد التام من خلو الكود من أي أخطاء أو تحذيرات (`No issues found!`).
2. **فحص الاختبارات**: تشغيل `flutter test` وضمان استمرار نجاح كافة الاختبارات القائمة بنسبة 100% مع كتابة اختبارات جديدة لكل وحدة تضاف.
3. **التوثيق**: تحديث `MASTER_PLAN.md` و `COMPLETED_WORK.md` فور إنجاز أي وحدة، ورفع رقم الإصدار في `app_version.dart` و `pubspec.yaml` وفق بروتوكول الكوميت في `AGENTS.md`.

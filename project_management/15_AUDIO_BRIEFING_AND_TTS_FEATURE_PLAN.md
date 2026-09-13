# 15. خطة ميزة القراءة الصوتية للمهام (Audio Briefing & Text-to-Speech)

## 1. الرؤية والهدف (Vision & Objective)
تمكين المستخدم من الاستماع إلى جدول مهامه ونطقها صوتياً بدون استخدام اليدين (Hands-free)، سواء كانت مهام اليوم، أو مهام مشروع محدد، أو مجال معين، أو كافة المهام النشطة، باستخدام محرك النطق الصوتي المدمج في النظام (Native TTS) دون أي تكلفة إضافية ودون الحاجة لاتصال بالإنترنت (Offline-first).

---

## 2. معمارية الميزة (Architecture & Tech Stack)

### أ. مكتبة النطق الصوتي (TTS Engine)
- اعتماد حزمة `flutter_tts: ^4.2.5` لدعم جميع المنصات (Android, Windows, iOS, Web).
- ضبط التحدث باللغتين العربية والإنجليزية تلقائياً حسب لغة المحتوى والواجهة.
- معالجة النصوص المنطوقة:
  - صياغة المقدمة: *"ملخص مهام {السياق}: لديك {عدد} مهام متبقية"*
  - صياغة كل مهمة: *"المهمة رقم {X}: {عنوان المهمة} - {الأولوية إن كانت عاجلة} - {موعد الاستحقاق إن وجد}"*

### ب. إدارة الحالة (AudioBriefingController)
- إنشاء متحكم نمط سينجلتون `AudioBriefingController extends ChangeNotifier` في المسار:
  `lib/features/tasks/presentation/controllers/audio_briefing_controller.dart`
- **الحالات المخزنة**:
  - `bool isPlaying`: هل الصوت قيد التشغيل حالياً؟
  - `bool isPaused`: هل التشغيل متوقف مؤقتاً؟
  - `int currentIndex`: مؤشر المهمة الحالية في قائمة القراءة.
  - `String? currentTaskId`: معرف المهمة المقروءة حالياً (للتظليل البصري المتزامن).
  - `String? contextTitle`: عنوان السياق النشط (مثل: اليوم، اسم المشروع، اسم المجال).
  - `List<TaskModel> activeQueue`: قائمة المهام الجاري قراءتها.
  - `double speechRate`: سرعة النطق (الافتراضي 0.5).
- **الدوال التنفيذية**:
  - `startBriefing({required String contextTitle, required List<TaskModel> tasks, String? languageCode})`
  - `pause()`
  - `resume()`
  - `stop()`
  - `next()`
  - `previous()`

---

## 3. تجربة المستخدم والواجهات (UI / UX Specifications)

### أ. زر التشغيل في الرأس (Top Header Audio Button)
1. **في `MainTopHeader`**:
   - إضافة أيقونة سماعة / مكبر صوت (`Icons.record_voice_over_rounded` أو `Icons.headphones_rounded`).
   - تلميح توضيحي (Tooltip): *"قراءة المهام صوتياً"* / *"Read Tasks Aloud"*.
   - عند الضغط: يبدأ قراءة المهام الحالية المعروضة في مساحة العمل.
2. **في `ProjectDetailScreen`**:
   - إضافة نفس الزر في شريط أدوات المشروع بجانب زر التنبيهات والمشاركة.

### ب. شريط التحكم الصوتي العائم (Floating Audio Briefing Bar)
- شريط عائم سفلي أنيق يظهر تلقائياً عندما تكون القراءة نشطة أو متوقفة مؤقتاً:
  - أيقونة موجة صوتية متفاعلة (Pulsing / Equalizer icon).
  - عنوان المهمة الحالية ورقمها من الإجمالي (مثال: "المهمة 2 من 5: مراجعة العقد").
  - أزرار التحكم:
    - زر السابق (⏮️)
    - زر تشغيل / إيقاف مؤقت (⏯️)
    - زر التالي (⏭️)
    - زر الإغلاق والإنهاء (✖️)

### ج. التظليل البصري التفاعلي للبطاقة (Visual Highlighting on TaskCard)
- عند نطق مهمة معينة، يتم إبراز بطاقتها (`TaskCard`) بإطار ملون خفيف (Active Reading Border) مع شارة صوتية صغيرة (🔊) ليواكب النظر السمع.

---

## 4. خطة الملفات والتعديلات (File Changes Plan)

| الملف | نوع الإجراء | الوصف |
|---|---|---|
| `pubspec.yaml` | تعديل | إضافة حزمة `flutter_tts: ^4.2.5` |
| `lib/l10n/app_ar.arb` & `app_en.arb` | تعديل | إضافة المفاتيح اللغوية الخاصة بالنطق والشريط العائم |
| `lib/features/tasks/presentation/controllers/audio_briefing_controller.dart` | جديد | متحكم النطق الصوتي وقائمة المهام |
| `lib/features/tasks/presentation/widgets/audio_briefing_bar.dart` | جديد | ويدجت الشريط الصوتي العائم |
| `lib/features/home/presentation/widgets/main_top_header.dart` | تعديل | إضافة زر القراءة الصوتية في الهيدر |
| `lib/features/home/presentation/screens/main_layout_screen.dart` | تعديل | توصيل المتحكم وإظهار شريط القراءة العائم |
| `lib/features/projects/presentation/screens/project_detail_screen.dart` | تعديل | إضافة زر القراءة الصوتية لمهام المشروع |
| `lib/features/tasks/presentation/widgets/task_card.dart` | تعديل | إضافة تظليل للمهمة التي يتم نطقها |
| `test/audio_briefing_test.dart` | جديد | اختبارات الوحدة للمتحكم وصياغة النصوص المنطوقة |

---

## 5. خطة التحقق والاختبار (Verification Plan)
1. **اختبارات الوحدة (Automated Tests)**:
   - فحص صياغة النصوص للنطق وتنقّل المؤشر (next/prev/stop).
2. **فحص التحليل الساكن (Static Analysis)**:
   - تشغيل `flutter analyze` للتأكد من خلو المشروع من أي تحذيرات أو أخطاء.
3. **التشغيل والتحقق البصري (Manual Smoke Test)**:
   - تشغيل التطبيق واختبار نطق مهام قائمة اليوم، مشروع معين، وتجربة أزرار التحكم بالشريط العائم.

# 10. وحدة الملاحظات العامة ومستودع المعرفة (General Notes & Knowledge Vault)

## 1. الرؤية والهدف (Vision & Purpose)
موديول مستقل تماماً بنمط **Offline-First** لحفظ الملاحظات العامة، الأفكار السريعة، النصوص المرجعية، جهات الاتصال، ومسودات العمل اليومية التي **لا ترتبط بمهام ولا بمواعيد استحقاق ولا بقوائم مهام**.
الهدف هو توفير مساحة هادئة لتدوين الأفكار والمراجع الشخصية والمهنية مع مزامنة سريعة وبحث فوري.

---

## 2. السيناريوهات وحالات الاستخدام الرئيسية (Core Use Cases)

### أ. تدوين الملاحظات السريعة والمراجع (Quick Notes & References)
* كتابة ملاحظة سريعة (نصوص، روابط مفيدة، أرقام حسابات أو جهات اتصال، أفكار مشاريع مستقبلية).
* دعم تثبيت الملاحظات الهامة في الأعلى (is_pinned: true).
* دعم تلوين الملاحظات وتصنيفها بوسوم ملونة سريعة (	ags).

### ب. تصنيف حسب المجال (Area-Scoped Notes)
* إمكانية تصنيف الملاحظة اختيارياً إلى (ملاحظات العمل | ملاحظات خاصة وشخصية) دون إجبار.
* عرض عام لجميع الملاحظات مع شريط فلترة وبحث لحظي في المحتوى والعناوين.

### ج. محرر نصوص نظيف وخفيف (Clean Distraction-Free Editor)
* كتابة سلسة تدعم التنسيق ومربعات الاختيار السريعة داخل النص (Bullet points / Checklists).
* حفظ تلقائي فوري بنمط Offline-First ومزامنة سحابية هادئة مع Supabase.

---

## 3. المخطط البياني للبيانات (Database Schema - SQLite & Supabase)

### جدول الملاحظات 
otes:
`sql
CREATE TABLE IF NOT EXISTS notes (
    id TEXT PRIMARY KEY,                       -- UUID v4
    title TEXT NOT NULL,                        -- عنوان الملاحظة
    content TEXT,                               -- محتوى الملاحظة الغني أو النصي
    color_hex TEXT,                             -- لون تمييز الملاحظة (اختياري)
    is_pinned INTEGER NOT NULL DEFAULT 0,       -- 1 لتثبيت الملاحظة في الأعلى
    is_archived INTEGER NOT NULL DEFAULT 0,     -- 1 لأرشفة الملاحظة
    area_id TEXT,                               -- اختياري: لربطها بمجال معين
    sync_status TEXT NOT NULL DEFAULT 'pending_insert',
    created_at TEXT NOT NULL,
    updated_at TEXT NOT NULL,
    deleted_at TEXT
);
`

### فهارس الأداء:
* idx_notes_pinned على (is_pinned, updated_at).
* idx_notes_area على rea_id.
* idx_notes_deleted على deleted_at.

---

## 4. تجربة المستخدم التفاعلية (UI/UX)

1. **القائمة الجانبية (Sidebar)**:
   - إضافة قسم مستقل: **"الملاحظات العامة" (Notes)** أسفل أو بجانب السجل المالي.
2. **شاشة الملاحظات الرئيسية (NotesScreen)**:
   - شبكة بطاقات أنيقة (Masonry / Grid View) أو قائمة متتالية تشبه Google Keep / Apple Notes.
   - قسم علوي للملاحظات المثبتة (Pinned Notes).
   - شريط بحث فوري وسريع في نصوص الملاحظات.
3. **نافذة/شاشة تحرير الملاحظة**:
   - محرر فوري وبسيط يفتح بسلاسة بدون تعقيدات الحقول الكثيرة.

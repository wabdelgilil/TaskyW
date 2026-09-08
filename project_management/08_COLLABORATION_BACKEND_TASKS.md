# 08. مواصفات مهام وكيل المنطق والخلفية: منظومة المشاركة مع أعضاء الفريق وتحديد الصلاحيات (Collaboration & Access Control Tasks)

> **موجه إلى مهندس المنطق والخدمات الخلفية (To Backend/Logic Agent)**:
> أنت مسؤول عن سكيما قاعدة البيانات (Supabase Migrations / SQLite)، وسياسات الأمان (Row Level Security - RLS)، ومحرك فحص الصلاحيات، وخدمات إدارة المشاركات بالبريد الإلكتروني وتوليد الدعوات. لا تقم بإنشاء أو تعديل شاشات أو ثيمات الواجهة الرسومية (UI).

---

## 1. الهدف والمطلوب برمجياً
تمكين مالك المجال (Area) أو المشروع (Project) أو المهمة (Task) من مشاركة الكيان مع مستخدمين آخرين لديهم حسابات في النظام (`Authenticated Collaborators`) عبر البريد الإلكتروني، وتحديد صلاحية كل شخص بدقة:
1. 👁️ **مشاهدة فقط (`viewer`)**: الاطلاع الحي والقراءة فقط.
2. ✏️ **محرر (`editor`)**: تعديل الحالات والبيانات وإضافة مهام فرعية أو مهام جديدة دون القدرة على حذف الكيان المشترك.
3. 🗑️ **مسؤول / تحكم كامل (`admin`)**: صلاحيات كاملة تشمل التعديل والحذف وإدارة الأعضاء داخل النطاق المصرح له به.

---

## 2. جدول المهام الموكلة إليك (Backend / Logic Deliverables)

### أولاً: قاعدة البيانات السحابية وسياسات الأمان (Supabase SQL & RLS)
1. **إنشاء ملف الهجرة (Migration)**:
   - مسار الملف المقترح: `supabase/migrations/20260908000500_entity_shares_and_permissions.sql`.
2. **جدول `entity_shares`**:
   ```sql
   CREATE TABLE IF NOT EXISTS public.entity_shares (
       id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
       entity_type TEXT NOT NULL CHECK (entity_type IN ('area', 'project', 'task')),
       entity_id UUID NOT NULL,
       owner_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
       collaborator_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
       collaborator_email TEXT NOT NULL,
       permission_level TEXT NOT NULL CHECK (permission_level IN ('viewer', 'editor', 'admin')),
       status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('pending', 'active', 'revoked')),
       created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
       updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
       deleted_at TIMESTAMPTZ,
       UNIQUE(entity_type, entity_id, collaborator_email)
   );
   ```
3. **سياسات الأمان (Row Level Security - RLS)**:
   - **جدول `entity_shares`**:
     - المالك يملك صلاحية `ALL` على سجلات مشاركاته.
     - المتعاون (`collaborator_id = auth.uid()` أو عبر بريده) يملك صلاحية `SELECT` لمعرفة ما تمت مشاركته معه.
   - **تحديث سياسات `tasks` و `projects` و `areas` و `subtasks`**:
     - القراءة (`SELECT`): مسموح للمالك + مسموح للمتعاونين في `entity_shares` بحالة `active`.
     - التعديل (`UPDATE`): مسموح للمالك + مسموح لمن يملك صلاحية (`editor` أو `admin`).
     - الحذف (`DELETE`): مسموح للمالك + مسموح لمن يملك صلاحية (`admin`).
4. **دالة ربط البريد بالحساب تلقائياً (Auto-Link on Signup/Login)**:
   - دالة أو Trigger عند تسجيل مستخدم جديد أو دخوله لربط بريده الإلكتروني بـ `collaborator_id` في سجلات المشاركة المعلقة.

---

### ثانياً: نماذج البيانات وطبقة التجريد المحلية (Data Models & Local Storage)
1. **نموذج المشاركة (`EntityShareModel`)**:
   - المسار: `lib/features/collaboration/data/models/entity_share_model.dart`.
   - الخصائص: `id`, `entityType`, `entityId`, `ownerId`, `collaboratorId`, `collaboratorEmail`, `permissionLevel`, `status`, `createdAt`.
   - دوال: `fromMap`, `toMap`, `copyWith`.
2. **قاعدة البيانات المحلية SQLite**:
   - إضافة جدول `entity_shares` محلياً لتخزين ومزامنة الصلاحيات والكيانات المشتركة أثناء وضع عدم الاتصال (Offline-First).
   - توفير دوال الفحص السريع محلياً: `getUserPermission(String entityId)`.

---

### ثالثاً: خدمات ومنطق المشاركة (Core Services & Logic)
1. **خدمة إدارة المشاركات (`CollaborationService`)**:
   - المسار: `lib/core/services/collaboration_service.dart`.
   - الدوال الأساسية:
     - `Future<List<EntityShareModel>> getEntityShares({required String entityType, required String entityId})`: جلب قائمة المشاركين في هذا الكيان.
     - `Future<EntityShareModel> inviteCollaborator({required String entityType, required String entityId, required String email, required String permissionLevel})`: إضافة دعوة لمستخدم.
     - `Future<void> updateCollaboratorPermission({required String shareId, required String newPermissionLevel})`: تغيير صلاحية مشارك موجود.
     - `Future<void> revokeShare({required String shareId})`: إلغاء المشاركة وسحب الوصول.
     - `Future<List<Map<String, dynamic>>> fetchSharedWithMe()`: جلب كل المجالات/المشاريع/المهام التي شاركها الآخرون مع المستخدم.
2. **محرك حراسة الصلاحيات (`PermissionGuardService`)**:
   - المسار: `lib/core/services/permission_guard_service.dart`.
   - فحص الصلاحيات قبل أي عملية:
     - `bool canEdit({required String entityId, String? currentUserId})`
     - `bool canDelete({required String entityId, String? currentUserId})`
     - `bool isOwner({required String entityId, String? currentUserId})`

---

### رابعاً: إدارة الحالة (Controllers)
1. **`CollaborationController`** (`ChangeNotifier`):
   - المسار: `lib/features/collaboration/presentation/controllers/collaboration_controller.dart`.
   - الحالات: `isLoading`, `errorMessage`, `sharesList`.
   - إتاحة البيانات لواجهات العرض، لتمكين الـ UI من إخفاء أزرار الحذف أو قفل التعديل للمستخدمين برتبة `viewer`.

---

### خامساً: معايير التسليم والتحقق (Quality & Verification)
1. كتابة اختبارات وحدة (`test/collaboration_service_test.dart` و `test/permission_guard_test.dart`) لتأكيد عمل فحص الصلاحيات.
2. خلو الكود تماماً من أي تنبيهات أو أخطاء عند تشغيل `flutter analyze`.
3. الالتزام الصارم بقاعدة العمل: لا تستخدم أدوات MCP لقاعدة البيانات، ولا تقم بأي تعديل على مشروع Supabase الخارجي؛ جميع التعديلات تتم عبر ترحيلات الكود المحلي ومكتبات التطبيق.
